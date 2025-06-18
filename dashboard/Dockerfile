FROM php:8.2-apache

# Enable Apache modules
RUN a2enmod rewrite headers

# Set ServerName to avoid warning
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Enable .htaccess files
RUN sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

# Enable sessions in PHP
RUN echo "session.auto_start = 0" >> /usr/local/etc/php/conf.d/sessions.ini
RUN echo "session.cookie_lifetime = 3600" >> /usr/local/etc/php/conf.d/sessions.ini
RUN echo "session.gc_maxlifetime = 3600" >> /usr/local/etc/php/conf.d/sessions.ini

# Set working directory
WORKDIR /var/www/html

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html

EXPOSE 80