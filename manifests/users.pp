class tortank::users (
  String $user = "",
  String $home = "",
  Hash $xdg_dirs = {},
) {
  if $user == "" { $user_ = "guest" } else { $user_ = $user }
  if $home == "" { $home_ = "/home/$user" } else { $home_ = $home }

  $xdg_dirs_ = hash($xdg_dirs.map |$key, $value| {
    [$key, inline_epp(regsubst($value, '\$HOME', '<%= $home_ %>'))]
  })

  $dev_dir = sprintf("%s/development", $xdg_dirs_["documents"])
  $remove = ["$home_/.bash_logout", "$home_/.bashrc"]

  $xdg_template = @(END)
  <% $xdg_dirs.each |$key, $value| { -%>
  XDG_<%= upcase($key) %>_DIR="<%= $value %>"
  <% } -%>
  | END

  Exec { user  => "$user_" }
  File { owner => "$user_", group => "$user_" }

  user { "$user_":
    shell      => "/usr/bin/zsh",
    ensure     => "present",
    managehome => true,
    password   => pw_hash(hiera("$user_.password"), "SHA-512", fqdn_rand_string(8)),
  }

  file { $remove:
    ensure => "absent",
  }

  file { $dev_dir:
    ensure => "directory",
  }

  exec { "clone $user_ dotfiles":
    cwd     => $dev_dir,
    command => "git clone --recursive https://github.com/IxDay/dotfiles",
    path    => "/usr/bin/:/bin/",
    unless  => "test -e dotfiles",
    notify  => Exec["install $user_ dotfiles"],
  }

  exec { "install $user_ dotfiles":
    cwd         => "$dev_dir/dotfiles",
    environment => ["HOME=$home_"],
    command     => "/usr/bin/make",
    refreshonly => true,
  }

  unique(values($xdg_dirs_)).each |$value| {
    file { $value: ensure => "directory" }
  }

  file { "$home_/.config/user-dirs.dirs":
    content => inline_epp($xdg_template, $xdg_dirs),
    notify  => Exec["update $user_ xdg dirs"],
  }

  exec { "update $user_ xdg dirs":
    command     => "/usr/bin/xdg-user-dirs-update",
    refreshonly => true,
  }

}
