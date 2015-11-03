// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

public class Dataset : Object {
    /// The address in the file of the dataset or `nil` if the offset is undefined. That address is expressed as the offset in bytes from the beginning of the file.
    public var offset: UInt64? {
        let offset = H5Dget_offset(id)
        guard offset != unsafeBitCast(-1, UInt64.self) else {
            return nil
        }
        return offset
    }

    public var space: Dataspace {
        return Dataspace(id: H5Dget_space(id))
    }
 
    public func readDouble(data: UnsafeMutablePointer<Double>) -> Bool {
        let status = H5Dread(id, NativeType.Double.rawValue, 0, 0, 0, data)
        return status >= 0
    }
    
    public func readDouble() -> [Double] {
        var result = [Double](count: Int(space.size), repeatedValue: 0.0)
        readDouble(&result)
        return result
    }

    public func writeDouble(data: UnsafePointer<Double>) -> Bool {
        let status = H5Dwrite(id, NativeType.Double.rawValue, 0, 0, 0, data);
        return status >= 0
    }

    public func readFloat(data: UnsafeMutablePointer<Float>) -> Bool {
        let status = H5Dread(id, NativeType.Float.rawValue, 0, 0, 0, data)
        return status >= 0
    }
    
    public func readFloat() -> [Float] {
        var result = [Float](count: Int(space.size), repeatedValue: 0.0)
        readFloat(&result)
        return result
    }

    public func writeFloat(data: UnsafePointer<Float>) -> Bool {
        let status = H5Dwrite(id, NativeType.Float.rawValue, 0, 0, 0, data);
        return status >= 0
    }

    public func readInt(data: UnsafeMutablePointer<Int>) -> Bool {
        let status = H5Dread(id, NativeType.Int.rawValue, 0, 0, 0, data)
        return status >= 0
    }
    
    public func readInt() -> [Int] {
        var result = [Int](count: Int(space.size), repeatedValue: 0)
        readInt(&result)
        return result
    }

    public func writeInt(data: UnsafePointer<Int>) -> Bool {
        let status = H5Dwrite(id, NativeType.Int.rawValue, 0, 0, 0, data);
        return status >= 0
    }

    public func readString() -> [String]? {
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
            let length = string.utf8.count
            var cstring = [Int8](count: length, repeatedValue: 0)
            string.withCString{ stringPointer in
                cstring.withUnsafeMutableBufferPointer{ cstringPointer in
                    let mutableStringPointer = UnsafeMutablePointer<Int8>(stringPointer)
                    cstringPointer.baseAddress.initializeFrom(mutableStringPointer, count: length)
                }
            }
            data.append(cstring)
        }

        // Create an array of pointers, which is what H5Dwrite expects
        var pointers = [UnsafePointer<Int8>]()
        pointers.reserveCapacity(data.count)
        for a in data {
            pointers.append(UnsafePointer<Int8>(a))
        }

        let type = Datatype.createString()
        guard H5Dwrite(id, type.id, 0, 0, 0, pointers) >= 0 else {
            return false
        }

        return true
    }
}
