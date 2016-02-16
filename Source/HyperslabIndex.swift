// Copyright © 2015 Venture Media Labs.
// Copyright © 2015 Tim Burgess
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

postfix operator .. {}

prefix operator .. {}

public postfix func .. (lhs: Int) -> Range<Int> {
    return lhs...HyperslabIndex.all
}

public prefix func .. (rhs: Int) -> Range<Int> {
    return 0...rhs
}

public protocol HyperslabIndexType {
    var start: Int { get }
    var stride: Int { get }
    var blockCount: Int { get }
    var blockSize: Int { get }
}

public struct HyperslabIndex: HyperslabIndexType {
    static let all = Int.max - 1

    public var start: Int
    public var stride: Int
    public var blockCount: Int
    public var blockSize: Int

    public var count: Int {
        get {
            return blockCount
        }
        set {
            blockCount = newValue
        }
    }

    public init(start: Int, end: Int) {
        self.start = start
        blockCount = end - start
        stride =  1
        blockSize = 1
    }

    public init(start: Int, count: Int) {
        self.start = start
        self.blockCount = count
        stride =  1
        blockSize = 1
    }

    public init(start: Int, stride: Int, count: Int, blockSize: Int = 1) {
        self.start = start
        self.stride = stride
        self.blockCount = count
        self.blockSize = blockSize
    }
}

extension Int: HyperslabIndexType {
    public var start: Int {
        return self
    }

    public var stride: Int {
        return 1
    }

    public var blockCount: Int {
        return 1
    }

    public var blockSize: Int {
        return 1
    }
}

extension Range: HyperslabIndexType {
    public var start: Int {
        return unsafeBitCast(startIndex, Int.self)
    }

    public var stride: Int {
        return 1
    }

    public var blockCount: Int {
        if unsafeBitCast(endIndex, Int.self) == HyperslabIndex.all + 1 {
            return HyperslabIndex.all
        }
        return unsafeBitCast(endIndex, Int.self) - start
    }

    public var blockSize: Int {
        return 1
    }
}

