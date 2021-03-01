shopt -s globstar

get_credit() {
	{
		while IFS= read -r line; do
			name=${line%%=*}
			value=$(echo ${line#*=} | tr -d '"')

			case $name in
				"user.dublincore.title")
					title=$value
					;;
				"user.dublincore.creator")
					creator=$value
					;;
				"user.dublincore.source")
					src=$value
					;;
				"user.dublincore.rights")
					rights=$value
					;;
				"user.modified")
					modified=$value
					;;
			esac
		done
	} < <(getfattr --match=user -d "$1" | head -n -1 | tail -n +2)

	if [[ -z "$title" || -z "$creator" || -z "$src" || -z "$rights" ]]; then
		return
	fi

	credit="\"$title\" by $creator, from $src, released under $rights"
	if [ "$modified" == "true" ]; then
		credit="$credit, modified from the original"
	fi
	
	echo $credit
}


# Generate licenses.txt files throughout the various subdirectories.
find ./game/* ./thirdparty/assets/* -name 'licenses.txt' -delete

for file in ./game/**/* ./thirdparty/assets/*; do
	if [[ ! -f "$file" ]]; then
		continue
	fi

	credit=$(get_credit "$file")

	if [[ -z $credit ]]; then
		continue
	fi

	echo $(basename $file), $credit >> $(echo "$(dirname "$file")/licenses.txt")
done
