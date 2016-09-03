define tortank::users::base (
  String $user = $title,
  String $home = "",
  String $dev_dir = "",
  Hash $xdg_dirs = {},
  Boolean $dev = false,
) {
  require tortank::packages
  $home_ = $home ? { "" => "/home/$user", default => $home }

  tortank::users::base::init { $user:
    home => $home_
  } ->
  tortank::users::base::install { $user:
    home     => $home_,
    xdg_dirs => $xdg_dirs,
    dev      => $dev,
    dev_dir  => $dev_dir,
  } ->
  tortank::users::base::clean { $home_: }
}

define tortank::users::base::init (
  $user = $title, $home
) {
  user { "$user":
    shell      => "/usr/bin/zsh",
    ensure     => "present",
    managehome => true,
    home       => $home,
    password   => pw_hash(hiera("$user.password", undef), "SHA-512", fqdn_rand_string(8)),
  }
}

define tortank::users::base::install (
  $user = $title, $home, $xdg_dirs, $dev, $dev_dir,
) {
  tortank::users::xdg { $user: xdg_dirs => $xdg_dirs, home => $home }

  if $dev {
    if $dev_dir != "" {
      $dev_dir_ = $dev_dir
    } elsif $xdg_dirs["documents"] {
      $dev_dir_ = sprintf(
        "%s/development", regsubst($xdg_dirs["documents"], '\$HOME', $home)
      )
    } else {
      $dev_dir_ = "$home/Documents/Development"
    }

    tortank::users::vim { $user: home => $home }
    tortank::users::dotfiles { $user:
      dev_dir => $dev_dir_,
      home    => $home
    }
  }
}

define tortank::users::base::clean (
  $home = $title
) {
  $remove = [
    "$home/.bash_logout", "$home/.bashrc", "$home/.bash_history",
    "$home/.profile"
  ]

  file { $remove:
    ensure => "absent",
  }
}
