// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

#if SWIFT_PACKAGE
    import CHDF5
#endif

public enum NativeType {
    case int
    case uint
    case float
    case double
    case int8
    case uint8
    case int16
    case uint16
    case int32
    case uint32
    case int64
    case uint64
    case opaque

    /// Return the Swift type corresponding to the NativeType
    public var type: Any.Type {
        switch self {
        case .int: return Swift.Int.self
        case .uint: return Swift.UInt.self
        case .float: return Swift.Float.self
        case .double: return Swift.Double.self
        case .int8: return Swift.Int8.self
        case .uint8: return Swift.UInt8.self
        case .int16: return Swift.Int16.self
        case .uint16: return Swift.UInt16.self
        case .int32: return Swift.Int32.self
        case .uint32: return Swift.UInt32.self
        case .int64: return Swift.Int64.self
        case .uint64: return Swift.UInt64.self
        case .opaque: return Any.self
        }
    }

    /// The raw value of the NativeType
    public var rawValue: hid_t {
        switch self {
        case .int: return H5T_NATIVE_LONG_g
        case .uint: return H5T_NATIVE_ULONG_g
        case .float: return H5T_NATIVE_FLOAT_g
        case .double: return H5T_NATIVE_DOUBLE_g
        case .int8: return H5T_NATIVE_INT8_g
        case .uint8: return H5T_NATIVE_UINT8_g
        case .int16: return H5T_NATIVE_INT16_g
        case .uint16: return H5T_NATIVE_UINT16_g
        case .int32: return H5T_NATIVE_INT32_g
        case .uint32: return H5T_NATIVE_UINT32_g
        case .int64: return H5T_NATIVE_INT64_g
        case .uint64: return H5T_NATIVE_UINT64_g
        case .opaque: return H5T_NATIVE_OPAQUE_g
        }
    }

    /// Create a NativeType from a Swift type
    public init?(type: Any.Type) {
        if type == Swift.Int.self {
            self = .int
        } else if type == Swift.UInt.self {
            self = .uint
        } else if type == Swift.Float.self {
            self = .float
        } else if type == Swift.Double.self {
            self = .double
        } else if type == Swift.Int8.self {
            self = .int8
        } else if type == Swift.UInt8.self {
            self = .uint8
        } else if type == Swift.Int16.self {
            self = .int16
        } else if type == Swift.UInt16.self {
            self = .uint16
        } else if type == Swift.Int32.self {
            self = .int32
        } else if type == Swift.UInt32.self {
            self = .uint32
        } else if type == Swift.Int64.self {
            self = .int64
        } else if type == Swift.UInt64.self {
            self = .uint64
        } else {
            return nil
        }
    }
}
