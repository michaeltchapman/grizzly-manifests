# This document serves as an example of how to deploy
# basic multi-node openstack environments.
# In this scenario Quantum is using OVS with GRE Tunnels
# Swift is not included.


node base {
  $build_node_fqdn = "${::build_node_name}.${::domain_name}"

  ########### Folsom Release ###############

  # Disable pipelining to avoid unfortunate interactions between apt and
  # upstream network gear that does not properly handle http pipelining
  # See https://bugs.launchpad.net/ubuntu/+source/apt/+bug/996151 for details

  file { '/etc/apt/apt.conf.d/00no_pipelining':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => 'Acquire::http::Pipeline-Depth "0";'
  }

  # Load apt prerequisites.  This is only valid on Ubuntu systmes
  if($::package_repo == 'cisco_repo') {

    apt::source { "cisco-openstack-mirror_grizzly":
      location => $::location,
      release => "grizzly-proposed",
      repos => "main",
      key => "E8CC67053ED3B199",
      key_content => '-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.11 (GNU/Linux)

mQENBE/oXVkBCACcjAcV7lRGskECEHovgZ6a2robpBroQBW+tJds7B+qn/DslOAN
1hm0UuGQsi8pNzHDE29FMO3yOhmkenDd1V/T6tHNXqhHvf55nL6anlzwMmq3syIS
uqVjeMMXbZ4d+Rh0K/rI4TyRbUiI2DDLP+6wYeh1pTPwrleHm5FXBMDbU/OZ5vKZ
67j99GaARYxHp8W/be8KRSoV9wU1WXr4+GA6K7ENe2A8PT+jH79Sr4kF4uKC3VxD
BF5Z0yaLqr+1V2pHU3AfmybOCmoPYviOqpwj3FQ2PhtObLs+hq7zCviDTX2IxHBb
Q3mGsD8wS9uyZcHN77maAzZlL5G794DEr1NLABEBAAG0NU9wZW5TdGFja0BDaXNj
byBBUFQgcmVwbyA8b3BlbnN0YWNrLWJ1aWxkZEBjaXNjby5jb20+iQE4BBMBAgAi
BQJP6F1ZAhsDBgsJCAcDAgYVCAIJCgsEFgIDAQIeAQIXgAAKCRDozGcFPtOxmXcK
B/9WvQrBwxmIMV2M+VMBhQqtipvJeDX2Uv34Ytpsg2jldl0TS8XheGlUNZ5djxDy
u3X0hKwRLeOppV09GVO3wGizNCV1EJjqQbCMkq6VSJjD1B/6Tg+3M/XmNaKHK3Op
zSi+35OQ6xXc38DUOrigaCZUU40nGQeYUMRYzI+d3pPlNd0+nLndrE4rNNFB91dM
BTeoyQMWd6tpTwz5MAi+I11tCIQAPCSG1qR52R3bog/0PlJzilxjkdShl1Cj0RmX
7bHIMD66uC1FKCpbRaiPR8XmTPLv29ZTk1ABBzoynZyFDfliRwQi6TS20TuEj+ZH
xq/T6MM6+rpdBVz62ek6/KBcuQENBE/oXVkBCACgzyyGvvHLx7g/Rpys1WdevYMH
THBS24RMaDHqg7H7xe0fFzmiblWjV8V4Yy+heLLV5nTYBQLS43MFvFbnFvB3ygDI
IdVjLVDXcPfcp+Np2PE8cJuDEE4seGU26UoJ2pPK/IHbnmGWYwXJBbik9YepD61c
NJ5XMzMYI5z9/YNupeJoy8/8uxdxI/B66PL9QN8wKBk5js2OX8TtEjmEZSrZrIuM
rVVXRU/1m732lhIyVVws4StRkpG+D15Dp98yDGjbCRREzZPeKHpvO/Uhn23hVyHe
PIc+bu1mXMQ+N/3UjXtfUg27hmmgBDAjxUeSb1moFpeqLys2AAY+yXiHDv57ABEB
AAGJAR8EGAECAAkFAk/oXVkCGwwACgkQ6MxnBT7TsZng+AgAnFogD90f3ByTVlNp
Sb+HHd/cPqZ83RB9XUxRRnkIQmOozUjw8nq8I8eTT4t0Sa8G9q1fl14tXIJ9szzz
BUIYyda/RYZszL9rHhucSfFIkpnp7ddfE9NDlnZUvavnnyRsWpIZa6hJq8hQEp92
IQBF6R7wOws0A0oUmME25Rzam9qVbywOh9ZQvzYPpFaEmmjpCRDxJLB1DYu8lnC4
h1jP1GXFUIQDbcznrR2MQDy5fNt678HcIqMwVp2CJz/2jrZlbSKfMckdpbiWNns/
xKyLYs5m34d4a0it6wsMem3YCefSYBjyLGSd/kCI/CgOdGN1ZY1HSdLmmjiDkQPQ
UcXHbA==
=v6jg
-----END PGP PUBLIC KEY BLOCK-----',
      proxy => $::proxy,
    }

    apt::pin { "cisco":
      priority => '990',
      originator => 'Cisco'
    }
  } elsif($::package_repo == 'cloud_archive') {
    apt::source { 'openstack_cloud_archive':
      location          => "http://ubuntu-cloud.archive.canonical.com/ubuntu",
      release           => "precise-updates/grizzly",
      repos             => "main",
      required_packages => 'ubuntu-cloud-keyring',
    }
  } else {
    fail("Unsupported package repo ${::package_repo}")
  }

  class { pip: }

  # Ensure that the pip packages are fetched appropriately when we're using an
  # install where there's no direct connection to the net from the openstack
  # nodes
  if ! $::default_gateway {
    Package <| provider=='pip' |> {
      install_options => "--index-url=http://${build_node_name}/packages/simple/",
    }
  } else {
    if($::proxy) {
      Package <| provider=='pip' |> {
        # TODO(ijw): untested
        install_options => "--proxy=$::proxy"
      }
    }
  }
  # (the equivalent work for apt is done by the cobbler boot, which sets this up as
  # a part of the installation.)


  # /etc/hosts entries for the controller nodes
  host { $::controller_hostname:
	  ip => $::controller_node_internal
  }

  class { 'collectd':
    graphitehost		=> $build_node_fqdn,
	  management_interface	=> $::public_interface,
  }
}

