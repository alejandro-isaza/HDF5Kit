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
    static let datasetDoubleData = (0..<datasetSize).map { Double($0) }
    static let datasetIntData = (0..<datasetSize).map { $0 }
    static let datasetStringData = (0..<datasetSize).map { String($0) }

    func createDoubleDataset() -> Dataset<Double> {
        let file = createFile(tempFilePath())
        return file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetDoubleData)
    }

    func createIntDataset() -> Dataset<Int> {
        let file = createFile(tempFilePath())
        return file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetIntData)
    }

    func createStringDataset() -> Dataset<String> {
        let file = createFile(tempFilePath())
        let space = Dataspace(dims: IndexingTests.datasetDims)
        let dataset = file.createDataset(IndexingTests.datasetName, type: String.self, dataspace: space)!
        dataset.writeString(IndexingTests.datasetStringData)
        return dataset
    }

    
    func testAllReadDouble() {
        let dataset = createDoubleDataset()
        XCTAssertEqual(dataset.read() as! [Double], IndexingTests.datasetDoubleData)
    }

    func testAllReadInt() {
        let dataset = createIntDataset()
        XCTAssertEqual(dataset.read() as! [Int], IndexingTests.datasetIntData)
    }

    func testAllReadString() {
        let dataset = createStringDataset()
        XCTAssertEqual(dataset.read() as! [String], IndexingTests.datasetStringData)
    }
    
    func testSliceFirstTwoColumnsDouble() {
        let dataset = createDoubleDataset()
        let result = dataset[0.., 0...1] as! [Double] // all rows and first two columns
        XCTAssertEqual(result, [0.0, 1.0, 3.0, 4.0, 6.0, 7.0])
    }

    func testSliceFirstTwoColumnsInt() {
        let dataset = createIntDataset()
        let result = dataset[0.., 0...1] as! [Int] // all rows and first two columns
        XCTAssertEqual(result, [0, 1, 3, 4, 6, 7])
    }

    func testSliceFirstTwoColumnsString() {
        let dataset = createStringDataset()
        let result = dataset[0.., 0...1] as! [String] // all rows and first two columns
        XCTAssertEqual(result, ["0", "1", "3", "4", "6", "7"])
    }

    func testSliceFirstTwoRowsDouble() {
        let dataset = createDoubleDataset()
        let result = dataset[..1, 0..] as! [Double] // first two rows and all columns
        XCTAssertEqual(result, [0.0, 1.0, 2.0, 3.0, 4.0, 5.0])
    }

    func testSliceFirstTwoRowsInt() {
        let dataset = createIntDataset()
        let result = dataset[..1, 0..] as! [Int] // first two rows and all columns
        XCTAssertEqual(result, [0, 1, 2, 3, 4, 5])
    }

    func testSliceFirstTwoRowsString() {
        let dataset = createStringDataset()
        let result = dataset[..1, 0..] as! [String] // first two rows and all columns
        XCTAssertEqual(result, ["0", "1", "2", "3", "4", "5"])
    }

    func testSliceLastTwoRows() {
        let dataset = createDoubleDataset()
        let result = dataset[1..,0..] as! [Double] // last two rows and all columns
        XCTAssertEqual(result, [3.0, 4.0, 5.0, 6.0, 7.0, 8.0])
    }

    func testSliceLastTwoColumns() {
        let dataset = createDoubleDataset()
        let result = dataset[0..,1..] as! [Double] // all rows and last two columns
        
        XCTAssertEqual(result, [1.0, 2.0, 4.0, 5.0, 7.0, 8.0])
    }
    
    func testSliceLastTwoColumnsOfLastTwoRows() {
        let dataset = createDoubleDataset()
        let result = dataset[1..,1..] as! [Double] // last two columns of last two rows
        XCTAssertEqual(result, [4.0, 5.0, 7.0, 8.0])
    }

    func testSliceMiddleValue() {
        let dataset = createDoubleDataset()
        let result = dataset[1,1] as! [Double]
        XCTAssertEqual(result, [4.0])
    }
    
    func testSliceMiddleRow() {
        let dataset = createDoubleDataset()
        let result = dataset[1,0..] as! [Double] // middle row, all columns
        XCTAssertEqual(result, [3.0, 4.0, 5.0])
    }

    func testSliceLastColumn() {
        let dataset = createDoubleDataset()
        let result = dataset[0..,2] as! [Double]// middle row, all columns
        XCTAssertEqual(result, [2.0, 5.0, 8.0])
    }
}
