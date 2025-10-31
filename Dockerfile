# Multi-stage Dockerfile for API Contracts

# Stage 1: Build environment with all tools
FROM ubuntu:22.04 AS builder

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install base dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    pkg-config \
    libssl-dev \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Buf
RUN BUF_VERSION="1.28.1" && \
    curl -sSL "https://github.com/bufbuild/buf/releases/download/v${BUF_VERSION}/buf-Linux-x86_64" \
    -o /usr/local/bin/buf && \
    chmod +x /usr/local/bin/buf

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Python
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Install Python tools
RUN pip3 install --no-cache-dir grpcio-tools black pytest

# Install Node.js and pnpm
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g pnpm && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Stage 2: Runtime image
FROM ubuntu:22.04

# Copy tools from builder
COPY --from=builder /usr/local/bin/buf /usr/local/bin/buf
COPY --from=builder /root/.cargo /root/.cargo
COPY --from=builder /usr/bin/python3 /usr/bin/python3
COPY --from=builder /usr/bin/node /usr/bin/node
COPY --from=builder /usr/bin/npm /usr/bin/npm

ENV PATH="/root/.cargo/bin:${PATH}"

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    git \
    libssl3 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# Default command
CMD ["/bin/bash"]
