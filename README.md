# Supported tags and respective `Dockerfile` links

- [`latest` (*Dockerfile*)](https://github.com/levonet/docker-rsyslog/blob/master/Dockerfile)
- [`8.1904.0-alpine`, `8.1904-alpine` (*Dockerfile*)](https://github.com/levonet/docker-rsyslog/blob/v8.1904.0/Dockerfile)

# Rsyslog

**Fastest** and **smaller** Rsyslog built for x86-64 CPU architecture.

This source is used to build an image for rsyslog. The image contains:

- Input Modules:
  - imbatchreport
  - imdiag
  - imdocker
  - imfile
  - imkafka
  - impstats
  - imptcp
  - imtuxedoulog
  - relp
  - rfc3195
  - tcp
  - udp
- Parser Modules:
  - pmaixforwardedfrom
  - pmciscoios
  - pmcisconames
  - pmdb2diag
  - pmnormalize
  - pmnull
  - pmpanngfw
  - pmsnare
- Message Modification:
  - mmanon
  - mmaudit
  - mmcount
  - mmdblookup
  - mmfields
  - mmgrok
  - mmjsonparse
  - mmkubernetes
  - mmnormalize
  - mmpstrucdata
  - mmrfc5424addhmac
  - mmrm1stspace
  - mmsequence
  - mmtaghostname
  - mmutf8fix
- Output Modules:
  - omclickhouse
  - omelasticsearch
  - largefile
  - libdbi
  - mail
  - mysql
  - omfile
  - omfile-hardened
  - omhttp
  - omhttpfs
  - omkafka
  - omprog
  - omruleset
  - omstdout
  - omuxsock
  - pgsql
  - relp
- Functions:
  - fmhash
  - fmhttp
- Other:
  - gnutls
  - inet
  - libfaketime
  - libgcrypt
  - openssl
  - regexp
  - testbench
  - uuid

## How to use this image

This container will listen on `514/udp`, and `514/tcp` and drop all input data without additional configuration.

Rsyslog configuration will load any additionnal configuration files within `/etc/rsyslog.d/` ending by the `.conf` extension.

Run a container from the CLI:

```sh
docker run --name rsyslog -d -p 514:514/tcp -p 514:514/udp \
    -v /etc/rsyslog.d:/etc/rsyslog.d \
    -v /path/syslog:/var/log/syslog \
    levonet/rsyslog
```

## Image Variants

### `levonet/rsyslog:<version>-alpine`

This image is based on the popular [Alpine Linux project](http://alpinelinux.org/), available in [the `alpine` official image](https://hub.docker.com/_/alpine).
Alpine Linux is much smaller than most distribution base images (~5MB), and thus leads to much slimmer images in general.

This variant is highly recommended when final image size being as small as possible is desired. The main caveat to note is that it does use [musl libc](http://www.musl-libc.org/) instead of [glibc and friends](http://www.etalabs.net/compare_libcs.html), so certain software might run into issues depending on the depth of their libc requirements. However, most software doesn't have an issue with this, so this variant is usually a very safe choice.
See [this Hacker News comment thread](https://news.ycombinator.com/item?id=10782897) for more discussion of the issues that might arise and some pro/con comparisons of using Alpine-based images.

To minimize image size, it's uncommon for additional related tools (such as `git` or `bash`) to be included in Alpine-based images. Using this image as a base, add the things you need in your own Dockerfile (see the [`alpine` image description](https://hub.docker.com/_/alpine/) for examples of how to install packages if you are unfamiliar).
