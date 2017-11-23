#!/bin/bash
echo $(dirname "$0")
cd "$(dirname "$0")"
pod install --verbose --no-repo-update 