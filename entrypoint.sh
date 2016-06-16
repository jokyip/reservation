#!/bin/sh

./node_modules/.bin/gulp --prod
export PORT=1337
npm start --prod