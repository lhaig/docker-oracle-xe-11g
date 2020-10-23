# For full documentation and examples, see
#     https://www.nomadproject.io/docs/job-specification/job.html
job "Oracle" {
    region      = "[[.job.region]]"
  datacenters = [ [[range $index, $value := .job.datacenters]][[if ne $index 0]],[[end]]"[[$value]]"[[end]] ]
  type        = "[[.job.type]]"


  group "DB_XS" {
    count = "[[.group.count]]"

    task "oracle-xe-11g" {
      driver = "docker"
      config {
        image = "[[.config.image]]"

        port_map {
          db = [[.config.port_map.db]]
          http = [[.config.port_map.http]]
          apex = [[.config.port_map.apex]]
        }
        }
    env {
        [[range $index, $value := .env]][[if ne $index 0]]/n[[end]] [[$value]] [[end]]
      }
      logs {
        max_files     = [[.logs.max_files]]
        max_file_size = [[.logs.max_file_size]]
      }
      resources {
       cpu    = [[.resources.cpu]]
        memory = [[.resources.memory]]

        network {
          mbits = [[.resources.network.mbits]]

          port "http" {
            static = "[[.resources.port.http]]"
          }

          port "db" {
            static = "[[.resources.port.db]]"
          }

          port "apex" {
            static = "[[.resources.port.apex]]"
          }
        }
      }
      service {
        name = "[[.service.name]]"
        tags = [ [[range $index, $value := .service.tags]][[if ne $index 0]],[[end]]"[[$value]]"[[end]] ]
        port = "[[.service.port]]"

        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

  }



  update {
    max_parallel = 1
    min_healthy_time = "5s"
    healthy_deadline = "3m"
    auto_revert = false
    canary = 0
  }
}
