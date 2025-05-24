#!/bin/bash

# REDAXO Multi-Instance Manager
# Verwaltung von mehreren REDAXO-Instanzen mit Docker

# Farben für Terminal-Output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Projektverzeichnis
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
INSTANCES_DIR="$PROJECT_DIR/instances"
SSL_DIR="$PROJECT_DIR/ssl"

# Konfiguration
DEFAULT_HTTP_PORT=8080
DEFAULT_HTTPS_PORT=8443
DEFAULT_DB_PORT=3306
DEFAULT_PHPMYADMIN_PORT=8081
DEFAULT_MAILHOG_PORT=8025

# Funktionen
show_help() {
    echo -e "${GREEN}REDAXO Multi-Instance Manager${NC}"
    echo "Verwaltung von mehreren REDAXO-Instanzen mit Docker"
    echo ""
    echo "Verwendung:"
    echo "  ./instance-manager.sh [Befehl] [Optionen]"
    echo ""
    echo "Befehle:"
    echo "  create <name>       - Neue Instanz erstellen"
    echo "  start <name>        - Instanz starten"
    echo "  stop <name>         - Instanz stoppen"
    echo "  restart <name>      - Instanz neustarten"
    echo "  remove <name>       - Instanz löschen"
    echo "  list               - Alle Instanzen auflisten"
    echo "  status [name]      - Status anzeigen (alle oder spezifische Instanz)"
    echo "  logs <name>        - Logs einer Instanz anzeigen"
    echo "  shell <name>       - Shell in der Instanz öffnen"
    echo "  ssl <name>         - SSL-Zertifikat für Instanz erneuern"
    echo "  help               - Diese Hilfe anzeigen"
    echo ""
    echo "Optionen bei create:"
    echo "  --http-port <port>     - HTTP-Port (Standard: automatisch vergeben)"
    echo "  --https-port <port>    - HTTPS-Port (Standard: automatisch vergeben)"
    echo "  --domain <domain>      - Domain für SSL-Zertifikat (Standard: <name>.local)"
    echo "  --repo <repository>    - GitHub-Repository (Standard: skerbis/REDAXO_MODERN_STRUCTURE)"
    echo "  --no-ssl              - SSL deaktivieren"
    echo ""
    echo "Repository-Beispiele:"
    echo "  --repo skerbis/REDAXO_MODERN_STRUCTURE  (Standard)"
    echo "  --repo redaxo/redaxo                    (Offizielles REDAXO)"
    echo "  --repo redaxo/demo_base                 (Demo-Installation)"
}

# Prüft ob eine Instanz existiert
instance_exists() {
    local name=$1
    if [ -d "$INSTANCES_DIR/$name" ]; then
        return 0
    else
        return 1
    fi
}

# Findet den nächsten verfügbaren Port
find_available_port() {
    local start_port=$1
    local port=$start_port
    
    while [ $port -lt 65535 ]; do
        # Prüfe Port-Verfügbarkeit (MacOS/Linux kompatibel)
        if command -v lsof &> /dev/null; then
            if ! lsof -i :$port >/dev/null 2>&1; then
                echo $port
                return
            fi
        elif command -v ss &> /dev/null; then
            if ! ss -tuln | grep -q ":$port "; then
                echo $port
                return
            fi
        elif command -v netstat &> /dev/null; then
            if ! netstat -an | grep -q ":$port "; then
                echo $port
                return
            fi
        else
            # Fallback: Port als verfügbar annehmen
            echo $port
            return
        fi
        ((port++))
    done
    
    echo "Fehler: Kein verfügbarer Port gefunden" >&2
    exit 1
}

