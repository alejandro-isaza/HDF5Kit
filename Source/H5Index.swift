//
//  H5Index.swift
//  HDF5Kit
//
//  Created by Tim Burgess on 17/11/2015.
//  Copyright © 2015 Venture Media Labs. All rights reserved.
//

postfix operator .. {}
prefix operator .. {}

postfix func .. (lhs: Int) -> Range<Int> {
  return lhs...Int.max-1
}

prefix func .. (rhs: Int) -> Range<Int> {
  return Int.min...rhs
}

protocol H5Index {
  var slice: Range<Int> { get }
}

extension Int: H5Index {
  var slice: Range<Int> {
    get {
      return Range<Int>(start: self, end: self+1)
    }
  }
}
extension Range: H5Index {
  var slice: Range<Int> {
    get {
      return Range<Int>(start: self.startIndex as! Int, end: self.endIndex as! Int)
    }
  }
}



class DatasetDemo {

  subscript() -> () {
    get {
      // get all
    }
  }
  
  subscript(x: H5Index) -> () {
    get {
      print(x.slice)
    }
  }
  
  subscript(x:H5Index, y:H5Index) -> () {
    get {
      if x.slice.startIndex != Int.min {
        print("\(x.slice.startIndex) x \(x.slice.endIndex)")
      }
    }
  }
  
}

var foo = DatasetDemo()
let start = 0
let end = 9
let result = foo[]  // get all available
let result1 = foo[1] // get one value for 1D or one row for 2D or plane for 3D..
let result2 = foo[start..<end, start...end] // get 2D range using variables
let result3 = foo[0, 0...3] // get first row, columns 0 to 3
let result4 = foo[0..<10, 1] // get first 10 rows of 2cnd column
let result5 = foo[0.., 0...3] // get all rows of first 4 columns
let result6 = foo[5.., 10...12] // get columns 10 to 12 from the 5th row onwards
let result7 = foo[0..<4] // get first three values of 1D or first three rows of 2D
let result8 = foo[0.., ..5] // all columns up to the 5th one


