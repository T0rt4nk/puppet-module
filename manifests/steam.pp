class tortank::steam {

  Package { ensure => installed, require => Exec["apt_update"], }
  exec { "/usr/bin/dpkg --add-architecture i386":
  } ->
  package { "libtinfo5:i386":
    install_options => ["-t", "unstable"],
  } ->
  package { "steam":
  }
}