node os_base inherits base {
  $build_node_fqdn = "${::build_node_name}.${::domain_name}"

  class { ntp:
	  servers		=> [$build_node_fqdn],
	  ensure 		=> running,
	  autoupdate 	=> true,
  }

  # Deploy a script that can be used to test nova
  class { 'openstack::test_file':
    image_type => 'cirros',
  }

  class { 'openstack::auth_file':
	  admin_password       => $admin_password,
	  keystone_admin_token => $keystone_admin_token,
	  controller_node      => $controller_node_internal,
  }

  class { "naginator::base_target": }

  # This value can be set to true to increase debug logging when
  # trouble-shooting services. It should not generally be set to
  # true as it is known to break some OpenStack components
  $verbose            = false

}

class control($internal_ip) {

  class { 'openstack::controller':
    public_address          => $controller_node_public,
    # network
    internal_address        => $controller_node_internal,
    # by default it does not enable multi-host mode
    multi_host              => $multi_host,
    verbose                 => $verbose,
    auto_assign_floating_ip => $auto_assign_floating_ip,
    mysql_root_password     => $mysql_root_password,
    admin_email             => $admin_email,
    admin_password          => $admin_password,
    keystone_db_password    => $keystone_db_password,
    keystone_admin_token    => $keystone_admin_token,
    glance_db_password      => $glance_db_password,
    glance_user_password    => $glance_user_password,

    # TODO this needs to be added
    glance_on_swift         => $glance_on_swift,

    nova_db_password        => $nova_db_password,
    nova_user_password      => $nova_user_password,
    rabbit_password         => $rabbit_password,
    rabbit_user             => $rabbit_user,
    # TODO deprecated
    #export_resources        => false,

