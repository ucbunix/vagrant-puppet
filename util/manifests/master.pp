#
# Bootstrap a Puppet Master with only Puppet Applied.
#
$version = '3.7.*'
$basemodulepath = '/vagrant/puppet/modules'
$environmentpath = '/vagrant/puppet/environment'
$hiera_config = '/vagrant/puppet/hiera.yaml'
$default_manifest = '/vagrant/puppet/manifests'

# we need our autosigning for development
file { '/etc/puppet/autosign.conf':
  ensure  => file,
  mode    => '0444',
  content => "*.lan\n",
  require => Class[puppet],
}

# disable selinux before we start configuring puppet
exec { 'disable-selinux':
  command => '/usr/sbin/setenforce 0 && touch /tmp/selinux_permissive',
  creates => '/tmp/selinux_permissive',
  before  => Class[puppet]
}

# restart firewalls whenever they change
exec { 'restart-firewall':
  command     => '/sbin/service iptables restart',
  refreshonly => true,
  subscribe   => Concat['/etc/sysconfig/iptables'],
}

class { 'puppet':
  master           => true,
  basemodulepath   => $basemodulepath,
  default_manifest => $default_manifest,
  dns_alt_names    => 'pm.lan,pm,puppet.lan,puppet',
  hiera_config     => $hiera_config,
  autosign         => '/etc/puppet/autosign.conf'
}

# firewall rules
iptables::rule {
  'allow-rel-est-traffic':
    comment            => 'allow related/established traffic',
    chain              => 'INPUT',
    state              => 'RELATED,ESTABLISHED',
    order              => '100';

  'allow-ssh-all':
    comment          => 'allow ssh from world',
    destination_port => [ '22' ],
    protocol         => 'tcp',
    order            => '110';

  'allow-icmp-all':
    comment  => 'allow icmp from world',
    protocol => 'icmp',
    action   => 'ACCEPT',
    order    => '101';

  'allow-puppetmaster':
    comment            => 'allow puppet agents to connect',
    action             => 'ACCEPT',
    destination_port   => '8140',
    protocol           => 'tcp',
    order              => '100';

  'allow-loopback':
    comment            => 'allow loopback',
    incoming_interface => 'lo',
    action             => 'ACCEPT',
    order              => '100';

  'input-deny-all':
    comment     => 'global deny',
    chain       => 'INPUT',
    order       => '999',
    action      => 'REJECT',
    reject_with => 'icmp-host-prohibited';

  'forward-deny-all':
    comment     => 'global deny',
    chain       => 'FORWARD',
    order       => '999',
    action      => 'REJECT',
    reject_with => 'icmp-host-prohibited';
}
