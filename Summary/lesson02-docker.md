# Lesson 2 — Docker
> Source: `Class2.Docker.pptx` (42 slides) — *DevOps Experts Class 2*

---

## What is Docker?

- Computer program performing **operating-system-level virtualization** (containerization)
- First released in 2013, developed by Docker, Inc.
- Wraps an application's software into a self-contained box with everything needed to run:
  OS, application code, runtime, system tools, system libraries, etc.

### Container vs VM
| Aspect | VM | Container |
|---|---|---|
| Virtualization | Hardware-level | OS-level |
| Isolation | Full OS per VM | Shared OS kernel |
| Size | GBs | MBs |
| Startup | Minutes | Seconds |

---

## Core Concepts

### Image
- Read-only templates built from instructions in a Dockerfile
- Each instruction adds a new "layer" to the image
- Layers represent portions of the filesystem
- Define the application + dependencies + processes to run

### Container
- Created from images
- Docker adds a **read-write layer** on top of the read-only image
- Containers are **isolated** from each other
- Bundle their own tools, libraries, and configuration files
- All containers run by a single OS kernel → more lightweight than VMs

### Hypervisor
- Software/firmware that VMs run on top of
- Host machine provides VMs with RAM and CPU resources
- Docker does NOT require a hypervisor — containers share the host OS kernel

---

## Dockerfile

A Dockerfile contains instructions to build a Docker image:

```dockerfile
FROM python:3
WORKDIR /usr/src
COPY first.py /usr/src
CMD ["python3", "/usr/src/first.py"]
```

### Key Instructions
| Instruction | Purpose |
|---|---|
| `FROM` | Base image |
| `WORKDIR` | Set working directory |
| `COPY` | Copy files into the image |
| `RUN` | Execute commands during build |
| `CMD` | Default command when container starts |
| `ENV` | Set environment variables |
| `VOLUME` | Mount point for external storage |

---

## Docker Image Naming Convention

```
docker.io / username / my-image : v0.1
{Registry URL} / {Owner} / {Image Name} : {Tag}
```

---

## Core Docker Commands

```bash
docker version                          # Show Docker version
docker pull <image>                     # Pull image from registry
docker run -itd --name <name> <image>   # Run a container (detached)
docker push <username/image>            # Push image to registry
docker images                           # List local images
docker rm <name/id>                     # Remove container
docker ps                               # List running containers
docker exec -it <name/id> bash          # Open shell in container
docker stop <name/id>                   # Stop container
docker image rm <image>                 # Remove image
```

---

## Running Nginx Example

```bash
# Pull and run nginx on port 80
docker pull nginx
docker run --name docker-nginx -p 80:80 -d nginx

# Verify running
docker ps

# Stop and remove
docker stop docker-nginx
docker rm docker-nginx
docker image rm nginx
```

---

## Docker Networking

### User-defined bridge network
- Self-contained IP subnet and gateway
- Containers in the same bridge communicate **directly** without port forwarding
- Automatic **DNS discovery** — containers reach each other by name
- External devices use published ports to access the network

```bash
docker network create <network_name>    # Create network
docker network ls                       # List networks
docker network rm <network_name>        # Remove network
docker run --name <name> --network <net_name> <image>  # Attach to network
```

### Hands-on example
```bash
docker network create nginx-network
docker run --name nginx1 --rm --network nginx-network -d nginx:alpine
docker run --name nginx2 --rm --network nginx-network -d nginx:alpine
docker exec -it nginx1 sh
ping nginx2   # DNS resolves to nginx2's IP automatically
```

---

## Docker Registry & DockerHub

- Registry: storage and content delivery system for Docker images
- DockerHub: public registry for sharing images
- Users interact via `docker push` and `docker pull`
- A repository can hold many image versions (stored as tags)

---

## Docker Multi-Stage Builds

### What is it?
Allows defining multiple stages in a single Dockerfile using multiple `FROM` instructions.
Each `FROM` starts a new stage; only **necessary artifacts** are copied to the final image.

