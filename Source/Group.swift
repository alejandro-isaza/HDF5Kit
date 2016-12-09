// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

#if SWIFT_PACKAGE
    import CHDF5
#endif

public protocol GroupType {
    var id: hid_t { get }
}

public class Group: Object, GroupType {
    /// Create a group
    public func createGroup(_ name: String) -> Group {
        let groupID = name.withCString{
            return H5Gcreate2(id, $0, 0, 0, 0)
        }
        return Group(id: groupID)
    }

    /// Open an existing group
    public func openGroup(_ name: String) -> Group? {
        let groupID = name.withCString{
            return H5Gopen2(id, $0, 0)
        }
        guard groupID >= 0 else {
            return nil
        }
        return Group(id: groupID)
    }

    /**
     Open an object in a group by path name.

     The object can be a group, dataset, or committed (named) datatype specified by a path name in an HDF5 file.

     - parameter name the path to the object relative to self
     */
    public func open(_ name: String) -> Object {
        let oid = name.withCString{ H5Oopen(id, $0, 0) }
        return Object(id: oid)
    }

    public func objectNames() -> [String] {
        var count: hsize_t = 0
        H5Gget_num_objs(id, &count)

        var names = [String]()
        names.reserveCapacity(Int(count))

        for i in 0..<count {
            let size = H5Gget_objname_by_idx(id, i, nil, 0)
            var name = [Int8](repeating: 0, count: size + 1)
            H5Gget_objname_by_idx(id, i, &name, size + 1)
            names.append(String(cString: name))
        }

        return names
    }
}
