#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include versions.sh

test_replace_version() {
    returns "my-package-0.0.2.tar.gz" \
        "replace_version 0.0.2 my-package-0.0.1.tar.gz"

    returns "my-package.0.0.2.tar.gz" \
        "replace_version 0.0.2 my-package.0.0.1.tar.gz"
}

# load shunit2
source /usr/share/shunit2/shunit2
