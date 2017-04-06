FROM alpine
RUN apk update && apk add ca-certificates openssl curl bash && update-ca-certificates
RUN apk add strace linux-pam openssh
RUN adduser tim -D -u 501
WORKDIR /home/tim
USER tim
