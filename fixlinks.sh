#!/bin/bash

# Update symbolic links in the pkg directory to all be pointing at the latest versions.

# Delete all symlinks in pkg that point to within pkg.
rm_intra_pkg_links () {
	for l in `find . -maxdepth 1 -mindepth 1 -type l`; do
		link_name=${l:2}
		link_name_len=`expr length "$link_name"`
		target=`readlink "$link_name"`
		#echo "$link_name -- ${target} -- ${target:0:$link_name_len}"
		if [[ "$link_name" == "${target:0:$link_name_len}" ]]; then
			rm "$link_name"
		fi
	done
}

make_upper_revision_link () {
	regex="(.*)\.[0-9]+$"
	[[ "$1" =~ $regex ]]
	#echo "${BASH_REMATCH[0]} <-- ${BASH_REMATCH[1]}"
	# If there's a match, we want to create a coarser-versioned link.
	if ! [ -z "${BASH_REMATCH[1]}" ]; then
		# Unless there's already something with our desired name.
		if [ ! -e "${BASH_REMATCH[1]}" ]; then
			ln -s "${BASH_REMATCH[0]}" "${BASH_REMATCH[1]}"
		elif [ ! -h "${BASH_REMATCH[1]}" ]; then
			echo "\"${BASH_REMATCH[1]}\" desired as symlink, but exists and is not a symlink."
		fi
		# Continue up to a coarser version number.
		make_upper_revision_link "${BASH_REMATCH[1]}"
	fi
}

#==========================================================

pushd ${CSaruDir}/pkg >/dev/null

rm_intra_pkg_links

for d in `find . -maxdepth 1 -mindepth 1 -type d | sort --numeric-sort --reverse`; do
	make_upper_revision_link $d
done

popd >/dev/null
exit 0

