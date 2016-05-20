import PackageDescription

let package = Package(
    name: "HDF5Kit",
    dependencies: [
        .Package(url: "https://github.com/aleph7/CHDF5.git", majorVersion: 1)
    ]
)
