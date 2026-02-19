FROM alpine:3.20
ARG DB_PASSWORD
ENV DB_PASSWORD=$DB_PASSWORD
WORKDIR /app
COPY server.sh /app/server.sh
RUN chmod +x /app/server.sh
CMD ["/app/server.sh"]