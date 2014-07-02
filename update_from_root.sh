ROOT='..'
FILES=`ls -a`
IGNORES=". .. .git README.md LICENSE"
for FILE in $FILES; do	
	IGNORE_FLAG=false
	for IGNORE in $IGNORES; do
		if [ $FILE == $IGNORE ]; then
			IGNORE_FLAG=true
		fi
	done

	ROOT_FILE="$ROOT/$FILE"

	if [ $IGNORE_FLAG == false ] &&  [ -e $ROOT/$FILE ]; then
		if [ $ROOT_FILE -nt $FILE  ]; then
		  echo "Updating $ROOT_FILE => $FILE..."
		  cp -R $ROOT_FILE $FILE
		else
		  echo "Ignoring $FILE because it was not modified"
		fi
	fi
done
