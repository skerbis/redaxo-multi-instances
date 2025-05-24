#!/bin/bash

# REDAXO Multi-Instance Manager by skerbis
# Verwaltung von mehreren REDAXO-Instanzen mit Docker

# Farben für Terminal-Output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Projektverzeichnis
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_DIR="$SCRIPT_DIR"
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
    echo "  config <name>      - Vollständige Konfiguration einer Instanz anzeigen"
    echo "  config-all         - Konfiguration aller Instanzen anzeigen"
    echo "  db-config <name>   - Datenbankonfiguration einer Instanz anzeigen"
    echo "  urls <name>        - URLs einer Instanz anzeigen"
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
    echo "Optionen bei Konfigurationsbefehlen:"
    echo "  config <name> [format] - Format: table (Standard), json"
    echo "  config-all [format]    - Format: table (Standard), summary, json"
    echo "  db-config <name> [format] - Format: setup (Standard), table, json, env"
    echo ""
    echo "Repository-Beispiele:"
    echo "  --repo skerbis/REDAXO_MODERN_STRUCTURE  (Standard)"
    echo "  --repo redaxo/redaxo                    (Offizielles REDAXO)"
    echo "  --repo redaxo/demo_base                 (Demo-Installation)"
    echo ""
    echo "Beispiele:"
    echo "  ./instance-manager.sh create meine-instanz"
    echo "  ./instance-manager.sh db-config meine-instanz"
    echo "  ./instance-manager.sh config meine-instanz"
    echo "  ./instance-manager.sh config-all summary"
    echo "  ./instance-manager.sh urls meine-instanz"
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
        "$PROJECT_DIR/redaxo-downloader.sh" download latest --repo "$repository" --extract-to "$instance_dir/app"
    else
        "$PROJECT_DIR/redaxo-downloader.sh" download latest --extract-to "$instance_dir/app"
    fi
    
    if [ ! -d "$instance_dir/app" ] || [ -z "$(ls -A "$instance_dir/app" 2>/dev/null)" ]; then
        echo -e "${RED}Fehler: REDAXO-Download fehlgeschlagen${NC}"
        echo -e "${RED}Keine REDAXO-Installation verfügbar${NC}"
        rm -rf "$instance_dir"
        exit 1
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
    echo -e "${BLUE}Starte die Instanz mit: ./instance-manager.sh start $name${NC}"
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
        
        echo "${prefix}${BLUE}URLs:${NC}"
        echo "${prefix}  REDAXO HTTP:   http://localhost:$HTTP_PORT"
        if [ -n "$HTTPS_PORT" ] && [ "$HTTPS_PORT" != "N/A" ]; then
            echo "${prefix}  REDAXO HTTPS:  https://localhost:$HTTPS_PORT"
        fi
        echo "${prefix}  phpMyAdmin:    http://localhost:$PHPMYADMIN_PORT"
        echo "${prefix}  MailHog:       http://localhost:$MAILHOG_PORT"
    fi
}

# Zeigt nur URLs einer Instanz (als separater Befehl)
show_urls() {
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
    
    if [ ! -f "$instance_dir/.env" ]; then
        echo -e "${RED}Fehler: .env-Datei für Instanz '$name' nicht gefunden${NC}"
        exit 1
    fi
    
    source "$instance_dir/.env"
    
    echo -e "${GREEN}URLs für Instanz '$name':${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${BLUE}REDAXO Anwendung:${NC}"
    echo "  HTTP:   http://localhost:$HTTP_PORT"
    if [ -n "$HTTPS_PORT" ] && [ "$HTTPS_PORT" != "N/A" ]; then
        echo "  HTTPS:  https://localhost:$HTTPS_PORT"
        echo "  Domain: https://$DOMAIN (wenn DNS konfiguriert)"
    fi
    echo ""
    echo -e "${BLUE}Development Tools:${NC}"
    echo "  phpMyAdmin: http://localhost:$PHPMYADMIN_PORT"
    echo "  MailHog:    http://localhost:$MAILHOG_PORT"
    echo ""
    
    # Status prüfen
    if docker ps --format "table {{.Names}}" | grep -q "redaxo-${name}-apache"; then
        echo -e "${GREEN}✓ Instanz ist aktiv - URLs sind verfügbar${NC}"
    else
        echo -e "${RED}⚠ Instanz ist gestoppt - Starten Sie sie mit: ./instance-manager.sh start $name${NC}"
    fi
}

