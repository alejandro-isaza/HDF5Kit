// Copyright © 2016 Alejandro Isaza.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

#if SWIFT_PACKAGE
    import CHDF5
#endif

open class FloatAttribute: Attribute {

    public func read() throws -> [Float] {
        let space = self.space
        let count = space.size
        var data = [Float](repeating: 0, count: count)
        try data.withUnsafeMutableBufferPointer { pointer in
            return try read(into: pointer.baseAddress!, type: .float)
        }
        return data
    }

    public func write(_ data: [Float]) throws {
        assert(space.size == data.count)
        try data.withUnsafeBufferPointer { pointer in
            try write(from: pointer.baseAddress!, type: .float)
        }
    }

}


public extension GroupType {
    /// Creates a `Float` attribute.
    public func createFloatAttribute(_ name: String, dataspace: Dataspace) -> FloatAttribute? {
        guard let datatype = Datatype(type: Float.self) else {
            return nil
        }
        let attributeID = name.withCString { name in
            return H5Acreate2(id, name, datatype.id, dataspace.id, 0, 0)
        }
        return FloatAttribute(id: attributeID)
    }

    /// Opens a `Float` attribute.
    public func openFloatAttribute(_ name: String) -> FloatAttribute? {
        let attributeID = name.withCString{ name in
            return H5Aopen(id, name, 0)
        }
        guard attributeID >= 0 else {
            return nil
        }
        return FloatAttribute(id: attributeID)
    }
}
