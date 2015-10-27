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

    public func readDouble(inout data: [Double]) -> Bool {
        let status = H5Dread(id, NativeType.Double.rawValue, 0, 0, 0, &data)
        return status >= 0
    }

    public func writeDouble(data: [Double]) -> Bool {
        let status = H5Dwrite(id, NativeType.Double.rawValue, 0, 0, 0, data);
        return status >= 0
    }

    public func readFloat(inout data: [Float]) -> Bool {
        let status = H5Dread(id, NativeType.Float.rawValue, 0, 0, 0, &data)
        return status >= 0
    }

    public func writeFloat(data: [Float]) -> Bool {
        let status = H5Dwrite(id, NativeType.Float.rawValue, 0, 0, 0, data);
        return status >= 0
    }

    public func readInt(inout data: [Int]) -> Bool {
        let status = H5Dread(id, NativeType.Int.rawValue, 0, 0, 0, &data)
        return status >= 0
    }

    public func writeInt(data: [Int]) -> Bool {
        let status = H5Dwrite(id, NativeType.Int.rawValue, 0, 0, 0, data);
        return status >= 0
    }

    public func readString() -> [String]? {
        let size = space.size
        var data = [UnsafePointer<CChar>](count: Int(size), repeatedValue: nil)
        guard H5Dread(id, H5T_C_S1_g, 0, 0, 0, &data) >= 0 else {
            return nil
        }

        var strings = [String]()
        strings.reserveCapacity(Int(size))
        for pointer in data {
            strings.append(String.fromCString(pointer) ?? "")
        }

        H5Dvlen_reclaim(H5T_C_S1_g, space.id, 0, &data);
        return strings
    }

    public func writeString(strings: [String]) -> Bool {
        var data = [UnsafePointer<CChar>]()
        data.reserveCapacity(strings.count)
        for s in strings {
            data.append(s.withCString{ $0 })
        }

        guard H5Dwrite(id, H5T_C_S1_g, 0, 0, 0, data) >= 0 else {
            return false
        }

        return true
    }
}
