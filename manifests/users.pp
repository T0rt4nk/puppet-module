class tortank::users {
  $xdg_dirs = {
    download    => '$HOME/downloads',
    templates   => '$HOME',
    publicshare => '$HOME',
    desktop     => '$HOME/desktop',
    documents   => '$HOME/documents',
    music       => '$HOME/music',
    pictures    => '$HOME/pictures',
    videos      => '$HOME/videos',
  }

  tortank::users::base { "max":
    xdg_dirs => $xdg_dirs,
    dev      => true
  }

  tortank::users::base { "guest":
    xdg_dirs  => {
      templates   => '$HOME',
      publicshare => '$HOME',
    }
  }
}
