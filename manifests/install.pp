# The class that takes care of the installation
class gitlab::install (
  $gitlab_version = $::gitlab::gitlab_version,
  $ruby_suffix = $::gitlab::ruby_suffix,
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

  $dbtype = $::gitlab::dbtype,
  $dbuser = $::gitlab::dbuser,
  $dbpass = $::gitlab::dbpass,   # you should definately override this one
  $dbname = $::gitlab::dbname,
  $dbhost = $::gitlab::dbhost,
  $dbport = $::gitlab::dbport,

  $redis_socket = $::gitlab::redis_socket,

  $db_key_base = $::gitlab::db_key_base,
  $secret_key_base = $::gitlab::secret_key_base,
  $otp_key_base = $::gitlab::otp_key_base,

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
    require => Vcsrepo[$unicorn_root],
  }
  file { "${unicorn_root}/config/unicorn.rb":
    owner   => 'root',
    group   => '0',
    mode    => '0644',
    content => template("gitlab/unicorn.rb.erb"),
    require => Vcsrepo[$unicorn_root],
  }
  file { "${unicorn_root}/config/database.yml":
    owner   => 'root',
    group   => '0',
    mode    => '0644',
    content => template("gitlab/database.yml.erb"),
    require => Vcsrepo[$unicorn_root],
  }
  file { "${unicorn_root}/config/resque.yml":
    owner   => 'root',
    group   => '0',
    mode    => '0644',
    content => template("gitlab/resque.yml.erb"),
    require => Vcsrepo[$unicorn_root],
  }
  file { "${unicorn_root}/config/secrets.yml":
    owner   => 'root',
    group   => $gitlab_group,
    mode    => '0640',
    content => template("gitlab/secrets.yml.erb"),
    require => Vcsrepo[$unicorn_root],
  }
  file { "${unicorn_root}/config/initializers/rack_attack.rb":
    owner   => 'root',
    group   => $gitlab_group,
    mode    => '0640',
    content => template("gitlab/rack_attack.rb.erb"),
    require => Vcsrepo[$unicorn_root],
  }

  if !defined (File[dirname($unicorn_stderr_log)]) {
    file { dirname($unicorn_stderr_log):
      ensure => 'directory',
      owner  => $gitlab_user,
      group  => $gitlab_group,
      require => Vcsrepo[$unicorn_root],
    }
  }
  if !defined (File[dirname($unicorn_stdout_log)]) {
    file { dirname($unicorn_stdout_log):
      ensure => 'directory',
      owner  => $gitlab_user,
      group  => $gitlab_group,
      require => Vcsrepo[$unicorn_root],
    }
  }
  if !defined (File[dirname($unicorn_socket)]) {
    file { dirname($unicorn_socket):
      ensure => 'directory',
      owner  => $gitlab_user,
      group  => $gitlab_group,
      require => Vcsrepo[$unicorn_root],
    }
  }
  file { "${unicorn_root}/public/uploads":
    ensure => 'directory',
    owner  => $gitlab_user,
    group  => $gitlab_group,
    mode   => '0700',
    require => Vcsrepo[$unicorn_root],
  }
  file { [ "${unicorn_root}/builds", "${unicorn_root}/shared/artifacts", "${unicorn_root}/shared/pages" ]:
    ensure => 'directory',
    owner  => $gitlab_user,
    group  => $gitlab_group,
    require => Vcsrepo[$unicorn_root],
  }

  exec { 'configure_building_nokogiri':
    command     => "bundle${ruby_suffix} config build.nokogiri --use-system-libraries --with-xml2-config=/usr/local/bin/xml2-config --with-xslt-config=/usr/local/bin/xslt-config",
    environment => [ "HOME=$gitlab_home",
                     "CFLAGS='-I/usr/local/include/libxml2 -I/usr/local/include/ruby-2.3", ],
    refreshonly => true,
    timeout     => 2000,
    subscribe   => Vcsrepo[$unicorn_root],
    before      => Exec['install_gitlab_gems'],
  }
  file { "${gitlab_home}/.bundle/cache":
    ensure  => 'directory',
    owner   => $gitlab_user,
    group   => $gitlab_group,
    require => Exec['configure_building_nokogiri'],
  }
  file { '/usr/local/bin/make':
    ensure  => 'link',
    target  => '/usr/local/bin/gmake',
    require => File["${gitlab_home}/.bundle/cache"],
  }
  exec { 'install_gitlab_gems':
    command     => "bundle${ruby_suffix} install --deployment --without development test mysql aws kerberos",
    environment => [ "HOME=$gitlab_home",
                     "CFLAGS=-I/usr/local/include/libxml2",
                     "CC=clang",
                     "CXX=clang++",
                     'PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11R6/bin:/usr/local/sbin' ],
    user        => $gitlab_user,
    cwd         => $unicorn_root,
    refreshonly => true,
    timeout     => 2000,
    subscribe   => Vcsrepo[$unicorn_root],
    require     => File['/usr/local/bin/make'],
  }
  exec { 'install_gitlab_shell':
    command     => "bundle${ruby_suffix} exec rake${ruby_suffix} gitlab:shell:install REDIS_URL=unix:${redis_socket} RAILS_ENV=production SKIP_STORAGE_VALIDATION=true",
    environment => "HOME=$gitlab_home",
    user        => $gitlab_user,
    cwd         => $unicorn_root,
    refreshonly => true,
    timeout     => 2000,
    subscribe   => Vcsrepo[$unicorn_root],
    require     => Exec['install_gitlab_gems'],
  }
  exec { 'install_gitlab_workhorse':
    command     => "bundle${ruby_suffix} exec rake${ruby_suffix} 'gitlab:workhorse:install[${workhorse_root}]' RAILS_ENV=production",
    environment => "HOME=$gitlab_home",
    user        => $gitlab_user,
    cwd         => $unicorn_root,
    refreshonly => true,
    timeout     => 2000,
    subscribe   => Vcsrepo[$unicorn_root],
    require     => Exec['install_gitlab_gems'],
  }

  if !defined (File[dirname($unicorn_pidfile)]) {
    file { dirname($unicorn_pidfile):
      ensure => 'directory',
      owner  => $gitlab_user,
      group  => $gitlab_group,
      require => Vcsrepo[$unicorn_root],
    }
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
      require => Vcsrepo[$unicorn_root],
    }
  }

}
