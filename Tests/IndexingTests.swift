// Created by Tim Burgess on 20/11/2015.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import XCTest
import HDF5Kit

class IndexingTests: XCTestCase {
    let datasetName = "MyData"

    func createDataset() -> Dataset {
        let file = createFile(tempFilePath())
        let createDims = [3, 3]
        let size = createDims.reduce(1, combine: *)
        let data = (0..<size).map { Double($0) }
        return file.createAndWriteDataset(datasetName, dims: createDims, data: data)
    }
    
    func testAllRead() {
        
        let dataset = createDataset()
        XCTAssertEqual(dataset[], dataset.readDouble())
    }
    
    func testSliceFirstTwoColumns() {
        
        let dataset = createDataset()
        let result = dataset[0..,0...1] // all rows and first two columns
        XCTAssertEqual(result, [0.0, 1.0, 3.0, 4.0, 6.0, 7.0])
    }

    func testSliceFirstTwoRows() {
        
        let dataset = createDataset()
        let result = dataset[..1,0..] // first two rows and all columns
        XCTAssertEqual(result, [0.0, 1.0, 2.0, 3.0, 4.0, 5.0])
    }

    func testSliceLastTwoRows() {
        
        let dataset = createDataset()
        let result = dataset[1..,0..] // last two rows and all columns
        XCTAssertEqual(result, [3.0, 4.0, 5.0, 6.0, 7.0, 8.0])
    }

    func testSliceLastTwoColumns() {
        
        let dataset = createDataset()
        let result = dataset[0..,1..] // all rows and last two columns
        
        XCTAssertEqual(result, [1.0, 2.0, 4.0, 5.0, 7.0, 8.0])
    }
    
    func testSliceLastTwoColumnsOfLastTwoRows() {
        
        let dataset = createDataset()
        let result = dataset[1..,1..] // last two columns of last two rows
        XCTAssertEqual(result, [4.0, 5.0, 7.0, 8.0])
    }

    func testSliceMiddleValue() {
        
        let dataset = createDataset()
        let result = dataset[1,1]
        XCTAssertEqual(result, [4.0])
    }
    
    func testSliceMiddleRow() {
        
        let dataset = createDataset()
        let result = dataset[1,0..] // middle row, all columns
        XCTAssertEqual(result, [3.0, 4.0, 5.0])
    }

    func testSliceLastColumn() {
        
        let dataset = createDataset()
        let result = dataset[0..,2] // middle row, all columns
        XCTAssertEqual(result, [2.0, 5.0, 8.0])
    }
    
}
