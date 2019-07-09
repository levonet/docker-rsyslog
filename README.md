# Supported tags and respective `Dockerfile` links

- [`latest` (*Dockerfile*)](https://github.com/levonet/docker-rsyslog/blob/master/Dockerfile)
- [`8.1907.0-alpine`, `8.1907-alpine` (*Dockerfile*)](https://github.com/levonet/docker-rsyslog/blob/v8.1907.0/Dockerfile)

# Rsyslog

[![](https://images.microbadger.com/badges/version/levonet/rsyslog.svg)](https://microbadger.com/images/levonet/rsyslog "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/levonet/rsyslog.svg)](https://microbadger.com/images/levonet/rsyslog "Get your own image badge on microbadger.com")
[![Docker Pulls](https://img.shields.io/docker/pulls/levonet/rsyslog.svg)](https://hub.docker.com/r/levonet/rsyslog/)

**Fastest** and **smaller** Rsyslog built for x86-64 CPU architecture.

This source is used to build an image for rsyslog.

## Modules

Rsyslog has a modular design. This enables functionality to be dynamically loaded from modules, which may also be written by any third party.
The image contains:

<table>
  <tr>
    <th>Output</th><th>Input</th><th>Parser</th><th>Message Modification</th><th>Functions</th><th>Library</th>
  </tr>
  <tr>
    <td>
      omclickhouse<br/>
      omelasticsearch<br/>
      omfile-hardened<br/>
      omhttp<br/>
      omhttpfs<br/>
      omkafka<br/>
      ommongodb<br/>
      omlibdbi<br/>
      ommail<br/>
      ommysql<br/>
      ompgsql<br/>
      omprog<br/>
      omrelp<br/>
      omruleset<br/>
      omstdout<br/>
      omtesting<br/>
      omuxsock
    </td><td>
      im3195<br/>
      imbatchreport<br/>
      imdiag<br/>
      imdocker<br/>
      imfile<br/>
      imkafka<br/>
      imklog<br/>
      immark<br/>
      impstats<br/>
      imptcp<br/>
      imrelp<br/>
      imtcp<br/>
      imtuxedoulog<br/>
      imudp<br/>
      imuxsock
    </td><td>
      pmaixforwardedfrom<br/>
      pmciscoios<br/>
      pmcisconames<br/>
      pmdb2diag<br/>
      pmnormalize<br/>
      pmnull<br/>
      pmpanngfw<br/>
      pmsnare
    </td><td>
      mmanon<br/>
      mmaudit<br/>
      mmcount<br/>
      mmdblookup<br/>
      mmexternal<br/>
      mmfields<br/>
      mmgrok<br/>
      mmjsonparse<br/>
      mmkubernetes<br/>
      mmnormalize<br/>
      mmpstrucdata<br/>
      mmrfc5424addhmac<br/>
      mmrm1stspace<br/>
      mmsequence<br/>
      mmtaghostname<br/>
      mmutf8fix
    </td><td>
      fmhash<br/>
      fmhttp
    </td><td>
      lmcry_gcry<br/>
      lmnet<br/>
      lmnetstrms<br/>
      lmnsd_gtls<br/>
      lmnsd_ossl<br/>
      lmnsd_ptcp<br/>
      lmregexp<br/>
      lmtcpclt<br/>
      lmtcpsrv<br/>
      lmzlibw
    </td>
  </tr>
</table>

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
