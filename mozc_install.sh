#!/bin/sh
set -e

mozc_build() {
    rm -rf work

    if [ ! -d gyp ]; then
        git clone https://chromium.googlesource.com/external/gyp
    fi

    export PATH=$PWD/gyp:$PATH

    # Use system python
    export PATH=/usr/bin:$PATH
    mkdir work
    cd work
    git clone https://github.com/google/mozc.git -b master --single-branch --recursive

    cd mozc/src
    curl -LO https://gist.githubusercontent.com/syohex/1cd72dccc345b3c7fa45/raw/40875a9b0970bc80202328ba4e195139834baf3f/mozc-macosx.patch
    patch build_mozc.py < mozc-macosx.patch
    GYP_DEFINES="mac_sdk=10.11 mac_deployment_target=10.11" python build_mozc.py gyp --noqt
    python build_mozc.py build -c Release mac/mac.gyp:GoogleJapaneseInput
    python build_mozc.py build -c Release mac/mac.gyp:gen_launchd_confs
    python build_mozc.py build -c Release unix/emacs/emacs.gyp:mozc_emacs_helper
}

mozc_install() {
    cd work/mozc/src

    set -x
    sudo cp out_mac/Release/mozc_emacs_helper /usr/local/bin
    sudo cp -r out_mac/Release/Mozc.app '/Library/Input Methods/'
    sudo cp -r out_mac/Release/gen/mac/org.mozc.inputmethod.Japanese.Converter.plist /Library/LaunchAgents
    sudo cp out_mac/Release/gen/mac/org.mozc.inputmethod.Japanese.Renderer.plist /Library/LaunchAgents
    set +x
}

mozc_clean() {
    rm -rf mozc gyp
}

mozc_check() {
    if ! which ninja >/dev/null 2>&1 ; then
        echo "Please install ninja(ex: brew install ninja)"
        exit 1
    fi
}

if [ "$1" = "" ]; then
	echo "mozc_install.sh (build|install|clean)"
	exit
fi

mozc_check
mozc_"$1"
