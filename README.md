# Flask Demo Application

A simple Flask application demonstrating basic REST API endpoints.

## Endpoints

- `GET /version` - Returns the application version
- `GET /status` - Returns the application health status
- `GET /` or `GET /hello` - Returns a "Hello, World!" message

## Setup

### Quick Setup

Run the setup script:
```bash
./setup.sh
```

This will automatically install `uv` (if needed), create a virtual environment, and install dependencies.

### Manual Setup

1. Install `uv` (if not already installed):
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```

2. Create virtual environment and install dependencies:
   ```bash
   uv venv
   uv pip install -e .
   ```

3. Activate the virtual environment:
   ```bash
   source .venv/bin/activate
   ```

4. Run the application:
   ```bash
   python app.py
   ```

   Or run directly with `uv`:
   ```bash
   uv run python app.py
   ```

5. The server will start on `http://localhost:5000`

## Testing the Endpoints

```bash
# Test version endpoint
curl http://localhost:5000/version

# Test status endpoint
curl http://localhost:5000/status

# Test hello world endpoint
curl http://localhost:5000/hello
```
