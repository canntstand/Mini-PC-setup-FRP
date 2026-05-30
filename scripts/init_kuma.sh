#!/bin/sh
set -e

echo "Ожидание запуска Kuma..."
until curl -s "$KUMA_URL" > /dev/null; do 
    sleep 5
done

echo "Создание администратора..."
curl -s -X POST "$KUMA_URL/api/v1/setup" \
  -H 'Content-Type: application/json' \
  -d "{\"username\":\"$ADMIN_USER\",\"password\":\"$ADMIN_PASS\"}"

echo "Авторизация для получения токена..."
RESPONSE=$(curl -s -X POST "$KUMA_URL/api/v1/login" \
  -H 'Content-Type: application/json' \
  -d "{\"username\":\"$ADMIN_USER\",\"password\":\"$ADMIN_PASS\"}")

TOKEN=$(echo "$RESPONSE" | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')

if [ -z "$TOKEN" ]; then
    echo "ОШИБКА: Не удалось получить токен авторизации!"
    exit 1
fi

echo "Создание Push-монитора для сервера..."
curl -s -X POST "$KUMA_URL/api/v1/monitor" \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  -d "{\"name\":\"Home-Server\",\"type\":\"push\",\"heartbeat\":60}"

echo "Инициализация Uptime Kuma успешно завершена!"