### Why use it?
| Benefit | Explanation |
|---|---|
| **Smaller images** | Only essential artifacts in final image — build tools discarded |
| **Better security** | Fewer tools = smaller attack surface |
| **Clean builds** | Intermediate stages handle compilation; final is minimal |

### Example pattern
```dockerfile
# Stage 1: Build
FROM node:18 AS builder
WORKDIR /app
COPY . .
RUN npm run build

# Stage 2: Production
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
```

---

## YAML

- Human-readable data serialization language used for configuration files
- Can use `.yml` or `.yaml` extensions
- **YAML rules:**
  - Case sensitive
  - No tabs — use spaces only
  - Python-style indentation for nesting
  - `[]` for lists, `{}` for maps
- Validate at: http://www.yamllint.com/

---

## Docker Compose

- Tool for defining and running **multi-container** Docker applications
- Uses a `docker-compose.yml` file to configure all services

### Three-step workflow
1. Define app environment in `Dockerfile`
2. Define services in `docker-compose.yml`
3. Run `docker-compose up` — starts everything

### Key features
- `volumes` — mount host directory inside container for live code changes
- Development purposes (not production-grade orchestration)
- Great for CI workflows and staging environments

### Example `docker-compose.yml`
```yaml
version: "3"
services:
  web:
    build: .
    ports:
      - "5000:5000"
    volumes:
      - .:/code
  redis:
    image: redis
```

---

## Key Takeaways

1. Containers are lightweight, isolated, portable units that share the host OS kernel
2. Images are immutable; containers add a writable layer on top
3. Dockerfile defines how to build an image step by step
4. Docker Compose manages multi-container applications with a single YAML file
5. Multi-stage builds keep production images small and secure
6. Docker networking with named bridges enables DNS-based service discovery

---

## Assignment

**Goal:** Package a Python HTTP server app into a Docker image and push it to Docker Hub.

**The provided app (`app.py`):**
```python
from http.server import BaseHTTPRequestHandler, HTTPServer
HOST = "0.0.0.0"
PORT = 8080
class SimpleHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.end_headers()
        self.wfile.write(b"Hello from Docker! Your app is running.\n")
if __name__ == "__main__":
    print(f"Server starting on {HOST}:{PORT}")
    HTTPServer((HOST, PORT), SimpleHandler).serve_forever()
```

**Tasks:**
1. Write a `Dockerfile` (no copying from internet — you must understand every line)
2. Build and tag the image locally
3. Create a Docker Hub account and generate an access token
4. Create a **public** repository on Docker Hub
5. Re-tag the image using the convention: `<username>/<repo>:1.0`
6. Push the image to Docker Hub

**Rules:** No external Python libraries. Image tag must be `<dockerhub-username>/<repo>:version`, **not** `latest`.

**Submission requires:**
- Docker Hub repository link
- Screenshot of image tag in Docker Hub
- Your Dockerfile
- Explanation of `FROM`, `COPY`, `CMD`, and why login is required for public repos

**Bonus:** Add a `latest` tag; change response text and rebuild; run on a different external port.

---

## Student Answers

**Docker Hub repository:** [https://hub.docker.com/repositories/henria](https://hub.docker.com/repositories/henria)

**Dockerfile used:**
```dockerfile
FROM python:3-slim
WORKDIR /usr/src
COPY app.py /usr/src
EXPOSE 8080
CMD ["python", "/usr/src/app.py"]
```

**Explanations:**
- **`FROM python:3-slim`** — Uses the official Python 3 slim base image as the foundation
- **`COPY app.py /usr/src`** — Copies the application file from the host into the image at `/usr/src`
- **`CMD ["python", "/usr/src/app.py"]`** — Defines the command to run the application when the container starts
- **Why login is required for public repos** — Rate limiting (anonymous: 100 pulls; logged-in: 200 pulls), abuse prevention, and corporate security policies require authentication even for public repositories

**Bonus:**
```bash
# Run on a different external port
docker run -p 8081:8080 henria/http_server:latest
```
