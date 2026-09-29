# Change MYSQL_VERSION to any official MySQL tag you already use
# (5.7, 8.0, 8.4, 9.0, or a pin like 8.0.40).
# https://hub.docker.com/_/mysql
ARG MYSQL_VERSION=8.0
FROM mysql:${MYSQL_VERSION}

# Do not put passwords here. Set them with:
#   andasy secret set MYSQL_ROOT_PASSWORD=... MYSQL_USER=app MYSQL_PASSWORD=...
# MYSQL_DATABASE comes from andasy.hcl.
#
# bind-address=* so other Andasy apps (<app>.internal) and `andasy proxy`
# can connect. Do not bind to 127.0.0.1.
# innodb-buffer-pool-size fits the example's 512 MiB; raise it if you raise memory.
CMD ["mysqld", "--bind-address=*", "--character-set-server=utf8mb4", "--collation-server=utf8mb4_unicode_ci", "--innodb-buffer-pool-size=128M"]
