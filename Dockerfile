# ============================================================================
# Build on top of Current Lychee
# ============================================================================
FROM ghcr.io/lycheeorg/lychee:edge
COPY --from=composer:2.10.2@sha256:4d71c3c2109c61d5415544264b59ad4087e4c5b7244481723664138fd36d5040 /usr/bin/composer /usr/local/bin/composer

COPY DemoSeeder.php /app/database/seeders/DemoSeeder.php
COPY import /app/import

RUN touch database/database.sqlite \
    && DB_CONNECTION=sqlite php /app/artisan migrate --force \
    && DB_CONNECTION=sqlite php /app/artisan lychee:create_user admin admin --may-administrate \
    && DB_CONNECTION=sqlite php /app/artisan lychee:create_user user password \
	&& mkdir -p /app/database/seeders \
	&& php -r '$json = json_decode(file_get_contents("composer.json"), true); $json["autoload"]["classmap"][] = "database/seeders"; file_put_contents("composer.json", json_encode($json, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));' \
	&& composer dump-autoload --optimize \
	&& mkdir -p import/Cat \
	&& mkdir -p import/Tulips \
    && DB_CONNECTION=sqlite php /app/artisan lychee:sync import/Cat --skip_duplicates=1 --delete_imported=1 \
    && DB_CONNECTION=sqlite php /app/artisan lychee:sync import/Tulips --skip_duplicates=1 --delete_imported=1 \
    && DB_CONNECTION=sqlite php /app/artisan db:seed --class=DemoSeeder --force \
	&& mkdir -p /app/storage/logs \
	&& mkdir -p /app/storage/tmp \
	&& chmod -R 777 /app/storage/*
