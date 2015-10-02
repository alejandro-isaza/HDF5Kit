//  Copyright © 2015 Venture Media Labs. All rights reserved.

import Foundation

public class File {
    public enum CreateMode: UInt32 {
        case Truncate  = 0x02 // Overwrite existing files
        case Exclusive = 0x04 // Fail if file already exists
    }

    public enum OpenMode: UInt32 {
        case ReadOnly  = 0x00
        case ReadWrite = 0x01
    }

    public class func create(filePath: String, mode: CreateMode) -> File? {
        var id: Int32 = -1
        filePath.withCString { filePath in
            id = H5Fcreate(filePath, mode.rawValue, 0, 0)
        }
        guard id >= 0 else {
            return nil
        }
        return File(id: id)
    }

    public class func open(filePath: String, mode: OpenMode) -> File? {
        var id: Int32 = -1
        filePath.withCString { filePath in
            id = H5Fopen(filePath, mode.rawValue, 0)
        }
        guard id >= 0 else {
            return nil
        }
        return File(id: id)
    }

    var id: Int32 = -1

    init(id: Int32) {
        self.id = id
        guard id >= 0 else {
            fatalError("Failed to create Dataspace")
        }
    }

    deinit {
        let status = H5Fclose(id)
        assert(status >= 0, "Failed to close HDF5 file")
    }

    public func flush() {
        H5Fflush(id, H5F_SCOPE_LOCAL)
    }
}
