class tortank::cinnamon {
  class { tortank::cinnamon::install: } ->
  class { tortank::cinnamon::config: } ~>
  class { tortank::cinnamon::reload: }
}

class tortank::cinnamon::install {
  $packages = [
    "xserver-xorg", "x11-xserver-utils", "xfonts-base", "xinit",
    "lightdm-gtk-greeter", "cinnamon-core", "libgl1-mesa-dri", "dmz-cursor-theme"
  ]
  $mint_packages = [
    "mint-themes", "mint-y-theme", "mint-y-icons"
  ]

  Package { ensure => installed }
  package { $packages:
    require         => Exec["apt_update"],
    install_options => ["-o", "Acquire::Retries=10"], # Long install need retries
  }


  apt::source { "mint":
    location   => "http://packages.linuxmint.com/",
    repos      => "main upstream import",
    release    => "sarah",
    key        => {
      id     => "302F0738F465C1535761F965A6616109451BBBF2",
      server => "keyserver.ubuntu.com",
    },
    pin        => {
      priority => 450,
      release  => "sarah",
    },
  }

  package { $mint_packages:
    require => [Apt::Source["mint"], Exec["apt_update"]],
  }
}

class tortank::cinnamon::config {

  file { "/etc/X11/xorg.conf.d/":
    ensure  => absent,
    force   => true,
  }

  file { "/usr/share/images/wallpaper.jpg":
    ensure => present,
    source => "puppet:///modules/tortank/wallpaper.jpg"
  }

  file_line { "lightdm-gtk-greeter.conf wallpaper":
    path  => "/etc/lightdm/lightdm-gtk-greeter.conf",
    line  => "background=/usr/share/images/wallpaper.jpg",
    match => '^#?background\=',
  }

  file_line { "lightdm-gtk-greeter.conf theme":
    path  => "/etc/lightdm/lightdm-gtk-greeter.conf",
    line  => "theme-name=Mint-Y",
    match => '^#?theme-name\=',
  }

  file_line { "lightdm-gtk-greeter.conf icons":
    path  => "/etc/lightdm/lightdm-gtk-greeter.conf",
    line  => "icon-theme-name=Mint-Y",
    match => '^#?icon-theme-name\=',
  }

  file_line { "lightdm-gtk-greeter.conf login":
    path  => "/etc/lightdm/lightdm-gtk-greeter.conf",
    line  => "position=5% -10%",
    match => '^#?position\=',
  }

  # This will not work, patch is not merged,
  # https://answers.launchpad.net/lightdm-gtk-greeter/+question/268888
  file_line { "lightdm-gtk-greeter.conf cursor":
    path  => "/etc/lightdm/lightdm-gtk-greeter.conf",
    line  => "cursor-theme-name=DMZ-White",
    match => '^#?cursor-theme-name\=',
  }

  file_line { "set grub background":
    path => "/etc/default/grub",
    line => "GRUB_BACKGROUND=/usr/share/images/wallpaper.jpg"
  }

  file { "/boot/grub/custom.cfg":
    ensure => present,
    source => "puppet:///modules/tortank/max_grub_theme",
    mode   => "755",
  }
}

class tortank::cinnamon::reload {
  exec { "/usr/sbin/update-grub":
    refreshonly => true
  }
}
