# Flask Demo Application

A simple Flask application demonstrating basic REST API endpoints with Docker containerization and Kubernetes deployment support.

## Features

- RESTful API endpoints with JSON responses
- Docker containerization with multi-stage builds
- Kubernetes deployment configurations with nginx sidecar proxy
- Automated scripts for building, testing, and deployment
- Comprehensive test suite with pytest
- Health check and status monitoring endpoints

## API Endpoints

- `GET /version` - Returns the application version (1.0.0)
- `GET /status` - Returns the application health status
- `GET /` or `GET /hello` - Returns a "Hello, World!" message
- `GET /greet/<name>` - Returns a personalized greeting for the specified name

## Project Structure

```
.
├── app.py                        # Main Flask application
├── test_app.py                   # Pytest test suite
├── pyproject.toml               # Python project configuration and dependencies
├── Dockerfile                   # Docker image for Flask app
├── Dockerfile.nginx             # Generic nginx proxy Docker image
├── nginx.conf.template          # Configurable nginx configuration
├── k8s-local-deployment.yaml    # Kubernetes deployment with nginx sidecar
├── k8s-pod-example.yaml         # Example Kubernetes pod manifest
├── NGINX-PROXY-README.md        # Detailed nginx proxy documentation
└── scripts/                     # Automation scripts
    ├── setup.sh                 # Environment setup
    ├── build.sh                 # Docker image building
    ├── run_local.sh             # Local development server
    ├── run_tests.sh             # Run test suite
    └── lint.sh                  # Code linting
```

## Quick Start

### 1. Setup

Run the automated setup script to install dependencies:

```bash
./scripts/setup.sh
```

This script will:
- Install `uv` package manager if not already installed
- Create a virtual environment
- Install all project dependencies
- Auto-detect Flask application and available ports
- Display instructions for running the app

### 2. Run Locally

Start the development server:

```bash
./scripts/run_local.sh
```

This script will:
- Auto-detect an available port (default: 5000-5010)
- Automatically find and run your Flask application
- Display all available endpoints

The server will start on `http://localhost:5000` (or the next available port)

### 3. Run Tests

Execute the test suite with coverage:

```bash
./scripts/run_tests.sh
```

This script runs:
- Full pytest test suite with verbose output
- Code coverage analysis with HTML reports
- Diff coverage for changed lines (if in a git repository)

### 4. Build Docker Images

Build both Flask and Nginx Docker images:

```bash
./scripts/build.sh
```

This script will:
- Check Docker availability and start if needed
- Build the Flask application image
- Build the Nginx proxy image
- Display instructions for running containers

### 5. Lint Code

Run code quality checks:

```bash
./scripts/lint.sh
```

This script runs:
- Ruff linter with auto-fix
- Ruff formatter for code style

## Scripts Overview

All common operations are automated through scripts in the `scripts/` directory:

| Script | Purpose | What it does |
|--------|---------|--------------|
| `setup.sh` | Initial setup | Installs `uv`, creates venv, installs dependencies, detects Flask app |
| `run_local.sh` | Run dev server | Auto-detects available port, starts Flask in debug mode |
| `run_tests.sh` | Run tests | Executes pytest with coverage and diff-coverage reporting |
| `build.sh` | Build Docker images | Builds both Flask and Nginx Docker images with validation |
| `lint.sh` | Code quality | Runs Ruff linter and formatter with auto-fix |

**All scripts include:**
- ✅ Automatic dependency detection and installation
- ✅ Smart Flask application discovery
- ✅ Port availability checking
- ✅ Comprehensive error handling
- ✅ Helpful output messages

## Docker Deployment

### Build Images (Recommended)

Use the build script to build both Flask and Nginx images:

```bash
./scripts/build.sh
```

This will build:
- `jonathan-flask-demo:latest` - Flask application
- `jonathan-flask-nginx:latest` - Nginx reverse proxy

### Run with Docker

**Option 1: Flask App Only**
```bash
docker run -p 5000:5000 jonathan-flask-demo:latest
```

**Option 2: With Nginx Proxy (Recommended)**
```bash
# Start Flask backend
docker run -d --name flask-app jonathan-flask-demo:latest

# Start Nginx proxy
docker run -d -p 8080:80 --link flask-app:flask-app --name nginx-proxy jonathan-flask-nginx:latest

# Access at http://localhost:8080
```

## Kubernetes Deployment

### Deploy to Local Kubernetes (Rancher Desktop/Minikube)

1. **Build both images** using the build script:
   ```bash
   ./scripts/build.sh
   ```

2. **Tag images for Kubernetes** (if needed):
   ```bash
   docker tag jonathan-flask-demo:latest flask-app:latest
   docker tag jonathan-flask-nginx:latest flask-proxy:v1.0.0
   ```

3. **Deploy to Kubernetes**:
   ```bash
   kubectl apply -f k8s-local-deployment.yaml
   ```

4. **Verify deployment**:
   ```bash
   kubectl get pods
   kubectl get services
   ```

5. **Access the application**:
   ```bash
   curl http://localhost:30080/version
   curl http://localhost:30080/status
   curl http://localhost:30080/hello
   curl http://localhost:30080/greet/YourName
   ```

The deployment uses the **sidecar pattern** with:
- Nginx proxy container listening on port 80 (public-facing)
- Flask application container on localhost:8080 (internal only)
- NodePort service exposing port 30080

For detailed information about the nginx proxy configuration and Kubernetes patterns, see [NGINX-PROXY-README.md](NGINX-PROXY-README.md).

## Testing the Endpoints

### Local Development (Port 5000)

```bash
# Test version endpoint
curl http://localhost:5000/version

# Test status endpoint
curl http://localhost:5000/status

# Test hello world endpoint
curl http://localhost:5000/hello

# Test personalized greeting
curl http://localhost:5000/greet/Alice
```

### Docker Container (Port 8080)

```bash
curl http://localhost:8080/version
curl http://localhost:8080/status
curl http://localhost:8080/hello
curl http://localhost:8080/greet/Bob
```

### Kubernetes Deployment (Port 30080)

```bash
curl http://localhost:30080/version
curl http://localhost:30080/status
curl http://localhost:30080/hello
curl http://localhost:30080/greet/Charlie
```

## Development Workflow

### Typical Development Flow

1. **Initial Setup** (one time):
   ```bash
   ./scripts/setup.sh
   ```

2. **Start Development Server**:
   ```bash
   ./scripts/run_local.sh
   ```

3. **Make Code Changes**

4. **Run Tests** (after changes):
   ```bash
   ./scripts/run_tests.sh
   ```
   - View coverage report: `open htmlcov/index.html`

5. **Lint Code** (before committing):
   ```bash
   ./scripts/lint.sh
   ```

6. **Build Docker Images** (when ready):
   ```bash
   ./scripts/build.sh
   ```

## Technologies Used

- **Flask 3.0.0** - Web framework
- **Python 3.9+** - Programming language
- **uv** - Fast Python package installer and resolver
- **Docker** - Containerization
- **Nginx** - Reverse proxy and load balancer
- **Kubernetes** - Container orchestration
- **pytest** - Testing framework
- **pytest-cov** - Code coverage reporting

## License

See [LICENSE](LICENSE) file for details.
