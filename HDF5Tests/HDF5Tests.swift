//  Copyright © 2015 Venture Media Labs. All rights reserved.

import XCTest
@testable import HDF5

class HDF5Tests: XCTestCase {

    var filePath: String {
        let fileName = NSProcessInfo.processInfo().globallyUniqueString + ".hdf"
        return NSTemporaryDirectory() + "/" + fileName
    }

    func testCreateDataset() {
        guard let file = File.create(filePath, mode: .Truncate) else {
            XCTFail("Failed to create file")
            return
        }

        let dims: [UInt64] = [100, 100]
        let dataspace = Dataspace(dims: dims)
        XCTAssertEqual(dataspace.size, 100*100)
        XCTAssertEqual(dataspace.dims, dims)
        
        let datatype = Datatype.copy(.Double)
        datatype.order = .LittleEndian
        let dataset = Dataset(file: file, name: "MyData", datatype: datatype, dataspace: dataspace)
        XCTAssertNil(dataset.offset)
    }

    func testWriteRead() {
        guard let file = File.create(filePath, mode: .Truncate) else {
            XCTFail("Failed to create file")
            return
        }

        let dims: [UInt64] = [10, 10]
        let dataspace = Dataspace(dims: dims)

        let datatype = Datatype.copy(.Double)
        datatype.order = .LittleEndian

        let writtenData = (0..<10*10).map{ _ in return Double(arc4random()) / Double(UINT32_MAX) }
        let dataset = Dataset(file: file, name: "MyData", datatype: datatype, dataspace: dataspace)
        XCTAssert(dataset.write(writtenData))

        var readData = [Double](count: 10*10, repeatedValue: 0.0)
        XCTAssert(dataset.read(&readData))

        XCTAssertEqual(writtenData, readData)
    }
}
