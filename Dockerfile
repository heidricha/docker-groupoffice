FROM ubuntu:xenial

ENV PASSWORD=sakalaka \
    MAILDOMAIN=domain.hu \
    GO_USER=groupoffice

ENV DEBIAN_FRONTEND=noninteractive \
    http_proxy=http://git:3128 \
    https_proxy=http://git:3128 \
    HTTP_PROXY=http://git:3128 \
    HTTPS_PROXY=http://git:3128

RUN printf -- "\
Acquire::http::proxy \"http://srvvm-aptcache:3128/\";\n\
Acquire::ftp::proxy \"ftp://srvvm-aptcache:3128/\";\n\
Acquire::https::proxy \"https://srvvm-aptcache:3128/\";\n\
" > /etc/apt/apt.conf.d/95proxies

RUN echo "deb [trusted=always] http://repos.groupoffice.eu/ sixtwo main" | tee /etc/apt/sources.list.d/groupoffice.list

RUN apt-get update && \
    apt-get install -y \
        apt-utils \
        debconf-utils

RUN printf -- "\
mysql-server-5.7    mysql-server/root_password password $PASSWORD\n\
mysql-server-5.7    mysql-server/root_password_again    password $PASSWORD\n\
postfix postfix/mailname string MAILDOMAIN\n\
postfix postfix/main_mailer_type string 'Internet Site'\n\
groupoffice-com groupoffice-com/mysql/method select Unix socket\n\
groupoffice-com groupoffice-com/db/app-user string $GO_USER\n\
groupoffice-com groupoffice-com/dbconfig-upgrade boolean true\n\
groupoffice-mailserver groupoffice-mailserver/domain string $MAILDOMAIN\n\
groupoffice-com groupoffice-com/mysql/admin-pass password $PASSWORD \n\
groupoffice-com groupoffice-com/mysql/app-pass password $PASSWORD \n\
groupoffice-com groupoffice-com/password-confirm password $PASSWORD \n\
groupoffice-com groupoffice-com/app-password-confirm password $PASSWORD\n\
" | debconf-set-selections

RUN useradd $GO_USER

RUN rm -f /usr/sbin/policy-rc.d &&\
    apt-get update && \
    apt-get install -y \
        mysql-server

RUN service mysql start &&\
    rm -f /usr/sbin/policy-rc.d &&\
    apt-get install -y \
        apache2 \
        postfix \
        postfix-mysql \
        dovecot-mysql \
        dovecot-sieve \
        dovecot-managesieved
    
RUN service mysql start &&\
    service apache2 start &&\
    rm -f /usr/sbin/policy-rc.d &&\
    apt-get install -y --allow-unauthenticated \
        groupoffice-mailserver \
    
