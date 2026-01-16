FROM golang:1.25.5-alpine AS build
RUN apk --no-cache add build-base autoconf automake curl libtool
RUN apk --no-cache add pkgconfig git musl-dev libpostal libpostal-dev
WORKDIR /go/src/github.com/owasp-amass/libpostal-rest-api
COPY . .
RUN CGO_ENABLED=1 go install -v ./...

FROM alpine:latest
RUN apk --no-cache add bash ca-certificates
RUN apk --no-cache add build-base autoconf automake curl libtool
RUN apk --no-cache add pkgconfig git musl-dev libpostal libpostal-dev
RUN apk --no-cache --update upgrade
COPY --from=build /go/bin/post_serv /bin/post_serv
ENV HOME=/
RUN addgroup user \
    && adduser user -D -G user \
    && mkdir /data \
    && chown user:user /data
USER user
WORKDIR /data
STOPSIGNAL SIGINT
ENTRYPOINT ["/bin/post_serv"]