//  Copyright © 2015 Venture Media Labs. All rights reserved.

public enum NativeType {
    case Int
    case UInt
    case Float
    case Double
    case Int8
    case UInt8
    case Int16
    case UInt16
    case Int32
    case UInt32
    case Int64
    case UInt64
    case Opaque

    public var type: Any.Type {
        switch self {
        case Int: return Swift.Int.self
        case UInt: return Swift.UInt.self
        case Float: return Swift.Float.self
        case Double: return Swift.Double.self
        case Int8: return Swift.Int8.self
        case UInt8: return Swift.UInt8.self
        case Int16: return Swift.Int16.self
        case UInt16: return Swift.UInt16.self
        case Int32: return Swift.Int32.self
        case UInt32: return Swift.UInt32.self
        case Int64: return Swift.Int64.self
        case UInt64: return Swift.UInt64.self
        case Opaque: return Swift.Any.self
        }
    }

    public var rawValue: Swift.Int32 {
        switch self {
        case Int: return H5T_NATIVE_LONG_g
        case UInt: return H5T_NATIVE_ULONG_g
        case Float: return H5T_NATIVE_FLOAT_g
        case Double: return H5T_NATIVE_DOUBLE_g
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
