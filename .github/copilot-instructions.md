# Copilot Instructions: Flask Demo Application

## Project Overview
Simple Flask REST API demo with automated deployment workflows. Core app is `app.py` (~40 lines), tests in `test_app.py`. Designed for Docker/Kubernetes deployment with nginx sidecar pattern.

## Architecture Pattern: Sidecar Proxy
The deployment uses **nginx as a sidecar container** in Kubernetes pods:
- **Nginx container** (port 80) - Public-facing, handles health checks at `/health`
- **Flask container** (port 8080) - Internal only, shares `localhost` networking with nginx
- Both containers run in the same pod and communicate via localhost
- See `k8s-local-deployment.yaml` for the complete sidecar configuration

## Development Workflow

### Package Management: `uv` (NOT pip)
**Critical**: This project uses [uv](https://github.com/astral-sh/uv) exclusively for dependency management:
- Install deps: `uv sync --allow-insecure-host pypi.org` (NOT `pip install`)
- Run commands: `uv run python <script>` or `uv run pytest`
- All scripts automatically use `uv` - never suggest `pip` commands

### Essential Scripts (in `scripts/`)
All operations use automated bash scripts with smart port detection and Flask app discovery:

1. **`./scripts/setup.sh`** - First-time setup
   - Installs `uv` if missing, creates venv, installs deps
   - Auto-detects Flask app file and variable name (e.g., `app = Flask(__name__)`)
   - Finds available port (5000-5010 range)

2. **`./scripts/run_local.sh`** - Run dev server
   - Auto-finds available port, detects Flask app, runs with debug mode
   - Use this instead of `flask run` or `python app.py`

3. **`./scripts/run_tests.sh`** - Run tests with coverage
   - Runs pytest with verbose output (`-v --tb=short`)
   - Generates HTML coverage reports in `htmlcov/` and XML in `coverage.xml`
   - Runs `diff-cover` against `origin/main` with 80% threshold
   - View report: `open htmlcov/index.html`

4. **`./scripts/lint.sh`** - Code quality
   - Uses Ruff (NOT flake8/black) for linting and formatting
   - Auto-fixes issues with `ruff check --fix`
   - Always run before committing

5. **`./scripts/build.sh`** - Build Docker images
   - Builds both Flask app (`jonathan-flask-demo:latest`) AND nginx proxy (`jonathan-flask-nginx:latest`)
   - Auto-starts Docker Desktop on macOS if not running
   - Always build both images together

### Testing Conventions
- Use pytest fixtures: `client` fixture provides test client (see `test_app.py`)
- Test function naming: `test_<feature>_<scenario>` (e.g., `test_greet_endpoint`)
- All endpoints return JSON, test with `.get_json()` on response
- Coverage config in `pyproject.toml` under `[tool.coverage.*]`

## Docker/Kubernetes Specifics

### Port Mapping Strategy
- **Local dev**: Auto-detected 5000-5010
- **Docker (Flask only)**: 5000:5000
- **Docker (with nginx)**: 8080:80 (nginx) → flask-app:8080 (backend)
- **Kubernetes**: 30080 (NodePort) → 80 (nginx) → 8080 (Flask)

### Container Communication
Docker setup uses `--link` for container networking:
```bash
docker run -d --name flask-app jonathan-flask-demo:latest
docker run -d -p 8080:80 --link flask-app:flask-app --name nginx-proxy jonathan-flask-nginx:latest
```

### Kubernetes Deployment
- Image pull policy: `Never` (uses local Rancher Desktop images)
- Tag Flask image as `flask-app:latest` and nginx as `flask-proxy:v1.0.0` before deployment
- Apply with: `kubectl apply -f k8s-local-deployment.yaml`
- Access at: `http://localhost:30080/version`

### Dockerfile Notes
- Multi-stage build based on `ghcr.io/astral-sh/uv:debian`
- Includes CA cert setup for SSL/TLS (required for `uv`)
- Production runs on port 8080 (NOT 5000)
- Uses `uv run` for execution (keeps venv activated)

## Code Conventions

### Flask Patterns
- All routes return `jsonify()` responses (never plain dicts)
- Route decorators: Use `methods=["GET"]` explicitly
- Docstrings: One-line descriptions for every route function
- Global constants: `VERSION` constant at module top for `/version` endpoint

### API Response Structure
Standard responses include descriptive keys:
```python
{"message": "...", "greeted": name}  # /greet/<name>
{"version": VERSION}                  # /version
{"status": "healthy", "message": "..."}  # /status
```

### Environment Variables
- `FLASK_ENV=production` in Docker/K8s (never `development`)
- `PORT=8080` for containerized environments
- Nginx config uses env var substitution: `${BACKEND_HOST}`, `${BACKEND_PORT}`, `${NGINX_PORT}`

## Common Operations

### Adding a New Endpoint
1. Add route function in `app.py` with `@app.route()` decorator
2. Return `jsonify()` response
3. Add test in `test_app.py` using `client` fixture
4. Run `./scripts/run_tests.sh` to verify
5. Run `./scripts/lint.sh` before committing

### Modifying Dependencies
1. Edit `pyproject.toml` under `[project.dependencies]` or `[project.optional-dependencies.dev]`
2. Run `uv sync --allow-insecure-host pypi.org`
3. Update Dockerfile if adding production dependencies (remove `--no-dev` flag if needed)

### Debugging Docker Issues
- Flask logs: `docker logs flask-app`
- Nginx logs: `docker logs nginx-proxy`
- Check nginx config: `docker exec nginx-proxy cat /etc/nginx/nginx.conf`
- Test Flask directly: `docker run -p 5000:5000 jonathan-flask-demo:latest`

## Key Files
- `app.py` - Flask application (single file, ~40 lines)
- `test_app.py` - Pytest test suite
- `pyproject.toml` - Dependencies and coverage config (uses `uv` tooling)
- `Dockerfile` - Flask app image (port 8080)
- `Dockerfile.nginx` - Nginx proxy image
- `nginx.conf.template` - Nginx config with env var substitution
- `k8s-local-deployment.yaml` - Complete sidecar deployment pattern
