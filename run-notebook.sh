#!/bin/bash

set -e

# TODO SSL
# TODO hashed password

jupyter notebook --no-browser --port 8888 --ip=*
