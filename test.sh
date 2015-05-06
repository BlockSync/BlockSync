#!/bin/sh
set -e
xctool -project Example/Async.xcodeproj -scheme AsyncTests build test -sdk iphonesimulator
