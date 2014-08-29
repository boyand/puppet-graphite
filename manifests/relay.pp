# define: graphite::relay
#
# This definition creates a graphite relay instance
#
# Parameters:
#   [*ensure*]                     - Enables or disables the specified cache (present|absent)
#   [*user*]                      - Specify the user to drop privileges to
#   [*line_receiver_interface*]    - Line Receiver IP to bind to
#   [*line_receiver_port*]         - Line Receiver Port
#   [*pickle_receiver_interface*]  - Pickle Receiver IP to bind to
#   [*pickle_receiver_port*]       - Pickle Receiver Port to bind to
#   [*relay_method*]               - Currently supports only consistent hashing
#   [*destinations*]               - This is a list of carbon daemons we will send any relayed or
#                                    generated metrics to
#   [*carboncache_instances*]      - an array of carbon cache information in the format:
#                                    'port:cache_name'
#   [*replication_factor*]         - The number of metric replicas stored in a cluster
#   [*max_datapoints_per_message*] - This defines the maximum "message size" between carbon daemons
#   [*max_queue_size*]             - This defines the maximum "message size" between carbon daemons
#   [*use_flow_control*]           - Set this to False to drop datapoints received after the cache
#                                    reaches MAX_CACHE_SIZE
#   [*use_whilist*]                - Use whitelisting or blacklisting files
#   [*whitelist_rules*]            - Array of whitelist / blacklist rules
#   [*log_listener_connections*]   - Set to false to disable logging of successful connections
#
# Actions:
#
# Requires:
#
# Sample Usage:
#  graphite::relay { 'a':
#    ensure               => present,
#    pickle_receiver_port => '2014',
#    line_receiver_port   => '2013',
#    destinations         => ['127.0.0.1:a', '127.0.0.1:b']
#    replication_factor   => '2'
#  }
define graphite::relay(
  $ensure                     = 'present',
  $user                       = 'www-data',
  $line_receiver_interface    = '0.0.0.0',
  $line_receiver_port         = '2013',
  $pickle_receiver_interface  = '0.0.0.0',
  $pickle_receiver_port       = '2014',
  $relay_method               = 'consistent-hashing',
  $destinations               = [],
  $carboncache_instances      = [],
  $replication_factor         = '1',
  $max_datapoints_per_message = '500',
  $max_queue_size             = '10000',
  $use_flow_control           = True,
  $use_whitelist              = False,
  $whitelist_rules            = [],
  $log_listener_connections   = True

) {

    if ! defined(Class['graphite']) {
      fail('You must include the graphite base class before using any defined types')
    }

    include graphite::config

    concat::fragment { "relay-${name}":
      target  => '/opt/graphite/conf/carbon.conf',
      order   => '20',
      content => template('graphite/part_relay.erb'),
      require => Class['graphite::install']
    }

    $init_config_file="carbon-relay-${name}"

    file { "/etc/init/${init_config_file}.conf":
      ensure  => $ensure,
      content => template('graphite/init.conf.erb'),
      mode    => '0555',
      require => Concat::Fragment["relay-${name}"]
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