# Zeigt Datenbankonfiguration einer Instanz (erweitert)
show_db_config() {
    local name=$1
    local format=${2:-"table"}
    local prefix=${3:-""}
    
    if [ -z "$name" ]; then
        echo -e "${RED}Fehler: Instanzname erforderlich${NC}"
        exit 1
    fi
    
    if ! instance_exists "$name"; then
        echo -e "${RED}Fehler: Instanz '$name' existiert nicht${NC}"
        exit 1
    fi
    
    local instance_dir="$INSTANCES_DIR/$name"
    
    if [ ! -f "$instance_dir/.env" ]; then
        echo -e "${RED}Fehler: .env-Datei für Instanz '$name' nicht gefunden${NC}"
        exit 1
    fi
    
    source "$instance_dir/.env"
    
    if [ "$format" = "json" ]; then
        cat << EOF
{
  "instance": "$name",
  "database": {
    "host": "mariadb",
    "port": "3306",
    "name": "$MYSQL_DATABASE",
    "user": "$MYSQL_USER",
    "password": "$MYSQL_PASSWORD",
    "root_password": "$MYSQL_ROOT_PASSWORD"
  }
}
EOF
    elif [ "$format" = "env" ]; then
        echo "${prefix}MYSQL_DATABASE=$MYSQL_DATABASE"
        echo "${prefix}MYSQL_USER=$MYSQL_USER"
        echo "${prefix}MYSQL_PASSWORD=$MYSQL_PASSWORD"
        echo "${prefix}MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD"
    elif [ "$format" = "setup" ]; then
        echo -e "${GREEN}Datenbankonfiguration für REDAXO-Setup:${NC}"
        echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${BLUE}Im REDAXO-Setup eingeben:${NC}"
        echo "┌─────────────────────────────────────────────┐"
        echo "│ Database Server: mariadb                    │"
        printf "│ Database Name:   %-23s │\n" "$MYSQL_DATABASE"
        printf "│ Username:        %-23s │\n" "$MYSQL_USER"
        printf "│ Password:        %-23s │\n" "$MYSQL_PASSWORD"
        echo "│ Host:            mariadb                    │"
        echo "│ Port:            3306                       │"
        echo "└─────────────────────────────────────────────┘"
        echo ""
        echo -e "${YELLOW}⚠ Wichtig: Verwenden Sie 'mariadb' als Host, nicht 'localhost'!${NC}"
        echo -e "${YELLOW}  Dies ist der Docker-Container-Name für die Datenbank.${NC}"
    else
        echo "${prefix}${BLUE}Datenbankonfiguration:${NC}"
        echo "${prefix}  Host:          mariadb"
        echo "${prefix}  Port:          3306"
        echo "${prefix}  Datenbank:     $MYSQL_DATABASE"
        echo "${prefix}  Benutzer:      $MYSQL_USER"
        echo "${prefix}  Passwort:      $MYSQL_PASSWORD"
        echo "${prefix}  Root-Passwort: $MYSQL_ROOT_PASSWORD"
    fi
}

