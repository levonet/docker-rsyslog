FROM alpine:3.10 AS build

COPY grok-*.diff /tmp/

ENV RSYSLOG_VERSION v8.1911.0
ENV LIBMONGOC_VERSION 1.15.2
ENV LIBLOGNORM_VERSION v2.0.6
ENV LIBRELP_VERSION v1.4.0
ENV LIBLOGGING_VERSION v1.0.6
ENV TOKYO_CABINET_VERSION 1.4.30
ENV CFLAGS "-pipe -m64 -Ofast -mtune=generic -march=x86-64 -fPIE -fPIC -funroll-loops -fstack-protector-strong -ffast-math -fomit-frame-pointer -Wformat -Werror=format-security"

RUN apk add --no-cache \
        autoconf \
        automake \
        bison \
        bsd-compat-headers \
        build-base \
        bzip2-dev \
        cmake \
        curl-dev \
        flex \
        git \
        glib-dev \
        gnutls-dev \
        gperf \
        libdbi-dev \
        libestr-dev \
        libevent-dev \
        libfastjson-dev \
        libgcrypt-dev \
        liblogging-dev \
        libmaxminddb-dev \
        librdkafka-dev \
        libtool \
        libuuid \
        linux-headers \
        mysql-dev \
        pcre-dev \
        portablexdr-dev \
        postgresql-dev \
        py-docutils \
        rpcgen \
        util-linux-dev \
        zlib-dev \
    && git clone -b ${LIBMONGOC_VERSION} --single-branch --depth 1 https://github.com/mongodb/mongo-c-driver.git /usr/src/mongo-c-driver \
    && echo "${LIBMONGOC_VERSION}" > /usr/src/mongo-c-driver/VERSION_CURRENT \
    && mkdir /usr/src/mongo-c-driver/cmake-build \
    && cd /usr/src/mongo-c-driver/cmake-build \
    && cmake \
        -DENABLE_AUTOMATIC_INIT_AND_CLEANUP=OFF \
        -DCMAKE_INSTALL_LIBDIR=/usr/local/lib \
        -DCMAKE_C_FLAGS="-pipe -m64 -Ofast -fPIE -fPIC -fomit-frame-pointer -Wformat -Werror=format-security" \
        -DCMAKE_BUILD_TYPE=Release \
        -DENABLE_STATIC=OFF \
        -DENABLE_TESTS=OFF \
        .. \
    && make \
    && make install \
    #
    && git clone -b ${LIBLOGNORM_VERSION} --single-branch --depth 1 https://github.com/rsyslog/liblognorm.git /usr/src/liblognorm \
    && cd /usr/src/liblognorm \
    && autoreconf --force --verbose --install \
    && ./configure \
        --prefix=/usr/local \
        --disable-docs \
        --disable-debug \
        --disable-testbench \
        --enable-regexp \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    #
    && git clone -b ${LIBRELP_VERSION} --single-branch --depth 1 https://github.com/rsyslog/librelp.git /usr/src/librelp \
    && cd /usr/src/librelp \
    && autoreconf --force --verbose --install \
    && CFLAGS="-pipe -m64 -Ofast -fPIE -fPIC -fomit-frame-pointer -Wformat -Werror=format-security" \
        ./configure \
            --prefix=/usr/local \
            --enable-tls \
            --enable-tls-openssl \
            --disable-debug \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    #
    && git clone -b ${LIBLOGGING_VERSION} --single-branch --depth 1 https://github.com/rsyslog/liblogging.git /usr/src/liblogging \
    && cd /usr/src/liblogging \
    && autoreconf --force --verbose --install \
    && CFLAGS="-pipe -m64 -Ofast -fPIE -fPIC -fomit-frame-pointer -Wformat -Werror=format-security" \
        ./configure \
            --prefix=/usr/local \
            --disable-journal \
            --enable-stdlog \
            --enable-rfc3195 \
            --disable-man-pages \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    #
    && git clone -b ${TOKYO_CABINET_VERSION} --single-branch --depth 1 https://github.com/clement/tokyo-cabinet.git /usr/src/tokyo-cabinet \
    && cd /usr/src/tokyo-cabinet \
    && ./configure \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    #
    && git clone --depth=1 https://github.com/bitbouncer/grok.git /usr/src/libgrok \
    && cd /usr/src/libgrok \
    && patch -p0 < /tmp/grok-re-buf-overflow-fix.diff \
    && patch -p0 < /tmp/grok-ipv6.diff \
    && patch -p0 < /tmp/grok-log-levels.diff \
    && patch -p1 < /tmp/grok-missing-semicolon-in-grammar-file.diff \
    && LDFLAGS=-lportablexdr make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    #
    && git clone -b ${RSYSLOG_VERSION} --single-branch --depth 1 https://github.com/rsyslog/rsyslog.git /usr/src/rsyslog \
    && cd /usr/src/rsyslog \
    && ./autogen.sh \
    && ./configure \
        --prefix=/usr/local \
        --sysconfdir=/etc \
        --localstatedir=/var \
        --disable-debug \
        --disable-generate-man-pages \
        --disable-imczmq \
        --disable-imsolaris \
        --disable-ksi-ls12 \
        --disable-liblogging-stdlog \
        --disable-mmsnmptrapd \
        --disable-omamqp1 \
        --disable-omczmq \
        --disable-omhdfs \
        --disable-omhiredis \
        --disable-omjournal \
        --disable-omrabbitmq \
        --disable-omtcl \
        --disable-omudpspoof \
        --disable-pmlastmsg \
        --disable-snmp \
        --disable-unlimited-select \
        --enable-clickhouse \
        --enable-distcheck-workaround \
        --enable-elasticsearch \
        --enable-fmhash \
        --enable-fmhttp \
        --enable-gnutls \
        --enable-imbatchreport \
        --enable-imdiag \
        --enable-imdocker \
        --enable-imfile \
        --enable-imkafka \
        --enable-impstats \
        --enable-imptcp \
        --enable-imtuxedoulog \
        --enable-inet \
        --enable-largefile \
        --enable-libdbi \
        --enable-libfaketime \
        --enable-libgcrypt \
        --enable-mail \
        --enable-mmanon \
        --enable-mmaudit \
        --enable-mmcount \
        --enable-mmdarwin \
        --enable-mmdblookup \
        --enable-mmfields \
        --enable-mmgrok \
        --enable-mmjsonparse \
        --enable-mmkubernetes \
        --enable-mmnormalize \
        --enable-mmpstrucdata \
        --enable-mmrfc5424addhmac \
        --enable-mmrm1stspace \
        --enable-mmsequence \
        --enable-mmtaghostname \
        --enable-mmutf8fix \
        --enable-mysql \
        --enable-omfile-hardened \
        --enable-omhttp \
        --enable-omhttpfs \
        --enable-omkafka \
        --enable-ommongodb \
        --enable-omprog \
        --enable-omruleset \
        --enable-omstdout \
        --enable-omuxsock \
        --enable-openssl \
        --enable-pgsql \
        --enable-pmaixforwardedfrom \
        --enable-pmciscoios \
        --enable-pmcisconames \
        --enable-pmdb2diag \
        --enable-pmnormalize \
        --enable-pmnull \
        --enable-pmpanngfw \
        --enable-pmsnare \
        --enable-regexp \
        --enable-relp \
        --enable-rfc3195 \
        --enable-rsyslogd \
        --enable-rsyslogrt \
        --enable-testbench \
        --enable-uuid \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && strip /usr/local/bin/* \
    && strip /usr/local/sbin/rsyslogd \
    && strip /usr/local/lib/*.so.*.*.* \
    && strip /usr/local/lib/libgrok.so \
    && strip /usr/local/lib/rsyslog/*.so \
    && rm -rf /usr/local/lib/*.a /usr/local/lib/*.la /usr/local/lib/rsyslog/*.la /usr/local/lib/cmake /usr/local/lib/pkgconfig

FROM alpine:3.10

COPY --from=build /usr/local/bin /usr/local/bin
COPY --from=build /usr/local/sbin/rsyslogd /usr/local/sbin/rsyslogd
COPY --from=build /usr/local/lib /usr/local/lib
COPY --from=build /usr/local/share/grok /usr/local/share/grok

RUN apk add --no-cache \
        glib \
        gnutls \
        libbz2 \
        libcrypto1.1 \
        libcurl \
        libdbi \
        libestr \
        libevent \
        libfastjson \
        libgcrypt \
        libmaxminddb \
        libpq \
        librdkafka \
        libssl1.1 \
        libuuid \
        mariadb-connector-c \
        musl \
        pcre \
        portablexdr \
        zlib \
    && mkdir -p /etc/rsyslog.d

COPY rsyslog.conf /etc/rsyslog.conf

ENV TZ=UTC
EXPOSE 514/tcp
EXPOSE 514/udp
STOPSIGNAL SIGTERM

ENTRYPOINT ["/usr/local/sbin/rsyslogd", "-n", "-f", "/etc/rsyslog.conf"]
