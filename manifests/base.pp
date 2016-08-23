class tortank::base {

  $packages_uninstall = ['apt-listchange']
  $packages_experimental = ['neovim']
  $packages = ['git', 'tig', 'zsh', 'tmux', 'apt-file', 'ranger', 'make']

  package { $packages_uninstall:
    ensure => purged,
  }

  package { $packages_experimental:
    ensure          => installed,
    install_options => ['-t', 'experimental'],
  }

  package { $packages:
    ensure => installed,
  }

  file { '/usr/local/bin/vim':
    ensure => 'link',
    target => '/usr/bin/nvim',
  }

  exec { 'refresh apt-file':
    command => 'apt-file update',
    path    => '/usr/bin/:/bin/',
    unless  => 'test -n "$(ls -A  /var/cache/apt/apt-file)"',
  }

  class { 'motd':
    template => 'tortank/motd.erb',
  }

  include tortank::python
  include tortank::users
}

class tortank::python {
  $packages = ['python-dev', 'virtualenv', 'ipython', 'python-pip']
  $packages_pip = ['pdbpp', 'path.py']

  package { $packages:
    ensure => installed,
  }

  package { $packages_pip:
    provider => 'pip',
    ensure   => installed,
  }
}

class tortank::users {
  include tortank::users::max
}
