//  Copyright © 2015 Venture Media Labs. All rights reserved.

import Foundation

public class Dataset {
    var id: Int32 = -1

    public init(file: File, name: String, datatype: Datatype, dataspace: Dataspace) {
        name.withCString{ name in
            id = H5Dcreate2(file.id, name, datatype.id, dataspace.id, 0, 0, 0)
        }
        guard id >= 0 else {
            fatalError("Failed to create Dataset")
        }
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

    public func read(inout data: [Double]) -> Bool {
        let status = H5Dread(id, H5T_NATIVE_DOUBLE_g, 0, 0, 0, &data)
        return status >= 0
    }

    public func write(data: [Double]) -> Bool {
        let status = H5Dwrite(id, H5T_NATIVE_DOUBLE_g, 0, 0, 0, data);
        return status >= 0
    }
}
