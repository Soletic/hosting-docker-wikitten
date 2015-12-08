FROM soletic/phpserver
MAINTAINER Sol&TIC <serveur@soletic.org>

RUN apt-get install -y wget

ADD config.php /tmp/config.php
ADD start-wiki.sh /root/scripts/start-wiki.sh
RUN chmod 755 /root/scripts/*.sh
ADD supervisord-wiki.conf /etc/supervisor/conf.d/supervisord-wiki.conf

COPY apache.confsite /etc/apache2/templates/default.confsite