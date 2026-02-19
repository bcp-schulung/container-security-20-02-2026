FROM registry.it-scholar.com/alpine:3.23.3

RUN apk add --no-cache nginx ca-certificates tzdata && update-ca-certificates

RUN getent group web >/dev/null || addgroup -S web \
  && getent passwd web >/dev/null || adduser -S -D -H -G web web

RUN mkdir -p /var/www/html \
	     /var/lib/nginx/logs \
	     /var/tmp/nginx \
	     /run/nginx \
	     /etc/nginx/conf.d

RUN chown -R web:web /var/www/html /var/lib/nginx /var/tmp/nginx /run/nginx

COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /var/www/html/index.html

RUN chmod -R 0555 /var/www/html && chmod 0644 /etc/nginx/nginx.conf

EXPOSE 8080

USER web

STOPSIGNAL SIGQUIT
CMD ["nginx", "-e", "/dev/stderr", "-g", "daemon off;"]