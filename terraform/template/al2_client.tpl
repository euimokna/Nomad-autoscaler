#!/bin/bash 
sudo yum update -y
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo #hashicorp repo추가 

sudo yum -y install nomad-1.2.8 nc  # noamd 1.2.8 버전을 설치 및  netcat설치(포트 오픈 및 네트워크 확인을 위한) 

for SOLUTION in "nomad";
do
    sudo mkdir -p /var/lib/$SOLUTION/{data,plugins}
    sudo chown -R $SOLUTION:$SOLUTION /var/lib/$SOLUTION
done

sudo cat <<EOCONFIG >  /etc/nomad.d/nomad.hcl
data_dir = "/var/lib/nomad/data"
bind_addr = "{{ GetInterfaceIP \"eth0\" }}"
advertise {
//  http = "{{ GetInterfaceIP \"eth0\" }}"
  rpc  = "{{ GetInterfaceIP \"eth0\" }}"
  serf = "{{ GetInterfaceIP \"eth0\" }}"
}

client {
  enabled = true
  servers = ["${server_ip}"]
  node_class = "client"  #이 설정은 nomad autoscaler job의 node_class와 동일해야 함. 
  server_join {
    retry_join = ["${server_ip}"]
  }
  options = {
   "driver.raw_exec.enable" = "1"
  }
  meta {
    "type" = "client"
  }
}

# consul {
#   address = "127.0.0.1:8500"
#   token = "" #consul join용 token
# }
EOCONFIG

#nomad enable and start 
sudo systemctl enable nomad
sudo systemctl start nomad

#UTC time change to Asia seoul time 
sudo cp /usr/share/zoneinfo/Asia/Seoul /etc/localtime