#!/bin/bash

display_usage() { 
	echo -e "This script initializes the working directory of a CGA project."
	echo -e "\nUsage:"
	echo -e "\t`basename $0` <working_directory>"
}

show_error() {
	tput setaf 1
	echo -e "${1}"
	tput sgr0
}

if [[ $1 == "--help" ]]; then
	display_usage
	exit 0
fi

if [ $# -ne 1 ] && [ $# -ne 2 ]
then 
	show_error "This script requires one argument.\n"
	display_usage
	exit 1
fi 

SOURCE_WD=${2:-/opt/working_dir}

cp -R ${SOURCE_WD}/* $1

touch $1/input.fasta
touch $1/ref.fasta
