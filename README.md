A Puppet module for managing the installation of
[Graphite](http://graphite.wikidot.com/).

# Usage

## Single server deployment with just one carbon cache

```
 class { '::graphite':
    port                 => 8888,
  }

  graphite::cache { 'a':
    ensure               => present,
  }
```

## Multi server deployment with several carbon relays and caches and local memcache on each node

```
 class { '::graphite':
    port                 => 8888,
    webapp_cluster_nodes => ["10.0.0.2"],
    carbonlink_hosts     => ['127.0.0.1:7002:a','127.0.0.1:7102:b','127.0.0.1:7202:c','127.0.0.1:7302:d'],
    memcache_hosts       => ['127.0.0.1']
  }

  graphite::cache { 'a':
    ensure               => present,
    pickle_receiver_port => '2004',
    line_receiver_port   => '2003',
    cache_query_port     => '7002'
  }

  graphite::cache { 'b':
    ensure               => present,
    pickle_receiver_port => '2104',
    line_receiver_port   => '2103',
    cache_query_port     => '7102',
  }

  graphite::cache { 'c':
    ensure               => present,
    pickle_receiver_port => '2204',
    line_receiver_port   => '2203',
    cache_query_port     => '7202',
  }

  graphite::cache { 'd':
    ensure               => present,
    pickle_receiver_port => '2304',
    line_receiver_port   => '2303',
    cache_query_port     => '7302',
  }

  # destinations - lists the ip addresses of all nodes in the cluster running carbon caches
  # carboncache_instances - lists the ports and instance names of the carbon caches on a single instance (We assume that all nodes are configured the same)
  graphite::relay { 'a':
    ensure                   => present,
    pickle_receiver_port     => '2014',
    line_receiver_port       => '2013',
    replication_factor       => '2',
    destinations             => ['10.0.0.1','10.0.0.2'],
    carboncache_instances    => ['2004:a','2104:b','2204:c','2304:d'],
    log_listener_connections => False
  }
```

## Yet another module?

There are many existing graphite modules that focus on particular default installation usecases and fail to address more sophisticated deployments. The motivation behind yet another graphite module is to provide the means for managing a graphite cluster in both single and multi server configuration in the most flexible way. 

This module is under development and currently has been tested only on Ubuntu. Nevertheless porting it to another distribution should be trivial.

At the moment this module can bring up arbitrary number of carbon caches and relays and federate the graphite dashboard. It is compatible with graphite 0.9.x

