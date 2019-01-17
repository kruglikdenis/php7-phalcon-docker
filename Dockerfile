FROM centos:7

COPY etc/ /etc/

# update yum
RUN yum -y update --nogpgcheck; yum clean all
RUN yum -y install yum-utils
# Install some must-haves
RUN yum -y install epel-release --nogpgcheck
RUN yum -y groupinstall "Development Tools"
RUN yum -y install wget --nogpgcheck
RUN yum -y install git --nogpgcheck
RUN yum -y install vim --nogpgcheck
# install remi repo
RUN wget http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
RUN rpm -Uvh remi-release-7*.rpm
RUN yum-config-manager --enable remi-php72

# install php7 # breaking it down to see where dockerhub dies.
RUN \
    yum -y install \
    cronie \
    beanstalkd \
    supervisor \
    java-1.8.0-openjdk \
    php php-common \
    php-curl \
    php-fpm \
    php-mbstring \
    php-mcrypt \
    php-devel \
    php-xml \
    php-mysqlnd \
    php-pdo \
    php-opcache --nogpgcheck \
    php-bcmath \
    php-pecl-memcached \
    php-pecl-mysql \
    php-pecl-xdebug \
    php-pecl-zip \
    php-pecl-apcu \
    php-soap \
    php-pecl-amqp --nogpgcheck \
    || true

# Install composer
RUN curl -sS http://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Install phalconphp with php7
RUN curl -sS https://packagecloud.io/install/repositories/phalcon/stable/script.rpm.sh | bash
RUN yum install -y php72-php-phalcon3.x86_64

# some additional php settings if you care
RUN echo "extension=/opt/remi/php72/root/usr/lib64/php/modules/phalcon.so" > /etc/php.d/phalcon.ini

RUN sed -i "s/memory_limit = 128M/memory_limit = 256M /g" /etc/php.ini

COPY flyway /usr/local/lib/flyway
RUN ln -s /usr/local/lib/flyway/flyway /usr/local/bin

RUN mkdir /run/php-fpm