    ######### quantum variables #############
    # need to set from a variable
    # database
    db_host     => $controller_node_address,
    quantum_db_password => "quantum",
    quantum_db_name     => 'quantum',
    quantum_db_user     => 'quantum',
    # enable quantum services
    enable_dhcp_agent     => $enable_dhcp_agent,
    enable_l3_agent       => $enable_l3_agent,
    enable_metadata_agent => $enable_metadata_agent,
    # ovs config
    ovs_local_ip        => '127.0.0.1',
    bridge_interface    => $external_interface,
    enable_ovs_agent    => true,
    # Quantum L3 Agent
    #l3_auth_url           => $quantum_l3_auth_url,
    # Keystone
    quantum_user_password => 'quantum',
    keystone_host         => $keystone_host,
    # horizon
    secret_key => 'super_secret',
  }

# Needed to ensure a proper "second" interface is online
# This same module may be useable for forcing bonded interfaces as well

  if $::node_gateway {
    network_config { $::private_interface:
      ensure => 'present',
      hotplug => false,
      family => 'inet',
      ipaddress => $::controller_node_address,
      method => 'static',
      netmask => $::node_netmask,
      options => {
        "dns-search" => $::domain_name,
        "dns-nameservers" => $::cobbler_node_ip,
        "gateway" => $::node_gateway
      },
      onboot => 'true',
      notify => Service['networking'],
    }
  } else {
    network_config { $::private_interface:
      ensure => 'present',
      hotplug => false,
      family => 'inet',
      ipaddress => $::controller_node_address,
      method => 'static',
      netmask => $::node_netmask,
      options => {
        "dns-search" => $::domain_name,
        "dns-nameservers" => $::cobbler_node_ip,
      },
      onboot => 'true',
      notify => Service['networking'],
    }
  }

  network_config { 'lo':
    ensure => 'present',
    hotplug => false,
    family => 'inet',
    method => 'loopback',
    onboot => 'true',
    notify => Service['networking'],
  }

  network_config { $::external_interface:
    ensure => 'present',
    hotplug => false,
    family => 'inet',
    method => 'static',
    ipaddress => '0.0.0.0',
    netmask => '255.255.255.255',
    onboot => 'true',
    notify => Service['networking'],
  }

  service {'networking':
    ensure => 'running',
    restart => 'true',
  }

  class { "naginator::control_target": }

}


class compute($internal_ip) {

  class { 'openstack::compute':
    internal_address   => $internal_ip,
    libvirt_type       => $libvirt_type,
    multi_host         => $multi_host,
    sql_connection     => $sql_connection,
    nova_user_password => $nova_user_password,
    rabbit_host        => $controller_node_internal,
    rabbit_password    => $rabbit_password,
    rabbit_user        => $rabbit_user,
    glance_api_servers => "${controller_node_internal}:9292",
    vncproxy_host      => $controller_node_public,
    vnc_enabled        => 'true',
    verbose            => $verbose,
    manage_volumes     => true,
    nova_volume        => 'nova-volumes',
    # quantum config
    quantum_enabled			=> false,
    quantum_url             	=> "http://${controller_node_address}:9696",
    quantum_admin_tenant_name    	=> 'services',
    quantum_admin_username       	=> 'quantum',
    quantum_admin_password       	=> 'quantum',
    quantum_admin_auth_url       	=> "http://${controller_node_address}:35357/v2.0",
    #quantum general
    quantum_log_verbose          	=> "False",
    quantum_log_debug            	=> false,
    quantum_bind_host            	=> "0.0.0.0",
    quantum_bind_port            	=> "9696",
    quantum_sql_connection       	=> "mysql://quantum:quantum@${controller_node_address}/quantum",
    quantum_auth_host            	=> $controller_node_address,
    quantum_auth_port            	=> "35357",
    quantum_rabbit_host          	=> $controller_node_address,
    quantum_rabbit_port          	=> "5672",
    quantum_rabbit_user          	=> $rabbit_user,
    quantum_rabbit_password      	=> $rabbit_password,
    quantum_rabbit_virtual_host  	=> "/",
    quantum_control_exchange     	=> "quantum",
    quantum_core_plugin            	=> "quantum.plugins.openvswitch.ovs_quantum_plugin.OVSQuantumPluginV2",
    quantum_mac_generation_retries 	=> 16,
    quantum_dhcp_lease_duration    	=> 120,
    #quantum ovs
    ovs_bridge_uplinks      	=> ["br-ex:${external_interface}"],
    ovs_bridge_mappings      	=> ['default:br-ex'],
    ovs_tenant_network_type  	=> "gre",
    ovs_network_vlan_ranges  	=> "default:1000:2000",
    ovs_integration_bridge   	=> "br-int",
    ovs_enable_tunneling    	=> "True",
    ovs_tunnel_bridge       	=> "br-tun",
    ovs_tunnel_id_ranges     	=> "1:1000",
    ovs_local_ip             	=> $internal_ip,
    ovs_server               	=> false,
    ovs_root_helper          	=> "sudo quantum-rootwrap /etc/quantum/rootwrap.conf",
    ovs_sql_connection       	=> "mysql://quantum:quantum@${controller_node_address}/quantum",
  }

