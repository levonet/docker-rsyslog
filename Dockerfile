FROM alpine:edge AS build

COPY grok-*.diff /tmp/

ENV RSYSLOG_VERSION v8.1903.0
ENV LIBLOGNORM_VERSION v2.0.6
ENV LIBRELP_VERSION v1.3.0
ENV LIBLOGGING_VERSION v1.0.6
ENV TOKYO_CABINET_VERSION 1.4.30
ENV CFLAGS "-pipe -m64 -Ofast -mtune=generic -march=x86-64 -fPIE -fPIC -funroll-loops -fstack-protector-strong -ffast-math -fomit-frame-pointer -Wformat -Werror=format-security"

RUN apk add --no-cache \
        git \
        autoconf \
        automake \
        libtool \
        build-base \
        flex \
        bison \
        rpcgen \
        gperf \
        py-docutils \
        gnutls-dev \
        zlib-dev \
        pcre-dev \
        curl-dev \
        mysql-dev \
        postgresql-dev \
        libdbi-dev \
        libuuid \
        util-linux-dev \
        libgcrypt-dev \
        bsd-compat-headers \
        linux-headers \
        librdkafka-dev \
        libestr-dev \
        libfastjson-dev \
        liblogging-dev \
        libmaxminddb-dev \
        bzip2-dev \
        portablexdr-dev \
        libevent-dev \
        glib-dev \
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
    && git clone --depth=1 https://github.com/jordansissel/grok.git /usr/src/libgrok \
    && cd /usr/src/libgrok \
    && patch -p0 < /tmp/grok-gperf3.1.diff \
    && patch -p0 < /tmp/grok-re-buf-overflow-fix.diff \
    && PREFIX=/usr/local LDFLAGS=-lportablexdr make -j$(getconf _NPROCESSORS_ONLN) \
    && PREFIX=/usr/local make install \
    #
    && git clone -b ${RSYSLOG_VERSION} --single-branch --depth 1 https://github.com/rsyslog/rsyslog.git /usr/src/rsyslog \
    && cd /usr/src/rsyslog \
    && ./autogen.sh \
    && ./configure \
        --prefix=/usr/local \
        --sysconfdir=/etc \
        --localstatedir=/var \
        --disable-debug \
        --enable-largefile \
        --enable-regexp \
        --enable-fmhash \
        --enable-inet \
        --disable-unlimited-select \
        --enable-mysql \
        --enable-pgsql \
        --enable-libdbi \
        --disable-snmp \
        --enable-uuid \
        --enable-elasticsearch \
        --enable-clickhouse \
        --enable-omhttp \
        --enable-openssl \
        --enable-gnutls \
        --enable-libgcrypt \
        --enable-rsyslogrt \
        --enable-rsyslogd \
        --enable-mail \
        --enable-fmhttp \
        --enable-imdiag \
        --enable-mmnormalize \
        --enable-mmjsonparse \
        --enable-mmgrok \
        --enable-mmaudit \
        --enable-mmanon \
        --enable-mmrm1stspace \
        --enable-mmutf8fix \
        --enable-mmcount \
        --enable-mmsequence \
        --enable-mmdblookup \
        --enable-mmfields \
        --enable-mmpstrucdata \
        --enable-mmrfc5424addhmac \
        --enable-omfile-hardened \
        --enable-relp \
        --disable-ksi-ls12 \
        --disable-liblogging-stdlog \
        --enable-rfc3195 \
        --enable-testbench \
        --enable-libfaketime \
        --enable-imfile \
        --disable-imsolaris \
        --enable-imptcp \
        --enable-impstats \
        --enable-omprog \
        --disable-omudpspoof \
        --enable-omstdout \
        --disable-omjournal \
        --disable-pmlastmsg \
        --enable-pmcisconames \
        --enable-pmciscoios \
        --enable-pmnull \
        --enable-pmnormalize \
        --enable-pmaixforwardedfrom \
        --enable-pmsnare \
        --enable-pmpanngfw \
        --enable-omruleset \
        --enable-omuxsock \
        --disable-mmsnmptrapd \
        --disable-omhdfs \
        --enable-omkafka \
        --enable-imkafka \
        --disable-ommongodb \
        --disable-imczmq \
        --disable-omczmq \
        --disable-omrabbitmq \
        --disable-omhiredis \
        --enable-omhttpfs \
        --disable-omamqp1 \
        --disable-omtcl \
        --enable-mmkubernetes \
        --disable-generate-man-pages \
        --enable-distcheck-workaround \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && strip /usr/local/bin/* \
    && strip /usr/local/sbin/rsyslogd \
    && strip /usr/local/lib/*.so.*.*.* \
    && strip /usr/local/lib/rsyslog/*.so \
    && rm -r /usr/local/lib/*.a /usr/local/lib/*.la /usr/local/lib/rsyslog/*.la

FROM alpine:edge

COPY --from=build /usr/local/bin /usr/local/bin
COPY --from=build /usr/local/sbin/rsyslogd /usr/local/sbin/rsyslogd
COPY --from=build /usr/local/lib /usr/local/lib

RUN apk add --no-cache \
        musl \
        libcrypto1.1 \
        libcurl \
        libdbi \
        libestr \
        libfastjson \
        libgcrypt \
        gnutls \
        mariadb-connector-c \
        libmaxminddb \
        pcre \
        libpq \
        librdkafka \
        libssl1.1 \
        libuuid \
        zlib \
        libbz2 \
        libevent \
        portablexdr \
        glib \
    && mkdir -p /etc/rsyslog.d

COPY rsyslogd.conf /etc/rsyslogd.conf

ENV TZ=UTC
EXPOSE 514/tcp
EXPOSE 514/udp
STOPSIGNAL SIGTERM

ENTRYPOINT ["/usr/local/sbin/rsyslogd", "-n", "-f", "/etc/rsyslogd.conf"]
