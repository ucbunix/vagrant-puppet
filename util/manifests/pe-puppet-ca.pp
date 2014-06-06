# Configures our Puppet CA

# Setup some iptables rules
$rules = {
  'allow puppet' => { 'destination_port' => '8140',
                      'order' => '200', },

  'allow web traffic' => { 'destination_port' => '80,443',
                            'order' => '210', },

  'allow loopback traffic' => { 'incoming_interface' => 'lo',
                                'protocol' => 'all', },

  'allow rel/est traffic' => { 'state' => 'REL,EST',
                                'protocol' => 'all', },

  'allow ssh traffic' => { 'destination_port' => '22', },
}

$rule_defaults = {
  'protocol' => 'tcp',
  'order'    => '100',
  'notify'   => 'Service["iptables"], Service["ip6tables"]',
}

create_resources('iptables::rule', $rules, $rule_defaults)

# setup our autosign file
file { '/etc/puppetlabs/puppet/autosign.conf':
  ensure  => file,
  content => "*.lan\n",
}

# configure our puppet.conf file
$puppet_conf_defaults = {
  'section' => 'main',
  'path'    => '/etc/puppetlabs/puppet/puppet.conf',
  'notify'  => 'Service["pe-httpd"]',
}

$puppet_conf_settings = {
  'modulepath' => { 'setting' => 'modulepath',
                    'value' => '/mnt/puppet/modules:/opt/puppet/share/puppet/modules/', },

  'manifest' => { 'setting' => 'manifest',
                  'value' => '/mnt/puppet/manifests/site.pp', },

}
create_resources('ini_setting', $puppet_conf_settings, $puppet_conf_defaults)

service { 'pe-httpd': ensure => running }
service { [ 'iptables', 'ip6tables' ]: ensure => running }
