# Procfile for Railway
# Tells Railway which processes to run

# Frontend - Nginx
web: npm run build && nginx -g "daemon off;"

# Backend - PHP
api: php -S 0.0.0.0:8000 -t .
