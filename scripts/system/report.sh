#!/bin/bash

echo "Generating system report..."

# Hostname
echo "Hostname: $(hostname)"

# System uptime
echo "Uptime: $(uptime -p)"

# Currently logged-in users
echo "Logged-in users:"
who

# Memory usage
echo "Memory usage:"
free -h

# Disk usage
echo "Disk usage:"
df -h

echo "System report generated successfully."
