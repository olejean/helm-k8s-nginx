FROM nginx:alpine

# Создаем пользователя nginxuser с UID 1001
RUN adduser -D -u 1001 nginxuser

# Копируем содержимое директории /app в контейнер
COPY app /usr/share/nginx/html

# Копируем наш конфигурационный файл nginx.conf
COPY nginx.conf /etc/nginx/nginx.conf

# Изменяем права на директорию и создаем необходимые директории
RUN chown -R nginxuser:nginxuser /usr/share/nginx/html && \
    mkdir -p /var/cache/nginx/client_temp /var/run/nginx && \
    chown -R nginxuser:nginxuser /var/cache/nginx /var/run/nginx

EXPOSE 8000

USER nginxuser

CMD ["nginx", "-g", "daemon off;"]

