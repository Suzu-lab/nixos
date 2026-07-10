# SwarmUI frontend — GPU-less. It drives the ComfyUI engine over the API (http://comfyui:8188 on
# the compose network), so all ROCm stays in the engine container. First start compiles the .NET
# project (give it a minute); the SDK image has everything it needs.
FROM mcr.microsoft.com/dotnet/sdk:8.0
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/mcmonkeyprojects/SwarmUI /SwarmUI
WORKDIR /SwarmUI
# Own the app dir by the host user (uid 1000) so the container can run as `user: "1000:100"`
# (see compose.yaml) — SwarmUI's launch-linux.sh does a git-pull + dotnet build into /SwarmUI on
# start, which a non-root user otherwise couldn't write. Generated images are then owned by you.
RUN chown -R 1000:100 /SwarmUI
EXPOSE 7801
CMD ["bash", "launch-linux.sh", "--launch_mode", "none", "--host", "0.0.0.0"]