  class { "naginator::compute_target": }

}


########### Definition of the Build Node #######################
#
# Definition of this node should match the name assigned to the build node in your deployment.
# In this example we are using build-node, you dont need to use the FQDN.
#
node master-node inherits "cobbler-node" {
  $build_node_fqdn = "${::build_node_name}.${::domain_name}"

  host { $build_node_fqdn:
	  ip => $::cobbler_node_ip
  }

  host { $::build_node_name:
	  ip => $::cobbler_node_ip
  }

  # Change the servers for your NTP environment
  # (Must be a reachable NTP Server by your build-node, i.e. ntp.esl.cisco.com)
  class { ntp:
	  servers 	=> [$::company_ntp_server],
  	ensure 		=> running,
	  autoupdate 	=> true,
  }

  class { 'naginator': }

  class { 'graphite':
	  graphitehost 	=> $build_node_fqdn,
  }

    # set up a local apt cache.  Eventually this may become a local mirror/repo instead
  class { apt-cacher-ng:
  	proxy 		=> $::proxy,
  	avoid_if_range  => true, # Some proxies have issues with range headers
                                 # this stops us attempting to use them
                                 # msrginally less efficient with other proxies
  }

  if ! $::default_gateway {
    # Prefetch the pip packages and put them somewhere the openstack nodes can fetch them

    file {  "/var/www":
      ensure => 'directory',
	  }

    file {  "/var/www/packages":
      ensure  => 'directory',
      require => File['/var/www'],
    }

    if($::proxy) {
      $proxy_pfx = "/usr/bin/env http_proxy=${::proxy} https_proxy=${::proxy} "
    } else {
      $proxy_pfx=""
    }
    exec { 'pip2pi':
      # Can't use package provider because we're changing its behaviour to use the cache
      command => "${proxy_pfx}/usr/bin/pip install pip2pi",
      creates => "/usr/local/bin/pip2pi",
      require => Package['python-pip'],
    }
    Package <| provider=='pip' |> {
      require => Exec['pip-cache']
    }
    exec { 'pip-cache':
      # All the packages that all nodes - build, compute and control - require from pip
      command => "${proxy_pfx}/usr/local/bin/pip2pi /var/www/packages collectd xenapi django-tagging graphite-web carbon whisper",
      creates => '/var/www/packages/simple', # It *does*, but you'll want to force a refresh if you change the line above
      require => Exec['pip2pi'],
    }
  }

  # set the right local puppet environment up.  This builds puppetmaster with storedconfigs (a nd a local mysql instance)
  class { puppet:
	  run_master 		=> true,
	  puppetmaster_address 	=> $build_node_fqdn, 
	  certname 		=> $build_node_fqdn,
	  mysql_password 		=> 'ubuntu',
  }<-

  file {'/etc/puppet/files':
	  ensure => directory,
	  owner => 'root',
	  group => 'root',
	  mode => '0755',
  }

  file {'/etc/puppet/fileserver.conf':
	  ensure => file,
	  owner => 'root',
	  group => 'root',
	  mode => '0644',
	  content => '

# This file consists of arbitrarily named sections/modules
# defining where files are served from and to whom

# Define a section "files"
# Adapt the allow/deny settings to your needs. Order
# for allow/deny does not matter, allow always takes precedence
# over deny
[files]
  path /etc/puppet/files
  allow *
#  allow *.example.com
#  deny *.evil.example.com
#  allow 192.168.0.0/24

[plugins]
#  allow *.example.com
#  deny *.evil.example.com
#  allow 192.168.0.0/24
',
    }
}

