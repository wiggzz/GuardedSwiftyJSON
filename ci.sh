#!/bin/bash

set -e

SIMULATOR_ID=$(xcrun instruments -s devices | grep -m1 "iPhone 7 (10.2)" | sed -E 's/.*\[(.*)\].*/\1/')
xcodebuild -scheme "GuardedSwiftyJson" -destination "platform=iOS Simulator,id=$SIMULATOR_ID" test
