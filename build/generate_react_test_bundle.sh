#!/bin/bash
if [ ! -d "external" ]
then
    echo "You must run this tool from the root directory of your repo clone"
else
    pushd libs/SalesforceReact
    react-native bundle --platform ios --dev true --entry-file node_modules/react-native-force/test/alltests.js --bundle-output ./SalesforceReactTests/main.jsbundle
    popd
fi
