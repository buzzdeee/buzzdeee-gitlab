# This defined type configures
# a repo to mirror remotely on pushes
# The repo itself should already exists by other means

define gitlab::mirror (
  $repopath,
  $url,
  $fetch = '+refs/*:refs/*',
  $mirror = 'true',
  $gitlab_repositories_path = $::gitlab::gitlab_repositories_path,
  $user = $::gitlab::gitlab_user,
  $group = $::gitlab::gitlab_group,
) {

  require gitlab

  file { "${gitlab_repositories_path}/${repopath}.git/custom_hooks/":
    ensure => 'directory',
    owner  => $user,
    group  => $group,
    mode   => '0755',
  }

  file { "${gitlab_repositories_path}/${repopath}.git/custom_hooks/post-receive":
    owner => $user,
    group => $group,
    mode  => '0755',
    content => "exec git push --quiet ${title} &",
  }

  ini_setting { "${repopath}_remote_${title}_url":
    ensure  => present,
    path    => "${gitlab_repositories_path}/${repopath}.git/config",
    section => "remote \"$title\"",
    setting => 'url',
    value   => $url,
  }
  ini_setting { "${repopath}_remote_${title}_fetch":
    ensure  => present,
    path    => "${gitlab_repositories_path}/${repopath}.git/config",
    section => "remote \"$title\"",
    setting => 'fetch',
    value   => $fetch,
  }
  ini_setting { "${repopath}_remote_${title}_mirror":
    ensure  => present,
    path    => "${gitlab_repositories_path}/${repopath}.git/config",
    section => "remote \"$title\"",
    setting => 'mirror',
    value   => $mirror,
  }

}
