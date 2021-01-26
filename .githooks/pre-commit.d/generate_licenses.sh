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
cd ../../

modified=$(git diff --dirstat=files,0 HEAD~1 | sed 's/^[ 0-9.]\+% //g')*

find $modified -name 'licenses.txt' -delete

for file in $modified; do
	if [[ ! -f "$file" ]]; then
		continue
	fi

	credit=$(get_credit "$file")

	if [[ -z $credit ]]; then
		continue
	fi

	echo $(basename $file), $credit >> $(echo "$(dirname "$file")/licenses.txt")
	git-add $(echo "$(dirname "$file")/licenses.txt")
done
