// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

public enum DataClass: Int32 {
    case NoClass   = -1  // error
    case Integer   = 0   // integer types
    case Float     = 1   // floating-point types
    case Time      = 2   // date and time types
    case String    = 3   // character string types
    case BitField  = 4   // bit field types
    case Opaque    = 5   // opaque types
    case Compound  = 6   // compound types
    case Reference = 7   // reference types
    case Enum      = 8	 // enumeration types
    case VarLength = 9	 // Variable-Length types
    case Array     = 10	 // Array types
}


public class Datatype : Object, Equatable {
    override init(id: Int32) {
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
        let id: Int32
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

    public class func createDouble() -> Datatype {
        return Datatype(nativeType: .Double)
    }

    public class func createInt() -> Datatype {
        return Datatype(nativeType: .Int)
    }

    public class func createString() -> Datatype {
        let id = H5Tcopy(H5T_C_S1_g)
        H5Tset_size(id, -1)
        return Datatype(id: id)
    }

    public var `class`: DataClass {
        return DataClass(rawValue: H5Tget_class(id).rawValue)!
    }

    public var nativeType: NativeType? {
        let type = Datatype(id: H5Tget_native_type(id, H5T_DIR_ASCEND))
        if H5Tequal(type.id, NativeType.Int.rawValue) > 0 { return .Int }
        if H5Tequal(type.id, NativeType.UInt.rawValue) > 0 { return .UInt }
        if H5Tequal(type.id, NativeType.Float.rawValue) > 0 { return .Float }
        if H5Tequal(type.id, NativeType.Double.rawValue) > 0 { return .Double }
        if H5Tequal(type.id, NativeType.Int8.rawValue) > 0 { return .Int8 }
        if H5Tequal(type.id, NativeType.UInt8.rawValue) > 0 { return .UInt8 }
        if H5Tequal(type.id, NativeType.Int16.rawValue) > 0 { return .Int16 }
        if H5Tequal(type.id, NativeType.UInt16.rawValue) > 0 { return .UInt16 }
        if H5Tequal(type.id, NativeType.Int32.rawValue) > 0 { return .Int32 }
        if H5Tequal(type.id, NativeType.UInt32.rawValue) > 0 { return .UInt32 }
        if H5Tequal(type.id, NativeType.Int64.rawValue) > 0 { return .Int64 }
        if H5Tequal(type.id, NativeType.UInt64.rawValue) > 0 { return .UInt64 }
        if H5Tequal(type.id, NativeType.Opaque.rawValue) > 0 { return .Opaque }
        return nil
    }

    public enum Order: Int32 {
        case Error        = -1
        case LittleEndian = 0
        case BigEndian    = 1
        case Vax          = 2
        case Mixed        = 3
        case Nonde        = 4
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
}

public func ==(lhs: Datatype, rhs: Datatype) -> Bool {
    return H5Tequal(lhs.id, rhs.id) > 0
}
