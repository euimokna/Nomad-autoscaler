# nomad namespace apply -description "ServiceMesh Sample" mesh

locals {
  mode     = "Legacy"
  namespace = "default"
  #artifact = "https://hashicorpjp.s3.ap-northeast-1.amazonaws.com/masa/Snapshots2021Jan_Nomad/frontback.tgz"
  artifact = "https://github.com/Great-Stone/Snapshots_2021Jan_Pseudo-containerized/raw/main/frontback.tgz"
  node = "https://github.com/Great-Stone/Snapshots_2021Jan_Pseudo-containerized/raw/main/nodejs-linux"
  subject    = "client"
}

variables {
  frontend_port = 8080
  upstream_port = 10000
}

variable "attrib_v1" {
  type = object({
    version    = string
    task_count = number
    text_color = string
  })
  default = {
    version    = "v1"
    task_count = 1
    text_color = "green"
  }
}

variable "attrib_v2" {
  type = object({
    version    = string
    task_count = number
    text_color = string
  })
  default = {
    version    = "v2"
    task_count = 1
    text_color = "red"
  }
}

job "frontback_job" {

  region = "global"
  datacenters = ["dc1"]
  namespace = local.namespace

  type = "service"

  constraint {
    #attribute = "${meta.subject}"
    attribute = "${meta.type}"
    value     = local.subject
  }

  group "backend_group_v1" {
    

    count = 1

    scaling {
        min = 0
        max = 100
    }

    consul {
      namespace = local.namespace
    }

    network {
      port "http" {}
    }

    service {
      name = "backend"
      port = "http"

      meta {
        version = var.attrib_v1["version"]
      }

      check {
        type     = "http"
        path     = "/"
        interval = "5s"
        timeout  = "3s"
      }

      tags = [
        "Snapshots",
        "Backend",
        local.mode,
        var.attrib_v1["version"]
      ]
    }

    task "backend" {

      driver = "exec"

      artifact {
        source = local.artifact
      }

      env {
        COLOR   = var.attrib_v1["text_color"]
        MODE    = local.mode
        TASK_ID = NOMAD_ALLOC_INDEX
        ADDR    = NOMAD_ADDR_http
        PORT    = NOMAD_PORT_http
        VERSION = var.attrib_v1["version"]
        # IMG_SRC		= "${local.img_dir}${var.attrib_v1["version"]}.png"
      }

      config {
        command = "backend"
      }

      resources {
        memory = 256 # reserve 256 MB
        cpu    = 100 # reserve 100 MHz
      }

    }

    reschedule {
      delay          = "30s"
      delay_function = "constant"
    }
  }
}