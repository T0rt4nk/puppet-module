class tortank::users::max {
  $home = "/home/max"
  $dev_dir = "$home/development"
  $remove = ["$home/.bash_logout", "$home/.bashrc"]


  user { 'max':
    ensure   => 'present',
    home     => '/home/max',
    shell    => '/usr/bin/zsh',
    password => hiera('max.password'),
  }

  file { $remove:
    ensure => 'absent',
  }

  file { $dev_dir:
    ensure => 'directory',
    owner  => 'max'
  }

  exec { 'clone max dotfiles':
    cwd     => $dev_dir,
    command => 'git clone --recursive https://github.com/IxDay/dotfiles',
    path    => '/usr/bin/:/bin/',
    unless  => 'test -e dotfiles',
    user    => 'max',
    notify  => Exec['install max dotfiles'],
  }

  exec { 'install max dotfiles':
    cwd         => "$dev_dir/dotfiles",
    environment => ['HOME=/home/max'],
    command     => '/usr/bin/make',
    user        => 'max',
    refreshonly => true,
  }

  class { 'tortank::xdg':
    user => 'max'
  }
}
