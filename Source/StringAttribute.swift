 // Copyright © 2016 Alejandro Isaza.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

open class StringAttribute: Attribute {

    public func read() throws -> String {
        let space = self.space
        let count = space.size

        var data = [UnsafePointer<CChar>?](repeating: nil, count: Int(count))
        let type = Datatype.createString()
        try data.withUnsafeMutableBufferPointer { pointer in
            let status = H5Aread(id, type.id, pointer.baseAddress)
            if status < 0 {
                throw Error.ioError
            }
        }

        return String(cString: data[0]!)
    }

    public func write(_ data: String) throws {
        let size = self.space.size
        precondition(1 == size, "Data size doesn't match Dataspace dimensions")

        try data.utf8CString.withUnsafeBufferPointer { pointer in
            // Create an array of pointers, which is what H5Dwrite expects
            var pointers = [UnsafePointer<Int8>]()
            pointers.append(pointer.baseAddress!)

            try pointers.withUnsafeBufferPointer { pp in
                let type = Datatype.createString()
                guard H5Awrite(id, type.id, pp.baseAddress) >= 0 else {
                    throw Error.ioError
                }
            }
        }
    }

}


public extension GroupType {
    /// Creates a `String` attribute.
    public func createStringAttribute(_ name: String) -> StringAttribute? {
        guard let datatype = Datatype(type: String.self) else {
            return nil
        }
        let dataspace = Dataspace(dims: [1])
        let attributeID = name.withCString { name in
            return H5Acreate2(id, name, datatype.id, dataspace.id, 0, 0)
        }
        return StringAttribute(id: attributeID)
    }

    /// Opens a `String` attribute.
    public func openStringAttribute(_ name: String) -> StringAttribute? {
        let attributeID = name.withCString{ name in
            return H5Aopen(id, name, 0)
        }
        guard attributeID >= 0 else {
            return nil
        }
        return StringAttribute(id: attributeID)
    }
}
