#!/bin/bash

# source this file from the CSaruEnv directory to set up your environment.
# That is: ". env.sh" or "source env.sh".
# If you execute it ("./env.sh"), it won't do you any good.

export CSaruDir=`pwd`

if [[ $PATH != *"${CSaruDir}/bin"* ]]; then
	export PATH="${PATH}:${CSaruDir}/bin"
fi

. use-clang.sh

