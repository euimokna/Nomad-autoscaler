locals {
    autoscaler_ver = "0.3.3"
    #autoscaler_ver = "0.3.3"   #first version
}

job "autoscaler" {
  datacenters = ["dc1"]

  constraint {
    attribute = meta.type
    value     = "server"   
  }

  group "autoscaler" {
    count = 1

    network {
      port "http" {}
    }

    task "autoscaler" {
      //   driver = "docker"
      //   config {
      //     image   = "hashicorp/nomad-autoscaler:0.3.6"
      //     command = "nomad-autoscaler"
      //     args = [
      //       "agent",
      //       "-config",
      //       "$${NOMAD_TASK_DIR}/config.hcl",
      //       "-policy-dir",
      //       "$${NOMAD_TASK_DIR}/policies/",
      //     ]
      //     ports = ["http"]
      //   }
      driver = "exec"

      config {
        command = "/usr/local/bin/nomad-autoscaler"
        args = [
          "agent",
          "-config",
          "$${NOMAD_TASK_DIR}/config.hcl",
          "-http-bind-address",
          "0.0.0.0",
          "-http-bind-port",
          "$${NOMAD_PORT_http}",
          "-policy-dir",
          "$${NOMAD_TASK_DIR}/policies/",
        ]
      }

      artifact {
        source      = "https://releases.hashicorp.com/nomad-autoscaler/${local.autoscaler_ver}/nomad-autoscaler_${local.autoscaler_ver}_linux_amd64.zip"
        destination = "/usr/local/bin"
      }
      template {
        data        = <<EOF
nomad {
  address = "http://{{env "attr.unique.network.ip-address" }}:4646"  #Adding nomad server addresss
  #token = "<Adding nomad server token>"   
}

apm "nomad-apm" {
  driver = "nomad-apm"
  config  = {
    address = "http://{{env "attr.unique.network.ip-address" }}:4646"
  }  
}

// dynamic_application_sizing {
//   // Lower the evaluate interval so we can reproduce recommendations after only
//   // 5 minutes, rather than having to wait for 24hrs as is the default.
//   evaluate_after = "5m"
// }

log_level = "DEBUG"

target "aws-asg" {
  driver = "aws-asg"
  config = {
    aws_region = "{{ $x := env "attr.platform.aws.placement.availability-zone" }}{{ $length := len $x |subtract 1 }}{{ slice $x 0 $length}}"
  }
}

strategy "target-value" {
  driver = "target-value"
}

  EOF
        destination = "$${NOMAD_TASK_DIR}/config.hcl"
      }
      template {
        data = <<EOF
scaling "cluster_policy_nomadclient" {
  enabled = true
  min     = 1
  max     = 100
  
  policy {
    cooldown            = "7m"
    evaluation_interval = "10s"
    
    check "mem_allocated_percentage" {
      source = "nomad-apm"
      query  = "percentage-allocated_memory"
      strategy "target-value" {
        target = 70
      }
    }

    // check "cpu_allocated_percentage" {
    //   source = "nomad-apm"
    //   query  = "percentage-allocated_cpu"

    //   strategy "target-value" {
    //     target = 70
    //   }
    // }    

    target "aws-asg" {
      dry-run             = "false"
      aws_asg_name        = "nomad_client_autoscaler"  # aws Autoscaling 그룹의 이름과 동일  
      node_class          = "client" # Nomad Client에 node_class속성 추가
      node_drain_deadline = "7m"
      node_purge          = "true"
    }
  }
}

EOF
        destination = "$${NOMAD_TASK_DIR}/policies/hashistack.hcl"
      }

      resources {
        cpu    = 50
        memory = 128
      }

      service {
        name = "autoscaler"
        port = "http"

        check {
          type     = "http"
          path     = "/v1/health"
          interval = "5s"
          timeout  = "2s"
        }
      }
    }
  }
}