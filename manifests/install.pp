# The class that takes care of the installation
class gitlab::install (
  $gitlab_version = $::gitlab::gitlab_version,
  $manage_user = $::gitlab::manage_user,
  $gitlab_user = $::gitlab::gitlab_user,
  $gitlab_group = $::gitlab::gitlab_group,
  $gitlab_home = $::gitlab::gitlab_home,
  $gitlab_usershell = $::gitlab::gitlab_usershell,
  $gitlab_uid = $::gitlab::gitlab_uid,
  $gitlab_gid = $::gitlab::gitlab_gid,
  $gitlab_groups = $::gitlab::gitlab_groups,

  $web_hostname = $::gitlab::web_hostname,
  $ssh_hostname = $::gitlab::ssh_hostname,
  $gitlab_email_from = $::gitlab::gitlab_email_from,
  $gitlab_email_display_name = $::gitlab::gitlab_email_display_name,
  $gitlab_email_reply_to = $::gitlab::gitlab_email_reply_to,
  $gitlab_email_subject_suffix = $::gitlab::gitlab_email_subject_suffix,

  $gitlab_satellites_path = $::gitlab::gitlab_satellites_path,
  $gitlab_repositories_path = $::gitlab::gitlab_repositories_path,
  $git_binary  =$::gitlab::git_binary,

  $unicorn_root = $::gitlab::unicorn_root,
  $workhorse_root = $::gitlab::workhorse_root,
  $gitlabshell_root = $::gitlab::gitlabshell_root,
  
  $unicorn_port = $::gitlab::unicorn_port,
  $unicorn_relative_web_path = $::gitlab::unicorn_relative_web_path,
  $unicorn_stderr_log = $::gitlab::unicorn_stderr_log,
  $unicorn_stdout_log = $::gitlab::unicorn_stdout_log,
  $unicorn_socket = $::gitlab::unicorn_socket,
  $unicorn_pidfile = $::gitlab::unicorn_pidfile,

  $workhorse_log = $::gitlab::workhorse_log,
  $workhorse_socket = $::gitlab::workhorse_socket,
  $workhorse_document_root = $::gitlab::workhorse_document_root,

  $sidekiq_log = $::gitlab::sidekiq_log,
  $sidekiq_pid = $::gitlab::sidekiq_pid,
  $sidekiq_config = $::gitlab::sidekiq_config,
  
  $mail_room_enabled = $::gitlab::mail_room_enabled,
  $mail_room_pid_path = $::gitlab::mail_room_pid_path,
  $mail_room_config = $::gitlab::mail_room_config,

  $gitlab_pages_enabled  =$::gitlab::gitlab_pages_enabled,
  $gitlab_pages_log = $::gitlab::gitlab_pages_log,
  $gitlab_pages_pid_path = $::gitlab::gitlab_pages_pid_path,

) {

  if ($manage_user) {
    group { $gitlab_group:
      gid => $gitlab_gid,
    }
    user { $gitlab_user:
      home       => $gitlab_home,
      shell      => $gitlab_shell,
      uid        => $gitlab_uid,
      gid        => $gitlab_gid,
      groups     => $gitlab_groups,
      managehome => true,
    }
  }

  vcsrepo { $unicorn_root:
    ensure   => present,
    provider => git,
    source   => 'https://gitlab.com/gitlab-org/gitlab-ce.git',
    revision => $gitlab_version,
    user     => $gitlab_user,
  }

  file { "${unicorn_root}/config/gitlab.yml":
    owner   => 'root',
    group   => '0',
    mode    => '0644',
    content => template("gitlab/gitlab.yml.erb"),
  }

  $rc_scripts = [ 'gitlab_unicorn',
                  'gitlab_mail_room',
                  'gitlab_sidekiq',
                  'gitlab_workhorse',
                ]
  $rc_scripts.each |String $script| {
    file { "/etc/rc.d/${script}":
      owner   => 'root',
      group   => '0',
      content => template("gitlab/${script}.erb"),
    }
  }

}
