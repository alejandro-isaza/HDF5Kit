//  Copyright © 2015 Venture Media Labs. All rights reserved.

import XCTest
@testable import HDF5

class HDF5Tests: XCTestCase {
    let width = UInt64(100)
    let height = UInt64(100)

    func tempFilePath() -> String {
        let fileName = NSProcessInfo.processInfo().globallyUniqueString + ".hdf"
        return NSTemporaryDirectory() + "/" + fileName
    }

    func createFile(filePath: String) -> File {
        guard let file = File.create(filePath, mode: .Truncate) else {
            fatalError("Failed to create file")
        }
        return file
    }

    func openFile(filePath: String) -> File {
        guard let file = File.open(filePath, mode: .ReadOnly) else {
            fatalError("Failed to open file")
        }
        return file
    }

    func writeData(filePath: String, data: [Double]) {
        let file = createFile(filePath)

        let dims: [UInt64] = [width, height]
        let dataspace = Dataspace(dims: dims)

        let datatype = Datatype.copy(type: .Double)
        datatype.order = .LittleEndian

        let dataset = Dataset.create(file: file, name: "MyData", datatype: datatype, dataspace: dataspace)
        XCTAssertEqual(UInt64(data.count), dataspace.size)
        XCTAssert(dataset.write(data))
    }

    func readData(filePath: String, inout data: [Double]) {
        let file = openFile(filePath)

        guard let dataset = Dataset.open(file: file, name: "MyData") else {
            XCTFail("Failed to open Dataset")
            return
        }
        XCTAssertEqual(UInt64(data.count), dataset.space.size)
        XCTAssert(dataset.read(&data))
    }

    func testCreateDataset() {
        let filePath = tempFilePath()

        let file = createFile(filePath)
        let dims: [UInt64] = [width, height]
        let dataspace = Dataspace(dims: dims)
        XCTAssertEqual(dataspace.size, width * height)
        XCTAssertEqual(dataspace.dims, dims)
        
        let datatype = Datatype.copy(type: .Double)
        datatype.order = .LittleEndian
        let dataset = Dataset.create(file: file, name: "MyData", datatype: datatype, dataspace: dataspace)
        XCTAssertNil(dataset.offset)
    }

    func testWriteRead() {
        let expected = (0..<width*height).map{ _ in return Double(arc4random()) / Double(UINT32_MAX) }

        let filePath = tempFilePath()
        writeData(filePath, data: expected)

        var actual = [Double](count: Int(width*height), repeatedValue: 0.0)
        readData(filePath, data: &actual)

        XCTAssertEqual(expected, actual)
    }
}
