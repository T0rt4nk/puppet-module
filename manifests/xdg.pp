class  tortank::xdg (
  $user = $tortank::xdg::params::user,
) inherits tortank::xdg::params {
  validate_string($user)

  anchor { 'tortank::xdg::begin': } ->
  class { '::tortank::xdg::install': } ->
  anchor { 'tortank::xdg::end': }

}

class tortank::xdg::params {
  $user = undef
}

class tortank::xdg::install inherits tortank::xdg {
  file { '/tmp/toto':
    ensure  => 'present',
    content => 'toto titi',
  }
}

