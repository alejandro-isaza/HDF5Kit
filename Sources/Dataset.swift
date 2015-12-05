// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import CHDF5

public enum DatasetError : ErrorType {
    case UnkownDataType
}

public class Dataset<Element> : Object {

    override init(id: Int32) {
        super.init(id: id)
    }

    /// The address in the file of the dataset or `nil` if the offset is undefined. That address is expressed as the offset in bytes from the beginning of the file.
    public var offset: Int? {
        let offset = H5Dget_offset(id)
        guard offset != unsafeBitCast(-1, UInt64.self) else {
            return nil
        }
        return Int(offset)
    }

    public var space: Dataspace {
        return Dataspace(id: H5Dget_space(id))
    }

    public var type: Datatype {
        return Datatype(id: H5Dget_type(id))
    }

    public var extent: [Int] {
        get {
            return space.dims
        }
        set {
            H5Dset_extent(id, ptr(newValue))
        }
    }

    /// Retrieves the size of chunks for the raw data of a chunked layout Dataset, or `nil` if the Dataset's layout is not chunked
    public var chunkSize: [Int]? {
        let plistId = H5Dget_create_plist(id)
        if H5Pget_layout(plistId) != H5D_CHUNKED {
            return nil
        }

        let rank = space.dims.count
        var chunkSize = [Int](count: rank, repeatedValue: 0)
        H5Pget_chunk(plistId, Int32(rank), ptr(&chunkSize))
        return chunkSize
    }

    public subscript(slices: HyperslabIndexType...) -> Any {
        get {
            let filespace = space
            filespace.select(slices)

            let memspace = Dataspace(dims: filespace.selectionDims)

            return read(memSpace: memspace, fileSpace: filespace)
        }
    }

    
    // MARK: Reading/Writing data

    /// Read data using an optional memory Dataspace and an optional file Dataspace
    ///
    /// - precondition: The `selectionSize` of the memory Dataspace is the same as for the file Dataspace
    public func read(memSpace memSpace: Dataspace? = nil, fileSpace: Dataspace? = nil) -> Any {
        let size: Int
        if let memspace = memSpace {
            size = memspace.selectionSize
        } else if let filespace = fileSpace {
            size = filespace.selectionSize
        } else {
            size = space.selectionSize
        }

        if Element.self == Double.self {
            var result = [Double](count: size, repeatedValue: 0.0)
            readDouble(&result, memSpace: memSpace, fileSpace: fileSpace)
            return result
        } else if Element.self == Float.self {
            var result = [Float](count: size, repeatedValue: 0.0)
            readFloat(&result, memSpace: memSpace, fileSpace: fileSpace)
            return result
        } else if Element.self == Int.self {
            var result = [Int](count: size, repeatedValue: 0)
            readInt(&result, memSpace: memSpace, fileSpace: fileSpace)
            return result
        } else if Element.self == String.self {
            return readString(fileSpace: fileSpace)
        }

        fatalError("Don't know how to read \(Element.self)")
    }

    /// Write data using an optional memory Dataspace and an optional file Dataspace
    ///
    /// - precondition: The `selectionSize` of the memory Dataspace is the same as for the file Dataspace and the same as `data.count`
    public func write(data: [Element], memSpace: Dataspace? = nil, fileSpace: Dataspace? = nil) -> Bool {
        let size: Int
        if let memspace = memSpace {
            size = memspace.selectionSize
        } else if let filespace = fileSpace {
            size = filespace.selectionSize
        } else {
            size = space.selectionSize
        }
        precondition(data.count == size, "Data size doesn't match Dataspace dimensions")

        if Element.self == Double.self {
            return writeDouble(UnsafeMutablePointer<Double>(data), memSpace: memSpace, fileSpace: fileSpace)
        } else if Element.self == Float.self {
            return writeFloat(UnsafeMutablePointer<Float>(data), memSpace: memSpace, fileSpace: fileSpace)
        } else if Element.self == Int.self {
            return writeInt(UnsafeMutablePointer<Int>(data), memSpace: memSpace, fileSpace: fileSpace)
        } else if Element.self == String.self {
            preconditionFailure("Use writeString function")
        }

        fatalError("Don't know how to write \(Element.self)")
    }

    /// Read double data using an optional memory Dataspace and an optional file Dataspace
    ///
    /// - precondition: The `selectionSize` of the memory Dataspace is the same as for the file Dataspace and there is as much available memory in the data buffer.
    public func readDouble(data: UnsafeMutablePointer<Double>, memSpace: Dataspace? = nil, fileSpace: Dataspace? = nil) -> Bool {
        let status = H5Dread(id, NativeType.Double.rawValue, memSpace?.id ?? 0, fileSpace?.id ?? 0, 0, data)
        return status >= 0
    }

