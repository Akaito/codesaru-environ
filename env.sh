#!/bin/bash

# source this file from the CSaruEnv directory to set up your environment

export CSaruDir=`pwd`
if [[ $PATH != *"$CSaruDir"* ]]; then
	export PATH="${PATH}:${CSaruDir}"
fi