# Zeigt vollständige Konfiguration einer Instanz
show_full_config() {
    local name=$1
    local format=${2:-"table"}
    
    if [ -z "$name" ]; then
        echo -e "${RED}Fehler: Instanzname erforderlich${NC}"
        exit 1
    fi
    
    if ! instance_exists "$name"; then
        echo -e "${RED}Fehler: Instanz '$name' existiert nicht${NC}"
        exit 1
    fi
    
    local instance_dir="$INSTANCES_DIR/$name"
    
    if [ ! -f "$instance_dir/.env" ]; then
        echo -e "${RED}Fehler: .env-Datei für Instanz '$name' nicht gefunden${NC}"
        exit 1
    fi
    
    source "$instance_dir/.env"
    
    # Status prüfen
    local status="Gestoppt"
    local status_color="${RED}"
    if docker ps --format "table {{.Names}}" | grep -q "redaxo-${name}-apache"; then
        status="Läuft"
        status_color="${GREEN}"
    fi
    
    if [ "$format" = "json" ]; then
        cat << EOF
{
  "instance": "$name",
  "status": "$status",
  "domain": "$DOMAIN",
  "created": "$(date -r "$instance_dir" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo 'Unknown')",
  "urls": {
    "redaxo_http": "http://localhost:$HTTP_PORT",
    "redaxo_https": "https://localhost:${HTTPS_PORT:-'N/A'}",
    "phpmyadmin": "http://localhost:$PHPMYADMIN_PORT",
    "mailhog": "http://localhost:$MAILHOG_PORT"
  },
  "database": {
    "host": "mariadb",
    "port": "3306",
    "name": "$MYSQL_DATABASE",
    "user": "$MYSQL_USER",
    "password": "$MYSQL_PASSWORD",
    "root_password": "$MYSQL_ROOT_PASSWORD"
  },
  "ports": {
    "http": "$HTTP_PORT",
    "https": "${HTTPS_PORT:-'N/A'}",
    "phpmyadmin": "$PHPMYADMIN_PORT",
    "mailhog": "$MAILHOG_PORT"
  },
  "ssl": {
    "enabled": $([ -n "$HTTPS_PORT" ] && [ "$HTTPS_PORT" != "N/A" ] && echo "true" || echo "false"),
    "cert_path": "$SSL_DIR/$name"
  }
}
EOF
    else
        echo -e "${GREEN}══════════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}Konfiguration für Instanz: $name${NC}"
        echo -e "${GREEN}══════════════════════════════════════════════════════════${NC}"
        echo ""
        
        echo -e "${BLUE}Allgemeine Informationen:${NC}"
        echo "  Status:        $status_color$status${NC}"
        echo "  Domain:        $DOMAIN"
        echo "  Erstellt:      $(date -r "$instance_dir" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo 'Unknown')"
        echo ""
        
        show_instance_urls "$name" "  "
        echo ""
        
        show_db_config "$name" "table" "  "
        echo ""
        
        echo -e "${BLUE}Port-Mapping:${NC}"
        echo "  HTTP:          $HTTP_PORT"
        if [ -n "$HTTPS_PORT" ] && [ "$HTTPS_PORT" != "N/A" ]; then
            echo "  HTTPS:         $HTTPS_PORT"
        fi
        echo "  phpMyAdmin:    $PHPMYADMIN_PORT"
        echo "  MailHog:       $MAILHOG_PORT"
        echo ""
        
        echo -e "${BLUE}SSL-Konfiguration:${NC}"
        if [ -n "$HTTPS_PORT" ] && [ "$HTTPS_PORT" != "N/A" ]; then
            echo "  SSL aktiviert: ${GREEN}Ja${NC}"
            echo "  Zertifikat:    $SSL_DIR/$name"
        else
            echo "  SSL aktiviert: ${RED}Nein${NC}"
        fi
        echo ""
        
        echo -e "${BLUE}Docker-Container:${NC}"
        echo "  Apache:        redaxo-${name}-apache"
        echo "  MariaDB:       redaxo-${name}-mariadb"
        echo "  phpMyAdmin:    redaxo-${name}-phpmyadmin"
        echo "  MailHog:       redaxo-${name}-mailhog"
        echo ""
        
        echo -e "${BLUE}Dateipfade:${NC}"
        echo "  Instance:      $instance_dir"
        echo "  App:           $instance_dir/app"
        echo "  Docker:        $instance_dir/docker"
        if [ -n "$HTTPS_PORT" ] && [ "$HTTPS_PORT" != "N/A" ]; then
            echo "  SSL:           $SSL_DIR/$name"
        fi
    fi
}

