#!/bin/sh

####### ######### #######
####### functions #######
####### ######### #######
function hasParam {
	for p in "${params[@]}"; do
		if [ "$p" == "$1" ]; then
			echo "true"
		fi
	done
}
function check {
	if [ $? -ne 0 ]; then
		echo "XXX failed $1"
		echo "XXX if you keep get errors, check \"Requirements\" in:"
		echo "XXX $srcDir/src/INSTALL"
		exit
	fi
	echo "OOO success: $1"	
}


function pprint {
	echo "### $1 ###"
}

####### ######### #######
####### variables #######
####### ######### #######
if [ $1 == "all" ]; then
	params=("clean" "get" "patch" "build", "install")
else
	params=("$@")
fi

baseDir="$(pwd)"
srcDir="source/"
distDir="dist/"
compileDir="compile/"

repoUrl="https://svn.filezilla-project.org/svn/FileZilla3/trunk"
####### ######### #######

####### #### #######
####### help #######
####### #### #######

if [ $(hasParam "help") ]; then
	pprint "help - this"
	pprint "clean - clean"
	pprint "get - get latest source"
	pprint "patch - apply patches"
	pprint "build - compile source (configure and make)"
	pprint "install - install compiled source (make install)"
	pprint "dist - create some distribution packages (currently: bzip, gzip, zip, xz)"
	pprint "all - clean, get, patch, build, install"
fi

####### ##### #######
####### clean #######
####### ##### #######

if [ $(hasParam "clean") ]; then
	cd "$baseDir"
	pprint "cleaning up..."

	rm -rf "$srcDir" "$distDir"
	check "cleaning"
fi

####### ########## #######
####### get source #######
####### ########## #######
if [ $(hasParam "get") ]; then
	cd "$baseDir"
	pprint "getting source..."

	if [ -d "$srcDir" ]; then
		svn up --quiet $srcDir
	else
		svn co --quiet $repoUrl $srcDir
	fi
	check "getting source!"
fi

####### ##### #######
####### patch #######
####### ##### #######
if [ $(hasParam "patch") ]; then
	cd "$baseDir"
	pprint "patching..."

	patch -i patches/PRET-support.patch source/src/engine/ftpcontrolsocket.cpp
	check "patching"
fi

####### ##### #######
####### build #######
####### ##### #######
if [ $(hasParam "build") ]; then
	cd "$baseDir"
	pprint "building..."

	cd "$srcDir"
	sh autogen.sh
	check "autogen"

	mkdir ../"$compileDir"
	cd ../"$compileDir"
	sh ../"$srcDir"/configure
	check "configure"

	make
	check "make"
fi

####### ####### #######
####### install #######
####### ####### #######
if [ $(hasParam "install") ]; then
	cd "$baseDir"
	pprint "installing..."

	cd "$compileDir"
	make install
	check "make install"
fi

####### #### #######
####### dist #######
####### #### #######
if [ $(hasParam "install") ]; then
	cd "$baseDir"
	pprint "installing..."

	cd "$compileDir"
	make dist-bzip2
	make dist-gzip
	make dist-xz
	make dist-zip
	check "make install"

	mkdir ../dist
	mv *.tar.bz2 ../dist
	mv *.tar.gz ../dist
	mv *.tar.xz ../dist
fi
