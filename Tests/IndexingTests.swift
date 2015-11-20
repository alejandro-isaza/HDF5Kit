// Created by Tim Burgess on 20/11/2015.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import XCTest
import HDF5Kit

class IndexingTests: XCTestCase {
    let datasetName = "MyData"
    
    func testAllRead() {
        
        let file = createFile(tempFilePath())
        
        let createDims = [4, 4]
        let size = createDims.reduce(1, combine: *)
        let data = (0..<size).map { Double($0) }
        
        let dataset = file.createAndWriteDataset(datasetName, dims: createDims, data: data)

        XCTAssertEqual(dataset[], dataset.readDouble())
    }
    
    func testSlice2x2Read() {
        
        let file = createFile(tempFilePath())
        
        let createDims = [3, 3]
        let size = createDims.reduce(1, combine: *)
        let data = (0..<size).map { Double($0) }
        
        let dataset = file.createAndWriteDataset(datasetName, dims: createDims, data: data)
        let result = dataset[0...1,0...1]
        
        XCTAssertEqual(result, [0.0, 1.0, 3.0, 4.0])
    }
}
