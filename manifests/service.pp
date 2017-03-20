# This class takes care to manage
# the various gitlab related services
class gitlab::service (
  $mail_room_enabled = $::gitlab::mail_room_enabled,
  $gitlab_pages_enabled = $::gitlab::gitlab_pages_enabled,
) {

  service { 'gitlab_unicorn':
    ensure => 'running',
    enable => true,
  }
  service { 'gitlab_workhorse':
    ensure => 'running',
    enable => true,
  }
  service { 'gitlab_sidekiq':
    ensure => 'running',
    enable => true,
  }
  if $mail_room_enabled {
    service { 'gitlab_workhorse':
      ensure => 'running',
      enable => true,
    }
  } else {
    service { 'gitlab_mail_room':
      ensure => 'stopped',
      enable => false,
    }
  }
}
