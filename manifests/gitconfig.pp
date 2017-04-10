# This class takes care to configure the
# global git settings of the gitlab user
class gitlab::gitconfig (
  $gitlab_user = $::gitlab::gitlab_user,
) {
  git::config { 'core.autocrlf':
    user    => $gitlab_user,
    value   => 'input',
    require => User[$gitlab_user],
  }
  git::config { 'gc.auto':
    user    => $gitlab_user,
    value   => '0',
    require => User[$gitlab_user],
  }
  git::config { 'repack.writeBitmaps':
    user    => $gitlab_user,
    value   => 'true',  # lint:ignore:quoted_booleans
    require => User[$gitlab_user],
  }
}
