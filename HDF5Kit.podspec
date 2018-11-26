version = `git describe --long --tags | cut -f 1 -d '-'`.chomp

Pod::Spec.new do |s|
  s.name         = 'HDF5Kit'
  s.version      = version
  s.summary      = 'Swift wrapper for HDF5'
  s.homepage     = 'https://github.com/aleph7/HDF5Kit'
  s.license      = 'MIT'
  s.author       = { 'Alejandro Isaza' => 'al@isaza.ca' }

  s.osx.deployment_target = '10.10'
  s.ios.deployment_target = '8.0'
  #s.tvos.deployment_target = '9.0'
  s.swift_version = '4.0'

  s.source        = { git: 'https://github.com/aleph7/HDF5Kit.git', tag: version }
  s.source_files  = 'Source', 'dist/src/*.{c,h}',
  s.exclude_files = 'dist/src/H5detect.c'

  s.public_header_files = 'dist/src/*public.h',
                          'dist/src/H5Epubgen.h',
                          'dist/src/H5api_adpt.h',
                          'dist/src/H5version.h',
                          'dist/src/H5pubconf.h'
  s.private_header_files = 'dist/src/*private.h'

  s.library = 'z'
end
