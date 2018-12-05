#!/bin/sh -
# Copyright 2014 The Gogs Authors. All rights reserved.
# Use of this source code is governed by a MIT-style
# license that can be found in the LICENSE file.
#
# start gogs web
#
IFS='
	'
PATH=/bin:/usr/bin:/usr/local/bin
USER=$(whoami)
HOME=$(grep "^$USER:" /etc/passwd | cut -d: -f6)
export USER HOME PATH

cd "$(pwd)" && exec ./gogs web