    /// Write double data using an optional memory Dataspace and an optional file Dataspace
    ///
    /// - precondition: The `selectionSize` of the memory Dataspace is the same as for the file Dataspace and there is as much data available in the data buffer.
    public func writeDouble(data: UnsafePointer<Double>, memSpace: Dataspace? = nil, fileSpace: Dataspace? = nil) -> Bool {
        let status = H5Dwrite(id, NativeType.Double.rawValue, memSpace?.id ?? 0, fileSpace?.id ?? 0, 0, data);
        return status >= 0
    }

    /// Read float data using an optional memory Dataspace and an optional file Dataspace
    ///
    /// - precondition: The `selectionSize` of the memory Dataspace is the same as for the file Dataspace and there is as much available memory in the data buffer.
    public func readFloat(data: UnsafeMutablePointer<Float>, memSpace: Dataspace? = nil, fileSpace: Dataspace? = nil) -> Bool {
        let status = H5Dread(id, NativeType.Float.rawValue, memSpace?.id ?? 0, fileSpace?.id ?? 0, 0, data)
        return status >= 0
    }

    /// Write float data using an optional memory Dataspace and an optional file Dataspace
    ///
    /// - precondition: The `selectionSize` of the memory Dataspace is the same as for the file Dataspace and there is as much data available in the data buffer.
    public func writeFloat(data: UnsafePointer<Float>, memSpace: Dataspace? = nil, fileSpace: Dataspace? = nil) -> Bool {
        let status = H5Dwrite(id, NativeType.Float.rawValue, memSpace?.id ?? 0, fileSpace?.id ?? 0, 0, data);
        return status >= 0
    }

    /// Read integer data using an optional memory Dataspace and an optional file Dataspace
    ///
    /// - precondition: The `selectionSize` of the memory Dataspace is the same as for the file Dataspace and there is as much available memory in the data buffer.
    public func readInt(data: UnsafeMutablePointer<Int>, memSpace: Dataspace? = nil, fileSpace: Dataspace? = nil) -> Bool {
        let status = H5Dread(id, NativeType.Int.rawValue, memSpace?.id ?? 0, fileSpace?.id ?? 0, 0, data)
        return status >= 0
    }

    /// Write integer data using an optional memory Dataspace and an optional file Dataspace
    ///
    /// - precondition: The `selectionSize` of the memory Dataspace is the same as for the file Dataspace and there is as much data available in the data buffer.
    public func writeInt(data: UnsafePointer<Int>, memSpace: Dataspace? = nil, fileSpace: Dataspace? = nil) -> Bool {
        let status = H5Dwrite(id, NativeType.Int.rawValue, memSpace?.id ?? 0, fileSpace?.id ?? 0, 0, data);
        return status >= 0
    }

    /// Read string data using an optional file Dataspace
    public func readString(fileSpace fileSpace: Dataspace? = nil) -> [String] {
        let size: Int
        if let fileSpace = fileSpace {
            size = fileSpace.selectionSize
        } else {
            size = self.space.selectionSize
        }

        let type = Datatype.createString()
        var data = [UnsafePointer<CChar>](count: Int(size), repeatedValue: nil)
        let memspace = Dataspace(dims: [size])
        guard H5Dread(id, type.id, memspace.id, fileSpace?.id ?? 0, 0, &data) >= 0 else {
            return []
        }

        var strings = [String]()
        strings.reserveCapacity(size)
        for pointer in data {
            strings.append(String.fromCString(pointer) ?? "")
        }

        H5Dvlen_reclaim(type.id, memspace.id, 0, &data);
        return strings
    }

    /// Write string data using an optional file Dataspace
    ///
    /// - precondition: The `selectionSize` of the file Dataspace is equal to `strings.count`
    public func writeString(strings: [String], fileSpace: Dataspace? = nil) -> Bool {
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
            return false
        }

        return true
    }

    func characterArrayFromString(string: String) -> [Int8] {
        let length = string.utf8.count
        var array = [Int8](count: length + 1, repeatedValue: 0)

        string.withCString{ stringPointer in
            array.withUnsafeMutableBufferPointer{ arrayPointer in
                let mutableStringPointer = UnsafeMutablePointer<Int8>(stringPointer)
                arrayPointer.baseAddress.initializeFrom(mutableStringPointer, count: length + 1)
            }
        }
        return array
    }
}
