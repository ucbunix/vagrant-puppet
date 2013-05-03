node 'nrpe.lan' {
  include eu::repo::epel
  class { 'nrpe':
    xinetd        => true,
    allowed_hosts => '169.229.216.224,127.0.0.1',
    require       => Class['eu::repo::epel'],
  }
  $check_nrpe_arr = [ '/usr/lib64/nagios/plugins/check_load',
                      '-w',
                      '15,10,5',
                      '-c',
                      '30,25,20' ]
  nrpe::command { 'check_nrpe': command => join( $check_nrpe_arr, ' ' ) }
  class { 'puppet':
    server     => 'pm.lan',
    pluginsync => undef,
  }
  include puppet::util::pluginsync
}
