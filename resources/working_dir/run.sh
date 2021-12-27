#!/bin/bash

CGA_VERSION=0.0.1

PROJECT_DIR=$1
PARAMS_FILE="cga.params"
ADDITIONAL_COMPI_PARAMS=$2

if [[ ! -f "${PROJECT_DIR}/${PARAMS_FILE}" ]]; then
	echo "The parameters file (${PROJECT_DIR}/${PARAMS_FILE}) does not exist.";
	exit;
else
	check=$(cat ${PROJECT_DIR}/${PARAMS_FILE} | grep "host_working_dir\=/path/to/host/working/dir" | wc -l)
	if [ check -eq 1 ]; then
		echo "It seems that host_working_dir is not set in the params file (${PROJECT_DIR}/${PARAMS_FILE})";
		exit;	
	fi
fi

docker run --rm \
	-v ${PROJECT_DIR}:/working_dir  \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v ~/.compi:/root/.compi \
	pegi3s/cga:${CGA_VERSION} \
            --params /working_dir/${PARAMS_FILE} \
            -l /working_dir/logs \
            -o ${ADDITIONAL_COMPI_PARAMS}
