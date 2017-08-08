FROM drupal:8-fpm-alpine

ENTRYPOINT ["docker-php-entrypoint"]
WORKDIR /var/www/html
EXPOSE 9000
CMD ["php-fpm"]
