// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

public class Group : Object {
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

    /// Create a Dataset
    public func createDataset<T>(name: String, type: T.Type, dataspace: Dataspace) -> Dataset<T>? {
        guard let datatype = Datatype(type: type) else {
            return nil
        }
        return createDataset(name, datatype: datatype, dataspace: dataspace)
    }

    /// Create a Dataset
    public func createDataset<T>(name: String, datatype: Datatype, dataspace: Dataspace) -> Dataset<T> {
        let datasetID = name.withCString{ name in
            return H5Dcreate2(id, name, datatype.id, dataspace.id, 0, 0, 0)
        }
        return Dataset(id: datasetID)
    }

    /// Open an existing Dataset
    public func openDataset<T>(name: String) -> Dataset<T>? {
        let datasetID = name.withCString{ name in
            return H5Dopen2(id, name, 0)
        }
        guard datasetID >= 0 else {
            return nil
        }
        return Dataset(id: datasetID)
    }

    /**
     Open an object in a group by path name.

     The object can be a group, dataset, or committed (named) datatype specified by a path name in an HDF5 file.

     - parameter name the path to the object relative to self
     */
    public func open(name: String) -> Object {
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
            var name = [Int8](count: size + 1, repeatedValue: 0)
            H5Gget_objname_by_idx(id, i, &name, size + 1)
            names.append(String.fromCString(name)!)
        }

        return names
    }
}
