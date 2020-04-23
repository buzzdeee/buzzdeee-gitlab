# The class that takes care of the installation
class gitlab::install (
  $gitlab_version = $::gitlab::gitlab_version,
  $gitlab_giturl = $::gitlab::gitlab_giturl,
  $ruby_suffix = $::gitlab::ruby_suffix,
  $manage_user = $::gitlab::manage_user,
  $gitlab_user = $::gitlab::gitlab_user,
  $gitlab_group = $::gitlab::gitlab_group,
  $gitlab_home = $::gitlab::gitlab_home,
  $gitlab_usershell = $::gitlab::gitlab_usershell,
  $gitlab_uid = $::gitlab::gitlab_uid,
  $gitlab_gid = $::gitlab::gitlab_gid,
  $gitlab_loginclass = $::gitlab::gitlab_loginclass,
  $gitlab_groups = $::gitlab::gitlab_groups,

  $web_hostname = $::gitlab::web_hostname,
  $ssh_hostname = $::gitlab::ssh_hostname,
  $gitlab_email_from = $::gitlab::gitlab_email_from,
  $gitlab_email_display_name = $::gitlab::gitlab_email_display_name,
  $gitlab_email_reply_to = $::gitlab::gitlab_email_reply_to,
  $gitlab_email_subject_suffix = $::gitlab::gitlab_email_subject_suffix,

  $gitlab_rundir_mode = $::gitlab::gitlab_rundir_mode,

  $gitaly_log_file = $::gitlab::gitaly_log_file,

  $gitlab_satellites_path = $::gitlab::gitlab_satellites_path,
  $gitlab_repositories_path = $::gitlab::gitlab_repositories_path,
  $gitlab_gitaly_address = $::gitlab::gitlab_gitaly_address,
  $git_binary = $::gitlab::git_binary,
  $gitlab_gitaly_client_path = $::gitlab::gitlab_gitaly_client_path,

  $unicorn_root = $::gitlab::unicorn_root,
  $workhorse_root = $::gitlab::workhorse_root,
  $gitlabshell_root = $::gitlab::gitlabshell_root,
  $gitaly_root = $::gitlab::gitaly_root,
  $web_chroot = $::gitlab::web_chroot,

  $unicorn_port = $::gitlab::unicorn_port,
  $unicorn_relative_web_path = $::gitlab::unicorn_relative_web_path,
  $unicorn_stderr_log = $::gitlab::unicorn_stderr_log,
  $unicorn_stdout_log = $::gitlab::unicorn_stdout_log,
  $unicorn_socket = $::gitlab::unicorn_socket,
  $unicorn_pidfile = $::gitlab::unicorn_pidfile,
  $unicorn_timeout = $::gitlab::unicorn_timeout,

  $auth_ldap_enabled = $::gitlab::auth_ldap_enabled,
  $auth_ldap_label = $::gitlab::auth_ldap_label,
  $auth_ldap_server = $::gitlab::auth_ldap_server,
  $auth_ldap_port = $::gitlab::auth_ldap_port,
  $auth_ldap_method = $::gitlab::auth_ldap_method,
  $auth_ldap_uid = $::gitlab::auth_ldap_uid,
  $auth_ldap_bind_dn = $::gitlab::auth_ldap_bind_dn,
  $auth_ldap_bind_pw = $::gitlab::auth_ldap_bind_pw,
  $auth_ldap_timeout = $::gitlab::auth_ldap_timeout,
  $auth_ldap_is_ad = $::gitlab::auth_ldap_is_ad,
  $auth_ldap_allow_username_or_email_login = $::gitlab::auth_ldap_allow_username_or_email_login,
  $auth_ldap_block_auto_created_users = $::gitlab::auth_ldap_block_auto_created_users,
  $auth_ldap_search_base = $::gitlab::auth_ldap_search_base,
  $auth_ldap_user_filter = $::gitlab::auth_ldap_user_filter,

  $workhorse_log = $::gitlab::workhorse_log,
  $workhorse_socket = $::gitlab::workhorse_socket,
  $workhorse_document_root = $::gitlab::workhorse_document_root,

  $gitlab_shell_audit_usernames = $::gitlab::gitlab_shell_audit_usernames,
  $gitlab_shell_self_signed_cert = $::gitlab::gitlab_shell_self_signed_cert,
  $gitlab_shell_log_level = $::gitlab::gitlab_shell_log_level,
  $gitlab_shell_log_file = $::gitlab::gitlab_shell_log_file,

  $sidekiq_log = $::gitlab::sidekiq_log,
  $sidekiq_pid = $::gitlab::sidekiq_pid,
  $sidekiq_config = $::gitlab::sidekiq_config,

  $mail_room_enabled = $::gitlab::mail_room_enabled,
  $mail_room_pid_path = $::gitlab::mail_room_pid_path,
  $mail_room_config = $::gitlab::mail_room_config,
  $mail_room_log = $::gitlab::mail_room_log,

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
      shell      => $gitlab_usershell,
      uid        => $gitlab_uid,
      loginclass => $gitlab_loginclass,
      gid        => $gitlab_gid,
      groups     => $gitlab_groups,
      managehome => true,
    }
  }

  # newer revisions are incompatible with re2 Ruby gem
  vcsrepo { '/usr/src/re2':
    ensure   => 'present',
    provider => 'git',
    source   => 'https://code.googlesource.com/re2',
    revision => 'b4073a9d29cdf7be063b8daaa9c8dca5fde2400d',
  }

  exec { 'build_and_install_re2':
    command     => "/usr/local/bin/gmake install",
    cwd         => '/usr/src/re2',
    environment => [ "CC=clang", "CXX=clang++" ],
    require     => Vcsrepo['/usr/src/re2'],
    before      => Vcsrepo[$unicorn_root],
    creates     => '/usr/local/lib/libre2.a',
  }

  vcsrepo { $unicorn_root:
    ensure   => present,
    provider => git,
    source   => $gitlab_giturl,
    revision => $gitlab_version,
    user     => $gitlab_user,
  }

  file { "${unicorn_root}/config/gitlab.yml":
    owner   => 'root',
    group   => '0',
    mode    => '0644',
    content => template('gitlab/gitlab.yml.erb'),
    require => Vcsrepo[$unicorn_root],
  }
  file { "${unicorn_root}/config/unicorn.rb":
    owner   => 'root',
    group   => '0',
    mode    => '0644',
    content => template('gitlab/unicorn.rb.erb'),
    require => Vcsrepo[$unicorn_root],
  }
  file { "${unicorn_root}/config/initializers/relative_url.rb":
    owner   => 'root',
    group   => '0',
    mode    => '0644',
    content => template('gitlab/relative_url.rb.erb'),
    require => Vcsrepo[$unicorn_root],
  }
  file { "${unicorn_root}/config/database.yml":
    owner   => 'root',
    group   => '0',
    mode    => '0644',
    content => template('gitlab/database.yml.erb'),
    require => Vcsrepo[$unicorn_root],
  }
  file { "${unicorn_root}/config/resque.yml":
    owner   => 'root',
    group   => '0',
    mode    => '0644',
    content => template('gitlab/resque.yml.erb'),
    require => Vcsrepo[$unicorn_root],
  }
  file { "${unicorn_root}/config/secrets.yml":
    owner   => 'root',
    group   => $gitlab_group,
    mode    => '0660',
    content => template('gitlab/secrets.yml.erb'),
    require => Vcsrepo[$unicorn_root],
  }
  file { "${unicorn_root}/config/initializers/rack_attack.rb":
    owner   => 'root',
    group   => $gitlab_group,
    mode    => '0640',
    content => template('gitlab/rack_attack.rb.erb'),
    require => Vcsrepo[$unicorn_root],
  }

  if !defined (File[dirname($workhorse_log)]) {
    file { dirname($workhorse_log):
      ensure  => 'directory',
      owner   => $gitlab_user,
      group   => $gitlab_group,
      mode    => '0775',
      require => Vcsrepo[$unicorn_root],
    }
  }
  if !defined (File[dirname($unicorn_stderr_log)]) {
    file { dirname($unicorn_stderr_log):
      ensure  => 'directory',
      owner   => $gitlab_user,
      group   => $gitlab_group,
      mode    => '0775',
      require => Vcsrepo[$unicorn_root],
    }
  }
  if !defined (File[dirname($unicorn_stdout_log)]) {
    file { dirname($unicorn_stdout_log):
      ensure  => 'directory',
      owner   => $gitlab_user,
      group   => $gitlab_group,
      mode    => '0775',
      require => Vcsrepo[$unicorn_root],
    }
  }
  if !defined (File[dirname($unicorn_socket)]) {
    file { dirname($unicorn_socket):
      ensure  => 'directory',
      owner   => $gitlab_user,
      group   => $gitlab_group,
      mode    => $gitlab_rundir_mode,
      require => Vcsrepo[$unicorn_root],
    }
  }
  $workhorse_socket_dir = dirname("${web_chroot}${workhorse_socket}")
  if !defined (File[$workhorse_socket_dir]) {
    if !defined (File[dirname($workhorse_socket_dir)]) {
      file { dirname($workhorse_socket_dir):
        ensure  => 'directory',
        require => Vcsrepo[$unicorn_root],
      }
    }
    file { $workhorse_socket_dir:
      ensure  => 'directory',
      owner   => $gitlab_user,
      group   => $gitlab_group,
      require => Vcsrepo[$unicorn_root],
    }
  }
  file { "${unicorn_root}/public/uploads":
    ensure  => 'directory',
    owner   => $gitlab_user,
    group   => $gitlab_group,
    mode    => '0700',
    require => Vcsrepo[$unicorn_root],
  }
  file { [ "${unicorn_root}/builds", "${unicorn_root}/shared/artifacts", "${unicorn_root}/shared/pages" ]:
    ensure  => 'directory',
    owner   => $gitlab_user,
    group   => $gitlab_group,
    require => Vcsrepo[$unicorn_root],
  }

  $ruby_maj_min = join(split($ruby_suffix, ''), '.')

  exec { 'configure_building_nokogiri':
    command     => "bundle${ruby_suffix} config build.nokogiri --use-system-libraries --with-xml2-config=/usr/local/bin/xml2-config --with-xslt-config=/usr/local/bin/xslt-config", # lint:ignore:140chars
    environment => [ "HOME=${gitlab_home}",
                      "CFLAGS='-I/usr/local/include/libxml2 -I/usr/local/include/ruby-${ruby_maj_min}'", ],
    user        => $gitlab_user,
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
  file { "${gitlab_home}/bin":
    ensure  => 'directory',
    require => Exec['configure_building_nokogiri'],
  }
  file { "${gitlab_home}/bin/tar":
    ensure  => 'link',
    target  => '/usr/local/bin/gtar',
    require => File["${gitlab_home}/bin"],
  }
  file { "${gitlab_home}/bin/make":
    ensure  => 'link',
    target  => '/usr/local/bin/gmake',
    require => File["${gitlab_home}/bin"],
  }
  file { "${gitlab_home}/bin/bundle":
    ensure  => 'link',
    target  => "/usr/local/bin/bundle${ruby_suffix}",
    require => File["${gitlab_home}/bin"],
  }
  file { "${gitlab_home}/bin/ruby":
    ensure  => 'link',
    target  => "/usr/local/bin/ruby${ruby_suffix}",
    require => File["${gitlab_home}/bin"],
  }
  exec { 'install_gitlab_gems':
    command     => "bundle${ruby_suffix} install --deployment --without development test mysql aws kerberos",
    environment => [ "HOME=${gitlab_home}",
                      'CC=clang',
                      'CXX=clang++',
                      'CFLAGS=-I/usr/local/include/libxml2',
                      "PATH=${gitlab_home}/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11R6/bin:/usr/local/sbin" ],
    user        => $gitlab_user,
    cwd         => $unicorn_root,
    refreshonly => true,
    timeout     => 6000,
    subscribe   => Vcsrepo[$unicorn_root],
    require     => File["${gitlab_home}/bin/make"],
  }
  exec { 'install_gitlab_shell':
    command     => "bundle${ruby_suffix} exec rake${ruby_suffix} gitlab:shell:install REDIS_URL=unix:${redis_socket} RAILS_ENV=production SKIP_STORAGE_VALIDATION=true", # lint:ignore:140chars
    environment => [ "HOME=${gitlab_home}",
                      "PATH=${gitlab_home}/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11R6/bin:/usr/local/sbin" ],
    user        => $gitlab_user,
    cwd         => $unicorn_root,
    refreshonly => false,
    timeout     => 2000,
    subscribe   => Vcsrepo[$unicorn_root],
    creates     => '/var/www/gitlab/gitlab-shell',
    require     => [ Exec['install_gitlab_gems'], Vcsrepo[$unicorn_root], ],
  }
  file { "${gitlabshell_root}/config.yml":
    owner   => 'root',
    group   => $gitlab_group,
    mode    => '0640',
    content => template('gitlab/gitlab_shell_config.yml.erb'),
    require => Exec['install_gitlab_shell'],
  }
  exec { 'fixup_ruby_path_in_gitlab_shell_scripts':
    command => "/usr/bin/sed -i 's|/usr/bin/env ruby|${gitlab_home}/bin/ruby|' *",
    user    => $gitlab_user,
    cwd     => "${gitlabshell_root}/bin",
    onlyif  => '/usr/bin/grep \'/usr/bin/env ruby\' * >> /dev/null 2>>/dev/null',
    require => Exec['install_gitlab_shell'],
  }
  exec { 'fixup_ruby_path_in_gitlab_shell_hooks':
    command => "/usr/bin/sed -i 's|/usr/bin/env ruby|${gitlab_home}/bin/ruby|' *",
    user    => $gitlab_user,
    cwd     => "${gitlabshell_root}/hooks",
    onlyif  => '/usr/bin/grep \'/usr/bin/env ruby\' * >> /dev/null 2>>/dev/null',
    require => Exec['install_gitlab_shell'],
  }

  exec { 'install_gitlab_workhorse':
    command     => "bundle${ruby_suffix} exec rake${ruby_suffix} 'gitlab:workhorse:install[${workhorse_root}]' RAILS_ENV=production",
    environment => [ "HOME=${gitlab_home}",
                      'CFLAGS=-I/usr/local/include/libxml2',
                      "PATH=${gitlab_home}/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11R6/bin:/usr/local/sbin" ],
    user        => $gitlab_user,
    cwd         => $unicorn_root,
    refreshonly => false,
    timeout     => 3000,
    creates     => $workhorse_root,
    require     => [ Exec['install_gitlab_gems'], Vcsrepo[$unicorn_root], ],
  }
  exec { 'install_gitaly':
    command     => "bundle${ruby_suffix} exec rake${ruby_suffix} 'gitlab:gitaly:install[${gitaly_root},${gitlab_repositories_path}]' RAILS_ENV=production",
    environment => [ "HOME=${gitlab_home}",
                      "PATH=${gitlab_home}/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11R6/bin:/usr/local/sbin" ],
    user        => $gitlab_user,
    cwd         => $unicorn_root,
    refreshonly => false,
    timeout     => 3000,
    creates     => $gitaly_root,
    require     => [ Exec['install_gitlab_workhorse'], Vcsrepo[$unicorn_root], ],
  }
  #exec { 'npm_install_production':
  #  command     => 'npm install --production',
  #  environment => [ "HOME=${gitlab_home}",
  #                    'CFLAGS=-I/usr/local/include/libxml2',
  #                    "PATH=${gitlab_home}/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11R6/bin:/usr/local/sbin" ],
  #  user        => $gitlab_user,
  #  cwd         => $unicorn_root,
  #  refreshonly => true,
  #  timeout     => 2000,
  #  subscribe   => Vcsrepo[$unicorn_root],
  #  require     => Exec['install_gitlab_gems'],
  #}
  
  exec { 'gitlab_compile_gettext':
    command     => "bundle${ruby_suffix} exec rake${ruby_suffix} gettext:compile RAILS_ENV=production",
    environment => [ "HOME=${gitlab_home}",
                      "PATH=${gitlab_home}/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11R6/bin:/usr/local/sbin" ],
    user        => $gitlab_user,
    cwd         => $unicorn_root,
    refreshonly => true,
    timeout     => 3000,
    subscribe   => [ Exec['install_gitlab_workhorse'], Vcsrepo[$unicorn_root], ],
    before      => Exec['yarn_install'],
  }
  exec { 'yarn_install':
    command     => "yarn install --production --pure-lockfile",
    environment => [ "HOME=${gitlab_home}",
                      "PATH=${gitlab_home}/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11R6/bin:/usr/local/sbin" ],
    user        => $gitlab_user,
    cwd         => $unicorn_root,
    refreshonly => true,
    timeout     => 3000,
    subscribe   => [ Exec['install_gitlab_workhorse'], Vcsrepo[$unicorn_root], ],
  }
  file { "${unicorn_root}/node_modules/webpack/bin/webpack.js":
    mode    => '0755',
    require => Exec['yarn_install'],
  }
  exec { 'gitlab_assets_compile':
    command     => "bundle${ruby_suffix} exec rake${ruby_suffix} gitlab:assets:compile RAILS_ENV=production NODE_ENV=production",
    environment => [ "HOME=${gitlab_home}",
                      'CFLAGS=-I/usr/local/include/libxml2',
                      "PATH=${gitlab_home}/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11R6/bin:/usr/local/sbin" ],
    user        => $gitlab_user,
    cwd         => $unicorn_root,
    refreshonly => true,
    timeout     => 3000,
    subscribe   => Exec['yarn_install'],
    require     => File["${unicorn_root}/node_modules/webpack/bin/webpack.js"],
  }

  if !defined (File[dirname($unicorn_pidfile)]) {
    file { dirname($unicorn_pidfile):
      ensure  => 'directory',
      owner   => $gitlab_user,
      group   => $gitlab_group,
      require => Vcsrepo[$unicorn_root],
    }
  }

  $rc_scripts = [ 'gitlab_unicorn',
                  'gitlab_mail_room',
                  'gitlab_sidekiq',
                  'gitlab_workhorse',
                  'gitlab_gitaly',
                ]
  $rc_scripts.each |String $script| {
    file { "/etc/rc.d/${script}":
      owner   => 'root',
      group   => '0',
      mode    => '0755',
      content => template("gitlab/${script}.erb"),
      require => Vcsrepo[$unicorn_root],
    }
  }

}
