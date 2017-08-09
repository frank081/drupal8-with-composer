FROM drupal:8.3

RUN apt-get update -y \
  && apt-get install -y git-core openssh-client openssl

RUN echo "memory_limit=-1" > "$PHP_INI_DIR/conf.d/memory-limit.ini" \
 && echo "date.timezone=${PHP_TIMEZONE:-UTC}" > "$PHP_INI_DIR/conf.d/date_timezone.ini"

ENV PATH "/composer/vendor/bin:$PATH"
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /composer
ENV COMPOSER_VERSION 1.4.2

RUN curl -s -f -L -o /tmp/installer.php https://raw.githubusercontent.com/composer/getcomposer.org/da290238de6d63faace0343efbdd5aa9354332c5/web/installer \
 && php -r " \
    \$signature = '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410'; \
    \$hash = hash('SHA384', file_get_contents('/tmp/installer.php')); \
    if (!hash_equals(\$signature, \$hash)) { \
        unlink('/tmp/installer.php'); \
        echo 'Integrity check failed, installer is either corrupt or worse.' . PHP_EOL; \
        exit(1); \
    }" \
 && php /tmp/installer.php --no-ansi --install-dir=/usr/bin --filename=composer --version=${COMPOSER_VERSION} \
 && rm /tmp/installer.php \
 && composer --ansi --version --no-interaction

RUN cd /var/www/html \
 && composer install --dev \
 && mkdir /var/www/html/modules/custom
 
RUN cd /usr/lib \
 && curl https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 > phantomjs-2.1.1-linux-x86_64.tar.bz2 \
 && mkdir phantomjs \
 && tar -xjvf phantomjs-2.1.1-linux-x86_64.tar.bz2 -C phantomjs \
 && rm phantomjs-2.1.1-linux-x86_64.tar.bz2 \
 && ln -s /usr/lib/phantomjs/bin/phantomjs /usr/bin/phantomjs

#ENTRYPOINT ["docker-php-entrypoint"]
#WORKDIR /var/www/html
#EXPOSE 9000
#CMD ["php-fpm"]
