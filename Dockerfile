# Build stage
FROM ghcr.io/astral-sh/uv:debian

ENV UV_NATIVE_TLS=1
ENV UV_INSECURE_HOST="pypi.org,files.pythonhosted.org,pypi.python.org"
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
# Set working directory
WORKDIR /app

# Install and update ca-certificates FIRST (critical for SSL to work)
RUN apt-get update && \
    apt-get install -y ca-certificates curl && \
    update-ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Copy setup script and dependencies
COPY . ./

# Run setup script to install uv and dependencies
RUN bash setup.sh

ENTRYPOINT [ "./local_run.sh" ]
