#
# Container Image PostgreSQL
#

FROM alpine:3.16.2

ARG PROJ_NAME
ARG PROJ_VERSION
ARG PROJ_BUILD_NUM
ARG PROJ_BUILD_DATE
ARG PROJ_REPO

LABEL org.opencontainers.image.authors="V10 Solutions"
LABEL org.opencontainers.image.title="${PROJ_NAME}"
LABEL org.opencontainers.image.version="${PROJ_VERSION}"
LABEL org.opencontainers.image.revision="${PROJ_BUILD_NUM}"
LABEL org.opencontainers.image.created="${PROJ_BUILD_DATE}"
LABEL org.opencontainers.image.description="Container image for PostgreSQL"
LABEL org.opencontainers.image.source="${PROJ_REPO}"

RUN apk update \
	&& apk add --no-cache "shadow" "bash" \
	&& usermod -s "$(command -v "bash")" "root"

SHELL [ \
	"bash", \
	"--noprofile", \
	"--norc", \
	"-o", "errexit", \
	"-o", "nounset", \
	"-o", "pipefail", \
	"-c" \
]

ENV LANG "C.UTF-8"
ENV LC_ALL "${LANG}"
ENV LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:/usr/local/lib/postgresql"
ENV PGDATA "/usr/local/var/lib/postgresql"

RUN apk add --no-cache \
	"ca-certificates" \
	"curl" \
	"tzdata" \
	"musl-locales" \
	"zstd" \
	"icu-dev" \
	"icu-data-full" \
	"lz4-dev" \
	"tcl-dev" \
	"krb5-dev" \
	"libc-dev" \
	"zlib-dev" \
	"perl-dev" \
	"perl-utils" \
	"perl-ipc-run" \
	"llvm13-dev" \
	"openssl-dev" \
	"python3-dev" \
	"libxml2-dev" \
	"libxslt-dev" \
	"readline-dev" \
	"openldap-dev" \
	"linux-pam-dev"

RUN apk add --no-cache -t "build-deps" \
	"make" \
	"patch" \
	"linux-headers" \
	"gcc" \
	"g++" \
	"clang" \
	"pkgconf" \
	"util-linux-dev" \
	"flex" \
	"bison"

RUN groupadd -r -g "480" "postgres" \
	&& useradd \
		-r \
		-m \
		-s "$(command -v "nologin")" \
		-g "postgres" \
		-c "Postgres" \
		-u "480" \
		"postgres"

WORKDIR "/tmp"

COPY "patches" "patches"

RUN curl -L -f -o "postgresql.tar.bz2" "https://ftp.postgresql.org/pub/source/v${PROJ_VERSION}/postgresql-${PROJ_VERSION}.tar.bz2" \
	&& mkdir "postgresql" \
	&& tar -x -f "postgresql.tar.bz2" -C "postgresql" --strip-components "1" \
	&& pushd "postgresql" \
	&& find "../patches" \
		-mindepth "1" \
		-type "f" \
		-iname "*.patch" \
		-exec bash --noprofile --norc -c "patch -p \"1\" < \"{}\"" ";" \
	&& ./configure \
		--prefix="/usr/local" \
		--libdir="/usr/local/lib/postgresql" \
		--libexecdir="/usr/local/libexec/postgresql" \
		--sysconfdir="/usr/local/etc/postgresql" \
		--datarootdir="/usr/local/share/postgresql" \
		--sharedstatedir="/usr/local/com/postgresql" \
		--with-uuid="e2fs" \
		--with-pam \
		--with-icu \
		--with-lz4 \
		--with-tcl \
		--with-llvm \
		--with-ldap \
		--with-perl \
		--with-zlib \
		--with-gssapi \
		--with-python \
		--with-libxml \
		--with-libxslt \
		--with-readline \
		--with-ssl="openssl" \
		--with-system-tzdata="/usr/share/zoneinfo" \
		--disable-rpath \
		--enable-tap-tests \
		--enable-thread-safety \
		--enable-integer-datetimes \
	&& make "world" \
	&& make "install-world" \
	&& ldconfig "${LD_LIBRARY_PATH}" \
	&& popd \
	&& rm -r -f "postgresql" \
	&& rm "postgresql.tar.bz2" \
	&& rm -r -f "patches"

WORKDIR "/usr/local"

RUN mkdir -p "etc/postgresql" "lib/postgresql" "libexec/postgresql" "share/postgresql" \
	&& folders=("com/postgresql" "var/lib/postgresql" "var/run/postgresql") \
	&& for folder in "${folders[@]}"; do \
		mkdir -p "${folder}" \
		&& chmod "700" "${folder}" \
		&& chown -R "480":"480" "${folder}"; \
	done

WORKDIR "/"

RUN apk del "build-deps"