# Erstellt lokale Certificate Authority falls noch nicht vorhanden
create_local_ca() {
    local ca_dir="$SSL_DIR/ca"
    
    if [ ! -f "$ca_dir/ca.crt" ]; then
        echo -e "${YELLOW}Erstelle lokale Certificate Authority...${NC}"
        mkdir -p "$ca_dir"
        
        # CA Private Key erstellen
        openssl genrsa -out "$ca_dir/ca.key" 4096
        
        # CA-Zertifikat erstellen
        openssl req -new -x509 -days 3650 -key "$ca_dir/ca.key" -out "$ca_dir/ca.crt" \
            -subj "/C=DE/ST=Germany/L=City/O=REDAXO Local CA/CN=REDAXO Local Certificate Authority" \
            -extensions v3_ca -config <(
            echo '[req]'
            echo 'distinguished_name = req_distinguished_name'
            echo '[v3_ca]'
            echo 'subjectKeyIdentifier = hash'
            echo 'authorityKeyIdentifier = keyid:always,issuer'
            echo 'basicConstraints = critical,CA:true'
            echo 'keyUsage = critical,digitalSignature,cRLSign,keyCertSign'
        )
        
        echo -e "${GREEN}Lokale CA erstellt in $ca_dir${NC}"
        echo -e "${YELLOW}Um Zertifikatswarnungen zu vermeiden, fügen Sie $ca_dir/ca.crt zu den vertrauenswürdigen Zertifikaten hinzu:${NC}"
        echo -e "${CYAN}security add-trusted-cert -d -r trustRoot -k ~/Library/Keychains/login.keychain $ca_dir/ca.crt${NC}"
    fi
}

# Generiert SSL-Zertifikat signiert von lokaler CA
generate_ssl_cert() {
    local name=$1
    local domain=${2:-"$name.local"}
    local cert_dir="$SSL_DIR/$name"
    local ca_dir="$SSL_DIR/ca"
    
    echo -e "${YELLOW}Generiere SSL-Zertifikat für $domain...${NC}"
    
    # Stelle sicher, dass lokale CA existiert
    create_local_ca
    
    mkdir -p "$cert_dir"
    
    # Generiere private key
    openssl genrsa -out "$cert_dir/private.key" 2048
    
    # Erstelle Konfigurationsdatei für das Zertifikat
    cat > "$cert_dir/cert.conf" << EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
C=DE
ST=Germany
L=City
O=REDAXO Instance
CN=$domain

[v3_req]
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = $domain
DNS.2 = localhost
DNS.3 = *.local
IP.1 = 127.0.0.1
IP.2 = ::1
EOF
    
    # Generiere certificate signing request
    openssl req -new -key "$cert_dir/private.key" -out "$cert_dir/cert.csr" \
        -config "$cert_dir/cert.conf"
    
    # Signiere Zertifikat mit lokaler CA
    openssl x509 -req -days 365 -in "$cert_dir/cert.csr" \
        -CA "$ca_dir/ca.crt" -CAkey "$ca_dir/ca.key" -CAcreateserial \
        -out "$cert_dir/cert.crt" \
        -extensions v3_req -extfile "$cert_dir/cert.conf"
    
    # Kombiniertes Zertifikat erstellen
    cat "$cert_dir/cert.crt" "$cert_dir/private.key" > "$cert_dir/combined.pem"
    
    # Vollständige Zertifikatskette erstellen
    cat "$cert_dir/cert.crt" "$ca_dir/ca.crt" > "$cert_dir/fullchain.crt"
    
    echo -e "${GREEN}SSL-Zertifikat für $domain erstellt${NC}"
    echo -e "${YELLOW}Zertifikat wurde von lokaler CA signiert${NC}"
}

