// Copyright © 2016 Alejandro Isaza.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

 #if SWIFT_PACKAGE
    import CHDF5
 #endif

open class StringAttribute: Attribute {

    public func read() throws -> [String] {
        if type.isVariableLengthString {
            return try readVariableLength()
        } else {
            return try readFixedLength()
        }
    }

    func readVariableLength() throws -> [String] {
        let count = self.space.selectionSize
        let type = Datatype.createString()
        var data = [UnsafePointer<CChar>?](repeating: nil, count: count)
        try data.withUnsafeMutableBufferPointer { pointer in
            let status = H5Aread(id, type.id, pointer.baseAddress)
            if status < 0 {
                throw Error.ioError
            }
        }

        var strings = [String]()
        strings.reserveCapacity(count)

        for pointer in data {
            if let pointer = pointer {
                strings.append(String(cString: pointer))
            } else {
                strings.append("")
            }
        }

        H5Dvlen_reclaim(type.id, space.id, 0, &data)
        return strings
    }

    func readFixedLength() throws -> [String] {
        let count = self.space.size
        let size = Int(H5Aget_storage_size(id))
        let stringSize = size / count

        var data = [CChar](repeating: 0, count: size)
        let type = Datatype.createString(size: stringSize + 1)
        try data.withUnsafeMutableBufferPointer { pointer in
            let status = H5Aread(id, type.id, pointer.baseAddress)
            if status < 0 {
                throw Error.ioError
            }
        }

        var strings = [String]()
        strings.reserveCapacity(count)

        var index = 0
        for _ in 0..<count {
            data.withUnsafeBufferPointer { pointer in
                let string = String(cString: pointer.baseAddress! + index)
                strings.append(string)
                index += string.lengthOfBytes(using: .ascii)
                while index <= size && pointer[index] == 0 {
                    index += 1
                }
            }
        }
        return strings
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
