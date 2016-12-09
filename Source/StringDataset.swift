// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

#if SWIFT_PACKAGE
    import CHDF5
#endif

public class StringDataset: Dataset {
    open subscript(slices: HyperslabIndexType...) -> [String] {
        // There is a problem with Swift where it gives a compiler error if `set` is implemented here
        return (try? read(slices)) ?? []
    }

    public subscript(slices: [HyperslabIndexType]) -> [String] {
        get {
            return (try? read(slices)) ?? []
        }
        set {
            try! write(newValue, to: slices)
        }
    }
    
    public func read(_ slices: [HyperslabIndexType]) throws -> [String] {
        let filespace = space
        filespace.select(slices)
        return try read(fileSpace: filespace)
    }

    public func write(_ data: [String], to slices: [HyperslabIndexType]) throws {
        let filespace = space
        filespace.select(slices)
        try write(data, fileSpace: filespace)
    }

    /// Append data to the table
    public func append(_ data: [String], dimensions: [Int]) throws {
        let oldExtent = extent
        extent[0] += dimensions[0]

        var start = [Int](repeating: 0, count: oldExtent.count)
        start[0] = oldExtent[0]

        let fileSpace = space
        fileSpace.select(start: start, stride: nil, count: dimensions, block: nil)

        try write(data, fileSpace: fileSpace)
    }

    /// Read string data using an optional file Dataspace
    public func read(fileSpace: Dataspace? = nil) throws -> [String] {
        if type.isVariableLengthString {
            return try readVariableLength(fileSpace: fileSpace)
        } else {
            return try readFixedLength(fileSpace: fileSpace)
        }
    }

    func readVariableLength(fileSpace: Dataspace? = nil) throws -> [String] {
        let count: Int
        if let fileSpace = fileSpace {
            count = fileSpace.selectionSize
        } else {
            count = self.space.selectionSize
        }

        let type = Datatype.createString()
        var data = [UnsafePointer<CChar>?](repeating: nil, count: count)
        let memspace = Dataspace(dims: [count])
        let status = H5Dread(id, type.id, memspace.id, fileSpace?.id ?? 0, 0, &data)
        if status < 0 {
            throw Error.ioError
        }

        var strings = [String]()
        strings.reserveCapacity(count)

        for pointer in data {
            if let pointer = pointer {
                strings.append(String(cString: pointer))
            } else {
                strings.append("")
            }
        }

        H5Dvlen_reclaim(type.id, memspace.id, 0, &data)
        return strings
    }

    func readFixedLength(fileSpace: Dataspace? = nil) throws -> [String] {
        let count: Int
        if let fileSpace = fileSpace {
            count = fileSpace.selectionSize
        } else {
            count = self.space.selectionSize
        }
        let size = Int(H5Aget_storage_size(id))
        let stringSize = size / count

        var data = [CChar](repeating: 0, count: size)
        let type = Datatype.createString(size: stringSize + 1)
        let memspace = Dataspace(dims: [count])
        try data.withUnsafeMutableBufferPointer { pointer in
            let status = H5Dread(id, type.id, memspace.id, fileSpace?.id ?? 0, 0, &data)
            if status < 0 {
                throw Error.ioError
            }
        }

        var strings = [String]()
        strings.reserveCapacity(count)

        var index = 0
        for _ in 0..<count {
            data.withUnsafeBufferPointer { pointer in
                let string = String(cString: pointer.baseAddress! + index)
                strings.append(string)
                index += string.lengthOfBytes(using: .ascii)
                while index <= size && pointer[index] == 0 {
                    index += 1
                }
            }
        }
        return strings
    }

    /// Write string data using an optional file Dataspace
    ///
    /// - precondition: The `selectionSize` of the file Dataspace is equal to `strings.count`
    public func write(_ strings: [String], fileSpace: Dataspace? = nil) throws {
        let size: Int
        if let fileSpace = fileSpace {
            size = fileSpace.selectionSize
        } else {
            size = self.space.selectionSize
        }
        precondition(strings.count == size, "Data size doesn't match Dataspace dimensions")

        // First convert the strings into character arrays
        var data = [[Int8]]()
        data.reserveCapacity(size)
        for string in strings {
            data.append(characterArrayFromString(string))
        }

        // Create an array of pointers, which is what H5Dwrite expects
        var pointers = [UnsafePointer<Int8>]()
        pointers.reserveCapacity(data.count)
        for array in data {
            pointers.append(UnsafePointer<Int8>(array))
        }

        let memspace = Dataspace(dims: [size])
        let type = Datatype.createString()
        guard H5Dwrite(id, type.id, memspace.id, fileSpace?.id ?? 0, 0, pointers) >= 0 else {
            throw Error.ioError
        }
    }

    func characterArrayFromString(_ string: String) -> [Int8] {
        let length = string.utf8.count
        var array = [Int8](repeating: 0, count: length + 1)

        string.withCString{ stringPointer in
            array.withUnsafeMutableBufferPointer{ arrayPointer in
                arrayPointer.baseAddress?.initialize(from: stringPointer, count: length + 1)
            }
        }
        return array
    }
}


// MARK: GroupType extension for StringDataset

extension GroupType {
    /// Create a StringDataset
    public func createStringDataset(_ name: String, dataspace: Dataspace) -> StringDataset? {
        guard let datatype = Datatype(type: String.self) else {
            return nil
        }
        let datasetID = name.withCString{ name in
            return H5Dcreate2(id, name, datatype.id, dataspace.id, 0, 0, 0)
        }
        return StringDataset(id: datasetID)
    }

    /// Create a chunked StringDataset
    public func createStringDataset(_ name: String, dataspace: Dataspace, chunkDimensions: [Int]) -> StringDataset? {
        guard let datatype = Datatype(type: String.self) else {
            return nil
        }
        precondition(dataspace.dims.count == chunkDimensions.count)

        let plist = H5Pcreate(H5P_CLS_DATASET_CREATE_ID_g)
        let chunkDimensions64 = chunkDimensions.map({ unsafeBitCast(hssize_t($0), to: hsize_t.self) })
        chunkDimensions64.withUnsafeBufferPointer { (pointer) -> Void in
            H5Pset_chunk(plist, Int32(chunkDimensions.count), pointer.baseAddress)
        }
        defer {
            H5Pclose(plist)
        }

        let datasetID = name.withCString{ name in
            return H5Dcreate2(id, name, datatype.id, dataspace.id, 0, plist, 0)
        }
        return StringDataset(id: datasetID)
    }

    /// Open an existing StringDataset
    public func openStringDataset(_ name: String) -> StringDataset? {
        let datasetID = name.withCString{ name in
            return H5Dopen2(id, name, 0)
        }
        guard datasetID >= 0 else {
            return nil
        }
        return StringDataset(id: datasetID)
    }
}
