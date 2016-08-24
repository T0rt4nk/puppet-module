class tortank::base {

  $packages_uninstall = ["apt-listchange"]
  $packages_experimental = ["neovim"]
  $packages = ["git", "tig", "zsh", "tmux", "apt-file", "ranger", "make"]

  package { $packages_uninstall:
    ensure => purged,
  }

  package { $packages_experimental:
    ensure          => installed,
    install_options => ["-t", "experimental"],
  }

  package { $packages:
    ensure => installed,
  }

  file { "/usr/local/bin/vim":
    ensure => "link",
    target => "/usr/bin/nvim",
  }

  exec { "refresh apt-file":
    command => "apt-file update",
    path    => "/usr/bin/:/bin/",
    unless  => 'test -n "$(ls -A  /var/cache/apt/apt-file)"',
  }

  class { "motd":
    template => "tortank/motd.erb",
  }

  include tortank::python

  class { tortank::users:
    user          => "max",
    xdg_dirs      => {
      download    => '$HOME/downloads',
      templates   => '$HOME',
      publicshare => '$HOME',
      desktop     => '$HOME',
      documents   => '$HOME/documents',
      music       => '$HOME/music',
      pictures    => '$HOME/pictures',
      videos      => '$HOME/videos',
    }
  }
}

class tortank::python {
  $packages = ["python-dev", "virtualenv", "ipython", "python-pip"]
  $packages_pip = ["pdbpp", "path.py"]

  package { $packages:
    ensure => installed,
  }

  package { $packages_pip:
    provider => "pip",
    ensure   => installed,
  }
}
