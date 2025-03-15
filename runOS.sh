#!/bin/bash

source log.sh

echo "envySystem"
echo "Copyright (c) 2025 Buck. All Rights Reserved."
echo

if [[ $1 == '-v' ]]; then
  set -x 
fi 

info "[1] Checking for QEMU first..."

which qemu-system-x86_64 1>/dev/null 2>/dev/null
if [[ $? != 0 ]]; then
  error "We couldn't find QEMU. Please install QEMU in your system first." yes
fi 

success "Found qemu in `which qemu-system-x86_64`."

info "[2] Finding envySystem image"
ENVYDIR=$(find | grep envy)
if [[ $? != 0 ]]; then
  error "Error in trying to find envySystem image." yes
fi 

# Check if more than one file was found.
if [[ $(echo $ENVYDIR | wc -l) > 1 ]]; then
  warn "Found more than one images. Trying to choose the first one."
  ENVYDIR=$(echo $ENVYDIR | head -n 1)
fi

# Error if $ENVYDIR is empty
if [[ -z $ENVYDIR ]]; then
  error "This script couldn't determine where the image is."
  error "Maybe running \`make\` will fix this." yes
fi 

success "Found envySystem image at $ENVYDIR."

info "[3] Starting Virtual Machine in 3 seconds. Send CTRL+C if you've changed your mind"
sleep 3
qemu-system-x86_64 -m 128 $ENVYDIR

if [[ $? != 0 ]]; then
  error "QEMU exitted abnormally." yes
fi
