FROM debian:10 as builder
WORKDIR /usr/src
RUN apt update && apt dist-upgrade -y && apt install wget build-essential libpam0g-dev -y
RUN wget https://www.inet.no/dante/files/dante-1.4.2.tar.gz && tar zxfv dante* --strip=1 && rm *.tar.gz
RUN mkdir /usr/src/release && ./configure --without-gssapi --without-krb5 && make -j4 DESTDIR=/usr/src/release install
 
FROM debian:10
RUN apt update && apt dist-upgrade -y && apt install libpam-pwdfile -y
COPY --from=builder /usr/src/release /
RUN echo 'auth required pam_pwdfile.so pwdfile /opt/sockd.pw' > /etc/pam.d/sockd && \
    echo 'account required pam_permit.so' >> /etc/pam.d/sockd
CMD sockd

