# define: graphite::cache
#
# This definition creates a graphite cache instance
#
# Parameters:
#   [*ensure*]                    - Enables or disables the specified cache (present|absent)
#   [*user*]                      - Specify the user to drop privileges to
#   [*max_cache_size*]            - Limit the size of the cache to avoid swapping or becoming CPU bound
#   [*max_updates_per_second*]    - Limits the number of whisper update_many() calls per second, which effectively
#                                   means the number of write requests sent to the disk
#   [*max_creates_per_minute*]    - Softly limits the number of whisper files that get created each minute.
#   [*line_receiver_interface*]   - Line Receiver IP to bind to
#   [*line_receiver_port*]        - Line Receiver Port
#   [*pickle_receiver_interface*] - Pickle Receiver IP to bind to
#   [*pickle_receiver_port*]      - Pickle Receiver Port to bind to
#   [*use_insecure_unpickler*]    - Per security concerns outlined in Bug #817247 the pickle receiver
#                                   will use a more secure and slightly less efficient unpickler.
#   [*cache_query_interface*]     - Cache query interface to bind to
#   [*cache_query_port*]          - Cache query port
#   [*log_updates*]               - By default, carbon-cache will log every whisper update.
#   [*use_flow_control*]          - Set this to False to drop datapoints received after the cache
#                                   reaches MAX_CACHE_SIZE
#   [*whisper_autoflush*]         - On some systems it is desirable for whisper to write synchronously.
#   [*use_whilist*]                - Use whitelisting or blacklisting files
#   [*whitelist_rules*]            - Array of whitelist / blacklist rules
#
# Actions:
#
# Requires:
#
# Sample Usage:
#  graphite::cache { 'a':
#    ensure               => present,
#    pickle_receiver_port => '2004',
#    line_receiver_port   => '2003',
#    cache_query_port     => '7002',
#  }
define graphite::cache(
  $ensure                     = present,
  $user                       = 'www-data',
  $max_cache_size             = '1000',
  $max_updates_per_second     = '5000',
  $max_creates_per_minute     = '500',
  $line_receiver_interface    = '0.0.0.0',
  $line_receiver_port         = '2003',
  $pickle_receiver_interface  = '0.0.0.0',
  $pickle_receiver_port       = '2004',
  $use_insecure_unpickler     = 'False',
  $cache_query_interface      = '0.0.0.0',
  $cache_query_port           = '7002',
  $log_updates                = False,
  $use_flow_control           = True,
  $whisper_autoflush          = False,
  $use_whitelist              = False,
) {

    if ! defined(Class['graphite']) {
      fail('You must include the graphite base class before using any defined types')
    }

    include graphite::config

    concat::fragment { "cache-${name}":
      target  => '/opt/graphite/conf/carbon.conf',
      order   => '10',
      content => template('graphite/part_cache.erb'),
      require => Class['graphite::install']
    }

    $init_config_file = "carbon-cache-${name}"

    file { "/etc/init/${init_config_file}.conf":
      ensure  => $ensure,
      content => template('graphite/init.conf.erb'),
      mode    => '0555',
      require => Concat::Fragment["cache-${name}"]
    }

    service { $init_config_file:
      ensure     => running,
      hasstatus  => true,
      hasrestart => true,
      provider   => upstart,
      require    => File["/etc/init/${init_config_file}.conf"],
      subscribe  => File["/etc/init/${init_config_file}.conf"]
    }

    Class['graphite::config'] ~> Service[$init_config_file]

  }
