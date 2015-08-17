#!/bin/sh

root=~/prod/reservation
export PORT=8010

forever start --workingDir ${root} -a -l reservation.log /usr/bin/npm start