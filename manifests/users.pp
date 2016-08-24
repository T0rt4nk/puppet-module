class tortank::users (String $user) {
  $home = "/home/$user"

  $dev_dir = "$home/development"
  $remove = ["$home/.bash_logout", "$home/.bashrc"]
  $xdg_dirs = {
    desktop   => '',
    downloads => '$HOME/downloads',
    templates => '',
    public    => '',
    documents => '$HOME/documents',
    music     => '$HOME/music',
    pictures  => '$HOME/pictures',
    videos    => '$HOME/videos',
  }

  Exec { user  => "$user" }
  File { owner => "$user", group => "$user" }

  user { "$user":
    shell      => "/usr/bin/zsh",
    ensure     => "present",
    managehome => true,
    password   => hiera("$user.password"),
  }

  file { $remove:
    ensure => "absent",
  }

  file { $dev_dir:
    ensure => "directory",
  }

  exec { "clone $user dotfiles":
    cwd     => $dev_dir,
    command => "git clone --recursive https://github.com/IxDay/dotfiles",
    path    => "/usr/bin/:/bin/",
    unless  => "test -e dotfiles",
    notify  => Exec["install $user dotfiles"],
  }

  exec { "install $user dotfiles":
    cwd         => "$dev_dir/dotfiles",
    environment => ["HOME=$home"],
    command     => "/usr/bin/make",
    refreshonly => true,
  }

  #$xdg_dirs.each |$key, $value| {
  #  file { $value:
  #    ensure => "directory",
  #  }
    #}

}
