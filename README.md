# NodeJS Puppet Module

This is a Puppet module for building NodeJS.

```puppet
class { 'nodejs':
  # required, the version of Node to build
  version => '0.10.2',
  # optional, where to store the source files
  src_dir => '/opt/node-src',
  # optional, where to install node
  bin_dir => '/opt/node',
}
```

It builds NodeJS from source. If you want to use the builtin
packages or Node's PPA, this is not the module for you.

After installation, the module creates the following symbolic links:

1. `${bin_dir}/${version}/bin/node` to `/usr/bin/node`
2. `${bin_dir}/${version}/bin/npm` to `/usr/bin/npm`
