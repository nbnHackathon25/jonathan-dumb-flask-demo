# Build stage
FROM ghcr.io/astral-sh/uv:debian

# Set environment variables for SSL/TLS
ENV UV_NATIVE_TLS=1 \
    SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt \
    CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

# Set working directory
WORKDIR /app

# Install system dependencies and update CA certificates
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    && update-ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Copy dependency files first (for better layer caching)
COPY pyproject.toml requirements.txt* ./

# Install dependencies using uv
# If no lock file exists, uv will resolve dependencies
RUN uv sync --no-dev --no-install-project || uv pip install -r requirements.txt --system

# Copy the rest of the application
COPY . .

# Expose the Flask port
EXPOSE 8080

# Set environment variables for Flask
ENV FLASK_ENV=production \
    PORT=8080

# Run the Flask app with gunicorn for production
# Using uv run ensures the virtual environment is activated
CMD ["uv", "run", "python", "-c", "from app import app; app.run(debug=False, host='0.0.0.0', port=8080)"]
