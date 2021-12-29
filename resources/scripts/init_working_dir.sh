#!/bin/bash

SOURCE_WD=${2:-/opt/working_dir}

cp -R ${SOURCE_WD}/* $1

touch $1/input.fasta
touch $1/ref.fasta
