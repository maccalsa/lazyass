#!/bin/bash

# Google
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null


# OpenDNS
echo "nameserver 208.67.222.222" | sudo tee /etc/resolvconf/resolv.conf.d/base > /dev/null
