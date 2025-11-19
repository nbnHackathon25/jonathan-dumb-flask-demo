# Generic Nginx Proxy for Kubernetes Sidecar Pattern

This directory contains a generic, reusable Nginx proxy container designed to run as a sidecar in Kubernetes pods alongside Flask (or other) application containers.

## Architecture

The proxy uses the **Kubernetes sidecar pattern** where:
- Nginx container listens on port 80 (public-facing)
- Application container listens on localhost:8080 (internal only)
- Both containers share the same network namespace via pod networking
- External traffic → Nginx (port 80) → Application (localhost:8080)

## Files

- `Dockerfile.nginx` - Generic nginx proxy Docker image
- `nginx.conf.template` - Configurable nginx configuration (uses env vars)
- `k8s-pod-example.yaml` - Example Kubernetes pod manifest with both containers

## Building the Nginx Proxy Image

```bash
# Build the image
docker build -f Dockerfile.nginx -t your-registry/nginx-proxy:latest .

# Push to your container registry
docker push your-registry/nginx-proxy:latest
```

## Configuration

The nginx proxy is configured entirely through environment variables:

### Required Variables
- `BACKEND_HOST` - Backend application hostname (default: `localhost`)
- `BACKEND_PORT` - Backend application port (default: `8080`)

### Optional Variables
- `NGINX_PORT` - Port nginx listens on (default: `80`)
- `NGINX_WORKER_PROCESSES` - Worker process count (default: `auto`)
- `NGINX_WORKER_CONNECTIONS` - Connections per worker (default: `1024`)
- `PROXY_READ_TIMEOUT` - Backend read timeout (default: `60s`)
- `PROXY_CONNECT_TIMEOUT` - Backend connect timeout (default: `60s`)
- `PROXY_SEND_TIMEOUT` - Backend send timeout (default: `60s`)
- `CLIENT_MAX_BODY_SIZE` - Max request body size (default: `10m`)
- `KEEPALIVE_TIMEOUT` - Keep-alive timeout (default: `65s`)
- `ACCESS_LOG` - Access log destination (default: `/dev/stdout`)
- `ERROR_LOG` - Error log destination (default: `/dev/stderr`)

## Usage in Kubernetes

### Basic Pod with Sidecar

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-app
spec:
  containers:
  - name: nginx-proxy
    image: your-registry/nginx-proxy:latest
    ports:
    - containerPort: 80
    env:
    - name: BACKEND_HOST
      value: "localhost"
    - name: BACKEND_PORT
      value: "8080"
  
  - name: flask-app
    image: your-registry/flask-app:latest
    ports:
    - containerPort: 8080
```

### Deployment with Multiple Replicas

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: flask-app
  template:
    metadata:
      labels:
        app: flask-app
    spec:
      containers:
      - name: nginx-proxy
        image: your-registry/nginx-proxy:latest
        ports:
        - containerPort: 80
        env:
        - name: BACKEND_HOST
          value: "localhost"
        - name: BACKEND_PORT
          value: "8080"
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "250m"
      
      - name: flask-app
        image: your-registry/flask-app:latest
        ports:
        - containerPort: 8080
        livenessProbe:
          httpGet:
            path: /status
            port: 8080
          initialDelaySeconds: 15
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /status
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          requests:
            memory: "128Mi"
            cpu: "200m"
          limits:
            memory: "512Mi"
            cpu: "500m"
```

## Features

### Security
- Security headers (X-Frame-Options, X-Content-Type-Options, etc.)
- Runs as non-root user (nginx user, UID 101)
- Supports security contexts and read-only root filesystems
- Hides backend implementation details

### Performance
- Gzip compression enabled
- Connection keep-alive to backend
- Upstream connection pooling
- Configurable buffering and timeouts

### Monitoring
- Health check endpoint: `/health`
- Nginx status endpoint: `/nginx-status` (localhost only)
- Access logs to stdout
- Error logs to stderr
- Built-in Docker healthcheck

### Reliability
- Automatic upstream retry on errors
- Connection timeout handling
- Graceful error pages

## Testing Locally

### Test with Docker

```bash
# Build the nginx image
docker build -f Dockerfile.nginx -t nginx-proxy:test .

# Run a simple backend (e.g., Python HTTP server)
docker run -d --name backend -p 8080:8080 \
  python:3.13-slim \
  python -m http.server 8080

# Run nginx proxy pointing to backend
docker run -d --name nginx-proxy -p 8000:80 \
  --link backend:backend \
  -e BACKEND_HOST=backend \
  -e BACKEND_PORT=8080 \
  nginx-proxy:test

# Test
curl http://localhost:8000/health
curl http://localhost:8000/
```

### Test with Docker Compose

```yaml
# docker-compose.yml
version: '3.8'
services:
  nginx:
    build:
      context: .
      dockerfile: Dockerfile.nginx
    ports:
      - "8000:80"
    environment:
      BACKEND_HOST: flask-app
      BACKEND_PORT: 8080
    depends_on:
      - flask-app
  
  flask-app:
    image: your-flask-app:latest
    ports:
      - "8080:8080"
```

## Customization

### Adding Custom Error Pages

Create an `errors/` directory with custom HTML error pages:

```bash
mkdir errors
echo '<h1>Not Found</h1>' > errors/404.html
echo '<h1>Server Error</h1>' > errors/50x.html
```

Then modify the Dockerfile to copy them:

```dockerfile
COPY errors/*.html /usr/share/nginx/html/errors/
```

### Adding Static File Serving

Uncomment the static location block in `nginx.conf.template`:

```nginx
location /static/ {
    proxy_pass http://backend/static/;
    proxy_cache_valid 200 1h;
    expires 1h;
    add_header Cache-Control "public, immutable";
}
```

### Adding Rate Limiting

Uncomment and configure the rate limiting zone in `nginx.conf.template`:

```nginx
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;

location / {
    limit_req zone=api_limit burst=20 nodelay;
    # ... rest of config
}
```

## Benefits of This Pattern

1. **Separation of Concerns** - Application code doesn't handle HTTP optimization
2. **Reusability** - Same nginx image works with any backend
3. **Security** - Single point for security headers and policies
4. **Performance** - Nginx handles compression, buffering, keep-alive
5. **Observability** - Consistent logging and monitoring
6. **Zero-Downtime** - Backend can restart without dropping connections
7. **SSL Termination** - Can add TLS at nginx layer (with cert volumes)

## EKS-Specific Considerations

### ALB Ingress Controller

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: flask-app-ingress
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: flask-app-service
            port:
              number: 80
```

### Service Mesh (App Mesh)

If using AWS App Mesh, you may not need the nginx sidecar as App Mesh provides similar functionality. Evaluate your needs.

### Auto-scaling

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: flask-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: flask-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## Troubleshooting

### Check nginx configuration

```bash
kubectl exec -it pod-name -c nginx-proxy -- nginx -t
```

### View generated config

```bash
kubectl exec -it pod-name -c nginx-proxy -- cat /etc/nginx/conf.d/default.conf
```

### Check backend connectivity

```bash
kubectl exec -it pod-name -c nginx-proxy -- wget -O- http://localhost:8080/health
```

### View logs

```bash
# Nginx logs
kubectl logs pod-name -c nginx-proxy

# Application logs
kubectl logs pod-name -c flask-app
```

## License

MIT
