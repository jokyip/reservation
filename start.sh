#!/bin/sh

root=~/prod/reservation

forever start --workingDir ${root} -a -l reservation.log /usr/bin/npm start