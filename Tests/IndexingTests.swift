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

    func createDoubleDataset() -> DoubleDataset {
        let file = createFile(tempFilePath())
        return try! file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetDoubleData)
    }

    func createIntDataset() -> IntDataset {
        let file = createFile(tempFilePath())
        return try! file.createAndWriteDataset(IndexingTests.datasetName, dims: IndexingTests.datasetDims, data: IndexingTests.datasetIntData)
    }

    func createStringDataset() -> StringDataset {
        let file = createFile(tempFilePath())
        let space = Dataspace(dims: IndexingTests.datasetDims)
        let dataset = file.createStringDataset(IndexingTests.datasetName, dataspace: space)!
        try! dataset.write(IndexingTests.datasetStringData)
        return dataset
    }

    
    func testAllReadDouble() {
        let dataset = createDoubleDataset()
        XCTAssertEqual(try! dataset.read(), IndexingTests.datasetDoubleData)
    }

    func testAllReadInt() {
        let dataset = createIntDataset()
        XCTAssertEqual(try! dataset.read(), IndexingTests.datasetIntData)
    }

    func testAllReadString() {
        let dataset = createStringDataset()
        XCTAssertEqual(try! dataset.read(), IndexingTests.datasetStringData)
    }
    
    func testSliceFirstTwoColumnsDouble() {
        let dataset = createDoubleDataset()
        let result = dataset[0.., 0...1] // all rows and first two columns
        XCTAssertEqual(result, [0.0, 1.0, 3.0, 4.0, 6.0, 7.0])
    }

    func testSliceFirstTwoColumnsInt() {
        let dataset = createIntDataset()
        let result = dataset[0.., 0...1] // all rows and first two columns
        XCTAssertEqual(result, [0, 1, 3, 4, 6, 7])
    }

    func testSliceFirstTwoColumnsString() {
        let dataset = createStringDataset()
        let result = dataset[0.., 0...1] // all rows and first two columns
        XCTAssertEqual(result, ["0", "1", "3", "4", "6", "7"])
    }

    func testSliceFirstTwoRowsDouble() {
        let dataset = createDoubleDataset()
        let result = dataset[..1, 0..] // first two rows and all columns
        XCTAssertEqual(result, [0.0, 1.0, 2.0, 3.0, 4.0, 5.0])
    }

    func testSliceFirstTwoRowsInt() {
        let dataset = createIntDataset()
        let result = dataset[..1, 0..] // first two rows and all columns
        XCTAssertEqual(result, [0, 1, 2, 3, 4, 5])
    }

    func testSliceFirstTwoRowsString() {
        let dataset = createStringDataset()
        let result = dataset[..1, 0..] // first two rows and all columns
        XCTAssertEqual(result, ["0", "1", "2", "3", "4", "5"])
    }

    func testSliceLastTwoRows() {
        let dataset = createDoubleDataset()
        let result = dataset[1..,0..] // last two rows and all columns
        XCTAssertEqual(result, [3.0, 4.0, 5.0, 6.0, 7.0, 8.0])
    }

    func testSliceLastTwoColumns() {
        let dataset = createDoubleDataset()
        let result = dataset[0..,1..] // all rows and last two columns
        
        XCTAssertEqual(result, [1.0, 2.0, 4.0, 5.0, 7.0, 8.0])
    }
    
    func testSliceLastTwoColumnsOfLastTwoRows() {
        let dataset = createDoubleDataset()
        let result = dataset[1..,1..] // last two columns of last two rows
        XCTAssertEqual(result, [4.0, 5.0, 7.0, 8.0])
    }

    func testSliceMiddleValue() {
        let dataset = createDoubleDataset()
        let result = dataset[1,1]
        XCTAssertEqual(result, [4.0])
    }
    
    func testSliceMiddleRow() {
        let dataset = createDoubleDataset()
        let result = dataset[1,0..] // middle row, all columns
        XCTAssertEqual(result, [3.0, 4.0, 5.0])
    }

    func testSliceLastColumn() {
        let dataset = createDoubleDataset()
        let result = dataset[0..,2]// middle row, all columns
        XCTAssertEqual(result, [2.0, 5.0, 8.0])
    }
}
