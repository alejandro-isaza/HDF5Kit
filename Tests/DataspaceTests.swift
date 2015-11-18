// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import XCTest
import HDF5Kit

class DataspaceTests: XCTestCase {

    func testDimensions() {
        let w = 10
        let h = 4
        let dataspace = Dataspace(dims: [w, h])

        XCTAssertEqual(dataspace.size, w * h)
        XCTAssertEqual(dataspace.selectionSize, w * h)
        XCTAssertEqual(dataspace.dims[0], w)
        XCTAssertEqual(dataspace.dims[1], h)
        XCTAssertEqual(dataspace.maxDims[0], w)
        XCTAssertEqual(dataspace.maxDims[1], h)
    }

    func testMaxDimensions() {
        let w = 10
        let h = 4
        let maxw = 100
        let maxh = 40
        let dataspace = Dataspace(dims: [w, h], maxDims: [maxw, maxh])

        XCTAssertEqual(dataspace.size, w * h)
        XCTAssertEqual(dataspace.dims[0], w)
        XCTAssertEqual(dataspace.dims[1], h)
        XCTAssertEqual(dataspace.maxDims[0], maxw)
        XCTAssertEqual(dataspace.maxDims[1], maxh)
    }

    func testSelect() {
        let spaceWidth = 10
        let spaceHeight = 4
        let dataspace = Dataspace(dims: [spaceWidth, spaceHeight])

        let selectionStartCol = 2
        let selectionStartRow = 1
        let selectionWidth = 3
        let selectionHeight = 2
        dataspace.select(start: [selectionStartCol, selectionStartRow], stride: nil, count: [selectionWidth, selectionHeight], block: nil)

        XCTAssertTrue(dataspace.hasValidSelection)
        XCTAssertEqual(dataspace.selectionSize, selectionWidth * selectionHeight)
        XCTAssertEqual(dataspace.dims[0], spaceWidth)
        XCTAssertEqual(dataspace.dims[1], spaceHeight)
    }

}
