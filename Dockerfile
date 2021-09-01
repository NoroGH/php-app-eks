FROM php:7.4-fpm AS stage-php

LABEL maintainer="nghazaryan@odc-tech.com"

# Defining variables
ARG SITENAME=php-app.noro.test

# installing required libs and extensions
RUN apt-get update; \
	apt-get install -y --no-install-recommends \
		libargon2-dev \
		libcurl4-openssl-dev \
		libedit-dev \
		libonig-dev \
		libsodium-dev \
		libsqlite3-dev \
		libssl-dev \
		libxml2-dev \
		zlib1g-dev \
        libpng-dev \
		sudo
RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo
USER docker
RUN docker-php-ext-install \
    curl \
    mysqli \
    json \
    opcache \
    mbstring \
    xml \
    gd 

RUN mkdir -p /var/www/${SITENAME}
COPY /php-app/index.php /var/www/${SITENAME}

EXPOSE 9000
WORKDIR /var/www


FROM nginx:latest AS stage-nginx

LABEL maintainer="nghazaryan@odc-tech.com"

# Defining variables
ARG SITENAME=php-app.noro.test

# Defining env variables
ENV MYSQL_ROOT_PASSWORD=pass1234
ENV MYSQL_USER=user
ENV MYSQL_PASSWORD=pass1234
ENV MYSQL_DATABASE=phpdb

# Moveing php-app to document root
RUN mkdir -p /var/www/${SITENAME}
RUN chown -R www-data:www-data /var/www/${SITENAME}

# Adding preconfigured files
COPY /php-app/index.php /var/www/${SITENAME}
COPY php-app.noro.test.conf /etc/nginx/conf.d/php-app.noro.test.conf
RUN rm -rf /etc/nginx/conf.d/default.*

EXPOSE 80