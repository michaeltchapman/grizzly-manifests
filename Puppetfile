# the account where the opensack modules should come from
openstack_module_account='stackforge'
branch_name='origin/grizzly'
#openstack_module_branch=branch_name
openstack_module_branch='master'

# coe specific modules
mod 'CiscoSystems/coe', :git => "git://github.com/CiscoSystems/puppet-coe", :ref => branch_name
mod 'CiscoSystems/openstack_admin', :git => "git://github.com/CiscoSystems/puppet-openstack_admin", :ref => branch_name

# the openstack module
mod 'CiscoSystems/openstack', :git => "git://github.com/CiscoSystems/puppet-openstack", :ref => branch_name
# openstack core modules
mod 'CiscoSystems/cinder', :git => "git://github.com/#{openstack_module_account}/puppet-cinder", :ref => openstack_module_branch
mod 'CiscoSystems/glance', :git => "git://github.com/#{openstack_module_account}/puppet-glance", :ref => openstack_module_branch
mod 'CiscoSystems/keystone', :git => "git://github.com/#{openstack_module_account}/puppet-keystone", :ref => openstack_module_branch
mod 'CiscoSystems/horizon', :git => "git://github.com/#{openstack_module_account}/puppet-horizon", :ref => openstack_module_branch
mod 'CiscoSystems/nova', :git => "git://github.com/#{openstack_module_account}/puppet-nova", :ref => openstack_module_branch
mod 'CiscoSystems/quantum', :git => "git://github.com/#{openstack_module_account}/puppet-quantum", :ref => openstack_module_branch
mod 'CiscoSystems/swift', :git => "git://github.com/#{openstack_module_account}/puppet-swift", :ref => openstack_module_branch

# middleware modules
mod 'CiscoSystems/apache', :git => "git://github.com/CiscoSystems/puppet-apache", :ref => branch_name
mod 'CiscoSystems/memcached', :git => "git://github.com/CiscoSystems/puppet-memcached", :ref => branch_name
mod 'CiscoSystems/mysql', :git => "git://github.com/puppetlabs/puppet-mysql"#, :ref => branch_name
mod 'CiscoSystems/rabbitmq', :git => "git://github.com/CiscoSystems/puppet-rabbitmq", :ref => branch_name

# linux tools
mod 'CiscoSystems/apt', :git => "git://github.com/CiscoSystems/puppet-apt", :ref => branch_name
mod 'CiscoSystems/apt-cacher-ng', :git => "git://github.com/CiscoSystems/puppet-apt-cacher-ng", :ref => branch_name
mod 'CiscoSystems/cobbler', :git => "git://github.com/bodepd/puppet-cobbler", :ref => 'origin/fix_cobbler_sync_issue'
mod 'CiscoSystems/collectd', :git => "git://github.com/CiscoSystems/puppet-collectd", :ref => branch_name
mod 'CiscoSystems/corosync', :git => "git://github.com/CiscoSystems/puppet-corosync", :ref => branch_name
mod 'CiscoSystems/dnsmasq', :git => "git://github.com/CiscoSystems/puppet-dnsmasq", :ref => branch_name
mod 'CiscoSystems/drbd', :git => "git://github.com/CiscoSystems/puppet-drbd", :ref => branch_name
mod 'CiscoSystems/graphite', :git => "git://github.com/CiscoSystems/puppet-graphite", :ref => branch_name
mod 'CiscoSystems/monit', :git => "git://github.com/CiscoSystems/puppet-monit", :ref => branch_name
mod 'CiscoSystems/naginator', :git => "git://github.com/CiscoSystems/puppet-naginator", :ref => branch_name
mod 'CiscoSystems/ntp', :git => "git://github.com/CiscoSystems/puppet-ntp", :ref => branch_name
mod 'CiscoSystems/pip', :git => "git://github.com/CiscoSystems/puppet-pip", :ref => branch_name
mod 'CiscoSystems/puppet', :git => "git://github.com/CiscoSystems/puppet-puppet", :ref => branch_name
mod 'CiscoSystems/rsync', :git => "git://github.com/CiscoSystems/puppet-rsync", :ref => branch_name
mod 'CiscoSystems/sysctl', :git => "git://github.com/CiscoSystems/puppet-sysctl", :ref => branch_name
mod 'CiscoSystems/vswitch', :git => "git://github.com/CiscoSystems/puppet-vswitch", :ref => branch_name
mod 'CiscoSystems/xinetd', :git => "git://github.com/CiscoSystems/puppet-xinetd", :ref => branch_name
mod 'CiscoSystems/network', :git => "git://github.com/CiscoSystems/puppet-network", :ref => branch_name
mod 'CiscoSystems/filemapper', :git => "git://github.com/CiscoSystems/puppet-filemapper", :ref => branch_name
mod 'CiscoSystems/boolean', :git => "git://github.com/CiscoSystems/puppet-boolean", :ref => branch_name
#mod 'CiscoSystems/ssh', :git => "git://github.com/CiscoSystems/puppet-ssh", :ref => branch_name

# puppet utilities
mod 'CiscoSystems/concat', :git => "git://github.com/CiscoSystems/puppet-concat", :ref => branch_name
mod 'CiscoSystems/inifile', :git => "git://github.com/cprice-puppet/puppet-inifile", :ref => 'origin/master'
mod 'CiscoSystems/stdlib', :git => "git://github.com/CiscoSystems/puppet-stdlib", :ref => branch_name
