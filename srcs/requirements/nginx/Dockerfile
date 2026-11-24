FROM debian:bullseye

RUN apt-get update -y && \
	apt-get upgrade -y && \
	apt install -y nginx openssl

RUN mkdir -p /etc/nginx/ssl && \
	openssl req \
	-x509 \
	-nodes \
	-out /etc/nginx/ssl/nginx.crt \
	-keyout /etc/nginx/ssl/nginx.key \
	-subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=luctan.42.fr/UID=luctan"

COPY conf/nginx.conf /etc/nginx/nginx.conf

RUN chmod 755 /var/www/html && \
	chown -R www-data:www-data /var/www/html/

ENTRYPOINT ["nginx"]

CMD ["-g", "daemon off;"]
