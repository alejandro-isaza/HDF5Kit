// Copyright © 2016 Alejandro Isaza.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

#if SWIFT_PACKAGE
    import CHDF5
#endif

open class IntAttribute: Attribute {

    public func read() throws -> [Int] {
        let space = self.space
        let count = space.size
        var data = [Int](repeating: 0, count: count)
        try data.withUnsafeMutableBufferPointer { pointer in
            return try read(into: pointer.baseAddress!, type: .int)
        }
        return data
    }

    public func write(_ data: [Int]) throws {
        assert(space.size == data.count)
        try data.withUnsafeBufferPointer { pointer in
            try write(from: pointer.baseAddress!, type: .int)
        }
    }

}


public extension GroupType {
    /// Creates a `Int` attribute.
    public func createIntAttribute(_ name: String, dataspace: Dataspace) -> IntAttribute? {
        guard let datatype = Datatype(type: Int.self) else {
            return nil
        }
        let attributeID = name.withCString { name in
            return H5Acreate2(id, name, datatype.id, dataspace.id, 0, 0)
        }
        return IntAttribute(id: attributeID)
    }

    /// Opens an `Int` attribute.
    public func openIntAttribute(_ name: String) -> IntAttribute? {
        let attributeID = name.withCString{ name in
            return H5Aopen(id, name, 0)
        }
        guard attributeID >= 0 else {
            return nil
        }
        return IntAttribute(id: attributeID)
    }
}
