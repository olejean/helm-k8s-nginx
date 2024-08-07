FROM nginx:alpine

# Создаем пользователя nginxuser с UID 1001
RUN useradd -M -u 1001 nginxuser

USER root
RUN mkdir -p /var/run/nginx && touch /var/run/nginx/nginx.pid &&  chmod -R 644 /var/run/nginx && \
    chown -R nginxuser:nginxuser  /var/cache/nginx /var/run/nginx /etc/nginx/conf.d /usr/share/nginx/html /etc/nginx


# Копируем содержимое директории /app в контейнер
COPY app /usr/share/nginx/html

# Копируем наш конфигурационный файл nginx.conf
COPY nginx.conf /etc/nginx/nginx.conf





EXPOSE 8000

USER nginxuser
CMD ["nginx", "-g", "daemon off;"]

