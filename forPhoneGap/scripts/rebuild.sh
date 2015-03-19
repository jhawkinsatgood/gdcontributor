#!/bin/sh

# ToDo: Replace the following by making contributor.jhawkins a proper plugin
rm -rf www/com.good.example.contributor.jhawkins
cp -Rf ../../src/com.good.example.contributor.jhawkins \
      www/com.good.example.contributor.jhawkins

# Script to re-prepare but without deleting GoodDynamics.js for example
cp -Rf www/ platforms/android/assets/www/
cp -Rf www/ platforms/ios/www/

