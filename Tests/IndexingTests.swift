// Copyright © 2015 Venture Media Labs.
// Copyright © 2015 Tim Burgess
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import XCTest
import HDF5Kit

class IndexingTests: XCTestCase {
    static let datasetName = "MyData"
    static let datasetDims = [3, 3]
    static let datasetSize = datasetDims.reduce(1, combine: *)
    static let datasetData = (0..<datasetSize).map { Double($0) }

    func createDataset() -> Dataset<Double> {
        let file = createFile(tempFilePath())
        return file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetData)
    }
    
    func testAllRead() {
        let dataset = createDataset()
        XCTAssertEqual(dataset.read() as! [Double], dataset.read() as! [Double])
    }
    
    func testSliceFirstTwoColumns() {
        let dataset = createDataset()
        let result = dataset[0..,0...1] as! [Double] // all rows and first two columns
        XCTAssertEqual(result, [0.0, 1.0, 3.0, 4.0, 6.0, 7.0])
    }

    func testSliceFirstTwoRows() {
        let dataset = createDataset()
        let result = dataset[..1,0..] as! [Double] // first two rows and all columns
        XCTAssertEqual(result, [0.0, 1.0, 2.0, 3.0, 4.0, 5.0])
    }

    func testSliceLastTwoRows() {
        let dataset = createDataset()
        let result = dataset[1..,0..] as! [Double] // last two rows and all columns
        XCTAssertEqual(result, [3.0, 4.0, 5.0, 6.0, 7.0, 8.0])
    }

    func testSliceLastTwoColumns() {
        let dataset = createDataset()
        let result = dataset[0..,1..] as! [Double] // all rows and last two columns
        
        XCTAssertEqual(result, [1.0, 2.0, 4.0, 5.0, 7.0, 8.0])
    }
    
    func testSliceLastTwoColumnsOfLastTwoRows() {
        let dataset = createDataset()
        let result = dataset[1..,1..] as! [Double] // last two columns of last two rows
        XCTAssertEqual(result, [4.0, 5.0, 7.0, 8.0])
    }

    func testSliceMiddleValue() {
        let dataset = createDataset()
        let result = dataset[1,1] as! [Double]
        XCTAssertEqual(result, [4.0])
    }
    
    func testSliceMiddleRow() {
        let dataset = createDataset()
        let result = dataset[1,0..] as! [Double] // middle row, all columns
        XCTAssertEqual(result, [3.0, 4.0, 5.0])
    }

    func testSliceLastColumn() {
        let dataset = createDataset()
        let result = dataset[0..,2] as! [Double]// middle row, all columns
        XCTAssertEqual(result, [2.0, 5.0, 8.0])
    }
}
