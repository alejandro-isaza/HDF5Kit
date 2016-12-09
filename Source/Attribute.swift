// Copyright © 2016 Alejandro Isaza.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

#if SWIFT_PACKAGE
    import CHDF5
#endif

open class Attribute {
    public internal(set) var id: hid_t = -1

    init(id: hid_t) {
        precondition(id >= 0, "Object ID needs to be non-negative")
        self.id = id
    }

    deinit {
        let status = H5Aclose(id)
        assert(status >= 0, "Failed to close Object")
    }

    open var name: String {
        let count = H5Aget_name(id, 0, nil)
        if count <= 0 {
            return ""
        }

        let pointer = UnsafeMutablePointer<CChar>.allocate(capacity: count + 1)
        H5Aget_name(id, count + 1, pointer)
        return String(cString: pointer)
    }

    public var space: Dataspace {
        return Dataspace(id: H5Aget_space(id))
    }

    public var type: Datatype {
        return Datatype(id: H5Aget_type(id))
    }

    /// Reads attribute data.
    open func read(into pointer: UnsafeMutableRawPointer, type: NativeType) throws {
        let status = H5Aread(id, type.rawValue, pointer)
        if status < 0 {
            throw Error.ioError
        }
    }

    /// Writes attribute data.
    open func write(from pointer: UnsafeRawPointer, type: NativeType) throws {
        let status = H5Awrite(id, type.rawValue, pointer);
        if status < 0 {
            throw Error.ioError
        }
    }
}
