// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import HDF5Kit

func tempFilePath() -> String {
    let fileName = ProcessInfo.processInfo.globallyUniqueString + ".hdf"
    return NSTemporaryDirectory() + "/" + fileName
}

func createFile(_ filePath: String) -> File {
    guard let file = File.create(filePath, mode: .truncate) else {
        fatalError("Failed to create file")
    }
    return file
}

func openFile(_ filePath: String) -> File {
    guard let file = File.open(filePath, mode: .readOnly) else {
        fatalError("Failed to open file")
    }
    return file
}
