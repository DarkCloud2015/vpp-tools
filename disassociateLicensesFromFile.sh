#!/bin/bash

timestamp=$(date '+%Y-%m-%d-%H%M%S')

sToken=""
location=""

if [[ "$sToken" == "" ]]; then
	echo "\nEnter sToken:"
	read sToken
fi

if [[ "$location" == "" ]]; then
	echo "\nEnter location of file with license IDs to disassociate:"
	read location
fi

outputLocation="/Users/Shared/disassociateLicensesFromFile_$timestamp.txt"
echo "disassociateLicensesFromFile.sh - Start: $timestamp" >> $outputLocation

echo "\nGetting license IDs from $location..." | tee -a $outputLocation
numLicenses=$( cat "$location" | wc -l | tr -d [[:space:]] )
echo "Found $numLicenses licenses in `basename "$location"`.\n" | tee -a $outputLocation

if [ $numLicenses -eq 0 ]; then
	echo "\nNo licenses to disassociate." | tee -a $outputLocation
else
	read -p "Would you like to proceed? [y/n] " answer
	echo "" | tee -a $outputLocation

	if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
		echo "Proceeding!\n" | tee -a $outputLocation
		failed=()

		for licenseId in $(cat "$location"); do
			echo "Attempting to disassociate license $licenseId... \c" | tee -a $outputLocation
			
			# Revoke license call - Credit to GK
		    userData="{\"licenseId\":\"${licenseId}\",\"sToken\":\"${sToken}\"}"
		    output=$(curl -s  https://vpp.itunes.apple.com/mdm/disassociateVPPLicenseSrv -d "$userData" -X POST)
		    error=""
		    error=`echo $output | grep "errorMessage"`
		    if [[ $error != "" ]]; then
		        failed+=("$licenseId $error")
		        echo "failed" | tee -a $outputLocation
		    else
		    	echo "done" | tee -a $outputLocation
		    fi
		done

		if [ ${#failed[@]} -eq 0 ]; then
			echo "\nAll licenses disassociated!" | tee -a $outputLocation
		elif [ ${#failed[@]} -gt 0 ]; then
			echo "\nThe following licenses could not be disassociated:" | tee -a $outputLocation
			printf -- '%s\n' "${failed[@]}" | tee -a $outputLocation
		fi
	else
		echo "Aborting!" | tee -a $outputLocation
	fi
fi