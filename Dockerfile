# Build stage
FROM ubuntu:22.04 AS build

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    curl \
    git \
    unzip \
    libglu1-mesa \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    xz-utils

# Install Flutter
ARG FLUTTER_VERSION=3.29.0
RUN git clone https://github.com/flutter/flutter.git -b ${FLUTTER_VERSION} /usr/local/flutter

# Set up environment
ENV PATH="$PATH:/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin"
ENV FLUTTER_ROOT="/usr/local/flutter"

# Verify installation
RUN flutter doctor -v

# Build app
WORKDIR /app
COPY . .
RUN flutter pub get && flutter build web --release

# Production stage
FROM nginx:alpine

# Copy built files
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy Nginx config (asegúrate de tener el archivo nginx.conf)
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]