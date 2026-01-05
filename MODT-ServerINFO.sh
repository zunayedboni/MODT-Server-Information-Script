#!/bin/bash
# ──────────────────────────────────────────────────────────────────────────────
# Production Server MOTD 
# Author : Zunayed Islam Rabbi 
# SYSTEM ENGINEER
# ──────────────────────────────────────────────────────────────────────────────
# Requirements: figlet lm-sensors bc procps
# Install: sudo apt install -y figlet lm-sensors bc procps
# Optional: sudo sensors-detect --auto (non-VM only)

# ── Color Palette ─────────────────────────────────────────────────────────────
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
RESET='\033[0m'

# ── Header & System Info ──────────────────────────────────────────────────────
clear
printf "%b\n" "${BLUE}┌───────────────────────────────────────────────────────────────────────────────┐${RESET}"

# Hostname Display (Figlet or fallback)
if command -v figlet &>/dev/null; then
    figlet -f slant "PROD MODE" | while IFS= read -r line; do
        printf "%b\n" "${BLUE}│${CYAN} ${line}${RESET}"
    done
else
    printf "%b\n" "${BLUE}│ ${WHITE}Hostname   : ${GREEN}$(hostname)${RESET}"
fi

printf "%b\n" "${BLUE}├───────────────────────────────────────────────────────────────────────────────┤${RESET}"

# Last Login
printf "%b\n" "${BLUE}│ ${WHITE}Last Login : ${YELLOW}$(last -n 1 -R -F | head -n 1)${RESET}"

# Uptime
printf "%b\n" "${BLUE}│ ${WHITE}Uptime     : ${GREEN}$(uptime -p)${RESET}"

# Load Average (alert on high load)
LOAD1=$(cut -d ' ' -f1 /proc/loadavg)
LOAD_COLOR="${YELLOW}"
[ "$(echo "$LOAD1 > 2.0" | bc -l)" -eq 1 ] && LOAD_COLOR="${RED}"
printf "%b\n" "${BLUE}│ ${WHITE}Load Avg   : ${LOAD_COLOR}$(cut -d ' ' -f1-3 /proc/loadavg)${RESET}"

# CPU Cores
printf "%b\n" "${BLUE}│ ${WHITE}CPU Cores  : ${GREEN}$(nproc)${RESET}"

# CPU Temperature
TEMP=$(sensors 2>/dev/null | awk '/^Package id 0:|^Tdie:|^Tctl:/ {print $2; exit}')
if [ -z "$TEMP" ] && [ -f /sys/class/thermal/thermal_zone0/temp ]; then
    TEMP_RAW=$(cat /sys/class/thermal/thermal_zone0/temp)
    TEMP=$(awk "BEGIN {printf \"%.1f°C\", $TEMP_RAW/1000}")
fi
printf "%b\n" "${BLUE}│ ${WHITE}CPU Temp   : ${GREEN}${TEMP:-Not available}${RESET}"

# Memory Usage
printf "%b\n" "${BLUE}│ ${WHITE}Memory     : ${GREEN}$(free -h | awk '/Mem:/ {print $3 "/" $2}')${RESET}"

# Disk Usage
printf "%b\n" "${BLUE}│ ${WHITE}Disk (/ )  : ${GREEN}$(df -h / | awk 'NR==2 {print $3 "/" $2 " used"}')${RESET}"

# Shell
printf "%b\n" "${BLUE}│ ${WHITE}Shell      : ${CYAN}$SHELL${RESET}"

# IP Address
printf "%b\n" "${BLUE}│ ${WHITE}IP Address : ${YELLOW}$(hostname -I | awk '{print $1}')${RESET}"

# MariaDB/MySQL Version
if command -v mariadb &>/dev/null; then
    DB_BIN="mariadb"
elif command -v mysql &>/dev/null; then
    DB_BIN="mysql"
else
    DB_BIN=""
fi

if [ -n "$DB_BIN" ]; then
    DB_VER=$($DB_BIN --version 2>/dev/null | grep -oE '([0-9]+\.)+[0-9]+(-MariaDB)?' | head -n1)
    printf "%b\n" "${BLUE}│ ${WHITE}MariaDB    : ${GREEN}${DB_BIN} v${DB_VER}${RESET}"
