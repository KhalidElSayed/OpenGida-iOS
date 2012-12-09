#!/bin/sh

if [ ! -d src ]
then
	cd ..
fi

if [ -d src ]
then
	~/bin/objctags -R \
		external/ELHASO-iOS-snippets/src \
		external/ABContactHelper \
		src
fi
