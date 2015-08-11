#!/bin/sh
set -e

mozc_build() {
	git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
	export PATH=$PWD/depot_tools:$PATH

	mkdir mozc
	cd mozc
	gclient config https://github.com/google/mozc.git --name=. --deps-file=src/DEPS
	gclient sync

	cd src
	curl -LO https://gist.githubusercontent.com/syohex/1cd72dccc345b3c7fa45/raw/40875a9b0970bc80202328ba4e195139834baf3f/mozc-macosx.patch
	patch build_mozc.py < mozc-macosx.patch
	GYP_DEFINES="mac_sdk=10.10 mac_deployment_target=10.10" python build_mozc.py gyp --noqt
	python build_mozc.py build -c Release mac/mac.gyp:GoogleJapaneseInput mac/mac.gyp:gen_launchd_confs unix/emacs/emacs.gyp:mozc_emacs_helper
}

mozc_install() {
	cd mozc/src

	set -x
	sudo cp out_mac/Release/mozc_emacs_helper /usr/local/bin
	sudo cp -r out_mac/Release/Mozc.app '/Library/Input Methods/'
	sudo cp -r out_mac/DerivedSources/Release/mac/org.mozc.inputmethod.Japanese.Converter.plist /Library/LaunchAgents
	sudo cp out_mac/DerivedSources/Release/mac/org.mozc.inputmethod.Japanese.Renderer.plist /Library/LaunchAgents
	set +x
}

if [ "$1" = "" ]; then
	echo "mozc_install.sh (build|install)"
	exit
fi

mozc_"$1"
