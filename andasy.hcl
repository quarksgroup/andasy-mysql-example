# andasy.hcl app configuration file for mysql-example
#
# See https://github.com/quarksgroup/andasy-cli for information about how to use this file.
# primary_region: "kgl" (Kigali) or "fsn" (Falkenstein, Germany).

app_name = "mysql-example"

app {
  primary_region = "kgl"
  image          = "mysql:8.0"

  env = {
    MYSQL_DATABASE = "app"
  }

  compute {
    cpu      = 1
    memory   = 512
    cpu_kind = "shared"
  }

  process {
    name = "mysql-example"
  }

  storage {
    name        = "mysql_data"
    destination = "/var/lib/mysql"
  }
}
