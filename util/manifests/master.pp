include git

$modulepath = [ '/tmp/master/modules' ]

# define what version of puppet we want to install here
$version = '2.7.*'

# add our puppetlabs repo, install the current version of puppet.  currently,
# this is geared towards redhat systems, but i would *love* for someone to make
# this ubuntu friendly as well.
case $::osfamily {
  'RedHat': {
    $repo = $::operatingsystemrelease ? {
      /^5/ => "http://yum.puppetlabs.com/el/5/products/${::architecture}/",
      /^6/ => "http://yum.puppetlabs.com/el/6/products/${::architecture}/",
    }
    yumrepo { 'puppetlabs':
      baseurl      => $repo,
      enabled      => '1',
      gpgcheck     => '0',
      gpgkey       => 'absent',
      http_caching => 'packages',
      before       => Package['yum-plugin-versionlock'],
    }
    package { 'yum-plugin-versionlock': ensure => installed }

    exec { "yum versionlock puppet-${version}-*; touch /tmp/vl-puppet":
      path    => '/bin:/sbin:/usr/bin:/usr/sbin',
      creates => '/tmp/vl-puppet',
      require => Package['yum-plugin-versionlock'],
    }
    exec { "yum versionlock puppet-server-${version}-*; touch /tmp/vl-puppetd":
      path    => '/bin:/sbin:/usr/bin:/usr/sbin',
      creates => '/tmp/vl-puppetd',
      require => Package['yum-plugin-versionlock'],
      before  => Class['puppet'],
    }
    $manifests_dir = '/tmp/master/manifests'
    $modules_dir = '/tmp/master/modules'
    $autosign_file = '/etc/puppet/autosign.conf'
  }

  default: {
    fail("unsupported \$::osfamily=${::osfamily}")
  }
}

# setup our symlinks
file { '/tmp/master/site.pp':
  ensure  => present,
  content => "import 'manifests/*.pp'\n",
  owner   => 'root',
  group   => 'root',
  mode    => '0444',
}
file { $autosign_file:
  ensure  => file,
  mode    => '0444',
  content => '*.lan',
}

# disable selinux before we start configuring puppet
exec { 'disable-selinux':
  command => '/usr/sbin/setenforce 0 && touch /tmp/selinux_permissive',
  creates => '/tmp/selinux_permissive',
  before  => Class['puppet']
}

exec { 'restart-firewall':
  command     => '/sbin/service iptables restart',
  refreshonly => true,
  subscribe   => Concat['/etc/sysconfig/iptables'],
}

class { 'puppet':
  master        => true,
  modulepath    => join($modulepath,':'),
  manifest      => '/tmp/master/site.pp',
  dns_alt_names => [ 'pm.lan', 'pm', 'puppet.lan', 'puppet' ],
}

iptables::rule { 'allow-rel-est-traffic':
  comment            => 'allow related/established traffic',
  chain              => 'INPUT',
  state              => 'RELATED,ESTABLISHED',
  order              => '100',
}
iptables::rule { 'allow-ssh-all':
  comment          => 'allow ssh from world',
  destination_port => [ '22' ],
  protocol         => 'tcp',
  order            => '110',
}
iptables::rule { 'allow-icmp-all':
  comment  => 'allow icmp from world',
  protocol => 'icmp',
  action   => 'ACCEPT',
  order    => '101',
}
iptables::rule { 'allow-puppetmaster':
  comment            => 'allow puppet agents to connect',
  action             => 'ACCEPT',
  destination_port   => '8140',
  protocol           => 'tcp',
  order              => '100',
}
iptables::rule { 'allow-loopback':
  comment            => 'allow loopback',
  incoming_interface => 'lo',
  action             => 'ACCEPT',
  order              => '100',
}
iptables::rule { 'input-deny-all':
  comment     => 'global deny',
  chain       => 'INPUT',
  order       => '999',
  action      => 'REJECT',
  reject_with => 'icmp-host-prohibited',
}
iptables::rule { 'forward-deny-all':
  comment     => 'global deny',
  chain       => 'FORWARD',
  order       => '999',
  action      => 'REJECT',
  reject_with => 'icmp-host-prohibited',
}
