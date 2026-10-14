FROM php:8.3-apache-bookworm

ARG INSTALL_PHP_EXTENSIONS_VERSION=2.8.1
ENV MAKEFLAGS=-j1

ADD https://github.com/mlocati/docker-php-extension-installer/releases/download/${INSTALL_PHP_EXTENSIONS_VERSION}/install-php-extensions /usr/local/bin/install-php-extensions

RUN printf 'Acquire::Retries "5";\n' > /etc/apt/apt.conf.d/80-retries \
    && sed -i 's|http://deb.debian.org|https://deb.debian.org|g' /etc/apt/sources.list.d/debian.sources \
    && chmod 0755 /usr/local/bin/install-php-extensions \
    && install-php-extensions curl \
    && install-php-extensions gd \
    && install-php-extensions intl \
    && install-php-extensions mysqli \
    && install-php-extensions mbstring \
    && install-php-extensions bcmath \
    && install-php-extensions bz2 \
    && install-php-extensions zip \
    && install-php-extensions exif \
    && install-php-extensions ldap \
    && install-php-extensions apcu \
    && a2enmod rewrite headers \
    && sed -ri 's!/var/www/html!/var/www/glpi/public!g' /etc/apache2/sites-available/*.conf \
    && printf '%s\n' \
       '<Directory /var/www/glpi/public>' \
       '  AllowOverride All' \
       '  Require all granted' \
       '  FallbackResource /index.php' \
       '</Directory>' \
       > /etc/apache2/conf-available/glpi.conf \
    && a2enconf glpi \
    && printf '%s\n' \
       'session.cookie_httponly = 1' \
       'session.cookie_secure = 0' \
       'expose_php = Off' \
       'memory_limit = 256M' \
       > /usr/local/etc/php/conf.d/glpi.ini \
    && rm -f /usr/local/bin/install-php-extensions

COPY branding-fixed/ /tmp/branding-fixed/
COPY emurb-desk-favicon.png /tmp/emurb-desk-favicon.png
COPY remove-rss-tab.php /tmp/remove-rss-tab.php
COPY glpi-12.0.0.tgz /tmp/glpi.tgz
RUN tar -xzf /tmp/glpi.tgz -C /var/www \
    && rm /tmp/glpi.tgz \
    && cp /tmp/branding-fixed/login_logo_glpi.png /var/www/glpi/public/pics/login_logo_glpi.png \
    && cp /tmp/branding-fixed/logo-GLPI-250-white.png /var/www/glpi/public/pics/logos/logo-GLPI-250-white.png \
    && cp /tmp/branding-fixed/logo-GLPI-250-grey.png /var/www/glpi/public/pics/logos/logo-GLPI-250-grey.png \
    && cp /tmp/branding-fixed/logo-GLPI-250-black.png /var/www/glpi/public/pics/logos/logo-GLPI-250-black.png \
    && cp /tmp/branding-fixed/logo-GLPI-100-white.png /var/www/glpi/public/pics/logos/logo-GLPI-100-white.png \
    && cp /tmp/branding-fixed/logo-GLPI-100-grey.png /var/www/glpi/public/pics/logos/logo-GLPI-100-grey.png \
    && cp /tmp/branding-fixed/logo-GLPI-100-black.png /var/www/glpi/public/pics/logos/logo-GLPI-100-black.png \
    && cp /tmp/emurb-desk-favicon.png /var/www/glpi/public/pics/favicon.ico \
    && cp /tmp/emurb-desk-favicon.png /var/www/glpi/public/pics/favicon.png \
    && sed -i 's#</head>#<link rel="icon" type="image/png" href="/pics/favicon.png" />\\n</head>#' /var/www/glpi/templates/layout/parts/head.html.twig \
    && php /tmp/remove-rss-tab.php \
    && rm -rf /tmp/branding-fixed /tmp/emurb-desk-favicon.png /tmp/remove-rss-tab.php \
    && sed -i 's/\$CFG_GLPI\['"'"'app_name'"'"'\] = '"'"'GLPI'"'"';/\$CFG_GLPI['"'"'app_name'"'"'] = '"'"'EMURB Desk'"'"';/' /var/www/glpi/src/autoload/CFG_GLPI.php \
    && sed -i 's#<span class="d-block">GLPI {{ constant('\''GLPI_VERSION'\'') }}</span>#<span class="d-block">EMURB Desk {{ constant('\''GLPI_VERSION'\'') }}</span><span class="d-block">Autores: João Oliveira e Varlei Oliveira</span>#' /var/www/glpi/templates/layout/parts/user_header.html.twig \
    && mkdir -p /var/www/glpi/config /var/www/glpi/files \
    && chown -R www-data:www-data /var/www/glpi \
    && find /var/www/glpi -type d -exec chmod 0755 {} + \
    && find /var/www/glpi -type f -exec chmod 0644 {} + \
    && chmod 0770 /var/www/glpi/config /var/www/glpi/files

WORKDIR /var/www/glpi
