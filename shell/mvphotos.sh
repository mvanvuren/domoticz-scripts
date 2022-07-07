#!/bin/bash
cam=$1
REGEX="^$cam([0-9]{4})([0-9]{2})([0-9]{2}).+$"
BASEDIR="$PHOTO_PATH/$cam"
FILES="$BASEDIR/*.jpg"

log2domo() {
	script="Script: $(basename "$0") $cam"
	message=$(echo -n "$script $1" | perl -pe's/([^-_.~A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg')
	curl -s -i -H "Accept: application/json" "$DOMO_URL/json.htm?type=command&param=addlogmessage&message=$message" >/dev/null 2>&1
}

log2domo "Start moving $cam photos..."
for srcfullfilename in $FILES; do
	filename=$(basename "$srcfullfilename")
	[[ $filename =~ $REGEX ]] && year="${BASH_REMATCH[1]}" && month="${BASH_REMATCH[2]}" && day="${BASH_REMATCH[3]}"
	dstdir="$BASEDIR/$year/$month/$day"
	dstfullfilename="$dstdir/$filename"
	mkdir -p "$dstdir"
	mv "$srcfullfilename" "$dstfullfilename"
	echo "$filename -> $dstfullfilename"
done
log2domo "Finished"
