# Class: graphite::config
#
# Configuration class
#
# Parameters:
#   admin_password
#   port
#   [...]
#
class graphite::config {

  include apache
  include concat::setup

  $admin_password = $graphite::admin_password
  $port = $graphite::port
  $blacklist = $graphite::blacklist
  $whitelist = $graphite::whitelist
  $webapp_cluster_nodes = $graphite::webapp_cluster_nodes
  $memcache_hosts = $graphite::memcache_hosts
  $carbonlink_hosts = $graphite::carbonlink_hosts
  $local_ip_address = $graphite::local_ip_address
  $max_unused_data_age_in_days = $graphite::max_unused_data_age_in_days
  $purge_cron_hour = $graphite::purge_cron_hour
  $purge_cron_minute = $graphite::purge_cron_minute
  $whisper_storage_directory = $graphite::whisper_storage_directory

  #Build the carbon config
  concat { '/opt/graphite/conf/carbon.conf':
      owner   => 'root',
      group   => 'root',
      mode    => '0644'
  }

  concat::fragment { 'header':
    target  => '/opt/graphite/conf/carbon.conf',
    order   => '01',
    content => template('graphite/part_config_header.erb')
  }

  file { '/opt/graphite/conf/storage-schemas.conf':
    ensure    => present,
    source    => 'puppet:///modules/graphite/storage-schemas.conf',
  }

  file { '/opt/graphite/conf/storage-aggregation.conf':
    ensure    => present,
    source    => 'puppet:///modules/graphite/storage-aggregation.conf',
  }

  file { '/opt/graphite/conf/graphite.wsgi':
    ensure    => present,
    source    => 'puppet:///modules/graphite/graphite.wsgi',
  }

  file { ['/opt/graphite/storage',
          '/opt/graphite/storage/whisper',
          '/opt/graphite/storage/lists',
          '/opt/graphite/storage/rrd',
          '/opt/graphite/storage/log',
          '/opt/graphite/storage/log/webapp',
          '/var/lib/wsgi']:
    owner     => 'www-data',
    mode      => '0775',
  }

  exec { 'init-db':
    command   => '/usr/bin/python manage.py syncdb --noinput',
    cwd       => '/opt/graphite/webapp/graphite',
    creates   => '/opt/graphite/storage/graphite.db',
    subscribe => File['/opt/graphite/storage'],
    require   => [File['/opt/graphite/webapp/graphite/initial_data.json'], File['/opt/graphite/webapp/graphite/local_settings.py']],
  }

  file { '/opt/graphite/webapp/graphite/initial_data.json':
    ensure  => present,
    require => File['/opt/graphite/storage'],
    content => template('graphite/initial_data.json'),
  }

  file { '/opt/graphite/storage/graphite.db':
    owner     => 'www-data',
    mode      => '0664',
    subscribe => Exec['init-db'],
  }

  file { '/opt/graphite/webapp/graphite/local_settings.py':
    ensure  => present,
    content => template('graphite/local_settings.py.erb'),
    require => File['/opt/graphite/storage']
  }

  if ! empty($whitelist) {
    file { '/opt/graphite/conf/whitelist.conf':
      ensure   => present,
      mode     => '0664',
      owner    => 'root',
      content  => template('graphite/whitelist.conf.erb')
    }
  }

  if ! empty($blacklist) {
    file { '/opt/graphite/conf/blacklist.conf':
      ensure   => present,
      mode     => '0664',
      owner    => 'root',
      content  => template('graphite/blacklist.conf.erb')
    }
  }

  class { 'apache::mod::wsgi':
      wsgi_socket_prefix => '/var/lib/wsgi',
      require            => [ File['/var/lib/wsgi'],
                              File['/opt/graphite/storage/log/webapp'] ]
  }

  #FIXME: Start using the vhost directive for headers
  #as opposed to including this directly
  include apache::mod::headers

  apache::vhost { 'graphite':
    priority        => '10',
    port            => $port,
    docroot         => '/opt/graphite/webapp',
    logroot         => '/opt/graphite/storage/log/webapp',
    custom_fragment => template('graphite/virtualhost.conf.erb'),
  }

  # Clear out old whisper databases:
  cron { 'graphite::config::purgeolddata':
    command => "/usr/bin/find ${whisper_storage_directory} -type f -mtime +${max_unused_data_age_in_days} -delete; /usr/bin/find ${whisper_storage_directory} -type d -empty -delete",
    minute  => $purge_cron_minute,
    hour    => $purge_cron_hour,
  }

}
