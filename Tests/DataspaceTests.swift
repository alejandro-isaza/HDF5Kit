// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import XCTest
import HDF5Kit

class DataspaceTests: XCTestCase {

    func testDimensions() {
        let height = 10
        let width = 4
        let dataspace = Dataspace(dims: [height, width])

        XCTAssertEqual(dataspace.size, height * width)
        XCTAssertEqual(dataspace.selectionSize, height * width)
        XCTAssertEqual(dataspace.dims[0], height)
        XCTAssertEqual(dataspace.dims[1], width)
        XCTAssertEqual(dataspace.maxDims[0], height)
        XCTAssertEqual(dataspace.maxDims[1], width)
    }

    func testMaxDimensions() {
        let height = 10
        let width = 4
        let maxHeight = 100
        let maxWidth = 40
        let dataspace = Dataspace(dims: [height, width], maxDims: [maxHeight, maxWidth])

        XCTAssertEqual(dataspace.size, height * width)
        XCTAssertEqual(dataspace.dims[0], height)
        XCTAssertEqual(dataspace.dims[1], width)
        XCTAssertEqual(dataspace.maxDims[0], maxHeight)
        XCTAssertEqual(dataspace.maxDims[1], maxWidth)
    }

    func testSelect() {
        let spaceHeight = 10
        let spaceWidth = 4
        let dataspace = Dataspace(dims: [spaceHeight, spaceWidth])

        let selectionStartRow = 2
        let selectionStartCol = 1
        let selectionHeight = 3
        let selectionWidth = 2
        dataspace.select(start: [selectionStartRow, selectionStartCol], stride: nil, count: [selectionHeight, selectionWidth], block: nil)

        XCTAssertTrue(dataspace.hasValidSelection)
        XCTAssertEqual(dataspace.selectionSize, selectionHeight * selectionWidth)
        XCTAssertEqual(dataspace.dims[0], spaceHeight)
        XCTAssertEqual(dataspace.dims[1], spaceWidth)
    }

}
