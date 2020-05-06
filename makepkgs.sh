#!/bin/bash

#
#    This file is part of the Pi Entertainment System (PES).
#
#    PES provides an interactive GUI for games console emulators
#    and is designed to work on the Raspberry Pi.
#
#    Copyright (C) 2020 Neil Munday (neil@mundayweb.com)
#
#    PES is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    PES is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with PES.  If not, see <http://www.gnu.org/licenses/>.
#

function die {
	echo $1
	exit 1
}

if [ -z $1 ]; then
	die "GPG key for package signing not provided"
fi

KEY=$1

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

repoDir="$DIR/repo"

cd $DIR/packages

# add known GPG public keys
gpg --recv-key 06CA9F5D1DCF2659 # Marcel Holtmann <marcel@holtmann.org>

for d in *; do
	pwd
	cd $d
	if [ ! -f PKGBUILD ]; then
		die "No PKGBUILD file found for $d"
	fi
	makepkg --sign --key $KEY
	mv *.xz *.xz.sig $DIR/repo/
	cd ..
done

cd $repoDir

repo-add --sign --key $KEY pes.db.tar.gz *.xz
