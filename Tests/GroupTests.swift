// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import XCTest
import HDF5Kit

class GroupTests: XCTestCase {

    func testName() {
        let filePath = tempFilePath()
        guard let file = File.create(filePath, mode: .Truncate) else {
            fatalError("Failed to create file")
        }
        let group = file.createGroup("group")
        XCTAssertEqual(group.name, "/group")

        let subGroup = group.createGroup("subGroup")
        XCTAssertEqual(subGroup.name, "/group/subGroup")
    }

    func testObjectNames() {
        let filePath = tempFilePath()
        guard let file = File.create(filePath, mode: .Truncate) else {
            fatalError("Failed to create file")
        }
        let group = file.createGroup("group")
        group.createGroup("subGroup")
        group.createDoubleDataset("data", dataspace: Dataspace(dims: [10]))

        let groupNames = group.objectNames()
        XCTAssert(groupNames.contains("data"))
        XCTAssert(groupNames.contains("subGroup"))
    }
    
}
