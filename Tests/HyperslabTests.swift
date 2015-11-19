//
//  HyperslabTests.swift
//  HDF5Kit
//
//  Created by Tim Burgess on 20/11/2015.
//  Copyright © 2015 Venture Media Labs. All rights reserved.
//

import XCTest
import HDF5Kit

class HyperslabTests: XCTestCase {
    let datasetName = "MyData"

    func testSlab2DRead() {
        let filePath = tempFilePath()
        var file = createFile(filePath)
        
        let createDims = [7, 7]
        let size = createDims.reduce(1, combine: *)
        let data = (0..<size).map { Double($0) }
        
        // write a 7x7 dataset
        let newDataset = file.createAndWriteDataset(datasetName, dims: createDims, data: data)
        XCTAssertEqual(Int(newDataset.space.size), size)
        
        // re-open file for reading
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
        dataset.readDouble(&actual, memSpace: memspace, fileSpace: dataspace)
        XCTAssertEqual(data[9...12], actual[0...3])
    }
  
    func testSlab3DRead() {
        let filePath = tempFilePath()
        var file = createFile(filePath)
        
        let createDims = [7, 7]
        let size = createDims.reduce(1, combine: *)
        let data = (0..<size).map { Double($0) }
        
        // write a 7x7 dataset
        let newDataset = file.createAndWriteDataset(datasetName, dims: createDims, data: data)
        XCTAssertEqual(Int(newDataset.space.size), size)
        
        // re-open file for reading
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
        let dims = [7,7,1]
        let offset_out = [0,0,0]
        let count_out = [3,4,1]
        let memspace = Dataspace(dims: dims)
        memspace.select(start: offset_out, stride: nil, count: count_out, block: nil)
        
        // create memory to read to
        var actual = [Double](count: dims.reduce(1, combine:*), repeatedValue: 0.0)
        
        // read dataspace to memspace
        dataset.readDouble(&actual, memSpace: memspace, fileSpace: dataspace)
        XCTAssertEqual(data[9...12], actual[0...3])
    }
}
