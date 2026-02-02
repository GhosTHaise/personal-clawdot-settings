# moltbot-ubuntu-docker

A minimal Ubuntu-based development container prepared for simple tasks like cloning repositories, running scripts, and keeping a small working directory mounted from the host.

This repository contains two files:

- `dockerfile` — a Dockerfile that builds an Ubuntu image and installs a few utilities (`git`, `curl`, `ca-certificates`) and sets the working directory to `/data`.
- `docker-compose.yaml` — a docker-compose configuration to build and run the image, expose a port, and mount a host directory into the container.

## Quick summary

- Image: based on `ubuntu:latest`
- Installs: `git`, `curl`, `ca-certificates`
- Working directory: `/data`
- Host folder mounted to container: `~/my_data` -> `/data`
- Port mapped: `18789` (host) -> `18789` (container)
- Container name: `my_ubuntu_container`
- Restart policy: `unless-stopped`

## Files of interest

`dockerfile` (root)

```dockerfile
FROM ubuntu:latest

# Install git and ca-certificates (needed for HTTPS cloning)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /data
```

`docker-compose.yaml` (root)

```yaml
services:
  ubuntu-box:
    build: .
    container_name: my_ubuntu_container
    stdin_open: true
    tty: true
    ports:
      - "18789:18789"
    volumes:
      - ~/my_data:/data
    working_dir: /data
    restart: unless-stopped
```

## How to build and run

From the repository root (where `docker-compose.yaml` is located):

1. Build and start the service (recommended):

```bash
docker compose up --build -d
```

or with the legacy command if you have older Docker Compose:

```bash
docker-compose up --build -d
```

2. Check running containers:

```bash
docker ps
```

3. Open a shell inside the running container:

```bash
docker exec -it my_ubuntu_container bash
```

4. Stop the container:

```bash
docker compose down
```

(or `docker-compose down` for the older command)

## Notes and tips

- Volume path: `~/my_data:/data` uses the current user's home directory. On some systems or CI environments, tilde (`~`) expansion inside `docker-compose.yaml` may not behave as expected. If you run into mount/permission errors, replace `~/my_data` with the absolute path, for example `/home/<your-username>/my_data:/data`.

- Permissions: Files created in the mounted directory will have the UID/GID of the process creating them in the container. If you need files to be owned by your host user, consider running the container processes with the host UID/GID or adjust permissions on the host directory.

- Exposed port `18789` is currently mapped but the image does not run a service that listens on that port by default. If you plan to run a web service inside the container, ensure it binds to `0.0.0.0:18789` inside the container (not `localhost`) so the host mapping works.

- The container is started with `stdin_open: true` and `tty: true`, which makes interactive shells convenient.

- Restart policy `unless-stopped` will keep the container running across host reboots unless the container was explicitly stopped.

## Customization ideas

- Add additional packages to the `apt-get install` line in the `dockerfile` (e.g., `python3`, `build-essential`, `vim`) if you need a fuller development environment.

- Add a small entrypoint script that sets up a user inside the container or runs a specific service automatically.

- If you want a smaller image, pin a specific Ubuntu distro (e.g., `ubuntu:22.04`) and remove unused packages.

## Troubleshooting

- "Port already in use": change the host side of the mapping in `docker-compose.yaml`, e.g. `18790:18789`.

- "Permission denied" when writing to the mounted folder: run `sudo chown -R $(id -u):$(id -g) ~/my_data` on the host or change the folder path to a directory your user owns.

- Build fails due to network issues on `apt-get update`: re-run the build or ensure your Docker daemon has network access.

## Example: run a simple Python HTTP server

1. Enter the container:

```bash
docker exec -it my_ubuntu_container bash
```

2. Install Python (one-off inside container) and run a server:

```bash
apt-get update && apt-get install -y python3
python3 -m http.server 18789 --bind 0.0.0.0
```

Now visiting `http://localhost:18789` on your host will show the `~/my_data` contents.

## Contributing

This repository is intentionally minimal. If you'd like to propose improvements (additional packages, automated setup, example services), open a PR or add an issue describing the change.

## License

This repository does not include a LICENSE file. Add one if you want to publish or share this project publicly with license terms.

---

If you'd like, I can:

- add a small entrypoint script and modify the `dockerfile` to create a non-root user,
- pin the Ubuntu version, or
- add example Dockerfile + compose edits to run a specific service.

Tell me which option you'd like next and I'll implement it.
# personal-clawdot-settings
