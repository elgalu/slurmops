#!/usr/bin/env ruby
VAGRANTFILE_API_VERSION = "2"
BOX_IMAGE = "generic/ubuntu2004"
BOX_IMAGE_VERSION = "3.2.22"

def vagrant_init_common(config)
  config.vm.box = BOX_IMAGE
  config.vm.box_version = BOX_IMAGE_VERSION

  # This is disabled, we had several contributors who ran into issues.
  # See: https://github.com/Varying-Vagrant-Vagrants/VVV/issues/1551
  config.ssh.insert_key = true # ~/.vagrant.d/insecure_private_key

  # Only use Vagrant-provided SSH private keys (do not use any keys stored in ssh-agent). The default value is true
  # Important: keys_only breaks vagrant connectivity so commented out:
  # config.ssh.keys_only = false
  # When pty is enabled the output will be delivered in full to the UI once the command has completed.
  config.ssh.pty = true
  config.ssh.shell = "bash -l"

  # SSH Agent Forwarding
  #
  # Enable agent forwarding on vagrant ssh commands. This allows you to use ssh keys
  # on your host machine inside the guest. See the manual for `ssh-add`.
  config.ssh.forward_agent = true

  ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip
  config.vm.provision 'shell', inline: "echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys", privileged: false
  # private_key_path breaks vagrant connectivity
  # config.ssh.private_key_path = "~/.ssh/id_rsa"

  return config
end

def vagrant_finish_common(config)
  # network:
  #   version: 2
  #   renderer: networkd
  #   ethernets:
  #     eth0:
  #       dhcp4: true
  #       dhcp6: false
  #       optional: true
  #       nameservers:
  #         addresses: [8.8.8.8, 8.8.4.4, 208.67.220.220]
  # config.vm.provision "shell", inline: <<-SHELL
  #     sed -i -e 's/4\.2\.2\.1/8.8.8.8/g' -e 's/4\.2\.2\.2/8.8.4.4/g' /etc/netplan/01-netcfg.yaml
  #     netplan apply
  # SHELL

  return config
end

def set_gpu_libvirt_settings(v)
  # Enabling Virtualization and GPU Passthrough
  # https://github.com/NVIDIA/deepops/tree/master/virtual#enabling-virtualization-and-gpu-passthrough
  # In the host machine (e.g. laptop), run:
  #   echo "pci_stub"         | sudo tee -a /etc/modules
  #   echo "vfio"             | sudo tee -a /etc/modules
  #   echo "vfio_iommu_type1" | sudo tee -a /etc/modules
  #   echo "vfio_pci"         | sudo tee -a /etc/modules
  #   echo "kvm"              | sudo tee -a /etc/modules
  #   echo "kvm_amd"          | sudo tee -a /etc/modules
  #   echo "options vfio-pci ids=10de:1d01,10de:0fb8" | sudo tee -a /etc/modprobe.d/vfio.conf
  #   echo "install vfio-pci /usr/local/bin/vfio-pci-override.sh" | sudo tee -a /etc/modprobe.d/vfio.conf
  #   dmesg | grep -iA5 vfio     #=> VFIO - User Level meta-driver version: 0.3
  #   dmesg | grep -iA5 vfio_pci #=> vfio_pci: add [10de:1d01[ffffffff:ffffffff]] class 0x000000/00000000
  #                              #=> vfio_pci: add [10de:0fb8[ffffffff:ffffffff]] class 0x000000/00000000
  #   lspci -nnk -d 10de:1d01    #=> Kernel driver in use: vfio-pci
  # https://github.com/vagrant-libvirt/vagrant-libvirt#libvirt-configuration
  v.driver = "kvm"
  v.random_hostname = false
  v.memory = 6144
  v.cpus = 2
  # v.nested = true
  # https://github.com/vagrant-libvirt/vagrant-libvirt#pci-device-passthrough
  # How to automate domain/bus/slot/function detection & how to set graphics_ip and video_type
  # https://github.com/cmrfrd/Going-dutch-on-the-GPU/blob/2aa512d9bba2a38/Vagrantfile#L52-L54
  # https://github.com/jsecchiero/miner/blob/1b9db08f908cdd3a311fbeebc58a/Vagrantfile#L29-L30
  v.cpu_mode = "host-passthrough"
  # GT-1030 Bus-Id: 00000000:03:00.0
  # see: lspci -nnk | grep NVIDIA
  # Add `"GP108 [GeForce GT 1030]":"vagrant",`
  # to salt/collection/slurm/files/gpu_model_map.jinja
  v.pci :domain => '0x0000', :bus => '0x03', :slot => '0x00', :function => '0x0'
  v.kvm_hidden = true
  # Some say we must blacklist nouveau
  # https://github.com/ccdcoe/CDMCS/blob/4f93a1dd17c23/SDM/vagrant/vagrant-nvidia-jupyter/install.sh#L29-L43
  # https://github.com/190ikp/zenn-articles/blob/44dedec9249ed1b2566e929964a/articles/vagrant_libvirt_gpu.md
  #
  # "q35" which corresponds to Intel's 82Q35 chipset released in 2007
  # https://github.com/openstack/nova-specs/blob/f7394b308818e6b92/specs/wallaby/implemented/libvirt-default-machine-type.rst
  # https://kubevirt.io/user-guide/virtual_machines/virtual_hardware/#machine-type
  v.machine_type = "q35"
  # v.customize ["modifyvm", :id, "--cpuexecutioncap", "90"]
  return v
end
