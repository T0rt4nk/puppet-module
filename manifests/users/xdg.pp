define tortank::users::xdg (
  $user = $title, $home, $xdg_dirs = {},
) {
  tortank::users::xdg::generate { $user:
    home => $home,
    xdg_dirs => $xdg_dirs,
  } ~>
  tortank::users::xdg::reload { $user:
  }
}

define tortank::users::xdg::generate (
  $user = $title, $home, $xdg_dirs,
) {
  $xdg_template = @(END)
  <% $xdg_dirs.each |$key, $value| { -%>
  XDG_<%= upcase($key) %>_DIR="<%= $value %>"
  <% } -%>
  | END

  File { owner => "$user", group => "$user" }

  $xdg_dirs_ = hash($xdg_dirs.map |$key, $value| {
    [$key, inline_epp(regsubst($value, '\$HOME', '<%= $home %>'))]
  })

  unique(values($xdg_dirs_)).each |$value| {
    file { $value: ensure => "directory" }
  }

  file { "$home/.config ensure for xdg":
    name   => "$home/.config",
    ensure => directory,
  }

  file { "$home/.config/user-dirs.dirs":
    content => inline_epp($xdg_template, $xdg_dirs),
  }
}

define tortank::users::xdg::reload ($user = $title) {
  exec { "update $user xdg dirs":
    command     => "/usr/bin/xdg-user-dirs-update",
    user        => $user,
    refreshonly => true,
  }
}
