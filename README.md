# 🚀 Andasy + MySQL Example

This guide walks you through deploying a **MySQL** server with a **persistent volume** using **Andasy**.

Andasy does not offer a managed MySQL service yet (managed Postgres is available separately). This example runs MySQL as a regular Andasy app.

## 🧰 Prerequisites

Make sure you have:

- ✅ An [Andasy](https://andasy.io) account
- 🖥️ Installed the [Andasy CLI](https://github.com/quarksgroup/andasy-cli)

## 🏷️ Choose your MySQL version

The `image` tag in `andasy.hcl` is the version you deploy. The default is `8.0`. Change it to whatever you already use.

```hcl
image = "docker.io/library/mysql:8.0"
```

Common tags: `5.7`, `8.0`, `8.4`, `9.0`, or a pin such as `8.0.40`. See [Docker Hub mysql](https://hub.docker.com/_/mysql).

This app is the **MySQL server**. Your own application is a separate Andasy app. It connects over the network after MySQL is up. Set `MYSQL_ROOT_PASSWORD` (and optional `MYSQL_USER` / `MYSQL_PASSWORD`) with `andasy secret set` after the first deploy.

⚠️ Do **not** change major versions on an existing `mysql_data` volume. Pick the version before the first deploy, or create a new volume if you need another major.

## 💾 Optional memory

`andasy.hcl` starts at **512 MiB**. That is not required — edit `compute.memory` like any other Andasy app:

- `256` — tiny trial (can be tight on MySQL 8 first boot)
- `512` — this example
- `1024+` — if the database will hold real traffic

Then redeploy.

## ⚙️ Setup Instructions

### 1️⃣ Create a New App on Andasy

Start the setup wizard (or keep the `andasy.hcl` already in this repo):

```bash
andasy setup
```

Follow the prompts. Set `app_name` in `andasy.hcl` to your app name (the file ships `mysql-example`).

Set `primary_region` to where you want the database to run:

- `kgl` — Kigali
- `fsn` — Falkenstein, Germany

The file ships `kgl` as a placeholder. Use the same region as the app that will connect to this MySQL.

### 2️⃣ Create a Persistent Volume

```bash
andasy volume create -a <mysql_app_name> -s 1 mysql_data
```

Replace `<mysql_app_name>` with your actual app name. `mysql_data` must match `storage.name` in `andasy.hcl`. `-s 1` allocates 1 GiB. This volume is mounted only on the MySQL app at `/var/lib/mysql`. Your application does not attach it.

### 3️⃣ Deploy once

Andasy can set secrets only after a release exists. Deploy first:

```bash
andasy deploy
```

MySQL may not stay up yet. That is expected. Logs may show that `MYSQL_ROOT_PASSWORD` is missing. Andasy may also warn that `https://mysql-example.andasy.dev` is not available; MySQL is not an HTTP service.

### 4️⃣ Set MySQL credentials

```bash
andasy secret set MYSQL_ROOT_PASSWORD='your-root-password' MYSQL_USER=app MYSQL_PASSWORD='your-app-password'
```

`MYSQL_DATABASE=app` is already set in `andasy.hcl`. Rename it there if you want a different database name.

### 5️⃣ Restart

```bash
andasy apps restart
andasy logs
```

Wait until logs show `ready for connections`.

## 🌐 Connecting to MySQL

MySQL listens on port `3306` inside the container. Do not use `https://<app-name>.andasy.dev` as the database host.

### From your laptop (`andasy proxy`)

```bash
andasy proxy 3306:3306
```

In another terminal:

```bash
mysql -h 127.0.0.1 -P 3306 -u app -p
```

### From your own Andasy app

Your app talks to MySQL on the private network. It does not mount `mysql_data`.

| What | Value |
| --- | --- |
| Host | `<mysql_app_name>.internal` |
| Port | `3306` |
| Database | `app` (or the `MYSQL_DATABASE` you set) |
| User | `app` (or the `MYSQL_USER` you set) |
| Password | the secret you set |

Connection string:

```
mysql://app:PASSWORD@<mysql_app_name>.internal:3306/app
```

Replace `<mysql_app_name>` with the `app_name` in this repo’s `andasy.hcl`.

### Optional: import an existing dump

If you already have a dump, restore it through the proxy using **your** database name:

```bash
andasy proxy 3306:3306
mysql -h 127.0.0.1 -P 3306 -u app -p app < your-dump.sql
```

## 🛠️ Useful commands

```bash
andasy logs
andasy ssh
andasy apps restart
```

📚 Configuration reference: [Andasy configuration](https://docs.andasy.io/docs/reference/configuration) · Volumes: [Persistent storage](https://docs.andasy.io/docs/services/volumes) · Proxy: [andasy proxy](https://docs.andasy.io/docs/services/proxy)