# Erstellt eine neue Instanz
create_instance() {
    local name=$1
    local http_port=""
    local https_port=""
    local domain=""
    local enable_ssl=true
    local repository=""
    
    if [ -z "$name" ]; then
        echo -e "${RED}Fehler: Instanzname erforderlich${NC}"
        show_help
        exit 1
    fi
    
    if instance_exists "$name"; then
        echo -e "${RED}Fehler: Instanz '$name' existiert bereits${NC}"
        exit 1
    fi
    
    # Parse Optionen
    shift
    while [[ $# -gt 0 ]]; do
        case $1 in
            --http-port)
                http_port="$2"
                shift 2
                ;;
            --https-port)
                https_port="$2"
                shift 2
                ;;
            --domain)
                domain="$2"
                shift 2
                ;;
            --repo)
                repository="$2"
                shift 2
                ;;
            --no-ssl)
                enable_ssl=false
                shift
                ;;
            *)
                echo -e "${RED}Unbekannte Option: $1${NC}"
                exit 1
                ;;
        esac
    done
    
    # Automatische Port-Zuweisung
    if [ -z "$http_port" ]; then
        http_port=$(find_available_port $DEFAULT_HTTP_PORT)
    fi
    
    if [ "$enable_ssl" = true ] && [ -z "$https_port" ]; then
        https_port=$(find_available_port $DEFAULT_HTTPS_PORT)
    fi
    
    if [ -z "$domain" ]; then
        domain="$name.local"
    fi
    
    local instance_dir="$INSTANCES_DIR/$name"
    
    echo -e "${YELLOW}Erstelle Instanz '$name'...${NC}"
    echo "  HTTP-Port: $http_port"
    if [ "$enable_ssl" = true ]; then
        echo "  HTTPS-Port: $https_port"
        echo "  Domain: $domain"
    fi
    if [ -n "$repository" ]; then
        echo "  Repository: $repository"
    fi
    
    # Erstelle Instanz-Verzeichnis
    mkdir -p "$instance_dir"
    
    # Kopiere REDAXO Modern Structure von GitHub (mit optionalem Repository)
    echo -e "${BLUE}Lade aktuelle REDAXO-Version von GitHub...${NC}"
    if [ -n "$repository" ]; then
        "$SCRIPT_DIR/redaxo-downloader.sh" download latest --repo "$repository" --extract-to "$instance_dir/app"
    else
        "$SCRIPT_DIR/redaxo-downloader.sh" download latest --extract-to "$instance_dir/app"
    fi
    
    if [ ! -d "$instance_dir/app" ] || [ -z "$(ls -A "$instance_dir/app" 2>/dev/null)" ]; then
        echo -e "${RED}Fehler: REDAXO-Download fehlgeschlagen${NC}"
        echo -e "${YELLOW}Verwende Fallback: app-template${NC}"
        
        # Fallback auf app-template
        if [ -d "$PROJECT_DIR/app-template" ]; then
            cp -r "$PROJECT_DIR/app-template" "$instance_dir/app"
        else
            echo -e "${RED}Fehler: Weder REDAXO-Download noch app-template verfügbar${NC}"
            rm -rf "$instance_dir"
            exit 1
        fi
    fi
    
    # Kopiere Docker-Konfiguration
    cp -r "$PROJECT_DIR/docker" "$instance_dir/"
    
    # SSL-Zertifikat generieren
    if [ "$enable_ssl" = true ]; then
        generate_ssl_cert "$name" "$domain"
        
        # Nginx-Konfiguration für HTTPS erweitern
        cat >> "$instance_dir/docker/apache/apache-vhost.conf" << 'EOF'

# HTTPS VirtualHost
<VirtualHost *:443>
    ServerName localhost
    DocumentRoot /var/www/html/public
    
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/cert.crt
    SSLCertificateKeyFile /etc/ssl/private/private.key
    
    <Directory /var/www/html/public>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF
        
        # Dockerfile für SSL erweitern
        sed -i '' '/^FROM php:8.2-apache/a\
RUN a2enmod ssl && a2enmod rewrite
' "$instance_dir/docker/apache/Dockerfile"
    fi
    
    # Docker Compose Datei erstellen
    create_docker_compose "$name" "$http_port" "$https_port" "$enable_ssl"
    
    # Umgebungsvariablen-Datei erstellen
    create_env_file "$name" "$http_port" "$https_port" "$domain"
    
    echo -e "${GREEN}Instanz '$name' erfolgreich erstellt${NC}"
    echo -e "${BLUE}Starte die Instanz mit: ./scripts/instance-manager.sh start $name${NC}"
}

