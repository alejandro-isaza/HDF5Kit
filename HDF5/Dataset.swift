//  Copyright © 2015 Venture Media Labs. All rights reserved.

import Foundation

public class Dataset {
    var id: Int32 = -1

    init(id: Int32) {
        precondition(id >= 0, "Dataset ID needs to be non-negative")
        self.id = id
    }

    deinit {
        let status = H5Dclose(id)
        assert(status >= 0, "Failed to close Dataset")
    }

    public class func create(file file: File, name: String, datatype: Datatype, dataspace: Dataspace) -> Dataset {
        var id: Int32 = -1
        name.withCString{ name in
            id = H5Dcreate2(file.id, name, datatype.id, dataspace.id, 0, 0, 0)
        }
        guard id >= 0 else {
            fatalError("Failed to create Dataset")
        }
        return Dataset(id: id)
    }

    public class func open(file file: File, name: String) -> Dataset? {
        var id: Int32 = -1
        name.withCString{ name in
            id = H5Dopen2(file.id, name, 0)
        }
        guard id >= 0 else {
            return nil
        }
        return Dataset(id: id)
    }

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
        let status = H5Dread(id, H5T_NATIVE_DOUBLE_g, 0, 0, 0, &data)
        return status >= 0
    }

    public func writeDouble(data: [Double]) -> Bool {
        let status = H5Dwrite(id, H5T_NATIVE_DOUBLE_g, 0, 0, 0, data);
        return status >= 0
    }

    public func readFloat(inout data: [Float]) -> Bool {
        let status = H5Dread(id, H5T_NATIVE_FLOAT_g, 0, 0, 0, &data)
        return status >= 0
    }

    public func writeFloat(data: [Float]) -> Bool {
        let status = H5Dwrite(id, H5T_NATIVE_FLOAT_g, 0, 0, 0, data);
        return status >= 0
    }

    public func readInt(inout data: [Int]) -> Bool {
        let status = H5Dread(id, H5T_NATIVE_INT_g, 0, 0, 0, &data)
        return status >= 0
    }

    public func writeInt(data: [Int]) -> Bool {
        let status = H5Dwrite(id, H5T_NATIVE_INT_g, 0, 0, 0, data);
        return status >= 0
    }
}
