class tortank::autologin (
  String $user,
) {
  File_line { path => "/etc/lightdm/lightdm.conf" }

  file_line { "lightdm.conf pam-service":
    match => '^#?pam-service\=',
    line  => "pam-service=lightdm",
  }

  file_line { "lightdm.conf pam-autologin-service":
    match => '^#?pam-autologin-service\=',
    line  => "pam-autologin-service=lightdm-autologin",
  }

  file_line { "lightdm.conf autologin-user":
    match => '^#?autologin-user\=',
    line  => "autologin-user=$user",
  }

  file_line { "lightdm.conf autologin-user-timeout":
    match => '^#?autologin-user-timeout\=',
    line  => "autologin-user-timeout=0",
  }

  group { "autologin":
    ensure  => present,
  } ->
  exec { "/usr/bin/gpasswd -a $user autologin": }
}
