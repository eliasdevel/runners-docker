#!/bin/bash
docker-compose down

read -p "Database password : " password

if test -f "db_password.txt"; then
    rm db_password.txt
fi

if test -f "db_root_password.txt"; then
    rm db_root_password.txt
fi

echo $password >> db_password.txt

echo $password >> db_root_password.txt

git clone https://github.com/eliasdevel/runners-api.git

echo "
APP_NAME=Lumen
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost
APP_TIMEZONE=UTC

LOG_CHANNEL=stack
LOG_SLACK_WEBHOOK_URL=

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=appdb
DB_USERNAME=user
DB_PASSWORD=$password

CACHE_DRIVER=file
QUEUE_CONNECTION=sync

" > runners-api/.env

docker-compose up -d

rm -rf src

mv runners-api src

docker-compose restart

docker exec -it app composer install

docker exec -it app php artisan migrate