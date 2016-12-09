// Copyright © 2016 Alejandro Isaza.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import XCTest
import HDF5Kit

class AttributeTests: XCTestCase {

    func testName() {
        let filePath = tempFilePath()
        guard let file = File.create(filePath, mode: .truncate) else {
            fatalError("Failed to create file")
        }
        let group = file.createGroup("group")
        XCTAssertEqual(group.name, "/group")

        let dataspace = Dataspace(dims: [4])
        guard let attribute = group.createIntAttribute("attribute", dataspace: dataspace) else {
            XCTFail()
            return
        }
        XCTAssertEqual(attribute.name, "attribute")
    }

    func testWriteReadInt() {
        let filePath = tempFilePath()
        guard let file = File.create(filePath, mode: .truncate) else {
            fatalError("Failed to create file")
        }
        let group = file.createGroup("group")
        XCTAssertEqual(group.name, "/group")

        let dataspace = Dataspace(dims: [4])
        guard let attribute = group.createIntAttribute("attribute", dataspace: dataspace) else {
            XCTFail()
            return
        }

        do {
            let writeData = [1, 2, 3, 4]
            try attribute.write(writeData)
            XCTAssertEqual(try attribute.read(), writeData)
        } catch {
            XCTFail()
        }
    }

    func testWriteReadString() {
        let filePath = tempFilePath()
        guard let file = File.create(filePath, mode: .truncate) else {
            fatalError("Failed to create file")
        }
        let group = file.createGroup("group")
        XCTAssertEqual(group.name, "/group")

        guard let attribute = group.createStringAttribute("attribute") else {
            XCTFail()
            return
        }

        do {
            let writeData = "ABCD"
            try attribute.write(writeData)
            XCTAssertEqual(try attribute.read(), [writeData])
        } catch {
            XCTFail()
        }
    }
}
