# taken from https://github.com/vayan/docker-godot
# just upped the version to 3.1.1 and removed template installation

FROM ubuntu:xenial

ENV GODOT_VERSION "3.1.1"

RUN apt-get update && apt-get install -y \
    expect \
    ca-certificates \
    wget \
    unzip \
    python \
    python-openssl \
    && rm -rf /var/lib/apt/lists/ \
    && wget https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-stable_linux_server.64.zip \
    && mkdir ~/.cache \
    && mkdir -p ~/.config/godot \
    && unzip Godot_v${GODOT_VERSION}-stable_linux_server.64.zip \
    && mv Godot_v${GODOT_VERSION}-stable_linux_server.64 /usr/local/bin/godot 

COPY . .

CMD unbuffer godot -d server/scenes/MainServer.tscn 2>&1 | tee /var/log/server_log.txt
