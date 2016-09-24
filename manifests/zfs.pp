class tortank::zfs {
  class { tortank::zfs::install: } ->
  class { tortank::zfs::config: } ->
  class { tortank::zfs::service: }
}

class tortank::zfs::install {
  package { "zfs-dkms":
    ensure  => installed,
    require => Exec["apt_update"],
  }

  file { "/mnt/data":
    ensure => directory
  }
}

class tortank::zfs::config {
  zpool { "bigdata":
    ensure => present,
    raidz  => join([
      "ata-WDC_WD2002FAEX-007BA0_WD-WMAY01162723",
      "ata-WDC_WD2003FZEX-00SRLA0_WD-WMC6N0D2JFSP",
      "ata-WDC_WD2003FZEX-00Z4SA0_WD-WMC130F4VSU6",
    ], " ")
  } ->
  zfs { "bigdata":
    ensure     => present,
    mountpoint => "/mnt/data",
    atime      => "off",
  }

  file { "/etc/systemd/system/zfs-scrub@.service":
    ensure  => present,
    source => "puppet:///modules/tortank/zfs-scrub@.service",
  }

  file { "/etc/systemd/system/scrub-bigdata.timer":
    ensure  => present,
    source => "puppet:///modules/tortank/scrub-bigdata.timer",
  }
}

class tortank::zfs::service {
  service { 'scrub-bigdata.timer':
    ensure => running,
    enable => true,
  }
}
