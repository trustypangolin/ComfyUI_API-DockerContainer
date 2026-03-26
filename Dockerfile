FROM python:3.12.13-trixie

ARG S6_OVERLAY_VERSION=3.2.2.0

# Install git, sudo, and some tools
ARG DEBIAN_FRONTEND="noninteractive"
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      curl git nano htop sudo gosu xz-utils tzdata \
    && echo "**** create abc user and make our folders ****" \
    && useradd -u 1000 -U -d /config -s /bin/false abc \
    && usermod -G users abc \
    && mkdir -p \
        /config \
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

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

################################################################################
# Setup the build scripts
################################################################################
COPY builder-scripts/.  /builder-scripts/

################################################################################
# Create Python virtual environment
################################################################################
ENV VIRTUAL_ENV=/opt/venv
RUN python -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

################################################################################
# Pre-download torch,torchvision,torchaudio for CPU only so its cached
################################################################################
WORKDIR /builder-scripts
RUN --mount=type=cache,target=/opt/venv/.cache/pip \
    pip install --upgrade pip

RUN --mount=type=cache,target=/opt/venv/.cache/pip \
    pip install \
        -r 'cpu-requirements.txt' \
        -r 'extra-requirements.txt' \
    && pip list

################################################################################
# Pre-download a ComfyUI bundle in the image
################################################################################
WORKDIR /default-comfyui-bundle
RUN bash /builder-scripts/preload-cache.sh

################################################################################
# Pre-download ComfyUI Custom Nodes in the image and pip packages
################################################################################
WORKDIR /default-comfyui-bundle/ComfyUI/custom_nodes/
RUN --mount=type=cache,target=/opt/venv/.cache/pip \
    bash /builder-scripts/preload-custom_nodes.sh \
    && pip list

################################################################################
# Final ComfyUI pip packages
################################################################################
WORKDIR /default-comfyui-bundle/ComfyUI
RUN --mount=type=cache,target=/opt/venv/.cache/pip \
    pip install \
        -r 'manager_requirements.txt' \
        -r 'requirements.txt' \
    && pip list

COPY runner-scripts/.  /runner-scripts/

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8188

ENTRYPOINT ["/init"]
