// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import XCTest
@testable import HDF5Kit

class FileTests: XCTestCase {
    let width = 100
    let height = 100
    let datasetName = "MyData"

    func writeData(filePath: String, data: [Double]) {
        let file = createFile(filePath)

        let dims: [Int] = [Int(width), Int(height)]
        let dataset = file.createAndWriteDataset(datasetName, dims: dims, data: data)
        XCTAssertEqual(data.count, dataset.space.size)
        XCTAssert(dataset.writeDouble(data))
    }

    func readData(filePath: String, inout data: [Double]) {
        let file = openFile(filePath)

        guard let dataset = file.openDataset(datasetName) else {
            XCTFail("Failed to open Dataset")
            return
        }
        XCTAssertEqual(data.count, dataset.space.size)
        XCTAssert(dataset.readDouble(&data))
    }

    func testCreateDataset() {
        let filePath = tempFilePath()

        let file = createFile(filePath)
        let dims = [width, height]
        let dataspace = Dataspace(dims: dims)
        XCTAssertEqual(Int(dataspace.size), width * height)
        XCTAssertEqual(dataspace.dims.map{ Int($0) }, dims)

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
        var actual = [Float](count: width*height, repeatedValue: 0.0)
        XCTAssert(dataset.readFloat(&actual))

        for i in 0..<expected.count {
            XCTAssertEqual(actual[i], Float(expected[i]))
        }
    }
  
    func testSlab7x7to3x4Read() {
      let createDims = [7, 7]
      let filePath = tempFilePath()
      var file = createFile(filePath)
      let incrementing = (0..<createDims.reduce(1, combine: *)).map { Double($0) }
 
      // write a dataset of 7x7 with incrementing Doubles from 0.0, 1.0, 2.0, ..
      let newDataset = file.createAndWriteDataset(datasetName, dims: createDims, data: incrementing)
      XCTAssertEqual(Int(newDataset.space.size), createDims.reduce(1, combine: *))
      
      file = openFile(filePath)
      guard let dataset = file.openDataset(datasetName) else {
        XCTFail("Failed to open Dataset")
        return
      }
      
      // define hyperslab in dataset
      let offset = [1,2]
      let count = [3,4]
      let dataspace = dataset.space // get new dataspace for hyperslab
      dataspace.select(start: offset, stride: nil, count: count, block: nil)
      
      // define memspace
      let offset_out = [0,0]
      let count_out = [3,4]
      let memspace = Dataspace(dims: count_out)
      memspace.select(start: offset_out, stride: nil, count: count_out, block: nil)
      
      // create memory to read to
      var actual = [Double](count: count_out.reduce(1, combine:*), repeatedValue: 0.0)
      
      // read dataspace to memspace
      dataset.readDouble(&actual, memspace_id: memspace.id, dataspace_id: dataspace.id)
      XCTAssertEqual(incrementing[9...12], actual[0...3])
  }
  
}
