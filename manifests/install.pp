# Class: graphite::install
#
# Installs whisper, carbon and graphite-web using pip
#
#
class graphite::install {

  class { 'python':
    pip => true,
    dev => true
  }

  ensure_packages([
    'python-ldap',
    'python-cairo',
    'python-django',
    'python-twisted',
    'python-django-tagging',
    'python-simplejson',
    'libapache2-mod-python',
    'python-memcache',
    'python-pysqlite2',
    'python-support',
  ])

  Package['python-pip'] -> Package <| provider == 'pip' and ensure != absent and ensure != purged |>

  #There is a bug in carbon and unfortunately we cannot use
  #this for carbon and graphite-web. FFS!
  package { ['whisper']:
    ensure   => installed,
    provider => pip,
    require  => Class['python'],
  }

  exec { 'carbon':
    command => 'pip install carbon',
    require => Package['whisper'],
    creates => '/opt/graphite/bin/carbon-cache.py',
    path    => ['/usr/bin', '/usr/sbin'],
    timeout => 100
  }

  exec { 'graphite-web':
    command => 'pip install graphite-web',
    require => Exec['carbon'],
    creates => '/opt/graphite/webapp/graphite/settings.py',
    path    => ['/usr/bin', '/usr/sbin'],
    timeout => 100
  }

  file { '/var/log/carbon':
    ensure => directory,
    owner  => www-data,
    group  => www-data,
  }

  file {'/var/lib/graphite':
    ensure => directory,
    owner  => www-data,
    group  => www-data,
  }

  file {'/var/lib/graphite/db.sqlite3':
    ensure => present,
    owner  => www-data,
    group  => www-data,
  }

}
