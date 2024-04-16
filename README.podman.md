
```
sudo /kaniko/executor --dockerfile ./ubi8.Dockerfile --context $(pwd) --destination r3dsh/test:latest --no-push --tar-path ubi-image.tar 
podman load --quiet -i ubi-image.tar
```
