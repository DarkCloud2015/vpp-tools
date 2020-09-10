#!/bin/bash

timestamp=$(date '+%Y-%m-%d_%H%M%S')

sToken=""
userId=""

if [[ "$sToken" == "" ]]; then
	echo "Please enter sToken"
	read sToken
fi

if [[ "$userId" == "" ]]; then
	echo "Please enter userId"
	read userId
fi

outputLocation="/Users/Shared/getLicenses_$userId_$timestamp.log"

echo "getLicenses.sh - Start: $timestamp" >> $outputLocation
echo "\nGetting licenses for userId $userId...\n" | tee -a $outputLocation
curl -s -X GET "https://vpp.itunes.apple.com/mdm/getVPPUserSrv?userId=$userId&sToken=$sToken" -H "Accept: application/json" -H 'Cache-Control: no-cache' -H 'Content-Type: application/json' | python -mjson.tool >> $outputLocation
echo "License report for user $userId saved to $outputLocation"