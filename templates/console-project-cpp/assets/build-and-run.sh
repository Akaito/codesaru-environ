#!/bin/bash

# run from base repo dir

make
if [ $? -eq 0 ]; then
	./PROJNAME
fi

