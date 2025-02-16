# based https://github.com/HaxeFoundation/docker-library-haxe/blob/91376738199ea5595bdc8254b3b84fa16b731a02/4.2/buster/Dockerfile

#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "haxe update.hxml"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM buildpack-deps:buster-scm

# ensure local haxe is preferred over distribution haxe
ENV PATH /usr/local/bin:$PATH

# runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
	libgc1c2 \
	zlib1g \
	libpcre3 \
	libmariadb3 \
	libsqlite3-0 \
	libmbedcrypto3 \
	libmbedtls12 \
	libmbedx509-0 \
	git \
	&& rm -rf /var/lib/apt/lists/*

# install neko, which is a dependency of haxelib
ENV NEKO_VERSION 2.3.0
RUN set -ex \
	&& buildDeps=' \
	gcc \
	make \
	cmake \
	libgc-dev \
	libssl-dev \
	libpcre3-dev \
	zlib1g-dev \
	apache2-dev \
	libmariadb-client-lgpl-dev-compat \
	libsqlite3-dev \
	libmbedtls-dev \
	libgtk2.0-dev \
	' \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/* \
	\
	&& wget -O neko.tar.gz "https://github.com/HaxeFoundation/neko/archive/v2-3-0/neko-2.3.0.tar.gz" \
	&& echo "850e7e317bdaf24ed652efeff89c1cb21380ca19f20e68a296c84f6bad4ee995 *neko.tar.gz" | sha256sum -c - \
	&& mkdir -p /usr/src/neko \
	&& tar -xC /usr/src/neko --strip-components=1 -f neko.tar.gz \
	&& rm neko.tar.gz \
	&& cd /usr/src/neko \
	&& cmake -DRELOCATABLE=OFF . \
	&& make \
	&& make install \
	\
	&& apt-get purge -y --auto-remove $buildDeps \
	&& rm -rf /usr/src/neko ~/.cache

# install haxe
ENV HAXE_VERSION 4.2.3
ENV HAXE_STD_PATH /usr/local/share/haxe/std
RUN set -ex \
	&& buildDeps=' \
	make \
	ocaml-nox \
	ocaml-native-compilers \
	camlp4 \
	ocaml-findlib \
	zlib1g-dev \
	libpcre3-dev \
	libmbedtls-dev \
	libxml-light-ocaml-dev \
	\
	opam \
	mccs \
	m4 \
	unzip \
	pkg-config \
	libstring-shellquote-perl \
	libipc-system-simple-perl \
	\
	' \
	&& git clone --recursive --depth 1 --branch 4.2.3 "https://github.com/HaxeFoundation/haxe.git" /usr/src/haxe \
	&& cd /usr/src/haxe \
	&& mkdir -p $HAXE_STD_PATH \
	&& cp -r std/* $HAXE_STD_PATH \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends \
	\
	\
	&& opam init --disable-sandboxing \
	&& eval `opam env` \
	\
	&& ( [ -f /usr/src/haxe/opam ] && opam install /usr/src/haxe --deps-only --yes || make opam_install ) \
	\
	&& make all tools \
	&& mkdir -p /usr/local/bin \
	&& cp haxe haxelib /usr/local/bin \
	&& mkdir -p /haxelib \
	&& cd / && haxelib setup /haxelib \
	\
	\
	&& eval `opam env --revert` \
	&& rm -rf ~/.opam \
	\
	&& rm -rf /var/lib/apt/lists/* \
	&& apt-get purge -y --auto-remove $buildDeps \
	&& rm -rf /usr/src/haxe ~/.cache

# install nodejs
# https://github.com/nodesource/distributions
RUN curl -fsSL https://deb.nodesource.com/setup_12.x | bash - \
	&& apt-get install -y nodejs \
	&& npm install -g yarn

CMD ["haxe"]
