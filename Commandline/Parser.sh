#! /usr/local/bin/bash

data=""

showHelp(){
	echo """

Usage: parser [verb] [input file path] ([output file path])

verb:
   help: show this help
   b: base64 encoding
   c: compress
   bc: both compressing and base64 encoding
   x: neither compressing nor base64 encoding



"""
}

omitComment(){
	local r="";local l
	local s="$data"
	local st="$1"
	local en="$2"
	while : ; do
		if [[ "$s" =~ $en ]] ; then
			l="${s%%$en*}"
			s="${s#*$en}"
			r="$r""${l%%$st*}"
		else
			r="$r""$s"
			break
		fi
	done
	data="$r"
}

compress(){
	# In the sed argument, \t doesn't represent a tab character. In order to match the tab character, use $'\t' instead. This is one of Shell features.
	omitComment "/\\*" "\\*/"
	omitComment "<!--" "-->"
	data=`echo "$data" |
	sed -E $'s/[ \t]+\/\/.+$//g' |
	sed -E "s/^\/\/.+$//g" |
	sed -E "s/<\/?editing-folder>//g" |
	sed -E "s/ +xml:space=[\"']?preserve[\"']? +/ /g" |
	sed -E "s/ +xml:space=[\"']?preserve[\"']? *//g" |
	sed -E "s/  +/ /g" |
	sed -E "s/^ //g" |
	sed -E "s/ $//g" | tr "\n" "\r"`
	local arr=(";" ":" "," "{" "}")
	for t in "${arr[@]}" ; do
		data=`echo "$data" | sed -E s/"$t"$'[ \v\f\r\t]\*[\v\f\r][ \v\f\r\t]\*'/"$t"/g`
	done
	data=`echo "$data" |
	sed -E s/[$'\v\f\r\t']+//g |
	sed -E "s/> +/>/g"`
}

if [ $# -gt 0 -a "$1" = "help" ]; then
	showHelp
	exit 0
elif [ $# -gt 1 ]; then
	if [ -r "$2" ] ; then
		m=`file --mime-type "$2" | grep -oE "([^/ ]+/[^/]+)$"`
		if [[ $1 =~ b ]]; then
			b=1
		else
			b=0
		fi
		if [[ $1 =~ c ]]; then
			c=1
		else
			c=0
		fi
		if [ $b -eq 1 -a $c -eq 0 ] ; then
			r="data:""$m"";base64,""`base64 "$2"`"
		else
			r="`cat "$2"`"
			if [ $c -eq 1 ]; then
				data="$r"
				compress
				r="$data"
			fi
			if [ $b -eq 1 ]; then
				r="data:""$m"";base64,""`printf "%s" "$r" | base64 | tr -d "\n" | tr -d "\r"`"
			fi
		fi
		if [ -n "$3" ]; then
			if [ -w "$3" -o ! -e "$3" ]; then
				printf "%s" "$r" > "$3"
				exit 0
			else
				echo "Cannot write into this file: ""$3" >&2
				exit 1
			fi
		else
			printf "%s" "$r"
			exit 0
		fi
	else
		echo "Cannot read this file or does not exist: ""$2">&2
		exit 1
	fi
else
	echo "Not enough arguments!" >&2
	echo
	echo
	showHelp
	exit 1
fi