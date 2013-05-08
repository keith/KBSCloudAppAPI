#!/usr/bin/env bash

if ! which rake &> /dev/null; then
    echo "You must have rake installed to setup the test frameworks"
    exit
fi

git submodule update --init --recursive
echo "Setting up test frameworks..."
cd Example/Vendor/Specta; rake > /dev/null
cd ../Expecta; rake > /dev/null
echo "Done"
cd ../../../
