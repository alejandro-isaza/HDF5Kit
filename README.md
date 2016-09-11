# HDF5Kit

![Swift 3.0 compatible](https://img.shields.io/badge/Swift-3.0-orange.svg)
<!-- [![Build Status](https://travis-ci.org/aleph7/HDF5Kit.svg?branch=master)](https://travis-ci.org/aleph7/HDF5Kit) -->

This is a Swift wrapper for the [HDF5](https://www.hdfgroup.org) file format. HDF5 is used in the scientific comunity for managing large volumes of data. The objective is to make it easy to read and write HDF5 files from Swift, including playgrounds.


## Usage

This example shows how to open an existing HDF5 file and write data to an existing dataset.

```swift
import HDF5Kit

// Initialize the data
let dataWidth = 6
let dataHeight = 4
var data = [Double](repeating: 0.0, count: dataHeight * dataWidth)
for r in 0..<dataHeight {
    for c in 0..<dataWidth {
        data[r * dataWidth + c] = Double(r * dataWidth + c + 1)
    }
}

// Open an existing file
let path = "file.h5"
guard let file = File.open(path, mode: .readWrite) else {
    fatalError("Failed to open \(path)")
}

// Open an existing dataset
let datasetName = "dset"
guard let dataset = file.openDoubleDataset(datasetName) else {
    fatalError("Failed to open dataset \(datasetName)")
}

// Write the data
try dataset.write(data)
```

Reading data is really easy with HDF5Kit:

```swift
// Open an existing file
let path = "file.h5"
guard let file = File.open(path, mode: .readWrite) else {
    fatalError("Failed to open \(path)")
}

// Open an existing dataset
let datasetName = "dset"
guard let dataset = file.openStringDataset(datasetName) else {
    fatalError("Failed to open dataset \(datasetName)")
}

let data = dataset[1...3, 2...5]
```

Supported types are: `Double`, `Float`, `Int` and `String`.
