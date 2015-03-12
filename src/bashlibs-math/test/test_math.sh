#!/bin/bash
$(bashlibs --load-base)
include shunit2_enhancements.sh
include math.sh

oneTimeSetUp() {
    DATA=$(mktemp)

	cat<<-EOF > $DATA
	1.45 3
	1.50 4
	2.95 5
	EOF
}

oneTimeTearDown() {
    rm -f $DATA
}

test_min() {
    returns 1.45 "min 1 $DATA"
    returns 3 "min 2 $DATA"
}

test_max() {
    returns 2.95 "max 1 $DATA"
    returns 5 "max 2 $DATA"
}

test_average() {
    returns 1.96667 "average 1 $DATA"
    returns 4 "average 2 $DATA"
}

# load shunit2
source /usr/share/shunit2/shunit2
