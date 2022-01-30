#!/bin/bash

PROJECT_DIR=$1
NEW_VERSION=$2

sed -i "s#<version>.*</version>#<version>${NEW_VERSION}</version>#" ${PROJECT_DIR}/pipeline.xml
sed -i "s#^CGA_VERSION=.*#CGA_VERSION=\${CGA_VERSION-${NEW_VERSION}}#" ${PROJECT_DIR}/resources/working_dir/run.sh
