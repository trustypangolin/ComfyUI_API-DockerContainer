# syntax=docker/dockerfile:1.2
FROM python:3.12.13-trixie

ARG S6_OVERLAY_VERSION=3.2.2.0

# Install git, sudo, and some tools
ARG DEBIAN_FRONTEND="noninteractive"
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      curl git nano htop sudo gosu xz-utils tzdata libgl1 ffmpeg ca-certificates \
    && echo "**** create abc user ****" \
    && useradd --uid 1000 --home /home/abc --user-group --shell /bin/false abc \
    && usermod -G users abc \
    && mkdir -p /home/abc \
    && echo "**** cleanup ****" \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/cache/apt/archives/* \
        /var/tmp/* \
        /var/log/* \
        /usr/share/man

################################################################################
# Create Python virtual environment
################################################################################
ENV VIRTUAL_ENV=/opt/venv
RUN python -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Download the latest installer
ADD https://astral.sh/uv/install.sh /uv-installer.sh

# Run the installer then remove it
RUN sh /uv-installer.sh && rm /uv-installer.sh

# Ensure the installed binary is on the `PATH`
ENV PATH="/root/.local/bin/:$PATH"

################################################################################
# Setup the build scripts
################################################################################
COPY builder-scripts/.  /builder-scripts/

################################################################################
# Pre-download torch,torchvision,torchaudio for CPU only so its cached
################################################################################
WORKDIR /builder-scripts
RUN --mount=type=cache,target=/root/.cache/pip \
    uv pip install --upgrade pip \
    && pip install \
        -r 'cpu-requirements.txt' \
        -r 'extra-requirements.txt'

################################################################################
# Pre-download a ComfyUI bundle in the image
################################################################################
WORKDIR /default-comfyui-bundle
RUN bash /builder-scripts/preload-cache.sh

################################################################################
# Pre-download ComfyUI Custom Nodes in the image and pip packages
################################################################################
WORKDIR /workspace/custom_nodes/
RUN --mount=type=cache,target=/root/.cache/pip \
    bash /builder-scripts/preload-custom_nodes.sh

################################################################################
# Final ComfyUI pip packages
################################################################################
WORKDIR /default-comfyui-bundle/ComfyUI
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install \
        -r 'manager_requirements.txt' \
        -r 'requirements.txt' \
    && chown -R abc:abc /default-comfyui-bundle \
    && chown -R abc:abc /opt/venv \
    && chown -R abc:abc /home/abc \
    && chown -R abc:abc /workspace 

# copy local files
COPY root/ /
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

# ports and volumes
EXPOSE 8188

USER abc
ENTRYPOINT ["/init"]
