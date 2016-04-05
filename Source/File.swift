// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

public class File: GroupType {
    public enum CreateMode: UInt32 {
        case Truncate  = 0x02 // Overwrite existing files
        case Exclusive = 0x04 // Fail if file already exists
    }

    public enum OpenMode: UInt32 {
        case ReadOnly  = 0x00
        case ReadWrite = 0x01
    }

    public class func create(filePath: String, mode: CreateMode) -> File? {
        var id: hid_t = -1
        filePath.withCString { filePath in
            id = H5Fcreate(filePath, mode.rawValue, 0, 0)
        }
        guard id >= 0 else {
            return nil
        }
        return File(id: id)
    }

    public class func open(filePath: String, mode: OpenMode) -> File? {
        var id: hid_t = -1
        filePath.withCString { filePath in
            id = H5Fopen(filePath, mode.rawValue, 0)
        }
        guard id >= 0 else {
            return nil
        }
        return File(id: id)
    }

    public internal(set) var id: hid_t = -1

    init(id: hid_t) {
        self.id = id
        guard id >= 0 else {
            fatalError("Failed to create HDF5 File")
        }
    }

    deinit {
        let status = H5Fclose(id)
        assert(status >= 0, "Failed to close HDF5 File")
    }

    public func flush() {
        H5Fflush(id, H5F_SCOPE_LOCAL)
    }

    /// Create a group
    public func createGroup(name: String) -> Group {
        let groupID = name.withCString{
            return H5Gcreate2(id, $0, 0, 0, 0)
        }
        return Group(id: groupID)
    }

    /// Open an existing group
    public func openGroup(name: String) -> Group? {
        let groupID = name.withCString{
            return H5Gopen2(id, $0, 0)
        }
        guard groupID >= 0 else {
            return nil
        }
        return Group(id: groupID)
    }

    /**
     Open an object in a file by path name.

     The object can be a group, dataset, or committed (named) datatype specified by a path name in an HDF5 file.

     - parameter name the path to the object
     */
    public func open(name: String) -> Object {
        let oid = name.withCString{ H5Oopen(id, $0, 0) }
        return Object(id: oid)
    }
}
