// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

public class FloatDataset: Dataset {
    public subscript(slices: HyperslabIndexType...) -> [Float] {
        // There is a problem with Swift where it gives a compiler error if `set` is implemented here
        return (try? read(slices)) ?? []
    }

    public subscript(slices: [HyperslabIndexType]) -> [Float] {
        get {
            return (try? read(slices)) ?? []
        }
        set {
            try! write(newValue, to: slices)
        }
    }

    public func read(slices: [HyperslabIndexType]) throws -> [Float] {
        let filespace = space
        filespace.select(slices)
        return try read(memSpace: Dataspace(dims: filespace.selectionDims), fileSpace: filespace)
   }

    public func write(data: [Float], to slices: [HyperslabIndexType]) throws {
        let filespace = space
        filespace.select(slices)
        try write(data, memSpace: Dataspace(dims: filespace.selectionDims), fileSpace: filespace)
    }

    /// Append data to the table
    public func append(data: [Float], dimensions: [Int], axis: Int = 0) throws {
        let oldExtent = extent
        extent[axis] += dimensions[axis]
        for (index, dim) in dimensions.enumerate() {
            if dim > oldExtent[index] {
                extent[index] = dim
            }
        }

        var start = [Int](count: oldExtent.count, repeatedValue: 0)
        start[axis] = oldExtent[axis]

        let fileSpace = space
        fileSpace.select(start: start, stride: nil, count: dimensions, block: nil)

        try write(data, memSpace: Dataspace(dims: dimensions), fileSpace: fileSpace)
    }

    /// Read data using an optional memory Dataspace and an optional file Dataspace
    ///
    /// - precondition: The `selectionSize` of the memory Dataspace is the same as for the file Dataspace
    public func read(memSpace memSpace: Dataspace? = nil, fileSpace: Dataspace? = nil) throws -> [Float] {
        let size: Int
        if let memspace = memSpace {
            size = memspace.size
        } else if let filespace = fileSpace {
            size = filespace.selectionSize
        } else {
            size = space.selectionSize
        }

        var result = [Float](count: size, repeatedValue: 0.0)
        try result.withUnsafeMutableBufferPointer() { (inout pointer: UnsafeMutableBufferPointer) in
            try readInto(pointer.baseAddress, memSpace: memSpace, fileSpace: fileSpace)
        }
        return result
    }

    /// Read data using an optional memory Dataspace and an optional file Dataspace
    ///
    /// - precondition: The `selectionSize` of the memory Dataspace is the same as for the file Dataspace and there is enough memory available for it
    public func readInto(pointer: UnsafeMutablePointer<Float>, memSpace: Dataspace? = nil, fileSpace: Dataspace? = nil) throws {
        try super.readInto(pointer, type: .Float, memSpace: memSpace, fileSpace: fileSpace)
    }

    /// Write data using an optional memory Dataspace and an optional file Dataspace
    ///
    /// - precondition: The `selectionSize` of the memory Dataspace is the same as for the file Dataspace and the same as `data.count`
    public func write(data: [Float], memSpace: Dataspace? = nil, fileSpace: Dataspace? = nil) throws {
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
            try writeFrom(bufferPointer.baseAddress, memSpace: memSpace, fileSpace: fileSpace)
        }
    }

    /// Write data using an optional memory Dataspace and an optional file Dataspace
    ///
    /// - precondition: The `selectionSize` of the memory Dataspace is the same as for the file Dataspace
    public func writeFrom(pointer: UnsafePointer<Float>, memSpace: Dataspace? = nil, fileSpace: Dataspace? = nil) throws {
        try super.writeFrom(pointer, type: .Float, memSpace: memSpace, fileSpace: fileSpace)
    }
}


// MARK: GroupType extension for FloatDataset

extension GroupType {
    /// Create a FloatDataset
    public func createFloatDataset(name: String, dataspace: Dataspace) -> FloatDataset? {
        guard let datatype = Datatype(type: Float.self) else {
            return nil
        }
        let datasetID = name.withCString{ name in
            return H5Dcreate2(id, name, datatype.id, dataspace.id, 0, 0, 0)
        }
        return FloatDataset(id: datasetID)
    }

    /// Create a chunked FloatDataset
    public func createFloatDataset(name: String, dataspace: Dataspace, chunkDimensions: [Int]) -> FloatDataset? {
        guard let datatype = Datatype(type: Float.self) else {
            return nil
        }
        precondition(dataspace.dims.count == chunkDimensions.count)

        let plist = H5Pcreate(H5P_CLS_DATASET_CREATE_ID_g)
        let chunkDimensions64 = chunkDimensions.map({ hsize_t($0) })
        chunkDimensions64.withUnsafeBufferPointer { pointer in
            H5Pset_chunk(plist, Int32(chunkDimensions.count), pointer.baseAddress)
        }
        defer {
            H5Pclose(plist)
        }

        let datasetID = name.withCString{ name in
            return H5Dcreate2(id, name, datatype.id, dataspace.id, 0, plist, 0)
        }
        return FloatDataset(id: datasetID)
    }

    /// Create a Float Dataset and write data
    public func createAndWriteDataset(name: String, dims: [Int], data: [Float]) throws -> FloatDataset {
        let space = Dataspace.init(dims: dims)
        let set = createFloatDataset(name, dataspace: space)!
        try set.write(data)
        return set
    }

    /// Open an existing FloatDataset
    public func openFloatDataset(name: String) -> FloatDataset? {
        let datasetID = name.withCString{ name in
            return H5Dopen2(id, name, 0)
        }
        guard datasetID >= 0 else {
            return nil
        }
        return FloatDataset(id: datasetID)
    }
}
