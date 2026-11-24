FROM debian:bullseye

RUN apt-get -y update && \
	apt-get -y upgrade

RUN apt-get -y install wget

RUN apt-get -y install php7.4\
	php-fpm\
	php-mysql\
	mariadb-client

RUN wget https://wordpress.org/wordpress-6.9.4.tar.gz -P /var/www && \
	cd /var/www/ && tar -xzf wordpress-6.9.4.tar.gz && \
	rm wordpress-6.9.4.tar.gz

RUN chown -R root:root /var/www/wordpress

RUN mkdir -p /run/php

COPY conf/www.conf /etc/php/7.4/fpm/pool.d

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

RUN chmod +x wp-cli.phar

RUN mv wp-cli.phar /usr/local/bin/wp

COPY tools/config.sh /

RUN chmod +x /config.sh

ENTRYPOINT ["/config.sh"]
