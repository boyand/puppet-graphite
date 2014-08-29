# Class: graphite::params
#
# This is a class for generic params. Not to be called directly
#
# Parameters:
#   admin_password - defaults to 'test'
#   port
#   whitelist
#   blacklist
#   ...
class graphite::params {
  $admin_password = 'sha1$83a35$8d6beb6347a608daf07110a11f596e9621b8c91c'
  $port = 8888
  $whitelist = []
  $blacklist = []
  $webapp_cluster_nodes = []
  $carbonlink_hosts= []
  $memcache_hosts = []
  $max_unused_data_age_in_days = 7
  $purge_cron_hour = 4
  $purge_cron_minute = 0
  $whisper_storage_directory = '/opt/graphite/storage/whisper/'
}
