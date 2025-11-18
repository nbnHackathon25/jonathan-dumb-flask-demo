# Flask Demo Application

A simple Flask application demonstrating basic REST API endpoints.

## Endpoints

- `GET /version` - Returns the application version
- `GET /status` - Returns the application health status
- `GET /` or `GET /hello` - Returns a "Hello, World!" message

## Setup

1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Run the application:
   ```bash
   python app.py
   ```

3. The server will start on `http://localhost:5000`

## Testing the Endpoints

```bash
# Test version endpoint
curl http://localhost:5000/version

# Test status endpoint
curl http://localhost:5000/status

# Test hello world endpoint
curl http://localhost:5000/hello
```
