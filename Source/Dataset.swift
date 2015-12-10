// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

public class Dataset: Object {
    override init(id: Int32) {
        super.init(id: id)
    }

    /// The address in the file of the dataset or `nil` if the offset is undefined. That address is expressed as the offset in bytes from the beginning of the file.
    public var offset: Int? {
        let offset = H5Dget_offset(id)
        guard offset != unsafeBitCast(-1, UInt64.self) else {
            return nil
        }
        return Int(offset)
    }

    public var space: Dataspace {
        return Dataspace(id: H5Dget_space(id))
    }

    public var type: Datatype {
        return Datatype(id: H5Dget_type(id))
    }

    public var extent: [Int] {
        get {
            return space.dims
        }
        set {
            H5Dset_extent(id, ptr(newValue))
        }
    }

    /// Retrieves the size of chunks for the raw data of a chunked layout Dataset, or `nil` if the Dataset's layout is not chunked
    public var chunkSize: [Int]? {
        let plistId = H5Dget_create_plist(id)
        if H5Pget_layout(plistId) != H5D_CHUNKED {
            return nil
        }

        let rank = space.dims.count
        var chunkSize = [Int](count: rank, repeatedValue: 0)
        H5Pget_chunk(plistId, Int32(rank), ptr(&chunkSize))
        return chunkSize
    }

    /// Read data using an optional memory Dataspace and an optional file Dataspace
    ///
    /// - precondition: The `selectionSize` of the memory Dataspace is the same as for the file Dataspace and there is enough memory available for it
    public func readInto(pointer: UnsafeMutablePointer<Void>, type: NativeType, memSpace: Dataspace? = nil, fileSpace: Dataspace? = nil) throws {
        let status = H5Dread(id, type.rawValue, memSpace?.id ?? 0, fileSpace?.id ?? 0, 0, pointer)
        if status < 0 {
            throw Error.IOError
        }
    }

    /// Write data using an optional memory Dataspace and an optional file Dataspace
    ///
    /// - precondition: The `selectionSize` of the memory Dataspace is the same as for the file Dataspace
    public func writeFrom(pointer: UnsafePointer<Void>, type: NativeType, memSpace: Dataspace? = nil, fileSpace: Dataspace? = nil) throws {
        let status = H5Dwrite(id, type.rawValue, memSpace?.id ?? 0, fileSpace?.id ?? 0, 0, pointer);
        if status < 0 {
            throw Error.IOError
        }
    }
}


// MARK: GroupType extension for Dataset

extension GroupType {
    /// Create a Dataset
    public func createDataset(name: String, datatype: Datatype, dataspace: Dataspace) -> Dataset {
        let datasetID = name.withCString{ name in
            return H5Dcreate2(id, name, datatype.id, dataspace.id, 0, 0, 0)
        }
        return Dataset(id: datasetID)
    }

    /// Create a chunked Dataset
    public func createDataset(name: String, datatype: Datatype, dataspace: Dataspace, chunkDimensions: [Int]) -> Dataset? {
        precondition(dataspace.dims.count == chunkDimensions.count)

        let plist = H5Pcreate(H5P_CLS_DATASET_CREATE_ID_g)
        H5Pset_chunk(plist, Int32(chunkDimensions.count), ptr(chunkDimensions))
        defer {
            H5Pclose(plist)
        }

        let datasetID = name.withCString{ name in
            return H5Dcreate2(id, name, datatype.id, dataspace.id, 0, plist, 0)
        }
        return Dataset(id: datasetID)
    }

    /// Open an existing Dataset
    public func openDataset(name: String) -> Dataset? {
        let datasetID = name.withCString{ name in
            return H5Dopen2(id, name, 0)
        }
        guard datasetID >= 0 else {
            return nil
        }
        return Dataset(id: datasetID)
    }
}
