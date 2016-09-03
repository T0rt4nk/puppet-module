define tortank::users::dotfiles (
  $user = $title, $dev_dir, $home,
) {

  tortank::users::dotfiles::init { $user:
    dev_dir => $dev_dir
  } ~>
  tortank::users::dotfiles::install { $user:
    dev_dir => $dev_dir,
    home => $home,
  }
}


define tortank::users::dotfiles::init (
  $user = $title, $dev_dir
) {
  file { $dev_dir:
    ensure => "directory",
     owner => $user,
     group => $user
  } ->
  exec { "clone $user dotfiles":
    cwd     => $dev_dir,
    user    => $user,
    command => "git clone --recursive https://github.com/IxDay/dotfiles.git",
    path    => "/usr/bin/:/bin/",
    unless  => "test -e dotfiles",
  }
}

define tortank::users::dotfiles::install (
  $user = $title, $dev_dir, $home
) {

  exec { "install $user dotfiles":
    cwd         => "$dev_dir/dotfiles",
    user        => $user,
    environment => ["HOME=$home"],
    command     => "/usr/bin/make",
    refreshonly => true,
  }
}
