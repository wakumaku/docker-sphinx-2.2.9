FROM debian:8.7

RUN apt-get update

RUN apt-get install -y \
    wget \
    tar \
    build-essential \
    unixodbc-dev \
    expat \
    libmysqlclient-dev

COPY install/*.tar.gz /opt/install/

WORKDIR /opt/install

RUN cat *.tar.gz | tar -xvzf - -i && \
    cp -R libstemmer_c/* sphinx-2.2.9-release/libstemmer_c/ && \
    cp -R re2-2015-05-01/* sphinx-2.2.9-release/libre2/

RUN cd sphinx-2.2.9-release && \
    ./configure --with-libstemmer --with-libexpat --with-iconv --with-unixodbc --with-re2 && \
    make && \
    make install

WORKDIR /

# expose ports
EXPOSE 9312 9306

# prepare directories
RUN mkdir -p /var/idx/sphinx && \
    mkdir -p /var/log/sphinx && \
    mkdir -p /var/lib/sphinx && \
    mkdir -p /var/run/sphinx

VOLUME ["/var/idx/sphinx", "/var/log/sphinx", "/var/lib/sphinx", "/var/run/sphinx"]

# scripts
ADD searchd.sh /
RUN chmod a+x searchd.sh
ADD indexall.sh /
RUN chmod a+x indexall.sh

RUN apt-get remove -y \
    build-essential && \
    rm -rf /opt/install



# run the script
CMD ["./indexall.sh"]