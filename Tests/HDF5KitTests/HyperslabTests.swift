// Copyright © 2015 Venture Media Labs.
// Copyright © 2015 Tim Burgess
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import XCTest
import HDF5Kit

class HyperslabTests: XCTestCase {
    let datasetName = "MyData"

    func testDoubleWriteRead() {
        let filePath = tempFilePath()
        let file = createFile(filePath)

        let createDims = [7, 7]
        let space = Dataspace(dims: createDims)
        let dataset = file.createDoubleDataset(datasetName, dataspace: space)!

        let data = (0..<7).map({ Double($0) })
        dataset[[0, 0..]] = data

        XCTAssertEqual(dataset[0, 0..], data)
    }

    func testStringWriteRead() {
        let filePath = tempFilePath()
        let file = createFile(filePath)

        let createDims = [7, 7]
        let space = Dataspace(dims: createDims)
        let dataset = file.createStringDataset(datasetName, dataspace: space)!

        let data = (0..<7).map({ "Number \($0)" })
        dataset[[0, 0..]] = data

        XCTAssertEqual(dataset[0, 0], ["Number 0"])
        XCTAssertEqual(dataset[0, 0..], data)
    }

    func testSlab2DReadDouble() {
        let filePath = tempFilePath()
        var file = createFile(filePath)
        
        let createDims = [7, 7]
        let size = createDims.reduce(1, *)
        let data = (0..<size).map { Double($0) }
        
        // write a 7x7 dataset
        let newDataset = try! file.createAndWriteDataset(datasetName, dims: createDims, data: data)
        XCTAssertEqual(Int(newDataset.space.size), size)
        
        // re-open file for reading
        file = openFile(filePath)
        guard let dataset = file.openDoubleDataset(datasetName) else {
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
        
        // read dataspace to memspace
        let actual = try! dataset.read(memSpace: memspace, fileSpace: dataspace)
        XCTAssertEqual(data[9...12], actual[0...3])
    }

    func testSlab2DReadString() {
        let filePath = tempFilePath()
        var file = createFile(filePath)

        let createDims = [7, 7]
        let size = createDims.reduce(1, *)
        let data = (0..<size).map { String($0) }

        // write a 7x7 dataset
        let space = Dataspace(dims: createDims)
        let newDataset = file.createStringDataset(datasetName, dataspace: space)!
        try! newDataset.write(data)
        XCTAssertEqual(Int(newDataset.space.size), size)

        // re-open file for reading
        file = openFile(filePath)
        guard let dataset = file.openStringDataset(datasetName) else {
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

        // read dataspace to memspace
        let actual = try! dataset.read(fileSpace: dataspace)
        XCTAssertEqual(data[9...12], actual[0...3])
    }

    func testReadStringSlab() {
        let filePath = tempFilePath()
        var file = createFile(filePath)

        let createDims = [7, 7]
        let size = createDims.reduce(1, *)
        let data = (0..<size).map { String($0) }

        // write a 7x7 dataset
        let space = Dataspace(dims: createDims)
        let newDataset = file.createStringDataset(datasetName, dataspace: space)!
        try! newDataset.write(data)
        XCTAssertEqual(Int(newDataset.space.size), size)

        // re-open file for reading
        file = openFile(filePath)
        guard let dataset = file.openStringDataset(datasetName) else {
            XCTFail("Failed to open Dataset")
            return
        }

        let actual = dataset[1...3, 2...5]
        XCTAssertEqual(actual.count, 12)
        XCTAssertEqual(data[9...12], actual[0...3])
    }
  
    func testSlab3DRead() {
        let filePath = tempFilePath()
        var file = createFile(filePath)
        
        let createDims = [7, 7]
        let size = createDims.reduce(1, *)
        let data = (0..<size).map { Double($0) }
        
        // write a 7x7 dataset
        let newDataset = try! file.createAndWriteDataset(datasetName, dims: createDims, data: data)
        XCTAssertEqual(Int(newDataset.space.size), size)
        
        // re-open file for reading
        file = openFile(filePath)
        guard let dataset = file.openDoubleDataset(datasetName) else {
            XCTFail("Failed to open Dataset")
            return
        }
        
        // define hyperslab in dataset
        let offset = [1,2]
        let count = [3,4]
        let dataspace = dataset.space // get new dataspace for hyperslab
        dataspace.select(start: offset, stride: nil, count: count, block: nil)
        
        // define memspace
        let dims = [7,7,1]
        let offset_out = [0,0,0]
        let count_out = [3,4,1]
        let memspace = Dataspace(dims: dims)
        memspace.select(start: offset_out, stride: nil, count: count_out, block: nil)
        
        // read dataspace to memspace
        let actual = try! dataset.read(memSpace: memspace, fileSpace: dataspace)
        XCTAssertEqual(data[9...12], actual[0...3])
    }
}
