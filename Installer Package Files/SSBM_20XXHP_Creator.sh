
#!/bin/sh
# This script created by shuall, phonos, DRGN, and Mage
# Script version 2.0

version=5.0.1
lastversion=5.0.0
sourceMd5="0e63d4223b01d9aba596259dc155a174"
modmd5="c8c019de7bcf08e096804802a9fd0693"
lastversionmd5="b67c7f8c107107b9db7e6d00a2b40817"

infile="$1"
outfile="SSBM, 20XXHP ${version}.iso"
delta="SSBM, 20XXHP ${version} patch (NTSC 1.02 base).xdelta"
lastdelta="SSBM, 20XXHP ${version} patch (20XXHP ${lastversion} base).xdelta"


# make sure you have these binaries installed somewhere
xdelta=xdelta3
md5sum=md5sum


checkhash () {
	printf "    This will take a few moments.... "
	filehash=$(${md5sum} -b "$1" |cut -d' ' -f1)
	if [ "$filehash" != "$2" ]; then
		return 1
	fi
	return 0
}

build () {
	# Confirm that xdelta is installed
	if [ ! -n "`command -v $xdelta 2>/dev/null`" ] ; then
		echo >&2 "xdelta does not appear to be installed. Attempting to install now. Please enter your user password when prompted to install. "
		sudo apt-get install $xdelta
		if [ ! -n "`command -v $xdelta 2>/dev/null`" ] ; then
			echo >&2 "Unable to install Xdelta. Please attempt to install xdelta manually and try again. Make sure you have an internet connection first and try again or try the command: 'sudo apt-get install $xdelta'"
			exit
		fi
	fi

	# Check if there's an existing file, and whether the user wants to overwrite it
	if [ -f "$outfile" ]; then
		printf "File $outfile already exists. Overwrite? (y/n) "
		read overwrite
		if [ "$overwrite" != "y" ]; then
			exit
		fi
	fi

	# Build the new ISO
	printf "Constructing 20XXHP ${version}.\n"
	printf "    Please stand by.... "

	$xdelta -f -d -s "$infile" "$delta" "$outfile" 2>/dev/null
}

if [ "$infile" = "" ]; then
	printf "usage: 20xx-${version}-convert.sh FILE\n"
	exit
fi
if test -f "$infile"; then
	printf ""
else
	printf "usage: 20xx-${version}-convert.sh FILE\n"
	exit
fi

printf "\nVerifying that the given file is a vanilla NTSC v1.02 copy of SSBM or version $lastversion of 20XX. This will take a few moments...\n"

filehash=$(${md5sum} -b "$infile" |cut -d' ' -f1) 

if [ "$filehash" = "$sourceMd5" ]; then
	printf "The ISO has been verified!\n\n"
elif [ "$filehash" = "$lastversionmd5" ]; then
	printf "The ISO for the most recent version has been verified!\n\n"
	delta=$lastdelta
else
	printf "Unable to verify the source file ISO Hash. Please make sure you are providing either the most recent copy of 20XX or a vanilla NTSC 1.02 copy of the game. Would you like to continue anyways? (y/n)"
	read cont;
	if [ "$cont" != "y" ]; then
		exit
	fi
fi

if build; then # Checks the exit code of build
	printf "SUCCESS\n\nConversion complete!\n\n"
else
	printf "FAIL\n\nThere was an error during the build process.\n\n"
	exit
fi

printf "Would you like to check the hash of your new 20XX copy? (y/n): "
read check;
if [ "$check" = "y" ]; then
	if checkhash "$outfile" "$modmd5"; then
		printf "SUCCESS\n\n"
	else
		printf "WARNING: The hash for the output file does NOT match the expected hash for the current version of the mod. It is very unlikely that this script was successful. Please use this output file at your own risk."
	fi
fi
