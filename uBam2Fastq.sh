#!/bin/bash

if [ -x "$( command -v perl )" ]; then
	# Perl is faster than sed and awk

else
	# Use sed if perl is not in $PATH

fi

