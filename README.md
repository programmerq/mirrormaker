# Docker CS Mirror Maker

Docker Inc.'s, Commercially Supported (CS) Docker Engine packages live at `packages.docker.com`. But what if you need a mirror of these packages in your own data center?

Enter the **mirrormaker**.

## Building

There is a `Makefile` which takes care of most everything for you. It even has a built in help.

    $ make
    help    This help message
    build   build the mirror server
    clean   start from scratch
    run     run the mirror server
    push    push the mirror server to a Docker repository

You'll need an internet connection with access to `packages.docker.com` for the build step.

    make build

## Running

Once you've got a build you can test it by running the `mirrorserver` image. The makefile will make this easy.

    make run

The server will be up on port 2015 on whatever your Docker engine IP address is. You can test this with a quick curl:

    curl -sSL http://<engine ip>:2015/index.html

Or you can just skip ahead and use the install script:

    curl -sSL http://<engine ip>:2015/install.sh

Or if all you want is the yum repo file to drop into `/etc/yum.repos.d/`

    curl -sSL http://<engine ip>:2015/docker.repo

Or maybe the Ubuntu/Debian list file to drop into `/etc/apt/sources.list.d/`
    curl -sSL http://<engine ip>:2015/docker.list

## Pushing to a Docker repository

Once you are happy with things you can push the `mirrorserver` image to any Docker registry.

    DOCKER_REPO='dtr.mycompany.com/infra/mirrorserver' make push

The makefile will push tags for both the CS version (e.g., 1.10) and `latest`.

# Clean up

In order to not constantly rebuild the world the makefile will only build the images once. If you need to rebuild but keep the caches around for fast builds you'll need to untag the images first. Luckily the makefile will help you here as well.

    make force-build

This will only rebuild the images (it won't delete the build cache). If you want to rebuild the package mirror you'll want to:

    make clean-mirror

You can of course do both:

    make clean-mirror force-build

But if you really want to start from scratch you'll want to:

    make clean
