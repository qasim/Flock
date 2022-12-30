#!/bin/bash
set -e
cd "$(dirname "${BASH_SOURCE[0]}")"

python -m uvicorn main:app --host 0.0.0.0 --port 80 --workers `sysctl -n hw.ncpu` --loop asyncio
