class nodejs (
  $version,
  $src_dir = '/opt/node-src',
  $bin_dir = '/opt/node',
) {
  include gcc

  # https://github.com/joyent/node/wiki/Installation#building-on-gnulinux-and-other-unix

  anchor { 'nodejs::begin':
      before => File[$src_dir]
  }

  $tarball_file = "node-v${version}.tar.gz"
  $tarball_url = "http://nodejs.org/dist/v${version}/${tarball_file}"
  $tarball_path = "${src_dir}/${tarball_file}"
  $target_src_dir = "${src_dir}/node-v${version}"
  $target_bin_dir = "${bin_dir}/v${version}"

  file { $src_dir:
    ensure => directory,
    owner => root,
    group => root
  }

  exec { 'get-nodejs-pkg':
    command => "wget --output-document ${tarball_path} ${tarball_url}",
    unless  => "test -f ${tarball_path}",
    require => File[$src_dir],
  }

  exec { 'unpack-nodejs':
    command => "tar -xzf ${tarball_path}",
    cwd     => $src_dir,
    unless  => "test -f ${target_src_dir}/Makefile",
    require => Exec['get-nodejs-pkg'],
  }

  exec { 'install-nodejs':
    command => "${target_src_dir}/configure --prefix=${target_bin_dir} && make && make install",
    cwd     => $target_src_dir,
    unless  => "test `${target_bin_dir}/bin/node --version` = 'v${version}'",
    require => [ Exec['unpack-nodejs'], Class['gcc'] ],
    timeout => 0, # this can take a long time
  }

  file { 'nodejs-symlink':
    ensure => link,
    path => '/usr/bin/node',
    target => "${target_bin_dir}/bin/node",
    require => Exec['install-nodejs']
  }
  file { 'npm-symlink':
    ensure => link,
    path => '/usr/bin/npm',
    target => "${target_bin_dir}/bin/npm",
    require => Exec['install-nodejs']
  }

  anchor { 'nodejs::end':
    require => [ File['nodejs-symlink'], File['npm-symlink'] ],
  }
}