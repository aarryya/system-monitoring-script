#!/bin/bash

echo "----------------------------------------"
echo "System Monitoring Report - $(date)"
echo "----------------------------------------"

# ---- CPU Usage ----
cpu=$(powershell -Command "(Get-CimInstance Win32_Processor | Measure-Object LoadPercentage -Average).Average" | tr -d '\r')
echo "CPU Usage: ${cpu:-N/A}%"

# ---- Memory Usage ----
mem_info=$(powershell -Command "(Get-CimInstance Win32_OperatingSystem | ForEach-Object {[math]::Round($_.TotalVisibleMemorySize/1MB) + ' ' + [math]::Round($_.FreePhysicalMemory/1MB)})" | tr -d '\r')

total_mem=$(echo "$mem_info" | awk '{print $1}')
free_mem=$(echo "$mem_info" | awk '{print $2}')

if [[ -n "$total_mem" && -n "$free_mem" ]]; then
    used_mem=$((total_mem - free_mem))
    mem_percent=$(( used_mem * 100 / total_mem ))
    echo "Memory Usage: ${mem_percent}% (${used_mem} MB used of ${total_mem} MB)"
else
    echo "Memory info not available"
fi

# ---- Disk Usage (C:) ----
disk_info=$(powershell -Command "(Get-CimInstance Win32_LogicalDisk -Filter \"DeviceID='C:'\" | ForEach-Object {[math]::Round($_.Size/1GB) + ' ' + [math]::Round($_.FreeSpace/1GB)})" | tr -d '\r')

size_gb=$(echo "$disk_info" | awk '{print $1}')
free_gb=$(echo "$disk_info" | awk '{print $2}')

if [[ -n "$size_gb" && -n "$free_gb" ]]; then
    used_gb=$((size_gb - free_gb))
    disk_percent=$(( used_gb * 100 / size_gb ))
    echo "Disk Usage (C:): ${disk_percent}% (${used_gb} GB used of ${size_gb} GB)"
else
    echo "Disk info not available"
fi

# ---- Top 5 processes by memory ----
echo ""
echo "Top 5 processes by memory:"
powershell -Command "Get-Process | Sort-Object -Descending WS | Select-Object -First 5 Name,Id,WS | Format-Table -AutoSize" | tr -d '\r'

echo ""
echo "----------------------------------------"
