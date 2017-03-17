# Class: gitlab
# ===========================
#
# Full description of class gitlab here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'gitlab':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2017 Your name here, unless otherwise noted.
#
class gitlab (
  $gitlab_version,
  $db_key_base = 'changeme',
  $secret_key_base = 'changeme',
  $otp_key_base = 'changeme',
  $ruby_suffix = $::gitlab::params::ruby_suffix,
  $manage_go_package = $::gitlab::params::manage_go_package,
  $manage_yarn_package = $::gitlab::params::manage_yarn_package,

  $web_hostname = $::gitlab::params::web_hostname,
  $ssh_hostname = $::gitlab::params::ssh_hostname,
  $gitlab_email_from = $::gitlab::params::gitlab_email_from,
  $gitlab_email_display_name = $::gitlab::params::gitlab_email_display_name,
  $gitlab_email_reply_to = $::gitlab::params::gitlab_email_reply_to,
  $gitlab_email_subject_suffix = $::gitlab::params::gitlab_email_subject_suffix,

  $gitlab_satellites_path = $::gitlab::params::gitlab_satellites_path,
  $gitlab_repositories_path = $::gitlab::params::gitlab_repositories_path,
  $git_binary = $::gitlab::params::git_binary,

  $manage_user = $::gitlab::params::manage_user,
  $gitlab_user = $::gitlab::params::gitlab_user,
  $gitlab_group = $::gitlab::params::gitlab_group,
  $gitlab_home = $::gitlab::params::gitlab_home,
  $gitlab_usershell = $::gitlab::params::gitlab_usershell,
  $gitlab_uid = $::gitlab::params::gitlab_uid,
  $gitlab_gid = $::gitlab::params::gitlab_gid,
  $gitlab_groups = $::gitlab::params::gitlab_groups,

  $unicorn_root = $::gitlab::params::unicorn_root,
  $workhorse_root = $::gitlab::params::workhorse_root,
  $gitlabshell_root = $::gitlab::params::gitlabshell_root,
  $web_chroot = $::gitlab::params::web_chroot,

  $unicorn_port = $::gitlab::params::unicorn_port,
  $unicorn_relative_web_path = $::gitlab::params::unicorn_relative_web_path,
  $unicorn_stderr_log = $::gitlab::params::unicorn_stderr_log,
  $unicorn_stdout_log = $::gitlab::params::unicorn_stdout_log,
  $unicorn_socket = $::gitlab::params::unicorn_socket,
  $unicorn_pidfile = $::gitlab::params::unicorn_pidfile,

  $workhorse_log = $::gitlab::params::workhorse_log,
  $workhorse_socket = $::gitlab::params::workhorse_socket,
  $workhorse_document_root = $::gitlab::params::workhorse_document_root,

  $sidekiq_log = $::gitlab::params::sidekiq_log,
  $sidekiq_pid = $::gitlab::params::sidekiq_pid,
  $sidekiq_config = $::gitlab::params::sidekiq_config,

  $gitlab_shell_audit_username = $::gitlab::params::gitlab_shell_audit_username,
  $gitlab_shell_self_signed_cert = $::gitlab::params::gitlab_shell_self_signed_cert,
  $gitlab_shell_log_level = $::gitlab::params::gitlab_shell_log_level,

  $mail_room_enabled = $::gitlab::params::mail_room_enabled,
  $mail_room_pid_path = $::gitlab::params::mail_room_pid_path,
  $mail_room_config = $::gitlab::params::mail_room_config,

  $gitlab_pages_enabled = $::gitlab::params::gitlab_pages_enabled,
  $gitlab_pages_log = $::gitlab::params::gitlab_pages_log,
  $gitlab_pages_pid_path = $::gitlab::params::gitlab_pages_pid_path,

  $manage_database = $::gitlab::params::manage_database,
  $dbtype = $::gitlab::params::dbtype,
  $dbuser = $::gitlab::params::dbuser,
  $dbpass = $::gitlab::params::dbpass,   # you should definately override this one
  $dbname = $::gitlab::params::dbname,
  $dbhost = $::gitlab::params::dbhost,
  $dbport = $::gitlab::params::dbport,
  $redis_socket = $::gitlab::params::redis_socket,
) inherits gitlab::params {

  include gitlab::install
  include gitlab::gitconfig

  Class['gitlab::install'] ~>
  Class['gitlab::gitconfig']
}
