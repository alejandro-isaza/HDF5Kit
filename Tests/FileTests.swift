// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import XCTest
import HDF5Kit

class FileTests: XCTestCase {
    let width = 100
    let height = 100
    let datasetName = "MyData"

    func writeData(filePath: String, data: [Double]) {
        let file = createFile(filePath)

        let dims: [Int] = [Int(width), Int(height)]
        let dataset = try! file.createAndWriteDataset(datasetName, dims: dims, data: data)
        XCTAssertEqual(data.count, dataset.space.size)
        try! dataset.write(data)
    }

    func readData(filePath: String) -> [Double]? {
        let file = openFile(filePath)

        guard let dataset = file.openDoubleDataset(datasetName) else {
            XCTFail("Failed to open Dataset")
            return nil
        }
        return try! dataset.read()
    }

    func testCreateDataset() {
        let filePath = tempFilePath()

        let file = createFile(filePath)
        let dims = [width, height]
        let dataspace = Dataspace(dims: dims)
        XCTAssertEqual(Int(dataspace.size), width * height)
        XCTAssertEqual(dataspace.dims.map{ Int($0) }, dims)

        let dataset = file.createDoubleDataset(datasetName, dataspace: dataspace)!
        XCTAssertNil(dataset.offset)
    }

    func testWriteRead() {
        let filePath = tempFilePath()

        let expected = (0..<width*height).map{ _ in return Double(arc4random()) / Double(UINT32_MAX) }
        writeData(filePath, data: expected)

        let actual = readData(filePath)!

        XCTAssertEqual(expected, actual)
    }

    func testConvert() {
        let filePath = tempFilePath()

        // Write as Double
        let expected = (0..<width*height).map{ _ in return Double(arc4random()) / Double(UINT32_MAX) }
        writeData(filePath, data: expected)

        let file = openFile(filePath)
        guard let dataset = file.openFloatDataset(datasetName) else {
            XCTFail("Failed to open Dataset")
            return
        }

        // Read as Float
        let actual = try! dataset.read()

        for i in 0..<expected.count {
            XCTAssertEqual(actual[i], Float(expected[i]))
        }
    }

}
