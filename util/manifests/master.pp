include git
include eu::repo::epel

# We're running in vagrant, which means we do some weirdness
$modulepath = [ '/tmp/vagrant-puppet/modules-0',
                '/tmp/vagrant-puppet/modules-1' ]

# define what version of puppet we want to install here
$version = '2.7.22'

# add our puppetlabs repo, install the current version of puppet.  currently,
# this is geared towards redhat systems, but i would *love* for someone to make
# this ubuntu friendly as well.
case $::osfamily {
  'RedHat': {
    $repo = $::operatingsystemrelease ? {
      /^5/ => "http://yum.puppetlabs.com/el/5/products/${architecture}/",
      /^6/ => "http://yum.puppetlabs.com/el/6/products/${architecture}/",
    }
    yumrepo { 'puppetlabs':
      baseurl      => $repo,
      enabled      => true,
      gpgcheck     => false,
      gpgkey       => 'absent',
      http_caching => 'packages',
    }
    package { 'yum-plugins-versionlock': ensure => installed }

    exec { "yum versionlock puppet-${version}-*; touch /tmp/vl-puppet":
      path    => '/bin:/sbin:/usr/bin:/usr/sbin',
      creates => '/tmp/vl-puppet',
      require => Package['yum-plugins-versionlock'],
    }
    exec { "yum versionlock puppet-server-${version}-*; touch /tmp/vl-puppetd":
      path    => '/bin:/sbin:/usr/bin:/usr/sbin',
      creates => '/tmp/vl-puppetd',
      require => Package['yum-plugins-versionlock'],
      before  => Package['puppet-server'],
    }
    package { 'puppet-server':
      ensure => installed,
      before => [ File[$manifests_dir], File[$autosign_file] ]
    }
    $manifests_dir = '/etc/puppet/manifests'
    $modules_dir = '/etc/puppet/modules'
    $autosign_file = '/etc/puppet/autosign.conf'
  }

  default: {
    fail("unsupported \$::osfamily=${::osfamily}")
  }
}

# setup our symlinks
file { $manifests_dir:
  ensure => link,
  target => '/tmp/vagrant-puppet/manifests',
  force  => true,
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
  manifest      => '/etc/puppet/manifests/site.pp',
  dns_alt_names => [ 'pm.lan', 'pm', 'puppet.lan', 'puppet' ],
  require       => Class['eu::repo::epel'],
}

iptables::rule { 'allow-rel-est-traffic':
  comment            => 'allow related/established traffic',
  chain              => 'INPUT',
  state              => 'RELATED,ESTABLISHED',
  priority           => '100',
}
iptables::rule { 'allow-ssh-all':
  comment          => 'allow ssh from world',
  destination_port => [ '22' ],
  protocol         => 'tcp',
  priority         => '110',
}
iptables::rule { 'allow-icmp-all':
  comment  => 'allow icmp from world',
  protocol => 'icmp',
  action   => 'accept',
  priority => '101',
}
iptables::rule { 'allow-puppetmaster':
  comment            => 'allow puppet agents to connect',
  action             => 'accept',
  destination_port   => '8140',
  protocol           => 'tcp',
  priority           => '100',
}
iptables::rule { 'allow-loopback':
  comment            => 'allow loopback',
  incoming_interface => 'lo',
  action             => 'accept',
  priority           => '100',
}
iptables::rule { 'input-deny-all':
  comment     => 'global deny',
  chain       => 'INPUT',
  priority    => '999',
  action      => 'REJECT',
  reject_with => 'icmp-host-prohibited',
}
iptables::rule { 'forward-deny-all':
  comment     => 'global deny',
  chain       => 'FORWARD',
  priority    => '999',
  action      => 'REJECT',
  reject_with => 'icmp-host-prohibited',
}
