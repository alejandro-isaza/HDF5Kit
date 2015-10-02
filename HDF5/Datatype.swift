//  Copyright © 2015 Venture Media Labs. All rights reserved.

import Foundation

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

public enum NativeType {
    case Byte
    case UByte
    case Short
    case UShort
    case Int
    case UInt
    case Long
    case ULong
    case LongLong
    case ULongLong
    case Float
    case Double
    case LongDouble
    case Int8
    case UInt8
    case Int16
    case UInt16
    case Int32
    case UInt32
    case Int64
    case UInt64
    case Opaque

    public var rawValue: Swift.Int32 {
        switch self {
        case Byte: return H5T_NATIVE_SCHAR_g
        case UByte: return H5T_NATIVE_UCHAR_g
        case Short: return H5T_NATIVE_SHORT_g
        case UShort: return H5T_NATIVE_USHORT_g
        case Int: return H5T_NATIVE_INT_g
        case UInt: return H5T_NATIVE_UINT_g
        case Long: return H5T_NATIVE_LONG_g
        case ULong: return H5T_NATIVE_ULONG_g
        case LongLong: return H5T_NATIVE_LLONG_g
        case ULongLong: return H5T_NATIVE_ULLONG_g
        case Float: return H5T_NATIVE_FLOAT_g
        case Double: return H5T_NATIVE_DOUBLE_g
        case LongDouble: return H5T_NATIVE_LDOUBLE_g
        case Int8: return H5T_NATIVE_INT8_g
        case UInt8: return H5T_NATIVE_UINT8_g
        case Int16: return H5T_NATIVE_INT16_g
        case UInt16: return H5T_NATIVE_UINT16_g
        case Int32: return H5T_NATIVE_INT32_g
        case UInt32: return H5T_NATIVE_UINT32_g
        case Int64: return H5T_NATIVE_INT64_g
        case UInt64: return H5T_NATIVE_UINT64_g
        case Opaque: return H5T_NATIVE_OPAQUE_g
        }
    }
}

public class Datatype {
    var id: Int32

    init(id: Int32) {
        self.id = id
        guard id >= 0 else {
            fatalError("Failed to create Datatype")
        }
    }

    deinit {
        let status = H5Tclose(id)
        assert(status >= 0, "Failed to close Datatype")
    }

    /// Create a Datatype from a class and a size
    public class func create(dataClass: DataClass, size: Int) -> Datatype {
        let id = H5Tcreate(H5T_class_t(dataClass.rawValue), size)
        guard id >= 0 else {
            fatalError("Failed to create Datatype")
        }
        return Datatype(id: id)
    }

    /// Copies an existing Datatype from a native type
    public class func copy(type type: NativeType) -> Datatype {
        let id = H5Tcopy(type.rawValue)
        return Datatype(id: id)
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
