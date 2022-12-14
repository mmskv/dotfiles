#!/bin/bash

if [ $(mpc --format %volume% volume | awk '{ print $2 }' | tr -cd '0-9') -gt 40 ]; 
then 
    mpc -q volume 40; 
else 
    mpc -q volume 80; 
fi;
