FROM python:3.9.10-slim

LABEL maintainer="Alex Louden <alex@louden.com>"

USER root

# Install all OS dependencies
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
  apt-get install -yq --no-install-recommends \
  build-essential \
  cmake \
  git \
  wget \
  bzip2 \
  sudo \
  libsm6 \
  libxext-dev \
  libxrender1 \
  lmodern \
  pandoc \
  python-dev \
  vim \
  unzip \
  wget \
  yasm \
  pkg-config \
  libswscale-dev \
  libtbb2 \
  libtbb-dev \
  libjpeg-dev \
  libpng-dev \
  libtiff-dev \
  libavformat-dev \
  libpq-dev \
  && rm -rf /var/lib/apt/lists/*

# Required for OpenCV to build
RUN pip install numpy

WORKDIR /

# Get OpenCV 4 and unzip it
RUN wget -q -O opencv.zip https://github.com/opencv/opencv/archive/refs/heads/4.x.zip \
  && wget -q -O contrib.zip https://github.com/opencv/opencv_contrib/archive/refs/heads/4.x.zip \
  && unzip -q opencv.zip \
  && unzip -q contrib.zip \
  && mv opencv-4.x opencv \
  && mv opencv_contrib-4.x opencv_contrib \
  && ls -l \
  && rm /opencv.zip \
  && rm /contrib.zip \
  && mkdir /opencv/cmake_binary \
  && cd /opencv/cmake_binary \
  && cmake \
  -D OPENCV_EXTRA_MODULES_PATH=/opencv_contrib/modules \
  -D BUILD_TIFF=ON \
  -D BUILD_opencv_java=OFF \
  -D WITH_CUDA=OFF \
  -D ENABLE_AVX=ON \
  -D WITH_OPENGL=ON \
  -D WITH_OPENCL=ON \
  -D WITH_IPP=ON \
  -D WITH_TBB=ON \
  -D WITH_EIGEN=ON \
  -D WITH_V4L=ON \
  -D BUILD_TESTS=OFF \
  -D BUILD_PERF_TESTS=OFF \
  -D CMAKE_BUILD_TYPE=RELEASE \
  -D CMAKE_INSTALL_PREFIX=$(python -c "import sys; print(sys.prefix)") \
  -D PYTHON_EXECUTABLE=$(which python) \
  -D PYTHON_INCLUDE_DIR=$(python -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
  -D PYTHON_PACKAGES_PATH=$(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") .. \
  && make install \
  && rm -r /opencv

WORKDIR /app/data

# Install python dependencies
COPY requirements.txt /app/
RUN pip install -r /app/requirements.txt --no-cache-dir

COPY run-notebook.sh /app/
RUN chmod +x /app/run-notebook.sh

VOLUME /app/data
EXPOSE 8888

CMD ["/app/run-notebook.sh"]
