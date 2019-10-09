#!/usr/bin/docker build .
#
# VERSION               1.0

FROM       alpine:latest
MAINTAINER jirka@dutka.net

ENV HOSTNAME XoruX
ENV VI_IMAGE 1

# create file to see if this is the firstrun when started
RUN touch /firstrun

RUN apk update && apk add \
    bash \
    wget \
    supervisor \
    apache2 \
    bc \
    net-snmp \
    rrdtool \
    perl-rrd \
    perl-xml-simple \
    perl-xml-libxml \
    perl-net-ssleay \
    perl-net-snmp \
    perl-lwp-protocol-https \
    perl-date-format \
    perl-dbd-pg \
    # libpdf-api2-perl \
    net-tools \
    libxml2-utils \
    # snmp-mibs-downloader \
    openssh-client \
    openssh-server \
    ttf-dejavu \
    vim \
    rsyslog \
    tzdata \
    sudo \
    less \
    ed \
    sharutils

#RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/main \
#    ed \
#    sharutils

# setup default user
RUN addgroup -S lpar2rrd 
RUN adduser -S lpar2rrd -G lpar2rrd -u 1005 -s /bin/bash
RUN echo 'lpar2rrd:xorux4you' | chpasswd
RUN echo '%lpar2rrd ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN mkdir /home/stor2rrd \
    && mkdir /home/lpar2rrd/stor2rrd \
    && ln -s /home/lpar2rrd/stor2rrd /home/stor2rrd \
    && chown lpar2rrd /home/lpar2rrd/stor2rrd

# configure Apache
COPY configs/apache2 /etc/apache2/sites-available
COPY configs/apache2/htpasswd /etc/apache2/conf/

# change apache user to lpar2rrd
RUN sed -i 's/^User apache/User lpar2rrd/g' /etc/apache2/httpd.conf

# adding web root
ADD htdocs.tar.gz /var/www/localhost
RUN chown -R apache.apache /var/www/localhost

# add product installations
ENV LPAR_VER_MAJ "6.10"
ENV LPAR_VER_MIN ""
ENV LPAR_SF_DIR "6.10"
ENV STOR_VER_MAJ "2.60"
ENV STOR_VER_MIN ""
ENV STOR_SF_DIR "2.60"

ENV LPAR_VER "$LPAR_VER_MAJ$LPAR_VER_MIN"
ENV STOR_VER "$STOR_VER_MAJ$STOR_VER_MIN"

# expose ports for SSH, HTTP, HTTPS and LPAR2RRD daemon
EXPOSE 22 80 443 8162

COPY configs/crontab /var/spool/cron/crontabs/lpar2rrd
RUN chmod 600 /var/spool/cron/crontabs/lpar2rrd && chown lpar2rrd.cron /var/spool/cron/crontabs/lpar2rrd

COPY tz.pl /var/www/localhost/cgi-bin/tz.pl
RUN chmod +x /var/www/localhost/cgi-bin/tz.pl

# download tarballs from SF
ADD http://downloads.sourceforge.net/project/lpar2rrd/lpar2rrd/$LPAR_SF_DIR/lpar2rrd-$LPAR_VER.tar /home/lpar2rrd/
ADD http://downloads.sourceforge.net/project/stor2rrd/stor2rrd/$STOR_SF_DIR/stor2rrd-$STOR_VER.tar /home/stor2rrd/

# extract tarballs
WORKDIR /home/lpar2rrd
RUN tar xvf lpar2rrd-$LPAR_VER.tar

WORKDIR /home/stor2rrd
RUN tar xvf stor2rrd-$STOR_VER.tar

COPY supervisord.conf /etc/
COPY startup.sh /startup.sh
RUN chmod +x /startup.sh

RUN mkdir -p /home/lpar2rrd/lpar2rrd /home/stor2rrd/stor2rrd
RUN chown -R lpar2rrd /home/lpar2rrd /home/stor2rrd
VOLUME [ "/home/lpar2rrd/lpar2rrd", "/home/stor2rrd/stor2rrd" ]

ENTRYPOINT [ "/startup.sh" ]

