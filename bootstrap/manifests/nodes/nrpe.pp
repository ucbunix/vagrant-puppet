node 'nrpe.lan' {
  include site::repo::epel
  class { 'nrpe':
    xinetd        => true,
    allowed_hosts => '169.229.216.224,127.0.0.1',
    require => Class['site::repo::epel'],
  }
  nrpe::command { 'check_nrpe': command => '/usr/lib64/nagios/plugins/check_load -w 15,10,5 -c 30,25,20' }
  file { '/etc/nrpe.d':
    ensure  => directory,
    recurse => true,
    purge   => true,
    force   => true,
  }
}