# Erstellt docker-compose.yml für Instanz
create_docker_compose() {
    local name=$1
    local http_port=$2
    local https_port=$3
    local enable_ssl=$4
    local instance_dir="$INSTANCES_DIR/$name"
    
    cat > "$instance_dir/docker-compose.yml" << EOF
version: '3.8'

services:
  # Apache mit PHP
  apache:
    build:
      context: ./docker/apache
    container_name: redaxo-${name}-apache
    ports:
      - "${http_port}:80"
EOF
    
    if [ "$enable_ssl" = true ]; then
        cat >> "$instance_dir/docker-compose.yml" << EOF
      - "${https_port}:443"
EOF
    fi
    
    cat >> "$instance_dir/docker-compose.yml" << EOF
    volumes:
      - ./app:/var/www/html
EOF
    
    if [ "$enable_ssl" = true ]; then
        cat >> "$instance_dir/docker-compose.yml" << EOF
      - ../../ssl/${name}/cert.crt:/etc/ssl/certs/cert.crt:ro
      - ../../ssl/${name}/private.key:/etc/ssl/private/private.key:ro
EOF
    fi
    
    cat >> "$instance_dir/docker-compose.yml" << EOF
    restart: unless-stopped
    depends_on:
      - mariadb
    networks:
      - redaxo-${name}-network

  # MariaDB
  mariadb:
    image: mariadb:latest
    container_name: redaxo-${name}-mariadb
    environment:
      MYSQL_ROOT_PASSWORD: \${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: \${MYSQL_DATABASE}
      MYSQL_USER: \${MYSQL_USER}
      MYSQL_PASSWORD: \${MYSQL_PASSWORD}
    volumes:
      - mariadb_data:/var/lib/mysql
    restart: unless-stopped
    networks:
      - redaxo-${name}-network

  # phpMyAdmin
  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    container_name: redaxo-${name}-phpmyadmin
    environment:
      PMA_HOST: mariadb
      PMA_USER: \${MYSQL_USER}
      PMA_PASSWORD: \${MYSQL_PASSWORD}
    ports:
      - "\${PHPMYADMIN_PORT}:80"
    depends_on:
      - mariadb
    restart: unless-stopped
    networks:
      - redaxo-${name}-network

  # MailHog für SMTP-Debugging
  mailhog:
    image: mailhog/mailhog
    container_name: redaxo-${name}-mailhog
    ports:
      - "\${MAILHOG_PORT}:8025"
    restart: unless-stopped
    networks:
      - redaxo-${name}-network

networks:
  redaxo-${name}-network:
    driver: bridge

volumes:
  mariadb_data:
EOF
}

# Erstellt .env-Datei für Instanz
create_env_file() {
    local name=$1
    local http_port=$2
    local https_port=$3
    local domain=$4
    local instance_dir="$INSTANCES_DIR/$name"
    
    # Finde verfügbare Ports für Services
    local phpmyadmin_port=$(find_available_port $(($DEFAULT_PHPMYADMIN_PORT + 100)))
    local mailhog_port=$(find_available_port $(($DEFAULT_MAILHOG_PORT + 100)))
    
    cat > "$instance_dir/.env" << EOF
# REDAXO Instance: $name
INSTANCE_NAME=$name
DOMAIN=$domain

# MariaDB-Konfiguration
MYSQL_ROOT_PASSWORD=redaxo_${name}_root
MYSQL_DATABASE=redaxo_$name
MYSQL_USER=redaxo_$name
MYSQL_PASSWORD=redaxo_${name}_pass

# Portmapping
HTTP_PORT=$http_port
HTTPS_PORT=$https_port
PHPMYADMIN_PORT=$phpmyadmin_port
MAILHOG_PORT=$mailhog_port

# Erstellt am: $(date)
EOF
}

# Startet eine Instanz
start_instance() {
    local name=$1
    
    if [ -z "$name" ]; then
        echo -e "${RED}Fehler: Instanzname erforderlich${NC}"
        exit 1
    fi
    
    if ! instance_exists "$name"; then
        echo -e "${RED}Fehler: Instanz '$name' existiert nicht${NC}"
        exit 1
    fi
    
    local instance_dir="$INSTANCES_DIR/$name"
    
    echo -e "${YELLOW}Starte Instanz '$name'...${NC}"
    
    cd "$instance_dir"
    docker-compose up -d
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Instanz '$name' erfolgreich gestartet${NC}"
        show_instance_urls "$name"
    else
        echo -e "${RED}Fehler beim Starten der Instanz '$name'${NC}"
        exit 1
    fi
}

# Stoppt eine Instanz
stop_instance() {
    local name=$1
    
    if [ -z "$name" ]; then
        echo -e "${RED}Fehler: Instanzname erforderlich${NC}"
        exit 1
    fi
    
    if ! instance_exists "$name"; then
        echo -e "${RED}Fehler: Instanz '$name' existiert nicht${NC}"
        exit 1
    fi
    
    local instance_dir="$INSTANCES_DIR/$name"
    
    echo -e "${YELLOW}Stoppe Instanz '$name'...${NC}"
    
    cd "$instance_dir"
    docker-compose down
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Instanz '$name' erfolgreich gestoppt${NC}"
    else
        echo -e "${RED}Fehler beim Stoppen der Instanz '$name'${NC}"
        exit 1
    fi
}

# Startet eine Instanz neu
restart_instance() {
    local name=$1
    
    echo -e "${YELLOW}Starte Instanz '$name' neu...${NC}"
    stop_instance "$name"
    sleep 2
    start_instance "$name"
}

# Entfernt eine Instanz
remove_instance() {
    local name=$1
    
    if [ -z "$name" ]; then
        echo -e "${RED}Fehler: Instanzname erforderlich${NC}"
        exit 1
    fi
    
    if ! instance_exists "$name"; then
        echo -e "${RED}Fehler: Instanz '$name' existiert nicht${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Möchten Sie die Instanz '$name' wirklich löschen? (y/N)${NC}"
    read -r confirmation
    
    if [[ $confirmation =~ ^[Yy]$ ]]; then
        local instance_dir="$INSTANCES_DIR/$name"
        
        # Stoppe Instanz falls sie läuft
        cd "$instance_dir"
        docker-compose down -v 2>/dev/null
        
        # Lösche Instanz-Verzeichnis
        rm -rf "$instance_dir"
        
        # Lösche SSL-Zertifikate
        rm -rf "$SSL_DIR/$name"
        
        echo -e "${GREEN}Instanz '$name' wurde gelöscht${NC}"
    else
        echo -e "${YELLOW}Löschung abgebrochen${NC}"
    fi
}

# Listet alle Instanzen auf
list_instances() {
    echo -e "${GREEN}Verfügbare REDAXO-Instanzen:${NC}"
    echo ""
    
    if [ ! -d "$INSTANCES_DIR" ] || [ -z "$(ls -A "$INSTANCES_DIR" 2>/dev/null)" ]; then
        echo -e "${YELLOW}Keine Instanzen gefunden${NC}"
        return
    fi
    
    for instance in "$INSTANCES_DIR"/*; do
        if [ -d "$instance" ]; then
            local name=$(basename "$instance")
            local status="Gestoppt"
            
            # Prüfe ob Container läuft
            if docker ps --format "table {{.Names}}" | grep -q "redaxo-${name}-apache"; then
                status="${GREEN}Läuft${NC}"
            else
                status="${RED}Gestoppt${NC}"
            fi
            
            echo -e "  ${BLUE}$name${NC} - Status: $status"
            
            # Zeige URLs wenn läuft
            if docker ps --format "table {{.Names}}" | grep -q "redaxo-${name}-apache"; then
                show_instance_urls "$name" "    "
            fi
        fi
    done
}

# Zeigt URLs einer Instanz
show_instance_urls() {
    local name=$1
    local prefix=${2:-""}
    local instance_dir="$INSTANCES_DIR/$name"
    
    if [ -f "$instance_dir/.env" ]; then
        source "$instance_dir/.env"
        
        echo "${prefix}URLs:"
        echo "${prefix}  REDAXO:     http://localhost:$HTTP_PORT"
        if [ -n "$HTTPS_PORT" ]; then
            echo "${prefix}  REDAXO SSL: https://localhost:$HTTPS_PORT"
        fi
        echo "${prefix}  phpMyAdmin: http://localhost:$PHPMYADMIN_PORT"
        echo "${prefix}  MailHog:    http://localhost:$MAILHOG_PORT"
    fi
}

# Zeigt Status einer oder aller Instanzen
show_status() {
    local name=$1
    
    if [ -n "$name" ]; then
        if ! instance_exists "$name"; then
            echo -e "${RED}Fehler: Instanz '$name' existiert nicht${NC}"
            exit 1
        fi
        
        local instance_dir="$INSTANCES_DIR/$name"
        cd "$instance_dir"
        docker-compose ps
    else
        list_instances
    fi
}

# Zeigt Logs einer Instanz
show_logs() {
    local name=$1
    
    if [ -z "$name" ]; then
        echo -e "${RED}Fehler: Instanzname erforderlich${NC}"
        exit 1
    fi
    
    if ! instance_exists "$name"; then
        echo -e "${RED}Fehler: Instanz '$name' existiert nicht${NC}"
        exit 1
    fi
    
    local instance_dir="$INSTANCES_DIR/$name"
    cd "$instance_dir"
    docker-compose logs -f
}

# Öffnet Shell in einer Instanz
open_shell() {
    local name=$1
    
    if [ -z "$name" ]; then
        echo -e "${RED}Fehler: Instanzname erforderlich${NC}"
        exit 1
    fi
    
    if ! instance_exists "$name"; then
        echo -e "${RED}Fehler: Instanz '$name' existiert nicht${NC}"
        exit 1
    fi
    
    docker exec -it "redaxo-${name}-apache" /bin/bash
}

# Erneuert SSL-Zertifikat
renew_ssl() {
    local name=$1
    
    if [ -z "$name" ]; then
        echo -e "${RED}Fehler: Instanzname erforderlich${NC}"
        exit 1
    fi
    
    if ! instance_exists "$name"; then
        echo -e "${RED}Fehler: Instanz '$name' existiert nicht${NC}"
        exit 1
    fi
    
    local instance_dir="$INSTANCES_DIR/$name"
    source "$instance_dir/.env"
    
    generate_ssl_cert "$name" "$DOMAIN"
    
    echo -e "${YELLOW}Starte Instanz neu um neues Zertifikat zu laden...${NC}"
    restart_instance "$name"
}

# Hauptlogik
case $1 in
    create)
        shift
        create_instance "$@"
        ;;
    start)
        start_instance "$2"
        ;;
    stop)
        stop_instance "$2"
        ;;
    restart)
        restart_instance "$2"
        ;;
    remove)
        remove_instance "$2"
        ;;
    list)
        list_instances
        ;;
    status)
        show_status "$2"
        ;;
    logs)
        show_logs "$2"
        ;;
    shell)
        open_shell "$2"
        ;;
    ssl)
        renew_ssl "$2"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}Unbekannter Befehl: $1${NC}"
        show_help
        exit 1
        ;;
esac
