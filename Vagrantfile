# -*- mode: ruby -*-
# vi: set ft=ruby  :

machines = {
  "master" => {"memory" => "2048", "cpu" => "2", "ip" => "110", "image" => "ubuntu/jammy64"},
  "worker01" => {"memory" => "2048", "cpu" => "2", "ip" => "111", "image" => "ubuntu/jammy64"},
  "worker02" => {"memory" => "2048", "cpu" => "2", "ip" => "112", "image" => "ubuntu/jammy64"},
}

$INET_IFACE=`ip r | awk '/^default/ {printf "%s", $5; exit 0}'`
$DEFAULT_GW=`ip r | awk '/^default/ {printf "%s", $3; exit 0}'`

Vagrant.configure("2") do |config|
  config.vm.post_up_message = "Setup Descomplicando Kubernetes!!"
  config.vm.box_check_update = false
  
  if Vagrant.has_plugin?("vagrant-timezone") || Vagrant.has_plugin?("vagrant-vbguest")
    config.timezone.value = "America/Sao_Paulo"
    config.vbguest.auto_update = false
end

  machines.each do |name, conf|
    config.vm.define "#{name}" do |machine| 
      machine.vm.box = "#{conf["image"]}"
      machine.vm.hostname = "#{name}"
      machine.vm.network "public_network", bridge: "#$INET_IFACE", ip: "192.168.1.#{conf["ip"]}"

      machine.vm.provider "virtualbox" do |vb|
        vb.name = "#{name}"
        vb.memory = conf["memory"]
        vb.cpus = conf["cpu"]
      end

      if "#{name}" == "master"
        config.vm.provision "shell", inline: <<-SCRIPT
           echo "sudo su -" >> .bashrc
        SCRIPT
        # Descomente essa linha caso queira uma pasta 'data/files' dentro do lab
        #config.vm.synced_folder "data/files", "/data_host", mount_options: ["dmode=744","fmode=644","uid=1000","gid=1000"], type: "rsync"
        machine.vm.provision "shell", path: "data/master.sh"
      else
        machine.vm.provision "shell", path: "data/worker.sh" 
      end

    end
  end
  config.vm.provision "shell",
    run: "always",
    inline: "ip route add default via #$DEFAULT_GW"
end