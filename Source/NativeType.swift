// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

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

    /// Return the Swift type corresponding to the NativeType
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

    /// The raw value of the NativeType
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

    /// Create a NativeType from a Swift type
    public init?(type: Any.Type) {
        if type == Swift.Int.self {
            self = .Int
        } else if type == Swift.UInt.self {
            self = .UInt
        } else if type == Swift.Float.self {
            self = .Float
        } else if type == Swift.Double.self {
            self = .Double
        } else if type == Swift.Int8.self {
            self = .Int8
        } else if type == Swift.UInt8.self {
            self = .UInt8
        } else if type == Swift.Int16.self {
            self = .Int16
        } else if type == Swift.UInt16.self {
            self = .UInt16
        } else if type == Swift.Int32.self {
            self = .Int32
        } else if type == Swift.UInt32.self {
            self = .UInt32
        } else if type == Swift.Int64.self {
            self = .Int64
        } else if type == Swift.UInt64.self {
            self = .UInt64
        } else {
            return nil
        }
    }
}
