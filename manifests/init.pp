# Class: graphite::init
#
# This module works with sensible defaults
#
#
class graphite(
  $port = $graphite::params::port,
  $admin_password = $graphite::params::admin_password,
  $whitelist = $graphite::params::whitelist,
  $blacklist = $graphite::params::blacklist,
  $webapp_cluster_nodes = $graphite::params::webapp_cluster_nodes,
  $carbonlink_hosts = $graphite::params::carbonlink_hosts,
  $memcache_hosts = $graphite::params::memcache_hosts,
  $local_ip_address = $::ipaddress,
  $max_unused_data_age_in_days = $graphite::params::max_unused_data_age_in_days,
  $purge_cron_hour = $graphite::params::purge_cron_hour,
  $purge_cron_minute = $graphite::params::purge_cron_minute,
  $whisper_storage_directory = $graphite::params::whisper_storage_directory,
) inherits graphite::params {
  class{'graphite::install': } ->
  class{'graphite::config': } ->
  Class['graphite']
}
