#!/bin/bash

# replace default template apache
mv -f /tmp/apache.confsite /etc/apache2/templates/default.confsite

# Apache protection
if [ ! -f ${DATA_VOLUME_WWWW}/conf/apache2/.htpasswd ]; then
	PASS=$(pwgen -s 12 1)
	echo "admin:${PASS}" > ${DATA_VOLUME_WWWW}/conf/apache2/.htpasswd.uncrypt
	htpasswd -bc ${DATA_VOLUME_WWWW}/conf/apache2/.htpasswd admin "${PASS}"
fi

# Create git content if no exist
if [ ! -d ${DATA_VOLUME_WWWW}/wiki-content ]; then
	mkdir -p ${DATA_VOLUME_WWWW}/wiki-content
	cd ${DATA_VOLUME_WWWW}/wiki-content
	git --bare init
fi

# Install app if not exist
if [ ! -f ${DATA_VOLUME_WWWW}/html/config.php ]; then
	rm -Rf ${DATA_VOLUME_WWWW}/html
	cd /tmp
	wget https://github.com/victorstanciu/Wikitten/archive/master.zip
	unzip master.zip
	mv Wikitten-master ${DATA_VOLUME_WWWW}/html
	rm -Rf ${DATA_VOLUME_WWWW}/html/library
	git clone ${DATA_VOLUME_WWWW}/wiki-content ${DATA_VOLUME_WWWW}/html/library
	mv /tmp/config.php ${DATA_VOLUME_WWWW}/html/

	echo "# Wiki Home Page" > ${DATA_VOLUME_WWWW}/html/library/index.md
	echo ""  >> ${DATA_VOLUME_WWWW}/html/library/index.md
	echo "Bonjour et bienvenue. Pour éditer le wiki, créer votre arborescence de contenu dans ${DATA_VOLUME_WWWW}/wiki-content via Git" >> ${DATA_VOLUME_WWWW}/html/library/index.md
	cd ${DATA_VOLUME_WWWW}/html/library
	git config --global user.name ${WORKER_NAME}
    git config --global user.email ${WORKER_NAME}@`hostname`
    git config --global push.default simple
	git add index.md
	git commit -m "Init wiki"
	git push

	# Cron deploy
	echo "* * * * * root bash -c 'cd ${DATA_VOLUME_WWWW}/html/library ; git add . ; git commit -m \"Changes from website\" ; git pull ; git push' > /dev/null 2>&1" >> /etc/crontab
fi

chown -R ${WORKER_UID}:${WORKER_UID} ${DATA_VOLUME_WWWW}/html ${DATA_VOLUME_WWWW}/wiki-content