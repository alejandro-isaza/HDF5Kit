// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

#if SWIFT_PACKAGE
    import CHDF5
#endif

open class Dataset: Object {
    /// The address in the file of the dataset or `nil` if the offset is undefined. That address is expressed as the offset in bytes from the beginning of the file.
    public var offset: Int? {
        let offset = H5Dget_offset(id)
        guard offset != unsafeBitCast(Int64(-1), to: UInt64.self) else {
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
            let array = newValue.map({ unsafeBitCast(hssize_t($0), to: hsize_t.self) })
            array.withUnsafeBufferPointer { (pointer) -> Void in
                H5Dset_extent(id, pointer.baseAddress)
            }
        }
    }

    /// Retrieves the size of chunks for the raw data of a chunked layout Dataset, or `nil` if the Dataset's layout is not chunked
    public var chunkSize: [Int]? {
        let plistId = H5Dget_create_plist(id)
        if H5Pget_layout(plistId) != H5D_CHUNKED {
            return nil
        }

        let rank = space.dims.count
        var chunkSize = [hsize_t](repeating: 0, count: rank)
        chunkSize.withUnsafeMutableBufferPointer { (pointer: inout UnsafeMutableBufferPointer<hsize_t>) -> Void in
            H5Pget_chunk(plistId, Int32(rank), pointer.baseAddress)
        }
        return chunkSize.map({ Int(unsafeBitCast($0, to: hssize_t.self)) })
    }

    /// Read data using an optional memory Dataspace and an optional file Dataspace
    ///
    /// - precondition: The `selectionSize` of the memory Dataspace is the same as for the file Dataspace and there is enough memory available for it
    open func read(into pointer: UnsafeMutableRawPointer, type: NativeType, memSpace: Dataspace? = nil, fileSpace: Dataspace? = nil) throws {
        let status = H5Dread(id, type.rawValue, memSpace?.id ?? 0, fileSpace?.id ?? 0, 0, pointer)
        if status < 0 {
            throw Error.ioError
        }
    }

    /// Write data using an optional memory Dataspace and an optional file Dataspace
    ///
    /// - precondition: The `selectionSize` of the memory Dataspace is the same as for the file Dataspace
    open func write(from pointer: UnsafeRawPointer, type: NativeType, memSpace: Dataspace? = nil, fileSpace: Dataspace? = nil) throws {
        let status = H5Dwrite(id, type.rawValue, memSpace?.id ?? 0, fileSpace?.id ?? 0, 0, pointer);
        if status < 0 {
            throw Error.ioError
        }
    }
}


// MARK: GroupType extension for Dataset

extension GroupType {
    /// Create a Dataset
    public func createDataset(_ name: String, datatype: Datatype, dataspace: Dataspace) -> Dataset {
        let datasetID = name.withCString{ name in
            return H5Dcreate2(id, name, datatype.id, dataspace.id, 0, 0, 0)
        }
        return Dataset(id: datasetID)
    }

    /// Create a chunked Dataset
    public func createDataset(_ name: String, datatype: Datatype, dataspace: Dataspace, chunkDimensions: [Int]) -> Dataset? {
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
        return Dataset(id: datasetID)
    }

    /// Open an existing Dataset
    public func openDataset(_ name: String) -> Dataset? {
        let datasetID = name.withCString{ name in
            return H5Dopen2(id, name, 0)
        }
        guard datasetID >= 0 else {
            return nil
        }
        return Dataset(id: datasetID)
    }
}
