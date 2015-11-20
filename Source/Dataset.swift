// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

public class Dataset : Object {
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

    // MARK: Reading/Writing data

    public subscript(sliceDims: H5Index...) -> [Double] {

        let dataspace = space
        var dimsOut = space.dims
        
        if !sliceDims.isEmpty {

            var slabOffset: [Int] = []
            for (i, dim) in sliceDims.enumerate() {
                
                slabOffset.append(dim.slice.startIndex)
                if dim.slice.endIndex < Int.max-1 {
                    dimsOut[i] = dim.slice.endIndex - (dim.slice.startIndex)
                } else {
                    dimsOut[i] -= dim.slice.startIndex
                }
                
            }
            // define hyperslab in dataset
            dataspace.select(start: slabOffset, stride: nil, count: dimsOut, block: nil)
        }
        // define memspace
        let memspace = Dataspace(dims: dimsOut)
        memspace.select(start: Array(count: dimsOut.count, repeatedValue: 0), stride: nil, count: dimsOut, block: nil)
        
        // create memory to read to
        var data = [Double](count: dimsOut.reduce(1, combine:*), repeatedValue: 0.0)

        // read dataspace to memspace
        readDouble(&data, memSpace: memspace, fileSpace: dataspace)
        return data
    }
  

    public func readDouble(data: UnsafeMutablePointer<Double>, memSpace: Dataspace? = nil, fileSpace: Dataspace? = nil) -> Bool {
        let status = H5Dread(id, NativeType.Double.rawValue, memSpace?.id ?? 0, fileSpace?.id ?? 0, 0, data)
        return status >= 0
    }
    
    public func readDouble() -> [Double] {
        var result = [Double](count: Int(space.size), repeatedValue: 0.0)
        readDouble(&result)
        return result
    }

    public func writeDouble(data: UnsafePointer<Double>, memSpace: Dataspace? = nil, fileSpace: Dataspace? = nil) -> Bool {
        let status = H5Dwrite(id, NativeType.Double.rawValue, memSpace?.id ?? 0, fileSpace?.id ?? 0, 0, data);
        return status >= 0
    }

    public func readFloat(data: UnsafeMutablePointer<Float>, memSpace: Dataspace? = nil, fileSpace: Dataspace? = nil) -> Bool {
        let status = H5Dread(id, NativeType.Float.rawValue, memSpace?.id ?? 0, fileSpace?.id ?? 0, 0, data)
        return status >= 0
    }
    
    public func readFloat() -> [Float] {
        var result = [Float](count: Int(space.size), repeatedValue: 0.0)
        readFloat(&result)
        return result
    }

    public func writeFloat(data: UnsafePointer<Float>, memSpace: Dataspace? = nil, fileSpace: Dataspace? = nil) -> Bool {
        let status = H5Dwrite(id, NativeType.Float.rawValue, memSpace?.id ?? 0, fileSpace?.id ?? 0, 0, data);
        return status >= 0
    }

    public func readInt(data: UnsafeMutablePointer<Int>, memSpace: Dataspace? = nil, fileSpace: Dataspace? = nil) -> Bool {
        let status = H5Dread(id, NativeType.Int.rawValue, memSpace?.id ?? 0, fileSpace?.id ?? 0, 0, data)
        return status >= 0
    }
    
    public func readInt() -> [Int] {
        var result = [Int](count: Int(space.size), repeatedValue: 0)
        readInt(&result)
        return result
    }

    public func writeInt(data: UnsafePointer<Int>, memSpace: Dataspace? = nil, fileSpace: Dataspace? = nil) -> Bool {
        let status = H5Dwrite(id, NativeType.Int.rawValue, memSpace?.id ?? 0, fileSpace?.id ?? 0, 0, data);
        return status >= 0
    }

    public func readString() -> [String]? {
        let space = self.space
        let size = space.size
        let type = Datatype.createString()

        var data = [UnsafePointer<CChar>](count: Int(size), repeatedValue: nil)
        guard H5Dread(id, type.id, 0, 0, 0, &data) >= 0 else {
            return nil
        }

        var strings = [String]()
        strings.reserveCapacity(Int(size))
        for pointer in data {
            strings.append(String.fromCString(pointer) ?? "")
        }

        H5Dvlen_reclaim(type.id, space.id, 0, &data);
        return strings
    }

    public func writeString(strings: [String]) -> Bool {
        // First convert the strings into character arrays
        var data = [[Int8]]()
        data.reserveCapacity(strings.count)
        for string in strings {
            data.append(characterArrayFromString(string))
        }

        // Create an array of pointers, which is what H5Dwrite expects
        var pointers = [UnsafePointer<Int8>]()
        pointers.reserveCapacity(data.count)
        for array in data {
            pointers.append(UnsafePointer<Int8>(array))
        }

        let type = Datatype.createString()
        guard H5Dwrite(id, type.id, 0, 0, 0, pointers) >= 0 else {
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
