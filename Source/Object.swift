// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

public class Object {
    public internal(set) var id: Int32 = -1

    init(id: Int32) {
        precondition(id >= 0, "Object ID needs to be non-negative")
        self.id = id
    }

    deinit {
        let status = H5Oclose(id)
        assert(status >= 0, "Failed to close Object")
    }

    public var file: File {
        let fileID = H5Iget_file_id(id)
        return File(id: fileID)
    }

    public var name: String {
        let size = H5Iget_name(id, nil, 0)
        print(size)
        if size <= 0 {
            return ""
        }

        var name = [Int8](count: size + 1, repeatedValue: 0)
        H5Iget_name(id, &name, size + 1)
        return String.fromCString(name) ?? ""
    }
}

public func == (lhs: Object, rhs: Object) -> Bool {
    return lhs.id == rhs.id
}
