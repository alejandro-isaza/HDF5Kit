//  Copyright © 2015 Venture Media Labs. All rights reserved.

import Foundation

public class Dataspace {
    var id: Int32

    init(id: Int32) {
        self.id = id
        guard id >= 0 else {
            fatalError("Failed to create Dataspace")
        }
    }

    public init(dims: [UInt64]) {
        id = H5Screate_simple(Int32(dims.count), dims, nil)
        guard id >= 0 else {
            fatalError("Failed to create Dataspace")
        }
    }

    deinit {
        let status = H5Sclose(id)
        assert(status >= 0, "Failed to close Dataspace")
    }

    public var size: Int64 {
        return H5Sget_simple_extent_npoints(id)
    }

    public var dims: [UInt64] {
        let rank = Int(H5Sget_simple_extent_ndims(id))
        var dims = [UInt64](count: rank, repeatedValue: UInt64(0))
        guard H5Sget_simple_extent_dims(id, &dims, nil) >= 0 else {
            fatalError("Coulnd't get the dimensons of the Dataspace")
        }
        return dims
    }
}
