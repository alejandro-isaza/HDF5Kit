// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

#if SWIFT_PACKAGE
    import CHDF5
#endif

public enum DataClass: Int32 {
    case noClass   = -1  // error
    case integer   = 0   // integer types
    case float     = 1   // floating-point types
    case time      = 2   // date and time types
    case string    = 3   // character string types
    case bitField  = 4   // bit field types
    case opaque    = 5   // opaque types
    case compound  = 6   // compound types
    case reference = 7   // reference types
    case `enum`    = 8	 // enumeration types
    case varLength = 9	 // Variable-Length types
    case array     = 10	 // Array types
}


public class Datatype : Object, Equatable {
    override init(id: hid_t) {
        super.init(id: id)
    }

    /// Create a Datatype from a class and a size
    public convenience init(dataClass: DataClass, size: Int) {
        let id = H5Tcreate(H5T_class_t(dataClass.rawValue), size)
        guard id >= 0 else {
            fatalError("Failed to create Datatype")
        }
        self.init(id: id)
    }

    /// Create a Datatype from a Swift type
    public convenience init?(type: Any.Type) {
        let id: hid_t
        if type == String.self {
            id = H5Tcopy(H5T_C_S1_g)
            H5Tset_size(id, -1)
        } else {
            guard let nativeType = NativeType(type: type) else {
                return nil
            }
            id = H5Tcopy(nativeType.rawValue)
        }
        self.init(id: id)
    }

    /// Copies an existing Datatype from a native type
    public convenience init(nativeType: NativeType) {
        let id = H5Tcopy(nativeType.rawValue)
        self.init(id: id)
    }

    /// The size of the `Datatype`.
    public var size: Int {
        get {
            return H5Tget_size(id)
        }
        set {
            H5Tset_size(id, newValue)
        }
    }

    public class func createDouble() -> Datatype {
        return Datatype(nativeType: .double)
    }

    public class func createInt() -> Datatype {
        return Datatype(nativeType: .int)
    }

    public class func createString(size: Int = -1) -> Datatype {
        let id = H5Tcopy(H5T_C_S1_g)
        let type = Datatype(id: id)
        type.size = size
        return type
    }

    public var `class`: DataClass {
        return DataClass(rawValue: H5Tget_class(id).rawValue)!
    }

    public var nativeType: NativeType? {
        let type = Datatype(id: H5Tget_native_type(id, H5T_DIR_ASCEND))
        if H5Tequal(type.id, NativeType.int.rawValue) > 0 { return .int }
        if H5Tequal(type.id, NativeType.uint.rawValue) > 0 { return .uint }
        if H5Tequal(type.id, NativeType.float.rawValue) > 0 { return .float }
        if H5Tequal(type.id, NativeType.double.rawValue) > 0 { return .double }
        if H5Tequal(type.id, NativeType.int8.rawValue) > 0 { return .int8 }
        if H5Tequal(type.id, NativeType.uint8.rawValue) > 0 { return .uint8 }
        if H5Tequal(type.id, NativeType.int16.rawValue) > 0 { return .int16 }
        if H5Tequal(type.id, NativeType.uint16.rawValue) > 0 { return .uint16 }
        if H5Tequal(type.id, NativeType.int32.rawValue) > 0 { return .int32 }
        if H5Tequal(type.id, NativeType.uint32.rawValue) > 0 { return .uint32 }
        if H5Tequal(type.id, NativeType.int64.rawValue) > 0 { return .int64 }
        if H5Tequal(type.id, NativeType.uint64.rawValue) > 0 { return .uint64 }
        if H5Tequal(type.id, NativeType.opaque.rawValue) > 0 { return .opaque }
        return nil
    }

    public enum Order: Int32 {
        case error        = -1
        case littleEndian = 0
        case bigEndian    = 1
        case vax          = 2
        case mixed        = 3
        case nonde        = 4
    }

    /// The byte order of the Datatype
    public var order: Order {
        get {
            return Order(rawValue: H5Tget_order(id).rawValue)!
        }
        set {
            H5Tset_order(id, H5T_order_t(newValue.rawValue))
        }
    }

    /// Determines whether datatype is a variable-length string.
    public var isVariableLengthString: Bool {
        return H5Tis_variable_str(id) != 0
    }
}

public func ==(lhs: Datatype, rhs: Datatype) -> Bool {
    return H5Tequal(lhs.id, rhs.id) > 0
}
