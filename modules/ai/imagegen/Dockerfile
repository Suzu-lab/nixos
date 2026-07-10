# ComfyUI engine image — ROCm PyTorch inside the container, nothing ROCm on the NixOS host.
#
# Base image: ROCm 7.2 is the primary target — per ROCm/TheRock#1795 it fixes the gfx1201 stall
# (ROCm/ROCm#5581) that plagued 7.0/7.1 *and* is ~2× faster than 6.4.4. The 6.4.4 tag stays here
# commented as the one-line rollback: if generation ever stalls (GPU pinned at 100% but power/temp
# sag, no progress), swap the FROM line, rebuild, and you're back on the last known-good stack.
FROM rocm/pytorch:rocm7.2.4_ubuntu24.04_py3.12_pytorch_release_2.9.1
# Rollback (known-good, no stall bug, slower):
# FROM rocm/pytorch:rocm6.4.4_ubuntu24.04_py3.12_pytorch_release_2.7.1

# Pin to a ComfyUI release tag for reproducible rebuilds. `master` works for the first build;
# once verified, set this to a tag (e.g. --build-arg COMFYUI_REF=v0.3.x) and rebuild.
ARG COMFYUI_REF=master

RUN git clone https://github.com/comfyanonymous/ComfyUI /ComfyUI && \
    cd /ComfyUI && git checkout "${COMFYUI_REF}"

WORKDIR /ComfyUI

# The base image ships a ROCm-built torch/torchvision/torchaudio. Strip them from ComfyUI's
# requirements so pip cannot replace them with CUDA/CPU wheels. (torchsde etc. remain and resolve
# against the already-installed ROCm torch.) This grep filter is the template for neutralizing any
# custom-node pack that force-pins torch.
RUN grep -vE '^(torch|torchvision|torchaudio)([=<>!~ ]|$)' requirements.txt > /tmp/requirements.txt && \
    pip install --no-cache-dir -r /tmp/requirements.txt

# Python deps for custom-node packs get baked in here (not runtime-installed — those die with the
# container). Workflow: clone node into custom_nodes/ → add its deps to extra-requirements.txt →
# `docker compose build` → restart.
COPY extra-requirements.txt /tmp/extra-requirements.txt
RUN pip install --no-cache-dir -r /tmp/extra-requirements.txt

EXPOSE 8188
# --temp-directory lives under the writable cache mount so ComfyUI can run as a non-root user
# (the image's /ComfyUI/temp is root-owned). See compose.yaml (user: 1000:100, HOME=/cache).
CMD ["python3", "main.py", "--listen", "0.0.0.0", "--port", "8188", "--temp-directory", "/cache/temp"]
