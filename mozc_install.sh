#!/bin/sh
set -e

mozc_build() {
	git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
	export PATH=$PWD/depot_tools:$PATH

	mkdir mozc
	gclient config https://github.com/google/mozc.git --name=. --deps-file=src/DEPS
	gclient sync

	cd src
	GYP_DEFINES="mac_sdk=10.10 mac_deployment_target=10.10" python build_mozc.py gyp --noqt
}

mozc_install() {
	sudo cp out_mac/Release/mozc_emacs_helper /usr/local/bin
	sudo cp -r out_mac/Release/Mozc.app '/Library/Input Methods/'
	sudo cp -r out_mac/DerivedSources/Release/mac/org.mozc.inputmethod.Japanese.Converter.plist /Library/LaunchAgents
	sudo cp src/out_mac/DerivedSources/Release/mac/org.mozc.inputmethod.Japanese.Renderer.plist /Library/LaunchAgents
    
}

if [ "$1" = "" ]; then
	echo "mozc_install.sh build|install"
	exit
fi

mozc_$1()
