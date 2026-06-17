# tornado images

Provides a rudimentary image server, easy upload, no security, etc.

# URLs  
/ - upload dialog  
/list - JSON output of what images are on the system  
/images/<name> - retreive the image as JPG or PNG, used for my websites.  
/healthz - Kubernetes health / live check  
/upload - called by post from /  

## Building

The repo and tag is picked up by the IMAGE and VERSION files

```
build
```

### Pushing
add a ```-push``` flag at the end

## Running locally

### basic UV run
```
uv run main.py
```

### Local with podman

Make sure podman machine is started

This makes the necessary volumes to store the images, not on the local FS

```
podman compose up
```

