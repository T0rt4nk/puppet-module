class tortank::keyboard (
  $model     = "pc105",
  $layout    = "us",
  $variant   = "",
  $options   = "",
  $backspace = "guess"
) {
  anchor { "tortank::keyboard::begin": } ->
  class { "tortank::keyboard::install": } ->
  class { "tortank::keyboard::config": } ~>
  class { "tortank::keyboard::reload": } ->
  anchor { "tortank::keyboard::end": }
}


class tortank::keyboard::install {
  package { "keyboard-configuration":
    ensure => present
  }
}

class tortank::keyboard::config inherits tortank::keyboard {
  $template = @(END)
  # KEYBOARD CONFIGURATION FILE
  # Consult the keyboard(5) manual page.
  XKBMODEL="<%= $model %>"
  XKBLAYOUT="<%= $layout %>"
  XKBVARIANT="<%= $variant %>"
  XKBOPTIONS="<%= $options %>"
  BACKSPACE="<%= $backspace %>"
  | END

  file { "/etc/default/keyboard":
    content => inline_epp($template)
  }
}

class tortank::keyboard::reload {
  exec { "apply-keyboard-configuration":
    command     => "/usr/sbin/dpkg-reconfigure -f noninteractive keyboard-configuration",
    refreshonly => true
  }
}
