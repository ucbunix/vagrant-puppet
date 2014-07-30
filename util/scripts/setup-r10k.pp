class { 'r10k':
  version           => '1.1.4',
  sources           => {
    'puppet' => {
      'remote'  => '/root/puppet-config',
      'basedir' => "${::settings::confdir}/environments",
      'prefix'  => false,
    },
    'hiera'  => {
      'remote'  => '/root/hiera-data',
      'basedir' => "${::settings::confdir}/hiera/",
      'prefix'  => false,
    }
  },
  purgedirs         => ["${::settings::confdir}/environments"],
  manage_modulepath => true,
  modulepath        => "${::settings::confdir}/environments/\$environment/modules:/opt/puppet/share/puppet/modules",
}
