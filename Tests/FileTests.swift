// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import XCTest
@testable import HDF5Kit

class FileTests: XCTestCase {
    let width = UInt64(100)
    let height = UInt64(100)
    let datasetName = "MyData"

    func writeData(filePath: String, data: [Double]) {
        let file = createFile(filePath)

        let dims: [Int] = [Int(width), Int(height)]
        let dataset = file.createAndWriteDataset(datasetName, dims: dims, data: data)
        XCTAssertEqual(UInt64(data.count), dataset.space.size)
        XCTAssert(dataset.writeDouble(data))
    }

    func readData(filePath: String, inout data: [Double]) {
        let file = openFile(filePath)

        guard let dataset = file.openDataset(datasetName) else {
            XCTFail("Failed to open Dataset")
            return
        }
        XCTAssertEqual(UInt64(data.count), dataset.space.size)
        XCTAssert(dataset.readDouble(&data))
    }

    func testCreateDataset() {
        let filePath = tempFilePath()

        let file = createFile(filePath)
        let dims: [UInt64] = [width, height]
        let dataspace = Dataspace(dims: dims)
        XCTAssertEqual(dataspace.size, width * height)
        XCTAssertEqual(dataspace.dims, dims)

        let dataset = file.createDataset(datasetName, datatype: Datatype.createDouble(), dataspace: dataspace)
        XCTAssertNil(dataset.offset)
    }

    func testWriteRead() {
        let filePath = tempFilePath()

        let expected = (0..<width*height).map{ _ in return Double(arc4random()) / Double(UINT32_MAX) }
        writeData(filePath, data: expected)

        var actual = [Double](count: Int(width*height), repeatedValue: 0.0)
        readData(filePath, data: &actual)

        XCTAssertEqual(expected, actual)
    }

    func testConvert() {
        let filePath = tempFilePath()

        // Write as Double
        let expected = (0..<width*height).map{ _ in return Double(arc4random()) / Double(UINT32_MAX) }
        writeData(filePath, data: expected)

        let file = openFile(filePath)
        guard let dataset = file.openDataset(datasetName) else {
            XCTFail("Failed to open Dataset")
            return
        }

        // Read as Float
        var actual = [Float](count: Int(width*height), repeatedValue: 0.0)
        XCTAssert(dataset.readFloat(&actual))

        for i in 0..<expected.count {
            XCTAssertEqual(actual[i], Float(expected[i]))
        }
    }
}
