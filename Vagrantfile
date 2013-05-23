# -*- mode: ruby -*-
# vi: set ft=ruby :

# Four networks:
# 0 - VM host NAT
# 1 - COE build/deploy
# 2 - COE openstack internal
# 3 - COE openstack external (public)


# Since puppet uses hostnames to determine which node is which
# we have a small shell provisioner to set hostnames to be
# different on each node.

Vagrant::Config.run do |config|

  config.vm.define :cache do |cache_config|
    cache_config.vm.box = "precise64"
    cache_config.vm.box_url = 'http://files.vagrantup.com/precise64.box'
    cache_config.vm.network :hostonly, "192.168.242.99"
    cache_config.vm.network :hostonly, "10.2.3.99"
    cache_config.vm.network :hostonly, "10.3.3.99"
    cache_config.vm.customize ['modifyvm', :id, '--name', 'cache']
    cache_config.vm.host_name = 'cache'
    cache_config.vm.provision :shell do |shell|
      shell.inline = "apt-get update; apt-get install apt-cacher-ng -y; cp /vagrant/01apt-cacher-ng-proxy /etc/apt/apt.conf.d; apt-get update;sysctl -w net.ipv4.ip_forward=1;"
    end
  end

  # Cobbler based "build" server
  config.vm.define :build do |build_config|
    build_config.vm.box = "precise64"
    build_config.vm.box_url = 'http://files.vagrantup.com/precise64.box'
    build_config.vm.customize ["modifyvm", :id, "--name", 'build-server']
    build_config.vm.host_name = 'build-server'
    build_config.vm.network :hostonly, "192.168.242.100"
    build_config.vm.network :hostonly, "172.16.2.1"
    build_config.vm.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
    build_config.vm.network :hostonly, "10.3.3.100"

    build_config.vm.provision :shell do |shell|
        shell.inline = "cp /vagrant/sources.list /etc/apt"
    end

    build_config.vm.provision :shell do |shell|
      shell.inline = "cp /vagrant/dhclient.conf /etc/dhcp;cp /vagrant/01apt-cacher-ng-proxy /etc/apt/apt.conf.d; apt-get update; dhclient -r eth0 && dhclient eth0; apt-get install -y git vim puppet curl;"
    end

    build_config.vm.provision :shell do |shell|
        shell.inline = "apt-get install -y cobbler; cobbler-ubuntu-import -m http://mirror.optus.net/ubuntu precise-x86_64"
    end    

    # now run puppet to install the build server
    build_config.vm.provision(:puppet, :pp_path => "/etc/puppet") do |puppet|
      puppet.manifests_path = 'manifests'
      puppet.manifest_file  = "site.pp"
      puppet.module_path    = 'modules'
      puppet.options        = ['--verbose', '--trace', '--debug']
    end

    build_config.vm.provision :shell do |shell|
      shell.inline = 'if [ ! -h /etc/puppet/modules ]; then rmdir /etc/puppet/modules;ln -s /etc/puppet/modules-0 /etc/puppet/modules; fi;puppet plugin download --server build-server.domain.name;service apache2 restart'
    end

    # enable ip forwarding and NAT so that the build server can act
    # as an external gateway for the quantum router.
    build_config.vm.provision :shell do |shell|
        shell.inline = "sysctl -w net.ipv4.ip_forward=1; iptables -A FORWARD -o eth0 -i eth1 -s 172.16.2.0/24 -m conntrack --ctstate NEW -j ACCEPT; iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT; iptables -t nat -F POSTROUTING; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE"
    end
  end

  # Openstack control server
  config.vm.define :control_pxe do |control_config|
    control_config.vm.customize(['modifyvm', :id ,'--nicbootprio2','1'])
    control_config.vm.box = 'blank'
    control_config.vm.boot_mode = 'gui'
    control_config.ssh.port = 2727
    control_config.vm.network :hostonly, "192.168.242.10", :mac => "001122334455"
    control_config.vm.network :hostonly, "10.2.3.10"
    control_config.vm.network :hostonly, "10.3.3.10"
  end

  config.vm.define :control_basevm do |control_config|
    control_config.vm.box = "precise64"
    control_config.vm.box_url = 'http://files.vagrantup.com/precise64.box'
    control_config.vm.customize ["modifyvm", :id, "--name", 'control-server']
    control_config.vm.customize ["modifyvm", :id, "--memory", 1536]
    control_config.vm.host_name = 'control-server.domain.name'
    # you cannot boot this at the same time as the control_pxe b/c they have the same ip address
    control_config.vm.network :hostonly, "192.168.242.10"
    control_config.vm.network :hostonly, "10.2.3.10"
    control_config.vm.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
    control_config.vm.network :hostonly, "10.3.3.10"
    control_config.vm.provision :shell do |shell|
        shell.inline = "cp /vagrant/sources.list /etc/apt"
    end
    control_config.vm.provision :shell do |shell|
      shell.inline = 'echo "192.168.242.100 build-server build-server.domain.name" >> /etc/hosts;cp /vagrant/01apt-cacher-ng-proxy /etc/apt/apt.conf.d; apt-get update;apt-get install ubuntu-cloud-keyring'
    end
    node_name = "control-server-#{Time.now.strftime('%Y%m%d%m%s')}"
    control_config.vm.provision(:puppet_server) do |puppet|
      puppet.puppet_server = 'build-server.domain.name'
      puppet.options       = ['-t', '--pluginsync', '--trace', "--certname #{node_name}"]
    end
    # TODO install from puppet
  end

  # Openstack compute server
  config.vm.define :compute_pxe do |compute_config|
    compute_config.vm.customize(['modifyvm', :id ,'--nicbootprio2','1'])
    compute_config.vm.box = 'blank'
    compute_config.vm.boot_mode = 'gui'
    compute_config.ssh.port = 2728
    compute_config.vm.network :hostonly,  "192.168.242.21", :mac => "001122334466"
    compute_config.vm.network :hostonly, "10.2.3.21"
    compute_config.vm.network :hostonly, "10.3.3.21"
  end

  config.vm.define :compute_basevm do |compute_config|
    compute_config.vm.box = "precise64"
    compute_config.vm.box_url = 'http://files.vagrantup.com/precise64.box'
    compute_config.vm.customize ["modifyvm", :id, "--name", 'compute-server02']
    compute_config.vm.host_name = 'compute-server02.domain.name'
    compute_config.vm.customize ["modifyvm", :id, "--memory", 2512]
    compute_config.vm.network :hostonly, "192.168.242.21"
    compute_config.vm.network :hostonly, "10.2.3.21"
    compute_config.vm.network :hostonly, "10.3.3.21"
    compute_config.vm.provision :shell do |shell|
        shell.inline = "cp /vagrant/sources.list /etc/apt"
    end
    compute_config.vm.provision :shell do |shell|
      shell.inline = 'echo "192.168.242.100 build-server build-server.domain.name" >> /etc/hosts;cp /vagrant/01apt-cacher-ng-proxy /etc/apt/apt.conf.d; apt-get update;apt-get install ubuntu-cloud-keyring'
    end
    node_name = "compute-server02-#{Time.now.strftime('%Y%m%d%m%s')}"
    compute_config.vm.provision(:puppet_server) do |puppet|
      puppet.puppet_server = 'build-server.domain.name'
      puppet.options       = ['-t', '--pluginsync', '--trace', "--certname #{node_name}"]
    end
    # TODO install from puppet
  end

end
