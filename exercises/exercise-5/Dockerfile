FROM registry.it-scholar.com/alpine:3.23.3

RUN apk add --no-cache nginx ca-certificates tzdata \
  && update-ca-certificates

RUN addgroup -S -g 101 nginx \
  && adduser  -S -D -H -u 101 -G nginx nginx

RUN mkdir -p /var/www/html \
             /var/lib/nginx \
             /var/tmp/nginx \
             /run/nginx \
             /etc/nginx/conf.d \
  && chown -R nginx:nginx /var/www/html /var/lib/nginx /var/tmp/nginx /run/nginx

COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /var/www/html/index.html

RUN chmod -R 0555 /var/www/html \
  && chmod 0644 /etc/nginx/nginx.conf

EXPOSE 8080

USER nginx

STOPSIGNAL SIGQUIT
CMD ["nginx", "-g", "daemon off;"]