#!/bin/bash

CGA_VERSION=0.0.1

PROJECT_DIR=$1
PARAMS_FILE="cga.params"
ADDITIONAL_COMPI_PARAMS=$2

show_error() {
	tput setaf 1
	echo -e "${1}"
	tput sgr0
}

if [[ ! -f "${PROJECT_DIR}/${PARAMS_FILE}" ]]; then
	show_error "The parameters file (${PROJECT_DIR}/${PARAMS_FILE}) does not exist."
	exit 1
else
	check=$(cat ${PROJECT_DIR}/${PARAMS_FILE} | grep "host_working_dir\=/path/to/host/working/dir" | wc -l)
	if [ ${check} -eq 1 ]; then
		show_error "It seems that host_working_dir is not set in the params file (${PROJECT_DIR}/${PARAMS_FILE})"
		exit 1
	fi
fi

timestamp=$(date +"%Y-%m-%d_%H:%M:%S")

mkdir -p ${PROJECT_DIR}/logs/${timestamp}

docker run --rm \
	-v ${PROJECT_DIR}:/working_dir  \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v ~/.compi:/root/.compi \
	pegi3s/cga:${CGA_VERSION} \
		--params /working_dir/${PARAMS_FILE} \
		-l /working_dir/logs \
		-o ${ADDITIONAL_COMPI_PARAMS} \
	2>&1 | tee ${PROJECT_DIR}/logs/${timestamp}/compi.log
