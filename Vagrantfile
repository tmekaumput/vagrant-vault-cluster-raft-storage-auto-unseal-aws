# -*- mode: ruby -*-
# vi: set ft=ruby :

GID=1001
UID=1001

shared_dir="/var/shared"
kms_key_id=ENV['KMS_KEY_ID']
aws_region=ENV['AWS_REGION']
aws_access_key_id=ENV['AWS_ACCESS_KEY_ID']
aws_secret_access_key=ENV['AWS_SECRET_ACCESS_KEY']

leader_node = {
  :id => "leader_node",
  :ip => "192.168.56.170",
  :hostname => "vault-leader",
  :api_addr => "http://192.168.56.170:8200"
}

followers = [
  {
    :id => "follower_node1",
    :ip => "192.168.56.171",
    :hostname => "vault-follower1"    
  },
  {
    :id => "follower_node2",
    :ip => "192.168.56.172",
    :hostname => "vault-follower2"    
  }
]


Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "512"]
    vb.customize ["modifyvm", :id, "--cpus", "1"]
    vb.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
    vb.customize ["modifyvm", :id, "--chipset", "ich9"]
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
  end
  config.vm.define "vault_leader" do |vault_leader|
    vault_leader.vm.box = "bento/centos-7.9"
    vault_leader.vm.box_version = "202110.25.0"
    vault_leader.vm.hostname = leader_node[:hostname]
    vault_leader.vm.network "private_network", ip: leader_node[:ip]
    vault_leader.vm.network "forwarded_port", guest: 8200, host: 8300, auto_correct: true
    vault_leader.vm.provision "shell", path: "scripts/setup-user.sh", args: ["vault", UID, GID]
    vault_leader.vm.synced_folder "data/", shared_dir, owner: "vault",  group: "vault", :mount_options => ["uid=1001,gid=1001,dmode=744,fmode=744"]
    vault_leader.vm.provision "file", source: "./license.txt", destination: "/tmp/license.txt"
    vault_leader.vm.provision "shell", path: "scripts/common.sh"
    vault_leader.vm.provision "shell", path: "scripts/install-vault.sh", args: leader_node[:ip]
    vault_leader.vm.provision "shell", path: "scripts/create-systemd-unit.sh"
    vault_leader.vm.provision "shell", path: "scripts/create-configs.sh", args: [leader_node[:id], leader_node[:ip], kms_key_id, leader_node[:id], leader_node[:api_addr], aws_region, aws_access_key_id, aws_secret_access_key]
    vault_leader.vm.provision "shell", inline: "sudo systemctl enable vault.service"
    vault_leader.vm.provision "shell", inline: "sudo systemctl start vault"
    vault_leader.vm.provision "shell", path: "scripts/setup-leader-node.sh", args: shared_dir
  end

  followers.each do |follower|
    config.vm.define follower[:id] do |follower_node|
      follower_node.vm.box = "bento/centos-7.9"
      follower_node.vm.box_version = "202110.25.0"
      follower_node.vm.hostname = follower[:hostname]
      follower_node.vm.network "private_network", ip: follower[:ip]
      follower_node.vm.network "forwarded_port", guest: 8200, host: 8301, auto_correct: true
      follower_node.vm.provision "shell", path: "scripts/setup-user.sh", args: ["vault", UID, GID]
      follower_node.vm.synced_folder "data/", shared_dir, owner: "vault",  group: "vault", :mount_options => ["uid=1001,gid=1001,dmode=744,fmode=744"]
      follower_node.vm.provision "file", source: "./license.txt", destination: "/tmp/license.txt"
      follower_node.vm.provision "shell", path: "scripts/common.sh"
      follower_node.vm.provision "shell", path: "scripts/install-vault.sh", args: follower[:ip]
      follower_node.vm.provision "shell", path: "scripts/create-systemd-unit.sh"
      follower_node.vm.provision "shell", path: "scripts/create-configs.sh", args: [follower[:id], follower[:ip], kms_key_id, leader_node[:id], leader_node[:api_addr], aws_region, aws_access_key_id, aws_secret_access_key]
      follower_node.vm.provision "shell", inline: "sudo systemctl enable vault.service"
      follower_node.vm.provision "shell", inline: "sudo systemctl start vault"
    end
  end

end
