// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation

/// Get the pointer to an array of values. Use only with arrays of a basic data type (e.g. `[Int]`)
func ptr<T>(array: [T]) -> UnsafePointer<T> {
    return UnsafePointer<T>(array)
}

/// Get the pointer to an optional array of values. Use only with arrays of a basic data type (e.g. `[Int]?`)
func ptr<T>(array: [T]?) -> UnsafePointer<T> {
    if array == nil {
        return nil
    }
    return ptr(array!)
}

/// Get the mutable pointer to an array of values. Use only with arrays of a basic data type (e.g. `[Int]`)
func ptr<T>(inout array: [T]) -> UnsafeMutablePointer<T> {
    return UnsafeMutablePointer<T>(array)
}

/// Get the mutable pointer to an optional array of values. Use only with arrays of a basic data type (e.g. `[Int]?`)
func ptr<T>(inout array: [T]?) -> UnsafeMutablePointer<T> {
    if array == nil {
        return nil
    }
    return ptr(&array!)
}


// MARK: - UInt64 implicit conversion

/// Get a UInt64 pointer to an array of values. Will only work for types that are 64 bits long.
func ptr<T: IntegerType>(array: [T]) -> UnsafePointer<UInt64> {
    precondition(sizeof(T) == sizeof(UInt64))
    return UnsafePointer<UInt64>(array)
}

/// Get a UInt64 pointer to an optional array of values. Will only work for types that are 64 bits long.
func ptr<T: IntegerType>(array: [T]?) -> UnsafePointer<UInt64> {
    if array == nil {
        return nil
    }
    return ptr(array!)
}

/// Get a mutable UInt64 pointer to an array of values. Will only work for types that are 64 bits long.
func ptr<T: IntegerType>(inout array: [T]) -> UnsafeMutablePointer<UInt64> {
    precondition(sizeof(T) == sizeof(UInt64))
    return UnsafeMutablePointer<UInt64>(array)
}

/// Get a mutable UInt64 pointer to an optional array of values. Will only work for types that are 64 bits long.
func ptr<T: IntegerType>(inout array: [T]?) -> UnsafeMutablePointer<UInt64> {
    if array == nil {
        return nil
    }
    return ptr(&array!)
}


// MARK: - Int64 implicit conversion

/// Get a Int64 pointer to an array of values. Will only work for types that are 64 bits long.
func ptr<T: IntegerType>(array: [T]) -> UnsafePointer<Int64> {
    precondition(sizeof(T) == sizeof(Int64))
    return UnsafePointer<Int64>(array)
}

/// Get a Int64 pointer to an optional array of values. Will only work for types that are 64 bits long.
func ptr<T: IntegerType>(array: [T]?) -> UnsafePointer<Int64> {
    if array == nil {
        return nil
    }
    return ptr(array!)
}

/// Get a mutable Int64 pointer to an array of values. Will only work for types that are 64 bits long.
func ptr<T: IntegerType>(inout array: [T]) -> UnsafeMutablePointer<Int64> {
    precondition(sizeof(T) == sizeof(Int64))
    return UnsafeMutablePointer<Int64>(array)
}

/// Get a mutable Int64 pointer to an optional array of values. Will only work for types that are 64 bits long.
func ptr<T: IntegerType>(inout array: [T]?) -> UnsafeMutablePointer<Int64> {
    if array == nil {
        return nil
    }
    return ptr(&array!)
}
