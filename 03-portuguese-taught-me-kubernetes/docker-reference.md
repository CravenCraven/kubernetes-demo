# Docker Grammar Reference

Companion to [Portuguese Taught Me Kubernetes](./README.md) and the [kubectl reference](./grammar-reference.md). Docker has almost the same grammar as kubectl, so once one clicks, the other reads the same way. The main difference: Docker has two styles.

```
docker [verb] [thing] [flags]           # old, flat, most common
docker [noun] [verb] [thing] [flags]    # newer, grouped
```

`docker ps` (old) and `docker container ls` (new) do the same thing. You'll see both. This uses the common form.

## Images vs containers

This distinction is the whole mental model.

- **Image** = the frozen blueprint. Built once, never changes.
- **Container** = a running copy of an image. You can have many from one image.

Same relationship as a Deployment (the spec) and a Pod (the running instance).

```
docker pull nginx              # download an image
docker images                  # list images you have
docker build -t myapp .        # build an image from the Dockerfile here (.)
docker rmi nginx               # remove an image
```

## docker run, flag by flag

`docker run` is the big one. It's pull + create + start in one command. The flags do the real work.

```
docker run nginx                       # foreground, ties up your terminal
docker run -d nginx                    # -d = detached, background
docker run -d -p 8080:80 nginx         # -p = map host:container port
docker run -d -v /data:/app/data nginx # -v = mount host dir into container
docker run -e ENV=prod nginx           # -e = set an environment variable
docker run --name web nginx            # --name = give it a readable name
docker run -it ubuntu bash             # -it + a command = interactive shell
docker run --rm alpine echo hi         # --rm = auto-delete when it exits
```

| flag | meaning | why |
| --- | --- | --- |
| `-d` | detached | so it doesn't hold your terminal |
| `-p H:C` | port map | reach the app from your host |
| `-v H:C` | volume | data that survives the container |
| `-e K=V` | env var | config the app reads at startup |
| `--name` | name it | so you're not typing container IDs |
| `--rm` | auto-clean | for throwaway runs |
| `-it` | interactive TTY | for shells and interactive tools |

`-p 8080:80` reads **host:container**. Traffic hitting your machine on 8080 forwards to port 80 inside the container. Host first, container second.

## Lifecycle

```
docker ps                      # running containers
docker ps -a                   # all, including stopped
docker stop <id>               # stop a running one
docker start <id>              # start a stopped one
docker restart <id>            # stop + start
docker rm <id>                 # remove (must be stopped first)
docker rm -f <id>              # force remove even if running
```

## Getting inside and watching

Same muscle memory as kubectl.

```
docker logs <id>               # print logs
docker logs -f <id>            # follow live
docker exec -it <id> bash      # shell inside a running container
docker inspect <id>            # full JSON detail (the docker 'describe')
```

`docker exec -it <id> bash` versus `kubectl exec -it <pod> -- bash`. Nearly the same. Docker skips the `--` because there's no pod or namespace layer to disambiguate.

## build: Dockerfile to image

```
docker build -t myapp:v1 .
             |         |
           name:tag  build context (the . = current dir)
```

`docker build` reads a `Dockerfile` and runs each instruction as a layer, producing an image. The `.` is the build context, the folder Docker can copy files from. `-t` tags the result so you refer to it by name instead of a hash.

## Cleanup

Images pile up. Check before you prune.

```
docker system df               # how much disk docker is using
docker system prune            # remove stopped containers + unused networks
docker system prune -a         # also remove unused images (aggressive)
docker image prune             # just dangling images
docker volume prune            # just unused volumes
```

## The bridge: docker to kubernetes

Kubernetes is the orchestration layer on top of containers. Docker builds and runs one container. Kubernetes decides where containers run, restarts them, scales them. Same concepts, one layer up.

| Docker | Kubernetes | concept |
| --- | --- | --- |
| image | container image | the blueprint (same thing) |
| container | pod | the running instance |
| `docker run` | a Deployment / `kubectl apply` | start the thing |
| `docker ps` | `kubectl get pods` | list running things |
| `docker logs -f` | `kubectl logs -f` | stream logs |
| `docker exec -it` | `kubectl exec -it --` | get inside |
| `docker inspect` | `kubectl describe` | full detail |
| `-p 8080:80` | a Service | expose a port |
| `-v` | a PVC + volume | persistent storage |
| `-e` | a ConfigMap / Secret | config injection |
| `docker restart` | `kubectl rollout restart` | bounce it |

The right column is where the homelab is heading. The left column is what's running underneath. They rhyme on purpose.
