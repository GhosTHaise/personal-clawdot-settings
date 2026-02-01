FROM ubuntu:latest

# Install git and ca-certificates (needed for HTTPS cloning)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /data