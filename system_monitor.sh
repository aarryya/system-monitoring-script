#!/bin/bash

DISK_THRESHOLD=80
MEM_THRESHOLD=75
LOG_FILE="system_monitor.log"

echo "----------------------------------------"
echo "System Monitoring Report - $(date)"
echo "----------------------------------------"

# Disk Usage
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

if [ "$DISK_USAGE" -ge "$DISK_THRESHOLD" ]; then
    ALERT="ALERT: Disk usage is high! Usage: ${DISK_USAGE}%"
    echo "$ALERT"
    echo "$(date) - $ALERT" >> $LOG_FILE
else
    echo "Disk usage is normal: ${DISK_USAGE}%"
fi

# Memory Usage
TOTAL_MEM=$(free | awk '/Mem:/ {print $2}')
USED_MEM=$(free | awk '/Mem:/ {print $3}')
MEM_USAGE=$((USED_MEM * 100 / TOTAL_MEM))

if [ "$MEM_USAGE" -ge "$MEM_THRESHOLD" ]; then
    ALERT="ALERT: Memory usage is high! Usage: ${MEM_USAGE}%"
    echo "$ALERT"
    echo "$(date) - $ALERT" >> $LOG_FILE
else
    echo "Memory usage is normal: ${MEM_USAGE}%"
fi

echo ""
echo "Top 5 CPU-consuming processes:"
ps -eo pid,cmd,%cpu,%mem --sort=-%cpu | head -n 6

echo ""
echo "Top 5 Memory-consuming processes:"
ps -eo pid,cmd,%cpu,%mem --sort=-%mem | head -n 6
