ARG DOCKER_IMAGE=alpine:latest
FROM $DOCKER_IMAGE AS builder

RUN apk add --no-cache gcc make cmake musl-dev ninja libedit-dev git \
	&& git clone --recurse-submodules https://github.com/fabianishere/brainfuck.git
WORKDIR /brainfuck
#--CPU=x86_64
RUN mkdir build && cd build \
	&& cmake .. -DCMAKE_BUILD_TYPE=Release -GNinja -DINSTALL_EXAMPLES=ON \
	&& ninja && ninja test && ninja install

RUN apk del gcc make cmake musl-dev ninja libedit-dev git

ARG DOCKER_IMAGE=alpine:latest
FROM $DOCKER_IMAGE AS runtime

LABEL author="Bensuperpc <bensuperpc@gmail.com>"
LABEL mantainer="Bensuperpc <bensuperpc@gmail.com>"

ARG VERSION="1.0.0"
ENV VERSION=$VERSION

RUN apk add --no-cache make libedit-dev

COPY --from=builder /usr/local /usr/local

ENV PATH="/usr/local/bin:${PATH}"
WORKDIR /usr/src/myapp

RUN brainfuck -h

CMD ["brainfuck", "-h"]

LABEL org.label-schema.schema-version="1.0" \
	  org.label-schema.build-date=$BUILD_DATE \
	  org.label-schema.name="bensuperpc/docker-brainfuck" \
	  org.label-schema.description="build brainfuck compiler" \
	  org.label-schema.version=$VERSION \
	  org.label-schema.vendor="Bensuperpc" \
	  org.label-schema.url="http://bensuperpc.com/" \
	  org.label-schema.vcs-url="https://github.com/Bensuperpc/docker-brainfuck" \
	  org.label-schema.vcs-ref=$VCS_REF \
	  org.label-schema.docker.cmd="docker build -t bensuperpc/brainfuck -f Dockerfile ."
