class tortank::base {
  include tortank::config
  include tortank::packages

  include tortank::cinnamon
  include tortank::zfs
  include tortank::steam
  include tortank::python
  include tortank::dconf
  include tortank::users

  class { "motd":
    template => "tortank/motd.erb",
  }

  class { tortank::autologin:
    user    => "guest",
    require => [Class["tortank::cinnamon"], Class["tortank::users"]]
  }
}

class tortank::packages::init {
  $debian_mirror = "http://httpredir.debian.org/debian"
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
    location   => "$debian_mirror",
    repos      => "main non-free contrib",
    release    => "stable",
    pin        => {
      priority => 550,
      release  => "stable",
    }
  }

  apt::source { "stable-updates":
    location => "$debian_mirror",
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
      priority => 1010,
      label    => "Debian-Security",
    }
  }

  apt::source { "unstable":
    location => "$debian_mirror",
    repos    => "main non-free contrib",
    release  => "unstable",
    pin        => {
      priority => 450,
      release  => "unstable",
    }
  }

  apt::source { "experimental":
    location => "$debian_mirror",
    repos    => "main non-free contrib",
    release  => "experimental",
    pin        => {
      priority => 200,
      release  => "experimental",
    }
  }

  apt::source { "google-chrome":
    location   => "[arch=amd64] http://dl.google.com/linux/chrome/deb/",
    repos      => "main",
    release    => "stable",
    key        => {
      "id"     => "A040830F7FAC5991",
      "server" => "keyserver.ubuntu.com",
    },
    include  => {
      'src' => false,
    }
  }
}

class tortank::packages {
  require tortank::packages::init

  $packages_uninstall = ["apt-listchange"]
  $packages_experimental = ["neovim"]
  $packages_unstable = ["libmsgpackc2"]
  $packages = [
    "git", "tig", "zsh", "tmux", "ranger", "make", "apt-file",
    "rxvt-unicode-256color", "google-chrome-stable",
  ]

  Package { ensure => installed }

  package { $packages_uninstall: ensure => purged, }

  package { $packages_unstable:
    install_options => ["-t", "unstable"],
    require  => Exec["apt_update"],
  } ->
  package { $packages_experimental:
    install_options => ["-t", "experimental"],
    require  => Exec["apt_update"],
  }

  package { $packages:
    require  => Exec["apt_update"],
  }

  file { "/usr/local/bin/vim":
    ensure  => "link",
    target  => "/usr/bin/nvim",
    require => Package["neovim"],
  }

  exec { "refresh apt-file":
    command => "apt-file update",
    path    => "/usr/bin/:/bin/",
    unless  => 'test -n "$(ls -A  /var/cache/apt/apt-file)"',
    require => Package["apt-file"],
  }

}

class tortank::python {
  require tortank::packages

  $packages = ["python-dev", "virtualenv", "ipython", "python-pip"]
  $packages_pip = ["pdbpp", "path.py"]
  Package { ensure => installed }


  package { $packages:
    install_options => ["--force-yes"],
    require         => Exec["apt_update"]
  }

  package { $packages_pip:
    provider => "pip",
    require  => Package["python-pip"]
  }
}

class tortank::config {
  class { "locales":
    default_locale  => "en_US.UTF-8",
    locales         => ["en_US.UTF-8 UTF-8", "fr_FR.UTF-8 UTF-8"],
  }

  class { tortank::keyboard:
    layout => "fr"
  }
}
