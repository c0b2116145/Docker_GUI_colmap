ARG UBUNTU_VERSION=22.04
ARG NVIDIA_CUDA_VERSION=11.8.0

FROM nvidia/cuda:${NVIDIA_CUDA_VERSION}-devel-ubuntu${UBUNTU_VERSION} AS builder

ARG COLMAP_GIT_COMMIT=main
ARG CUDA_ARCHITECTURES=86
ENV QT_XCB_GL_INTEGRATION=xcb_egl
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
        git cmake ninja-build build-essential \
        libboost-program-options-dev libboost-graph-dev libboost-system-dev \
        libeigen3-dev libflann-dev libfreeimage-dev libmetis-dev \
        libgoogle-glog-dev libgtest-dev libgmock-dev libsqlite3-dev \
        libglew-dev qtbase5-dev libqt5opengl5-dev libcgal-dev \
        libceres-dev libcurl4-openssl-dev

RUN git clone https://github.com/colmap/colmap.git && \
    cd colmap && \
    git fetch origin ${COLMAP_GIT_COMMIT} && \
    git checkout FETCH_HEAD && \
    mkdir build && cd build && \
    cmake .. -GNinja -DCMAKE_CUDA_ARCHITECTURES=${CUDA_ARCHITECTURES} \
        -DCMAKE_INSTALL_PREFIX=/colmap-install && \
    ninja install

FROM nvidia/cuda:${NVIDIA_CUDA_VERSION}-runtime-ubuntu${UBUNTU_VERSION} AS runtime

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:0

# ビルド引数
ARG RDP_USER
ARG RDP_PASS

RUN apt-get update && apt-get install -y --no-install-recommends --no-install-suggests \
    libboost-program-options1.74.0 libc6 libceres2 libfreeimage3 \
    libgcc-s1 libgl1 libglew2.2 libgoogle-glog0v5 \
    libqt5core5a libqt5gui5 libqt5widgets5 libcurl4 \
    xfce4 xfce4-terminal xfce4-clipman xrdp dbus-x11 sudo \
    xserver-xorg-core xserver-xorg-input-all xserver-xorg-video-all \
    xfonts-base x11-xserver-utils locales xorgxrdp \
    fonts-dejavu fonts-noto fonts-noto-cjk fonts-noto-color-emoji fonts-vlgothic \
    ffmpeg && \
    rm -rf /var/lib/apt/lists/* && \
    locale-gen ja_JP.UTF-8 && \
    echo "LANG=ja_JP.UTF-8" > /etc/default/locale && \
    fc-cache -fv

COPY --from=builder /colmap-install/ /usr/local/

# RDPユーザーの作成（ARGで渡す）
RUN useradd -m -s /bin/bash ${RDP_USER} && \
    echo "${RDP_USER}:${RDP_PASS}" | chpasswd && \
    usermod -aG sudo ${RDP_USER} && \
    echo xfce4-session > /home/${RDP_USER}/.xsession && \
    chown ${RDP_USER}:${RDP_USER} /home/${RDP_USER}/.xsession && \
    chmod +x /home/${RDP_USER}/.xsession

RUN echo "startxfce4" > /etc/xrdp/startwm.sh && chmod +x /etc/xrdp/startwm.sh

COPY startup.sh /root/startup.sh
RUN chmod +x /root/startup.sh

EXPOSE 3389

CMD ["/root/startup.sh"]


# ARG UBUNTU_VERSION=22.04
# ARG NVIDIA_CUDA_VERSION=11.8.0

# #
# # Docker builder stage.
# #
# FROM nvidia/cuda:${NVIDIA_CUDA_VERSION}-devel-ubuntu${UBUNTU_VERSION} AS builder

# ARG COLMAP_GIT_COMMIT=main

# ARG CUDA_ARCHITECTURES=86

# ENV QT_XCB_GL_INTEGRATION=xcb_egl

# # Prevent stop building ubuntu at time zone selection.
# ENV DEBIAN_FRONTEND=noninteractive

# # Prepare and empty machine for building.
# RUN apt-get update && \
#     apt-get install -y --no-install-recommends --no-install-suggests \
#         git \
#         cmake \
#         ninja-build \
#         build-essential \
#         libboost-program-options-dev \
#         libboost-graph-dev \
#         libboost-system-dev \
#         libeigen3-dev \
#         libflann-dev \
#         libfreeimage-dev \
#         libmetis-dev \
#         libgoogle-glog-dev \
#         libgtest-dev \
#         libgmock-dev \
#         libsqlite3-dev \
#         libglew-dev \
#         qtbase5-dev \
#         libqt5opengl5-dev \
#         libcgal-dev \
#         libceres-dev \
#         libcurl4-openssl-dev

# # Build and install COLMAP.
# RUN git clone https://github.com/colmap/colmap.git
# RUN cd colmap && \
#     git fetch https://github.com/colmap/colmap.git ${COLMAP_GIT_COMMIT} && \
#     git checkout FETCH_HEAD && \
#     mkdir build && \
#     cd build && \
#     cmake .. -GNinja -DCMAKE_CUDA_ARCHITECTURES=${CUDA_ARCHITECTURES} \
#         -DCMAKE_INSTALL_PREFIX=/colmap-install && \
#     ninja install

# #
# # Docker runtime stage.
# #
# FROM nvidia/cuda:${NVIDIA_CUDA_VERSION}-runtime-ubuntu${UBUNTU_VERSION} AS runtime

# # Minimal dependencies to run COLMAP binary compiled in the builder stage.
# # Note: this reduces the size of the final image considerably, since all the
# # build dependencies are not needed.
# RUN apt-get update && \
#     apt-get install -y --no-install-recommends --no-install-suggests \
#         libboost-program-options1.74.0 \
#         libc6 \
#         libceres2 \
#         libfreeimage3 \
#         libgcc-s1 \
#         libgl1 \
#         libglew2.2 \
#         libgoogle-glog0v5 \
#         libqt5core5a \
#         libqt5gui5 \
#         libqt5widgets5 \
#         libcurl4

# # Copy all files from /colmap-install/ in the builder stage to /usr/local/ in
# # the runtime stage. This simulates installing COLMAP in the default location
# # (/usr/local/), which simplifies environment variables. It also allows the user
# # of this Docker image to use it as a base image for compiling against COLMAP as
# # a library. For instance, CMake will be able to find COLMAP easily with the
# # command: find_package(COLMAP REQUIRED).
# COPY --from=builder /colmap-install/ /usr/local/

# # ------------ VNC ------------
# ENV DEBIAN_FRONTEND=noninteractive
# ENV DISPLAY=:0

# RUN apt-get update && \
#     apt-get install -y --no-install-recommends --no-install-suggests \
#     # Install VNC server.
#     x11vnc \
#     xvfb \
#     xfce4 \
#     xfce4-terminal \
#     xfce4-clipman \
#     # Install noVNC.
#     git \
#     xinit \
#     dbus-x11 && \
#     git clone https://github.com/novnc/noVNC.git /opt/noVNC && \
#     git clone https://github.com/novnc/websockify /opt/noVNC/utils/websockify && \
#     echo "xfce4-clipman &" >> ~/.xsession

# COPY startup.sh /root/startup.sh
# RUN chmod +x /root/startup.sh

# EXPOSE 6080

# CMD ["/root/startup.sh"]