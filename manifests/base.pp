class tortank::base {
  include tortank::packages
  include tortank::cinnamon
  include tortank::python

  class { tortank::users:
    user          => "max",
    xdg_dirs      => {
      download    => '$HOME/downloads',
      templates   => '$HOME',
      publicshare => '$HOME',
      desktop     => '$HOME/desktop',
      documents   => '$HOME/documents',
      music       => '$HOME/music',
      pictures    => '$HOME/pictures',
      videos      => '$HOME/videos',
    }
  }
}

class tortank::packages {
  $packages_uninstall = ["apt-listchange"]
  $packages_experimental = ["neovim"]
  $packages = ["git", "tig", "zsh", "tmux", "apt-file", "ranger", "make"]

  class { "apt":
    purge => {
      "sources.list"   => true,
      "sources.list.d" => true,
      "preferences"    => true,
      "preferences.d"  => true,
    },
  }

  Apt::Source {
    include => {'deb' => true, 'src' => true}
  }

  apt::source { "stable":
    location   => "http://httpredir.debian.org/debian/",
    repos      => "main non-free contrib",
    release    => "stable",
    pin        => {
      priority => 550,
      release  => "stable",
    }
  }

  apt::source { "stable-updates":
    location => "http://httpredir.debian.org/debian/",
    repos    => "main non-free contrib",
    release  => "stable-updates",
    pin        => {
      priority => 650,
      release  => "stable-updates",
    }
  }

  apt::source { "stable-security":
    location   => "http://security.debian.org/",
    repos      => "main non-free contrib",
    release    => "stable/updates",
    pin        => {
      priority => 990,
      label    => "Debian-Security",
    }
  }

  apt::source { "unstable":
    location => "http://httpredir.debian.org/debian/",
    repos    => "main non-free contrib",
    release  => "unstable",
    pin        => {
      priority => 650,
      release  => "unstable",
    }
  }

  apt::source { "experimental":
    location => "http://httpredir.debian.org/debian/",
    repos    => "main non-free contrib",
    release  => "experimental",
    pin        => {
      priority => 200,
      release  => "experimental",
    }
  }

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

class tortank::cinnamon {
  $packages = [
    "xserver-xorg", "xserver-xorg-core", "xfonts-base",
    "xinit", "cinnamon-core", "lightdm", "libgl1-mesa-dri"
  ]

  package { $packages:
    ensure => installed,
  }

  file { "/etc/X11/xorg.conf.d/":
    ensure => absent,
    force  => true
  }
}
