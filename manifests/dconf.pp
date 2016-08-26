class tortank::dconf {
  class { tortank::dconf::install: } ->
  class { tortank::dconf::config: } ~>
  class { tortank::dconf::reload: }
}

class tortank::dconf::install {
  package { "dconf-cli":
    ensure  => present,
    require => Exec["apt_update"],
  }
}

class tortank::dconf::config {
  file { "/etc/dconf":
    ensure  => present,
    recurse => true,
    source  => "puppet:///modules/tortank/dconf",
  }
}

class tortank::dconf::reload {
  exec { "/usr/bin/dconf update":
    refreshonly => true;
  }
}
