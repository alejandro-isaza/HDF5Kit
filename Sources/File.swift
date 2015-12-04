// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import CHDF5

public class File {
    public enum CreateMode: UInt32 {
        case Truncate  = 0x02 // Overwrite existing files
        case Exclusive = 0x04 // Fail if file already exists
    }

    public enum OpenMode: UInt32 {
        case ReadOnly  = 0x00
        case ReadWrite = 0x01
    }

    public class func create(filePath: String, mode: CreateMode) -> File? {
        var id: Int32 = -1
        filePath.withCString { filePath in
            id = H5Fcreate(filePath, mode.rawValue, 0, 0)
        }
        guard id >= 0 else {
            return nil
        }
        return File(id: id)
    }

    public class func open(filePath: String, mode: OpenMode) -> File? {
        var id: Int32 = -1
        filePath.withCString { filePath in
            id = H5Fopen(filePath, mode.rawValue, 0)
        }
        guard id >= 0 else {
            return nil
        }
        return File(id: id)
    }

    var id: Int32 = -1

    init(id: Int32) {
        self.id = id
        guard id >= 0 else {
            fatalError("Failed to create HDF5 File")
        }
    }

    deinit {
        let status = H5Fclose(id)
        assert(status >= 0, "Failed to close HDF5 File")
    }

    public func flush() {
        H5Fflush(id, H5F_SCOPE_LOCAL)
    }

    /// Create a group
    public func createGroup(name: String) -> Group {
        let groupID = name.withCString{
            return H5Gcreate2(id, $0, 0, 0, 0)
        }
        return Group(id: groupID)
    }

    /// Open an existing group
    public func openGroup(name: String) -> Group? {
        let groupID = name.withCString{
            return H5Gopen2(id, $0, 0)
        }
        guard groupID >= 0 else {
            return nil
        }
        return Group(id: groupID)
    }

    /// Create a Dataset
    public func createDataset<T>(name: String, type: T.Type, dataspace: Dataspace) -> Dataset<T>? {
        guard let datatype = Datatype(type: type) else {
            return nil
        }
        return createDataset(name, datatype: datatype, dataspace: dataspace)
    }

    /// Create a Dataset
    public func createDataset<T>(name: String, datatype: Datatype, dataspace: Dataspace) -> Dataset<T> {
        let datasetID = name.withCString{ name in
            return H5Dcreate2(id, name, datatype.id, dataspace.id, 0, 0, 0)
        }
        return Dataset<T>(id: datasetID)
    }

    /// Create a chunked Dataset
    public func createDataset<T>(name: String, type: T.Type, dataspace: Dataspace, chunkDimensions: [Int]) -> Dataset<T>? {
        guard let datatype = Datatype(type: type) else {
            return nil
        }
        return createDataset(name, datatype: datatype, dataspace: dataspace, chunkDimensions: chunkDimensions)
    }

    /// Create a chunked Dataset
    public func createDataset<T>(name: String, datatype: Datatype, dataspace: Dataspace, chunkDimensions: [Int]) -> Dataset<T> {
        precondition(dataspace.dims.count == chunkDimensions.count)

        let plist = H5Pcreate(H5P_CLS_DATASET_CREATE_ID_g)
        H5Pset_chunk(plist, Int32(chunkDimensions.count), ptr(chunkDimensions))
        defer {
            H5Pclose(plist)
        }

        let datasetID = name.withCString{ name in
            return H5Dcreate2(id, name, datatype.id, dataspace.id, 0, plist, 0)
        }
        return Dataset<T>(id: datasetID)
    }

    /// Create a Double Dataset and write data
    public func createAndWriteDataset(name: String, dims: [Int], data: [Double]) -> Dataset<Double> {
        let space = Dataspace.init(dims: dims)
        let set = createDataset(name, type: Double.self, dataspace: space)!
        set.writeDouble(data)
        return set
    }

    /// Create an Int Dataset and write data
    public func createAndWriteDataset(name: String, dims: [Int], data: [Int]) -> Dataset<Int> {
        let space = Dataspace.init(dims: dims)
        let set = createDataset(name, type: Int.self, dataspace: space)!
        set.writeInt(data)
        return set
    }

    /// Open an existing Dataset
    public func openDataset<T>(name: String, type: T.Type) -> Dataset<T>? {
        let datasetID = name.withCString{ name in
            return H5Dopen2(id, name, 0)
        }
        guard datasetID >= 0 else {
            return nil
        }
        return Dataset<T>(id: datasetID)
    }

    /**
     Open an object in a file by path name.

     The object can be a group, dataset, or committed (named) datatype specified by a path name in an HDF5 file.

     - parameter name the path to the object
     */
    public func open(name: String) -> Object {
        let oid = name.withCString{ H5Oopen(id, $0, 0) }
        return Object(id: oid)
    }
}
