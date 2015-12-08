# Docker image to start a simple Wiki PHP

Based on the [open source project Wikitten](https://github.com/victorstanciu/Wikitten).

## How does it work ?

1. The directory /var/www/wiki-content is a git repository and containing the content : markdown files organized in a directory tree. You edit this files, add, commit and push.
2. A cron pull the repository in the directory /var/www/html/library of wikitten

The directory **private** is protected by http authentification (see the .htpasswd generated in /var/www/conf/apache2)

The POST method is protected too to prevent editing by user disallowed.

## Install and run

```
$ git clone https://github.com/Soletic/hosting-docker-ubuntu.git ./ubuntu
$ git clone https://github.com/Soletic/hosting-docker-phpserver.git ./phpserver
$ git clone https://github.com/Soletic/hosting-docker-wikitten.git ./wikitten
$ docker build --pull -t soletic/ubuntu ./ubuntu
$ docker build -t soletic/phpserver ./phpserver
$ docker build -t soletic/wikitten ./wikitten
$ mkdir ./wikitten-www
$ docker run -d -h example.org --name=example.wikitten -e WORKER_NAME=example -e WORKER_UID=1000 -e HOST_DOMAIN_NAME=example.org -v ./wikitten-www:/var/www soletic/wikitten
```

## Modify Wiki content

### From the wiki

Click "Toggle source", change file and save chances.

### From your local editor

Clone the repository /var/www/wiki-content, modify and push

To clone, you must deploy a ssh container giving access to the directory. After settinp up it, commands are : 

**Clone**

```
$ git clone ssh://wiki@wiki.example.org:2222/var/www/wiki-content $DOCKER_HOSTING/wiki
$ git config --global push.default matching
```

**Publish**

```
$ git add new_file.md
$ git commit -m "Add new file"
$ gill pull
```

Resolve conflit if required (because of website editing) and push

```
$ git push
```

## Roadmap

* Manage conflit when content modified from website AND local editor
