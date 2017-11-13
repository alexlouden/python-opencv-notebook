#!/bin/bash
cd /app/data
jupyter notebook --no-browser --port 8888 --ip=* --allow-root