# Zeigt Konfiguration aller Instanzen
show_all_configs() {
    local format=${1:-"table"}
    local filter=${2:-""}
    
    if [ ! -d "$INSTANCES_DIR" ] || [ -z "$(ls -A "$INSTANCES_DIR" 2>/dev/null)" ]; then
        echo -e "${YELLOW}Keine Instanzen gefunden${NC}"
        return
    fi
    
    if [ "$format" = "json" ]; then
        echo "{"
        echo '  "instances": ['
        local first=true
        for instance in "$INSTANCES_DIR"/*; do
            if [ -d "$instance" ]; then
                local name=$(basename "$instance")
                if [ -n "$filter" ] && [[ ! "$name" =~ $filter ]]; then
                    continue
                fi
                if [ "$first" = false ]; then
                    echo ","
                fi
                show_full_config "$name" "json" | sed 's/^/    /'
                first=false
            fi
        done
        echo ""
        echo "  ],"
        echo '  "total": '$(ls -1 "$INSTANCES_DIR" | wc -l | tr -d ' ')','
        echo '  "generated": "'$(date -Iseconds)'"'
        echo "}"
    else
        echo -e "${GREEN}REDAXO Multi-Instance Übersicht${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
        echo ""
        
        local total=0
        local running=0
        
        for instance in "$INSTANCES_DIR"/*; do
            if [ -d "$instance" ]; then
                local name=$(basename "$instance")
                if [ -n "$filter" ] && [[ ! "$name" =~ $filter ]]; then
                    continue
                fi
                
                ((total++))
                
                if docker ps --format "table {{.Names}}" | grep -q "redaxo-${name}-apache"; then
                    ((running++))
                fi
                
                if [ "$format" = "summary" ]; then
                    show_instance_summary "$name"
                else
                    show_full_config "$name" "table"
                    echo ""
                fi
            fi
        done
        
        echo -e "${BLUE}Zusammenfassung:${NC}"
        echo "  Gesamt:        $total Instanzen"
        echo "  Aktiv:         ${GREEN}$running${NC} Instanzen"
        echo "  Gestoppt:      ${RED}$((total - running))${NC} Instanzen"
    fi
}

# Zeigt kompakte Zusammenfassung einer Instanz
show_instance_summary() {
    local name=$1
    local instance_dir="$INSTANCES_DIR/$name"
    
    if [ ! -f "$instance_dir/.env" ]; then
        echo -e "${RED}  $name: Keine Konfiguration gefunden${NC}"
        return
    fi
    
    source "$instance_dir/.env"
    
    local status="Gestoppt"
    local status_color="${RED}"
    if docker ps --format "table {{.Names}}" | grep -q "redaxo-${name}-apache"; then
        status="Läuft"
        status_color="${GREEN}"
    fi
    
    printf "%-20s %s %s:%s" "$name" "$status_color$status${NC}" "HTTP" "$HTTP_PORT"
    if [ -n "$HTTPS_PORT" ] && [ "$HTTPS_PORT" != "N/A" ]; then
        printf " %s:%s" "HTTPS" "$HTTPS_PORT"
    fi
    printf " %s:%s" "DB" "$MYSQL_DATABASE"
    echo ""
}

# Zeigt Datenbankonfiguration einer Instanz
show_db_config() {
    local name=$1
    local format=${2:-"table"}
    local prefix=${3:-""}
    
    if [ -z "$name" ]; then
        echo -e "${RED}Fehler: Instanzname erforderlich${NC}"
        return 1
    fi
    
    if ! instance_exists "$name"; then
        echo -e "${RED}Fehler: Instanz '$name' existiert nicht${NC}"
        return 1
    fi
    
    local instance_dir="$INSTANCES_DIR/$name"
    
    if [ ! -f "$instance_dir/.env" ]; then
        echo -e "${RED}Fehler: .env-Datei für Instanz '$name' nicht gefunden${NC}"
        return 1
    fi
    
    source "$instance_dir/.env"
    
    if [ "$format" = "json" ]; then
        cat << EOF
{
  "instance": "$name",
  "database": {
    "host": "mariadb",
    "port": "3306",
    "name": "$MYSQL_DATABASE",
    "user": "$MYSQL_USER",
    "password": "$MYSQL_PASSWORD",
    "root_password": "$MYSQL_ROOT_PASSWORD"
  }
}
EOF
    elif [ "$format" = "env" ]; then
        echo "${prefix}MYSQL_DATABASE=$MYSQL_DATABASE"
        echo "${prefix}MYSQL_USER=$MYSQL_USER"
        echo "${prefix}MYSQL_PASSWORD=$MYSQL_PASSWORD"
        echo "${prefix}MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD"
    else
        echo "${prefix}${BLUE}Datenbankonfiguration:${NC}"
        echo "${prefix}  Host:          mariadb"
        echo "${prefix}  Port:          3306"
        echo "${prefix}  Datenbank:     $MYSQL_DATABASE"
        echo "${prefix}  Benutzer:      $MYSQL_USER"
        echo "${prefix}  Passwort:      $MYSQL_PASSWORD"
        echo "${prefix}  Root-Passwort: $MYSQL_ROOT_PASSWORD"
    fi
}

# Zeigt vollständige Konfiguration einer Instanz
show_full_config() {
    local name=$1
    local format=${2:-"table"}
    
    if [ -z "$name" ]; then
        echo -e "${RED}Fehler: Instanzname erforderlich${NC}"
        return 1
    fi
    
    if ! instance_exists "$name"; then
        echo -e "${RED}Fehler: Instanz '$name' existiert nicht${NC}"
        return 1
    fi
    
    local instance_dir="$INSTANCES_DIR/$name"
    
    if [ ! -f "$instance_dir/.env" ]; then
        echo -e "${RED}Fehler: .env-Datei für Instanz '$name' nicht gefunden${NC}"
        return 1
    fi
    
    source "$instance_dir/.env"
    
    # Status prüfen
    local status="Gestoppt"
    local status_color="${RED}"
    if docker ps --format "table {{.Names}}" | grep -q "redaxo-${name}-apache"; then
        status="Läuft"
        status_color="${GREEN}"
    fi
    
    if [ "$format" = "json" ]; then
        cat << EOF
{
  "instance": "$name",
  "status": "$status",
  "domain": "$DOMAIN",
  "created": "$(date -r "$instance_dir" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo 'Unknown')",
  "urls": {
    "redaxo_http": "http://localhost:$HTTP_PORT",
    "redaxo_https": "https://localhost:${HTTPS_PORT:-'N/A'}",
    "phpmyadmin": "http://localhost:$PHPMYADMIN_PORT",
    "mailhog": "http://localhost:$MAILHOG_PORT"
  },
  "database": {
    "host": "mariadb",
    "port": "3306",
    "name": "$MYSQL_DATABASE",
    "user": "$MYSQL_USER",
    "password": "$MYSQL_PASSWORD",
    "root_password": "$MYSQL_ROOT_PASSWORD"
  },
  "ports": {
    "http": "$HTTP_PORT",
    "https": "${HTTPS_PORT:-'N/A'}",
    "phpmyadmin": "$PHPMYADMIN_PORT",
    "mailhog": "$MAILHOG_PORT"
  },
  "ssl": {
    "enabled": $([ -n "$HTTPS_PORT" ] && echo "true" || echo "false"),
    "cert_path": "$SSL_DIR/$name"
  }
}
EOF
    else
        echo -e "${GREEN}══════════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}Konfiguration für Instanz: $name${NC}"
        echo -e "${GREEN}══════════════════════════════════════════════════════════${NC}"
        echo ""
        
        echo -e "${BLUE}Allgemeine Informationen:${NC}"
        echo "  Status:        $status_color$status${NC}"
        echo "  Domain:        $DOMAIN"
        echo "  Erstellt:      $(date -r "$instance_dir" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo 'Unknown')"
        echo ""
        
        echo -e "${BLUE}URLs:${NC}"
        echo "  REDAXO HTTP:   http://localhost:$HTTP_PORT"
        if [ -n "$HTTPS_PORT" ]; then
            echo "  REDAXO HTTPS:  https://localhost:$HTTPS_PORT"
        fi
        echo "  phpMyAdmin:    http://localhost:$PHPMYADMIN_PORT"
        echo "  MailHog:       http://localhost:$MAILHOG_PORT"
        echo ""
        
        show_db_config "$name" "table" "  "
        echo ""
        
        echo -e "${BLUE}Port-Mapping:${NC}"
        echo "  HTTP:          $HTTP_PORT"
        if [ -n "$HTTPS_PORT" ]; then
            echo "  HTTPS:         $HTTPS_PORT"
        fi
        echo "  phpMyAdmin:    $PHPMYADMIN_PORT"
        echo "  MailHog:       $MAILHOG_PORT"
        echo ""
        
        echo -e "${BLUE}SSL-Konfiguration:${NC}"
        if [ -n "$HTTPS_PORT" ]; then
            echo "  SSL aktiviert: ${GREEN}Ja${NC}"
            echo "  Zertifikat:    $SSL_DIR/$name"
        else
            echo "  SSL aktiviert: ${RED}Nein${NC}"
        fi
        echo ""
        
        echo -e "${BLUE}Docker-Container:${NC}"
        echo "  Apache:        redaxo-${name}-apache"
        echo "  MariaDB:       redaxo-${name}-mariadb"
        echo "  phpMyAdmin:    redaxo-${name}-phpmyadmin"
        echo "  MailHog:       redaxo-${name}-mailhog"
        echo ""
        
        echo -e "${BLUE}Dateipfade:${NC}"
        echo "  Instance:      $instance_dir"
        echo "  App:           $instance_dir/app"
        echo "  Docker:        $instance_dir/docker"
        echo "  SSL:           $SSL_DIR/$name"
    fi
}

# Zeigt Konfiguration aller Instanzen
show_all_configs() {
    local format=${1:-"table"}
    local filter=${2:-""}
    
    if [ ! -d "$INSTANCES_DIR" ] || [ -z "$(ls -A "$INSTANCES_DIR" 2>/dev/null)" ]; then
        echo -e "${YELLOW}Keine Instanzen gefunden${NC}"
        return
    fi
    
    if [ "$format" = "json" ]; then
        echo "{"
        echo '  "instances": ['
        local first=true
        for instance in "$INSTANCES_DIR"/*; do
            if [ -d "$instance" ]; then
                local name=$(basename "$instance")
                if [ -n "$filter" ] && [[ ! "$name" =~ $filter ]]; then
                    continue
                fi
                if [ "$first" = false ]; then
                    echo ","
                fi
                show_full_config "$name" "json" | sed 's/^/    /'
                first=false
            fi
        done
        echo ""
        echo "  ],"
        echo '  "total": '$(ls -1 "$INSTANCES_DIR" | wc -l | tr -d ' ')','
        echo '  "generated": "'$(date -Iseconds)'"'
        echo "}"
    else
        echo -e "${GREEN}REDAXO Multi-Instance Übersicht${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
        echo ""
        
        local total=0
        local running=0
        
        for instance in "$INSTANCES_DIR"/*; do
            if [ -d "$instance" ]; then
                local name=$(basename "$instance")
                if [ -n "$filter" ] && [[ ! "$name" =~ $filter ]]; then
                    continue
                fi
                
                ((total++))
                
                if docker ps --format "table {{.Names}}" | grep -q "redaxo-${name}-apache"; then
                    ((running++))
                fi
                
                if [ "$format" = "summary" ]; then
                    show_instance_summary "$name"
                else
                    show_full_config "$name" "table"
                    echo ""
                fi
            fi
        done
        
        echo -e "${BLUE}Zusammenfassung:${NC}"
        echo "  Gesamt:        $total Instanzen"
        echo "  Aktiv:         ${GREEN}$running${NC} Instanzen"
        echo "  Gestoppt:      ${RED}$((total - running))${NC} Instanzen"
    fi
}

# Zeigt kompakte Zusammenfassung einer Instanz
show_instance_summary() {
    local name=$1
    local instance_dir="$INSTANCES_DIR/$name"
    
    if [ ! -f "$instance_dir/.env" ]; then
        echo -e "${RED}  $name: Keine Konfiguration gefunden${NC}"
        return
    fi
    
    source "$instance_dir/.env"
    
    local status="Gestoppt"
    local status_color="${RED}"
    if docker ps --format "table {{.Names}}" | grep -q "redaxo-${name}-apache"; then
        status="Läuft"
        status_color="${GREEN}"
    fi
    
    printf "%-20s %s %s:%s" "$name" "$status_color$status${NC}" "HTTP" "$HTTP_PORT"
    if [ -n "$HTTPS_PORT" ]; then
        printf " %s:%s" "HTTPS" "$HTTPS_PORT"
    fi
    printf " %s:%s" "DB" "$MYSQL_DATABASE"
    echo ""
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
    config)
        if [ -z "$2" ]; then
            echo -e "${RED}Fehler: Instanzname erforderlich${NC}"
            echo "Verwendung: ./instance-manager.sh config <instanzname>"
            exit 1
        fi
        show_full_config "$2" "${3:-table}"
        ;;
    config-all)
        show_all_configs "${2:-table}" "$3"
        ;;
    db-config)
        if [ -z "$2" ]; then
            echo -e "${RED}Fehler: Instanzname erforderlich${NC}"
            echo "Verwendung: ./instance-manager.sh db-config <instanzname>"
            exit 1
        fi
        show_db_config "$2" "${3:-setup}"
        ;;
    urls)
        if [ -z "$2" ]; then
            echo -e "${RED}Fehler: Instanzname erforderlich${NC}"
            echo "Verwendung: ./instance-manager.sh urls <instanzname>"
            exit 1
        fi
        show_urls "$2"
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
