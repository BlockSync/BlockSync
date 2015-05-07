#!/bin/sh
set -e
xctool -project Example/Async.xcodeproj -scheme AsyncTests build test -sdk iphonesimulator  GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES GCC_GENERATE_TEST_COVERAGE_FILES=YES
