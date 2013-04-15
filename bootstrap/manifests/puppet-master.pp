node 'pm.lan' {
  include git
  include site::repo::epel

  # our puppet master modulepath
  $modulepath = [ '/var/lib/puppet/env/$environment/modules',
                  '/var/lib/puppet/env/production/modules',
                  '/etc/puppet/modules' ]

  class { 'puppet':
    master     => true,
    agent      => true,
    modulepath => $modulepath,
    service    => true,
    manifest   => '/var/lib/puppet/env/$environment/manifests/site.pp',
  }
}
