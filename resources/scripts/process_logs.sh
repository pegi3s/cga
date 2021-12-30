#!/bin/bash

WORKING_DIR=$1
FILES_LIST="${WORKING_DIR}/cga_working_dir/files"
LOGS_DIR=$2


display_usage() { 
  echo -e "This script processes the Compi logs directory to create a report of tasks with errors or warnings."
  echo -e "\nUsage:"
  echo -e "\t`basename $0` <working_directory> <compi_logs_directory>"
}

if [[ $1 == "--help" ]]; then
  display_usage
  exit 0
fi

if [ $# -ne 2 ]
then 
	echo -e "This script requires two arguments.\n"
	display_usage
	exit 1
fi 

if [[ ! -d ${LOGS_DIR} ]]; then
	echo -e "The logs directory (${LOGS_DIR}) does not exist."
	exit 1
else
	if [[ ! -f ${FILES_LIST} ]]; then
		echo -e "The files list (${FILES_LIST}) does not exist."
		exit 1
	fi
fi

function list () {
	for error in $(grep -li "$1" *); do
		count=$(echo "${error}" | grep '_' | wc -l)

		if [ ${count} -eq 0 ]; then
			task=$(echo ${error} | cut -d'.' -f1)
			filename="-"
		else
			n=$(echo ${error} | cut -d'_' -f2 | cut -d'.' -f1)
			n=$((n + 1))
			task=$(echo ${error} | cut -d'_' -f1)
			filename=$(awk -v LINE=${n} 'NR==LINE{print $0}' ${FILES_LIST})
		fi

		echo -e "${1}\t${error}\t${task}\t${filename}"
	done
}

cd ${LOGS_DIR}

echo -e "type\tlog_file\ttask\tinput_file"
list "error"
list "warning"
