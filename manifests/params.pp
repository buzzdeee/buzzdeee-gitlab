# The default values for the GitLab module
class gitlab::params {
  $manage_go_package = false
  $manage_yarn_package = false

  $ruby_suffix='23'

  $web_hostname = $::fqdn
  $ssh_hostname = $::fqdn

  # GitLab user configuration
  $manage_user = true
  $gitlab_user = '_gitlab'
  $gitlab_group = '_gitlab'
  $gitlab_home = '/var/www/gitlab'
  $gitlab_usershell = '/usr/local/bin/bash'
  $gitlab_uid = '999'
  $gitlab_gid = '999'
  $gitlab_groups = [ '_redis', ]

  $unicorn_root = '/var/www/gitlab/gitlab'
  $workhorse_root = '/var/www/gitlab/gitlab-workhorse'
  $gitlabshell_root = '/var/www/gitlab/gitlab-shell'
  $web_chroot = '/var/www'

  $unicorn_port = '8080'
  $unicorn_relative_web_path = '/gitlab'
  $unicorn_stderr_log = '/var/log/gitlab/unicorn.stderr.log'
  $unicorn_stdout_log = '/var/log/gitlab/unicorn.stdout.log'
  $unicorn_socket = '/var/run/gitlab/gitlab.socket'
  $unicorn_pidfile = '/var/run/gitlab/unicorn.pid'
  $unicorn_timeout = '60'

  $auth_ldap_enabled = 'false'
  $auth_ldap_label = 'LDAP'
  $auth_ldap_server = 'auth_ldap_server'
  $auth_ldap_port = '389'
  $auth_ldap_method = 'plain'	# may also be 'tls' or 'ssl'
  $auth_ldap_uid = 'uid'
  $auth_ldap_bind_dn = ''
  $auth_ldap_bind_pw = ''
  $auth_ldap_timeout = '10'
  $auth_ldap_is_ad = 'false'
  $auth_ldap_allow_username_or_email_login = 'false'
  $auth_ldap_block_auto_created_users = 'false'
  $auth_ldap_search_base = ''
  $auth_ldap_user_filter = ''

  $gitlab_email_from = "${gitlab_user}@${::fqdn}"
  $gitlab_email_display_name = 'GitLab'
  $gitlab_email_reply_to = "noreply@${::fqdn}"
  $gitlab_email_subject_suffix = ''

  $gitlab_satellites_path = '/var/www/gitlab/gitlab-satellites'
  $gitlab_repositories_path = '/var/www/gitlab/repositories'
  $git_binary = '/usr/local/bin/git'

  $gitlab_shell_audit_usernames = 'true'
  $gitlab_shell_self_signed_cert = 'false'
  $gitlab_shell_log_level = 'INFO'

  $workhorse_log = '/var/log/gitlab/gitlab-workhorse.log'
  $workhorse_socket = '/var/run/gitlab/gitlab-workhorse.socket'
  $workhorse_document_root = '/var/www/gitlab/gitlab/public'

  $sidekiq_log = '/var/log/gitlab/sidekiq.log'
  $sidekiq_pid = '/var/run/gitlab/sidekiq.pid'
  $sidekiq_config  = '/etc/gitlab/sidekiq_queues.yml'

  $mail_room_enabled = false
  $mail_room_pid_path = '/var/run/gitlab/mail_room.pid'
  $mail_room_config  = '/etc/gitlab/mail_room.yml'

  # NOT YET!!!
  $gitlab_pages_enabled = false
  $gitlab_pages_log = '/var/log/gitlab/gitlab-pages.log'
  $gitlab_pages_pid_path = '/var/run/gitlab/gitlab-pages.pid'

  $manage_database = false
  $dbtype = 'postgresql' # other valid value may be 'mysql'
  $dbname = 'gitlab'
  $dbuser = 'gitlab'
  $dbpass = 'changeme'
  $dbhost = 'localhost'
  $dbport = '5432'

  $redis_socket = 'unix:/var/run/redis/redis_gitlab.sock'
}
