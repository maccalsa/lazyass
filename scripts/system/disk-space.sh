#!/bin/bash

# Set the threshold percentage (e.g., 20%)
THRESHOLD=20

# Check disk usage
USAGE=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')

if [ "$USAGE" -gt "$THRESHOLD" ]; then
  echo "Disk space is below threshold: ${USAGE}% used."
else
  echo "Disk space is sufficient: ${USAGE}% used."
fi
