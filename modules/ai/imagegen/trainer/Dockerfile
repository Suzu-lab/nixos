# Anima LoRA training image — diffusion-pipe on ROCm, inside the container (nothing ROCm on the host,
# same philosophy as the ComfyUI engine). This is an ON-DEMAND service: `docker compose run`, not a
# long-running `up -d` (see compose.yaml, profile "train"). It shares the exact ROCm/torch stack the
# inference engine is validated on, so if inference works, training has the same GPU userspace.
#
# Anima is a DiT model (Qwen-image VAE + a Qwen3-0.6B text encoder), NOT SDXL — diffusion-pipe is the
# model author's own trainer and the one place `type = 'anima'` is supported. Training toolchains for
# RDNA4 are younger than inference; if a rebuild fights back, CivitAI's on-site trainer is the fallback.
FROM rocm/pytorch:rocm7.2.4_ubuntu24.04_py3.12_pytorch_release_2.9.1
# Rollback (same known-good tag the engine falls back to):
# FROM rocm/pytorch:rocm6.4.4_ubuntu24.04_py3.12_pytorch_release_2.7.1

# Pin to a diffusion-pipe commit/tag for reproducible rebuilds once a training run works end to end.
# `main` gets you current Anima support; bump deliberately. Submodules are REQUIRED (the repo vendors
# code under submodules/) — clone recursively and keep them in sync on every bump.
ARG DIFFUSION_PIPE_REF=main

RUN git clone --recurse-submodules https://github.com/tdrussell/diffusion-pipe /diffusion-pipe && \
    cd /diffusion-pipe && git checkout "${DIFFUSION_PIPE_REF}" && \
    git submodule update --init --recursive

WORKDIR /diffusion-pipe

# Same guard as the engine Dockerfile: the ROCm base image already ships a ROCm-built
# torch/torchvision/torchaudio. Strip them from diffusion-pipe's requirements so pip cannot replace
# them with CUDA/CPU wheels. deepspeed, transformers, safetensors, etc. remain and resolve against the
# already-installed ROCm torch. (deepspeed JIT-compiles its ops at runtime; the base image has hipcc.)
RUN grep -vE '^(torch|torchvision|torchaudio)([=<>!~ ]|$)' requirements.txt > /tmp/requirements.txt && \
    pip install --no-cache-dir -r /tmp/requirements.txt

# No baked ENTRYPOINT/long CMD — this container is driven by `docker compose run` with the deepspeed
# invocation supplied by compose.yaml's `command:` (overridable per run). A bare default just prints help.
CMD ["python3", "train.py", "--help"]
