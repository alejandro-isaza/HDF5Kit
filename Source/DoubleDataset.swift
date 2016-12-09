// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

#if SWIFT_PACKAGE
    import CHDF5
#endif

public class DoubleDataset: Dataset {
    public subscript(slices: HyperslabIndexType...) -> [Double] {
        // There is a problem with Swift where it gives a compiler error if `set` is implemented here
        return (try? read(slices)) ?? []
    }

    public subscript(slices: [HyperslabIndexType]) -> [Double] {
        get {
            return (try? read(slices)) ?? []
        }
        set {
            try! write(newValue, to: slices)
        }
    }
    
    public func read(_ slices: [HyperslabIndexType]) throws -> [Double] {
        let filespace = space
        filespace.select(slices)
        return try read(memSpace: Dataspace(dims: filespace.selectionDims), fileSpace: filespace)
    }

    public func write(_ data: [Double], to slices: [HyperslabIndexType]) throws {
        let filespace = space
        filespace.select(slices)
        try write(data, memSpace: Dataspace(dims: filespace.selectionDims), fileSpace: filespace)
    }

    /// Append data to the table
    public func append(_ data: [Double], dimensions: [Int], axis: Int = 0) throws {
        let oldExtent = extent
        extent[axis] += dimensions[axis]
        for (index, dim) in dimensions.enumerated() {
            if dim > oldExtent[index] {
                extent[index] = dim
            }
        }

        var start = [Int](repeating: 0, count: oldExtent.count)
        start[axis] = oldExtent[axis]

        let fileSpace = space
        fileSpace.select(start: start, stride: nil, count: dimensions, block: nil)

        try write(data, memSpace: Dataspace(dims: dimensions), fileSpace: fileSpace)
    }

    /// Read data using an optional memory Dataspace and an optional file Dataspace
    ///
    /// - precondition: The `selectionSize` of the memory Dataspace is the same as for the file Dataspace
    public func read(memSpace: Dataspace? = nil, fileSpace: Dataspace? = nil) throws -> [Double] {
        let size: Int
        if let memspace = memSpace {
            size = memspace.size
        } else if let filespace = fileSpace {
            size = filespace.selectionSize
        } else {
            size = space.selectionSize
        }

        var result = [Double](repeating: 0.0, count: size)
        try result.withUnsafeMutableBufferPointer() { (pointer: inout UnsafeMutableBufferPointer) in
            try read(into: pointer.baseAddress!, memSpace: memSpace, fileSpace: fileSpace)
        }
        return result
    }

    /// Read data using an optional memory Dataspace and an optional file Dataspace
    ///
    /// - precondition: The `selectionSize` of the memory Dataspace is the same as for the file Dataspace and there is enough memory available for it
    public func read(into pointer: UnsafeMutablePointer<Double>, memSpace: Dataspace? = nil, fileSpace: Dataspace? = nil) throws {
        try super.read(into: pointer, type: .double, memSpace: memSpace, fileSpace: fileSpace)
    }

    /// Write data using an optional memory Dataspace and an optional file Dataspace
    ///
    /// - precondition: The `selectionSize` of the memory Dataspace is the same as for the file Dataspace and the same as `data.count`
    public func write(_ data: [Double], memSpace: Dataspace? = nil, fileSpace: Dataspace? = nil) throws {
        let size: Int
        if let memspace = memSpace {
            size = memspace.size
        } else if let filespace = fileSpace {
            size = filespace.selectionSize
        } else {
            size = space.selectionSize
        }
        precondition(data.count == size, "Data size doesn't match Dataspace dimensions")

        try data.withUnsafeBufferPointer() { bufferPointer in
            try write(from: bufferPointer.baseAddress!, memSpace: memSpace, fileSpace: fileSpace)
        }
    }

    /// Write data using an optional memory Dataspace and an optional file Dataspace
    ///
    /// - precondition: The `selectionSize` of the memory Dataspace is the same as for the file Dataspace
    public func write(from pointer: UnsafePointer<Double>, memSpace: Dataspace? = nil, fileSpace: Dataspace? = nil) throws {
        try super.write(from: pointer, type: .double, memSpace: memSpace, fileSpace: fileSpace)
    }
}


// MARK: GroupType extension for DoubleDataset

extension GroupType {
    /// Create a DoubleDataset
    public func createDoubleDataset(_ name: String, dataspace: Dataspace) -> DoubleDataset? {
        guard let datatype = Datatype(type: Double.self) else {
            return nil
        }
        let datasetID = name.withCString{ name in
            return H5Dcreate2(id, name, datatype.id, dataspace.id, 0, 0, 0)
        }
        return DoubleDataset(id: datasetID)
    }

    /// Create a chunked DoubleDataset
    public func createDoubleDataset(_ name: String, dataspace: Dataspace, chunkDimensions: [Int]) -> DoubleDataset? {
        guard let datatype = Datatype(type: Double.self) else {
            return nil
        }
        precondition(dataspace.dims.count == chunkDimensions.count)

        let plist = H5Pcreate(H5P_CLS_DATASET_CREATE_ID_g)
        let chunkDimensions64 = chunkDimensions.map({ unsafeBitCast(hssize_t($0), to: hsize_t.self) })
        chunkDimensions64.withUnsafeBufferPointer { (pointer) -> Void in
            H5Pset_chunk(plist, Int32(chunkDimensions.count), pointer.baseAddress)
        }
        defer {
            H5Pclose(plist)
        }

        let datasetID = name.withCString{ name in
            return H5Dcreate2(id, name, datatype.id, dataspace.id, 0, plist, 0)
        }
        return DoubleDataset(id: datasetID)
    }

    /// Create a Double Dataset and write data
    public func createAndWriteDataset(_ name: String, dims: [Int], data: [Double]) throws -> DoubleDataset {
        let space = Dataspace.init(dims: dims)
        let set = createDoubleDataset(name, dataspace: space)!
        try set.write(data)
        return set
    }

    /// Open an existing DoubleDataset
    public func openDoubleDataset(_ name: String) -> DoubleDataset? {
        let datasetID = name.withCString{ name in
            return H5Dopen2(id, name, 0)
        }
        guard datasetID >= 0 else {
            return nil
        }
        return DoubleDataset(id: datasetID)
    }
}
