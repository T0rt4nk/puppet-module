define tortank::users::vim (
  $user = $title, $home,
  $nvim_dir = "",
  $nvim_repo = "https://github.com/IxDay/.vim.git",
) {
  $nvim_dir_ = $nvim_dir ? { "" => "$home/.config/nvim", default => $nvim_dir }

  tortank::users::vim::init { $user: nvim_dir => $nvim_dir_, nvim_repo => $nvim_repo } ~>
  tortank::users::vim::install { $user: home  => $home }
}

define tortank::users::vim::init (
  $user = $title,
  $nvim_dir, $nvim_repo
) {
  $dir = dirname($nvim_dir)

  exec { "create $dir directory":
    user    => $user,
    command => "/bin/mkdir -p $dir",
    unless  => "/usr/bin/test -e $dir",
  } ->
  exec { "clone $user vim setup":
    cwd     => $dir,
    command => sprintf(
      "git clone --recursive %s %s", $nvim_repo, basename($nvim_dir)
    ),
    user   => $user,
    path   => "/usr/bin/:/bin/",
    unless => sprintf("test -e %s", basename($nvim_dir)),
  }
}

define tortank::users::vim::install (
  $user = $title, $home
) {
  exec { "Install vim plugins for $user":
    command     => "vim +PluginInstall +qall",
    path        => "/usr/bin/:/usr/local/bin/",
    cwd         => $home,
    environment => ["HOME=$home"],
    refreshonly => true,
    user        => $user
  }
}
