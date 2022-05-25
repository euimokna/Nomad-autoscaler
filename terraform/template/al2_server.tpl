#!/bin/bash
sudo yum update -y
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo #hashicorp repo추가 

sudo yum -y install nomad-1.2.8  # noamd 1.2.8 버전을 설치 및  netcat설치(포트 오픈 및 네트워크 확인을 위한) 

for SOLUTION in "nomad";
do
    sudo mkdir -p /var/lib/$SOLUTION/{data,plugins}
    sudo chown -R $SOLUTION:$SOLUTION /var/lib/$SOLUTION
done

sudo cat <<EOCONFIG > /etc/nomad.d/nomad.hcl
data_dir = "/var/lib/nomad/data"
bind_addr = "{{ GetInterfaceIP \"eth0\" }}"
server {
  enabled          = true
  bootstrap_expect = 1
  encrypt = "H6NAbsGpPXKJIww9ak32DAV/kKAm7vh9awq0fTtUou8="
}
advertise {
//  http = "{{ GetInterfaceIP \"eth0\" }}"
  rpc  = "{{ GetInterfaceIP \"eth0\" }}"
  serf = "{{ GetInterfaceIP \"eth0\" }}"
}

client {
  enabled = true
  network_interface = "eth0"
  options = {
   "driver.raw_exec.enable" = "1"
  }
  meta {
    "type" = "server"
  }  
}

# acl {
#   enabled = true
# }
EOCONFIG

sudo systemctl enable nomad
sudo systemctl start nomad

#UTC time change to Asia seoul time 
sudo cp /usr/share/zoneinfo/Asia/Seoul /etc/localtime