else
    printf "%b\n" "${BLUE}│ ${WHITE}MariaDB    : ${RED}Not installed${RESET}"
fi

# Zombie Process Detection
ZOMBIES=$(ps -eo stat,pid | awk '$1 ~ /^Z/ {print $2}')
if [ -n "$ZOMBIES" ]; then
    count=$(echo "$ZOMBIES" | wc -l)
    printf "%b\n" "${BLUE}│ ${WHITE}Zombies    : ${RED}$count process(es) detected${RESET}"
    printf "%b\n" "${BLUE}│ ${WHITE}Zombie PIDs: ${YELLOW}$(echo $ZOMBIES | tr '\n' ' ')${RESET}"
else
    printf "%b\n" "${BLUE}│ ${WHITE}Zombies    : ${GREEN}None detected${RESET}"
fi

# Terminal Session Type
if [ -n "$TMUX" ]; then
    SESSION_TYPE="tmux"
elif [ -n "$STY" ]; then
    SESSION_TYPE="screen"
elif [ -n "$SSH_CONNECTION" ]; then
    SESSION_TYPE="SSH"
elif [ -n "$XDG_SESSION_TYPE" ]; then
    SESSION_TYPE="$XDG_SESSION_TYPE"
else
    SESSION_TYPE=$(tty 2>/dev/null || echo "Unknown")
fi
printf "%b\n" "${BLUE}│ ${WHITE}Terminal   : ${CYAN}${SESSION_TYPE}${RESET}"

# Date/Time
printf "%b\n" "${BLUE}│ ${WHITE}Date/Time  : ${GREEN}$(date +"%a, %d %b %Y %H:%M:%S %Z")${RESET}"

# ── Service Status Bar ────────────────────────────────────────────────────────
printf "%b\n" "${BLUE}├───────────────────────────────────────────────────────────────────────────────┤${RESET}"

check_service() {
    local service=$1
    local name=$2
    
    if ! command -v systemctl &>/dev/null; then return; fi
    
    systemctl status "$service" &>/dev/null
    case $? in
        0) printf "%b" "${BLUE}│${RESET}\033[1;32m[✔ $name]\033[0m " ;;
        3|4) ;; # Inactive or non-existent - skip
        *) printf "%b" "${BLUE}│${RESET}\033[1;31m[✘ $name]\033[0m " ;;
    esac
}

# PHP (detect all installed versions)
if [ -d /etc/php ]; then
    for phpver in $(ls /etc/php 2>/dev/null | sort -r); do
        check_service "php${phpver}-fpm.service" "PHP${phpver}-FPM"
    done
fi

# Core Infrastructure
check_service "nginx.service" "NGINX"
check_service "apache2.service" "Apache2"
check_service "mariadb.service" "MariaDB"
check_service "mysql.service" "MySQL"
check_service "postgresql.service" "PostgreSQL"
check_service "redis-server.service" "Redis"
check_service "mongodb.service" "MongoDB"
check_service "docker.service" "Docker"
check_service "containerd.service" "Containerd"
check_service "supervisor.service" "Supervisor"

# Messaging & Queues
check_service "rabbitmq-server.service" "RabbitMQ"
check_service "kafka.service" "Kafka"
check_service "mosquitto.service" "MQTT"

# Kubernetes
check_service "kubelet.service" "Kubelet"
check_service "kube-apiserver.service" "K8s-API"
check_service "kube-controller-manager.service" "K8s-CM"
check_service "kube-scheduler.service" "K8s-Scheduler"

# Monitoring & Logging
check_service "elasticsearch.service" "Elasticsearch"
check_service "kibana.service" "Kibana"
check_service "logstash.service" "Logstash"

# Time Sync
check_service "chronyd.service" "Chrony"
check_service "ntpd.service" "NTPD"

# Document Servers
check_service "onlyoffice-documentserver.service" "OnlyOffice"
check_service "collabora.service" "Collabora"

printf "\n%b\n" "${BLUE}└───────────────────────────────────────────────────────────────────────────────┘${RESET}"
