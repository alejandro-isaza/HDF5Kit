//
// Created by Tim Burgess on 17/11/2015.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

postfix operator .. {}

prefix operator .. {}

let MAX = Int.max-1
let MIN = Int.min

public postfix func .. (lhs: Int) -> Range<Int> {
    return lhs...MAX
}

public prefix func .. (rhs: Int) -> Range<Int> {
    return Int.min...rhs
}

public protocol H5Index {
      var slice: Range<Int> { get }
}

extension Int: H5Index {
    public var slice: Range<Int> {
        get {
            return Range<Int>(start: self, end: self+1)
        }
    }
}
extension Range: H5Index {
    public var slice: Range<Int> {
        get {
          return Range<Int>(start: self.startIndex as! Int, end: self.endIndex as! Int)
        }
    }
}

