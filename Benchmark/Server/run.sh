#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")"

# Generate test files
POWERS=$(seq 0 13)
for power in $POWERS; do
    sizeMB=$((2**$power))
    sizeB=$(($sizeMB*1048576))
    if [[ ! -f $sizeB.bin ]]; then
        echo "making ${sizeB}.bin"
        mkfile ${sizeMB}m ${sizeB}.bin
    fi
done

# Start file server
caddy run
