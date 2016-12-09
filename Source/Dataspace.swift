// Copyright © 2015 Venture Media Labs. All rights reserved.
//
// This file is part of HDF5Kit. The full HDF5Kit copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

#if SWIFT_PACKAGE
    import CHDF5
#endif

public class Dataspace {
    var id: hid_t

    init(id: hid_t) {
        self.id = id
        guard id >= 0 else {
            fatalError("Failed to create Dataspace")
        }
        selectionDims = []
        selectionDims = dims
    }

    deinit {
        let status = H5Sclose(id)
        assert(status >= 0, "Failed to close Dataspace")
    }

    public internal(set) var selectionDims: [Int]

    /// Create a Dataspace
    public init(dims: [Int]) {
        let dims64 = dims.map({ unsafeBitCast(hssize_t($0), to: hsize_t.self) })
        id = dims64.withUnsafeBufferPointer { pointer in
            return H5Screate_simple(Int32(dims.count), pointer.baseAddress, nil)
        }
        guard id >= 0 else {
            fatalError("Failed to create Dataspace")
        }
        selectionDims = dims
    }

    /// Create a Dataspace for use in a chunked Dataset. No component of `maxDims` should be less than the corresponding element of `dims`. Elements of `maxDims` can have a value of -1, those dimension will have an unlimited size.
    public init(dims: [Int], maxDims: [Int]) {
        let dims64 = dims.map({ unsafeBitCast(hssize_t($0), to: hsize_t.self) })
        let maxDims64 = maxDims.map({ unsafeBitCast(hssize_t($0), to: hsize_t.self) })
        id = withExtendedLifetime((dims64, maxDims64)) {
            return H5Screate_simple(Int32(dims.count), dims64, maxDims64)
        }
        guard id >= 0 else {
            fatalError("Failed to create Dataspace")
        }
        selectionDims = dims
    }

    public convenience init(_ space: Dataspace) {
        self.init(id: H5Scopy(space.id))
    }

    /// The total number of elements in the Dataspace
    public var size: Int {
        let result = H5Sget_simple_extent_npoints(id)
        guard result >= 0 else {
            fatalError("Failed to get Dataspace size")
        }
        return Int(result)
    }

    /// The size of each dimension in the Dataspace
    public var dims: [Int] {
        let rank = Int(H5Sget_simple_extent_ndims(id))
        var dims = [hsize_t](repeating: 0, count: rank)
        dims.withUnsafeMutableBufferPointer { pointer in
            guard H5Sget_simple_extent_dims(id, pointer.baseAddress, nil) >= 0 else {
                fatalError("Coulnd't get the dimensons of the Dataspace")
            }
        }
        return dims.map({ Int(unsafeBitCast($0, to: hssize_t.self)) })
    }

    /// The maximum size of each dimension in the Dataspace
    public var maxDims: [Int] {
        let rank = Int(H5Sget_simple_extent_ndims(id))
        var maxDims = [hsize_t](repeating: 0, count: rank)
        maxDims.withUnsafeMutableBufferPointer { pointer in
            guard H5Sget_simple_extent_dims(id, nil, pointer.baseAddress) >= 0 else {
                fatalError("Coulnd't get the dimensons of the Dataspace")
            }
        }
        return maxDims.map({ Int(unsafeBitCast($0, to: hssize_t.self)) })
    }

    // MARK: - Selection

    public var hasValidSelection: Bool {
        return H5Sselect_valid(id) > 0
    }

    public var selectionSize: Int {
        return Int(H5Sget_select_npoints(id))
    }

    /// Selects the entire dataspace.
    public func selectAll() {
        H5Sselect_all(id)
        selectionDims = dims
    }

    /// Resets the selection region to include no elements.
    public func selectNone() {
        H5Sselect_none(id)
        for i in 0..<selectionDims.count {
            selectionDims[i] = 0
        }
    }

    /// Select a hyperslab region.
    ///
    /// - parameter start:  Specifies the offset of the starting element of the specified hyperslab.
    /// - parameter stride: Chooses array locations from the dataspace with each value in the stride array determining how many elements to move in each dimension. Stride values of 0 are not allowed. If the stride parameter is `nil`, a contiguous hyperslab is selected (as if each value in the stride array were set to 1).
    /// - parameter count:  Determines how many blocks to select from the dataspace, in each dimension.
    /// - parameter block:  Determines the size of the element block selected from the dataspace. If the block parameter is set to `nil`, the block size defaults to a single element in each dimension (as if each value in the block array were set to 1).
    public func select(start: [Int], stride: [Int]?, count: [Int]?, block: [Int]?) {
        let start64 = start.map({ unsafeBitCast(hssize_t($0), to: hsize_t.self) })
        let stride64 = stride?.map({ unsafeBitCast(hssize_t($0), to: hsize_t.self) })
        let count64 = count?.map({ unsafeBitCast(hssize_t($0), to: hsize_t.self) })
        let block64 = block?.map({ unsafeBitCast(hssize_t($0), to: hsize_t.self) })
        withExtendedLifetime((start64, stride64, count64, block64)) { () -> Void in
            H5Sselect_hyperslab(id, H5S_SELECT_SET, start64,  pointerOrNil(stride64), pointerOrNil(count64), pointerOrNil(block64))
        }
        selectionDims = count ?? dims
    }

    /// Select a hyperslab region.
    public func select(_ slices: HyperslabIndexType...) {
        select(slices)
    }

    /// Select a hyperslab region.
    public func select(_ slices: [HyperslabIndexType]) {
        let dims = self.dims
        let rank = dims.count
        var start = [Int](repeating: 0, count: rank)
        var stride = [Int](repeating: 1, count: rank)
        var count = [Int](repeating: 0, count: rank)
        var block = [Int](repeating: 1, count: rank)

        for (index, slice) in slices.enumerated() {
            start[index] = slice.start
            stride[index] = slice.stride
            if slice.blockCount != HyperslabIndex.all {
                count[index] = slice.blockCount
            } else {
                count[index] = dims[index] - slice.start
            }
            block[index] = slice.blockSize
        }

        select(start: start, stride: stride, count: count, block: block)
    }

    /// This function allows the same shaped selection to be moved to different locations within a dataspace without requiring it to be redefined.
    public func offset(_ offset: [Int]) {
        let offset64 = offset.map({ hssize_t($0) })
        offset64.withUnsafeBufferPointer { (pointer) -> Void in
            H5Soffset_simple(id, pointer.baseAddress)
        }
    }
}

func pointerOrNil(_ array: [hsize_t]?) -> UnsafePointer<hsize_t>? {
    if let array = array {
        return UnsafePointer(array)
    }
    return nil
}
