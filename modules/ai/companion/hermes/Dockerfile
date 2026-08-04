# Hermes Agent image. Hermes installs to $HOME/.hermes via its script; we bake that into an
# image so it joins the `companion` docker network and reaches llama-swap / qdrant / embeddings
# by service name. This container stays alive; you drive Hermes with:
#   docker exec -it companion-hermes-1 hermes --tui
# (or run a messaging gateway as the CMD once you've configured one — e.g. Telegram for the phone).
#
# NOTE: this is the shakiest file of the scaffold — Hermes is designed for a host install, so the
# runtime deps below are a best guess. If the build or `hermes doctor` complains, add what it asks.
# Fallback if containerizing fights us: install Hermes straight on the yosai host (curl | bash) and
# point its config.yaml at 127.0.0.1:8080 instead of the service name.
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
      curl ca-certificates git python3 python3-venv nodejs npm \
    && rm -rf /var/lib/apt/lists/*

ENV HERMES_HOME=/root/.hermes
ENV PATH="/root/.local/bin:${PATH}"

# --skip-setup: don't launch the interactive first-run wizard during build; config comes in by mount.
RUN curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash -s -- --skip-setup

# Keep the container up so you can exec into the TUI / run a gateway.
CMD ["sleep", "infinity"]
