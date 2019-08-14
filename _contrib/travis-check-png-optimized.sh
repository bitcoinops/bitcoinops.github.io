#!/bin/sh

## Finds newly added or modified PNG files in the branch and checks if each file is optimized.
## If not optimized, it fails with an error code of 1.

## This check might be run on a system where optipng is not installed (e.g. Netlify). If so, the check should not fail.
if ! which optipng > /dev/null; then
	echo "Skipping check since optipng is not istalled."
	exit 0
fi

## Travis is not aware of the origin/master branch. Needs to be added and fetched first.
## As per https://github.com/travis-ci/travis-ci/issues/6069#issuecomment-266546552
if [ "$TRAVIS" = "true" ]; then
	git remote set-branches --add origin master
	git fetch
fi

EXITCODE=0
CHANGEDFILES=$(git diff --name-only --diff-filter=AM origin/master HEAD)

for FILE in $CHANGEDFILES; do
	if echo "$FILE" | grep -q ".png$"; then 
		echo checking "$FILE"
		OPTIPNGOUTPUT=$(optipng -simulate "$FILE" 2>&1)
		if ! echo "$OPTIPNGOUTPUT" | grep -q "is already optimized"; then
			echo "The file $FILE is not optimized. To optimize use 'optipng -o7 $FILE'."
			EXITCODE=1
		fi
	fi
done

exit $EXITCODE
