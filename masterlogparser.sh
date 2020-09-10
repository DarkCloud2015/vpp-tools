#!/bin/bash

# 	2020-08-27 15:40:16,479 [DEBUG] [ralPool-194] [viceAssignResponseHandler] - 
# 	ManagedLicensesResponse(status: -1 Adam ID: 1196524622 
# 		Association[ Client User ID Str: null Serial Number: FNXW50V3HLF9 License ID Str: null Error Message: License already assigned Error Number: 9616 License Already Assigned[ License ID Str: 13121343443 Client User ID Str: null Serial Number: FNXW50V3HLF9]]  
# 		Association[ Client User ID Str: null Serial Number: DMQTV9RFHLF9 License ID Str: null Error Message: License already assigned Error Number: 9616 License Already Assigned[ License ID Str: 13121342972 Client User ID Str: null Serial Number: DMQTV9RFHLF9]]  
# 		Association[ Client User ID Str: null Serial Number: GG7D2AX2MF3M License ID Str: null Error Message: License already assigned Error Number: 9616 License Already Assigned[ License ID Str: 13121342987 Client User ID Str: null Serial Number: GG7D2AX2MF3M]]  
# 		Association[ Client User ID Str: null Serial Number: DMRVKMNFHLF9 License ID Str: null Error Message: License already assigned Error Number: 9616 License Already Assigned[ License ID Str: 13121342989 Client User ID Str: null Serial Number: DMRVKMNFHLF9]]  
# 		Association[ Client User ID Str: null Serial Number: DMQTVDQYHLF9 License ID Str: null Error Message: License already assigned Error Number: 9616 License Already Assigned[ License ID Str: 13121343005 Client User ID Str: null Serial Number: DMQTVDQYHLF9]]  
# 		Association[ Client User ID Str: null Serial Number: FFLZK0SPHLF9 License ID Str: null Error Message: License already assigned Error Number: 9616 License Already Assigned[ License ID Str: 13121343007 Client User ID Str: null Serial Number: FFLZK0SPHLF9]]  
# 		Association[ Client User ID Str: null Serial Number: GG7D2GFKMF3M License ID Str: null Error Message: License already assigned Error Number: 9616 License Already Assigned[ License ID Str: 13121343008 Client User ID Str: null Serial Number: GG7D2GFKMF3M]]  
# 		Association[ Client User ID Str: null Serial Number: DMQTVFNUHLF9 License ID Str: null Error Message: License already assigned Error Number: 9616 License Already Assigned[ License ID Str: 13121343010 Client User ID Str: null Serial Number: DMQTVFNUHLF9]]  
# 		Association[ Client User ID Str: null Serial Number: DMQTVCMBHLF9 License ID Str: null Error Message: License already assigned Error Number: 9616 License Already Assigned[ License ID Str: 13121343012 Client User ID Str: null Serial Number: DMQTVCMBHLF9]]  
#		Association[ Client User ID Str: null Serial Number: GG7D2JEAMF3M License ID Str: null Error Message: License already assigned Error Number: 9616 License Already Assigned[ License ID Str: 13121343015 Client User ID Str: null Serial Number: GG7D2JEAMF3M]] )

timestamp=$(date '+%Y-%m-%d_%H%M%S')
reportFile="vppLogParse_report_$timestamp.txt"
adamIdFile="vppLogParse_adamIds_$timestamp.txt"
licenseIdFile="vppLogParse_licenseIds_$timestamp.txt"
serialNumberFile="vppLogParse_serialNumbers_$timestamp.txt"
clientUserIdFile="vppLogParse_clientUserIds_$timestamp.txt"
adamIds=()
licenseIds=()
serialNumbers=()
clientUserIds=()

input=""

while [[ ! "$input" =~ ^.*\.log(\.\d)? ]]; do
	read -p "Path to log file: " input
	if [[ ! "$input" =~ ^.*\.log(\.\d)? ]]; then
		echo "Invalid input."
	fi
done

#outputLocation="/Users/Shared"
outputLocation=$( dirname "$input" )
echo "Output location set to $outputLocation"

echo ""
echo "Checking `basename "$input"`..." #| tee -a "$outputLocation"/"$reportFile"
# echo "" >> "$outputLocation"/"$reportFile"
# echo "|    Date    |     Time     |  Adam ID  |  Serial No.  | License ID |" >> "$outputLocation"/"$reportFile"
# echo "|------------|--------------|-----------|--------------|------------|" >> "$outputLocation"/"$reportFile"

IFS=$'\n'

for line in $(cat "$input" | grep "License Already Assigned"); do

	logLineDate=$( echo $line | awk '{ print $1 }' )
	logLineTime=$( echo $line | awk '{ print $2 }' )
	
	buffer=$( echo "$line" | sed 's/\ \ /\,/g' | sed 's/.*ManagedLicensesResponse(status\:\ //g' )
	
	# I'm not sure if the status code is important, but it is parsed and stored here just in case.
	status=$( echo "$buffer" | sed 's/\ .*//g' )

	buffer=$( echo "$buffer" | sed 's/.*Adam\ ID\:\ //g' )

	adamId=$( echo "$buffer" | sed 's/\ .*//g' )
	adamIds+=($adamId)
	
	buffer=$( echo "$buffer" | sed 's/^[[:digit:]]*\ //g' )
	
	oldIFS=$IFS
	IFS=","
	
	for line in $buffer; do
		# echo "| $logLineDate | $logLineTime | $adamId\c" >> "$outputLocation"/"$reportFile"
		innerBuffer=$( echo $line | sed 's/^Association\[\ Client\ User\ ID\ Str\:\ //g' )
		clientUserIdStr=$( echo $innerBuffer | sed 's/\ .*//g' )
		# if [ "$clientUserIdStr" != "null" ]; then
		# 	echo " | $clientUserIdStr\c" >> "$outputLocation"/"$reportFile"
		# fi
		# Need better regex to filter out client user ID str, using null for now since DVPP is more likely.
		innerBuffer=$( echo $innerBuffer | sed 's/^null\ Serial\ Number\:\ //g' )
		serialNumber=$( echo $innerBuffer | sed 's/\ .*//g' )
		# if [ "$serialNumber" != "null" ]; then
		# 	echo " | $serialNumber\c" >> "$outputLocation"/"$reportFile"
		# fi
		serialNumbers+=($serialNumber)
		innerBuffer=$( echo $innerBuffer | sed 's/^.\{12\}\ .*License\ ID\ Str\:\ //g' )
		licenseIdStr=$( echo $innerBuffer | sed 's/\ .*//g' )
		# echo " | $licenseIdStr |\c" >> "$outputLocation"/"$reportFile"
		licenseIds+=($licenseIdStr)
		innerBuffer=$( echo $innerBuffer | sed 's/^[[:digit:]]*\ Client\ User\ ID\ Str\:\ //g' )
		clientUserIdStr=$( echo $innerBuffer | sed 's/\ .*//g' )
		# if [ "$clientUserIdStr" != "null" ]; then
		# 	echo " | $clientUserIdStr\c" >> "$outputLocation"/"$reportFile"
		# fi
		innerBuffer=$( echo $innerBuffer | sed 's/^null\ Serial\ Number\:\ //g' )
		serialNumber=$( echo $innerBuffer | sed 's/]]$//g' )
		# if [ "$serialNumber" != "null" ]; then
		# 	echo " | $serialNumber\c" >> "$outputLocation"/"$reportFile"
		# fi
		# echo "" >> "$outputLocation"/"$reportFile"
	done

	IFS=$oldIFS
done

#echo "|------------|--------------|-----------|--------------|------------|" >> "$outputLocation"/"$reportFile"

uniqAdamIds=($(printf -- '%s\n' "${adamIds[@]}" | sort | uniq))
uniqLicenseIds=($(printf -- '%s\n' "${licenseIds[@]}" | sort | uniq | tee "$outputLocation"/"$licenseIdFile"))
uniqSerialNumbers=($(printf -- '%s\n' "${serialNumbers[@]}" | sort | uniq | tee "$outputLocation"/"$serialNumberFile"))

echo "Done!\n\nFound ${#uniqAdamIds[*]} Adam IDs and ${#uniqSerialNumbers[*]} serial numbers associated with \"License Already Assigned\" errors.\nGenerating output files in $outputLocation..." #| tee -a "$outputLocation"/"$reportFile"

for i in ${!uniqAdamIds[@]}; do
	echo "\nAdam ID: ${uniqAdamIds[$i]}" | tee -a "$outputLocation"/"$adamIdFile"

	check=$( curl -s -X GET "https://uclient-api.itunes.apple.com/WebObjects/MZStorePlatform.woa/wa/lookup?version=2&p=mdm-lockup&caller=MDM&platform=omni&cc=us&l=en&id=${uniqAdamIds[$i]}" -H "Accept: application/json" -H 'Cache-Control: no-cache' -H 'Content-Type: application/json' -H 'Cookie: itvt=eyJleHBEYXRlIjoiMjAyMC0wOS0yNVQxMDozMToxNC0wNzAwIiwidG9rZW4iOiJWajNsUDNKZGhKSnEycjZEVXhGRUVUbHBJbXFCRFRLVERONTZmOFJyUHNrNGFiaFc3TWZjemZ1dzRHVHlDZTdsRC9FY2tpeHJUdmRnRmtMYlZ0cVd4d2pPN29MS2pyOG1KdElGRXNXMFBpQT0iLCJvcmdOYW1lIjoiSkFNRiBTb2Z0d2FyZSBVUyJ9' | python -mjson.tool | grep "\"results\"" | sed 's/.*\:\ //g' | sed 's/\,//g' )

	if [ "$check" == "{" ]; then

		# The greps and seds at the end could be replaced with a single 'jq' command, but I can't figure out the syntax to properly pass the quotes around the Adam ID. It seems like it works but just produces an output of "null". When running the command on its own, it works just fine. ¯\_(ツ)_/¯
		name=$( curl -s -X GET "https://uclient-api.itunes.apple.com/WebObjects/MZStorePlatform.woa/wa/lookup?version=2&p=mdm-lockup&caller=MDM&platform=omni&cc=us&l=en&id=${uniqAdamIds[$i]}" -H "Accept: application/json" -H 'Cache-Control: no-cache' -H 'Content-Type: application/json' -H 'Cookie: itvt=eyJleHBEYXRlIjoiMjAyMC0wOS0yNVQxMDozMToxNC0wNzAwIiwidG9rZW4iOiJWajNsUDNKZGhKSnEycjZEVXhGRUVUbHBJbXFCRFRLVERONTZmOFJyUHNrNGFiaFc3TWZjemZ1dzRHVHlDZTdsRC9FY2tpeHJUdmRnRmtMYlZ0cVd4d2pPN29MS2pyOG1KdElGRXNXMFBpQT0iLCJvcmdOYW1lIjoiSkFNRiBTb2Z0d2FyZSBVUyJ9' | python -mjson.tool | grep "\"nameRaw\"\:" | sed 's/.*\:\ \"//g' | sed 's/\"\,//g' )
		kind=$( curl -s -X GET "https://uclient-api.itunes.apple.com/WebObjects/MZStorePlatform.woa/wa/lookup?version=2&p=mdm-lockup&caller=MDM&platform=omni&cc=us&l=en&id=${uniqAdamIds[$i]}" -H "Accept: application/json" -H 'Cache-Control: no-cache' -H 'Content-Type: application/json' -H 'Cookie: itvt=eyJleHBEYXRlIjoiMjAyMC0wOS0yNVQxMDozMToxNC0wNzAwIiwidG9rZW4iOiJWajNsUDNKZGhKSnEycjZEVXhGRUVUbHBJbXFCRFRLVERONTZmOFJyUHNrNGFiaFc3TWZjemZ1dzRHVHlDZTdsRC9FY2tpeHJUdmRnRmtMYlZ0cVd4d2pPN29MS2pyOG1KdElGRXNXMFBpQT0iLCJvcmdOYW1lIjoiSkFNRiBTb2Z0d2FyZSBVUyJ9' | python -mjson.tool | grep "\"kind\"\:" | sed 's/.*\:\ \"//g' | sed 's/\"\,//g' )
		attempt="0"
		while [ -z "$name" ]; do
			((attempt++))
			if [ "$attempt" -lt "21" ]; then
				sleep 1
			else break
			fi
			name=$( curl -s -X GET "https://uclient-api.itunes.apple.com/WebObjects/MZStorePlatform.woa/wa/lookup?version=2&p=mdm-lockup&caller=MDM&platform=omni&cc=us&l=en&id=${uniqAdamIds[$i]}" -H "Accept: application/json" -H 'Cache-Control: no-cache' -H 'Content-Type: application/json' -H 'Cookie: itvt=eyJleHBEYXRlIjoiMjAyMC0wOS0yNVQxMDozMToxNC0wNzAwIiwidG9rZW4iOiJWajNsUDNKZGhKSnEycjZEVXhGRUVUbHBJbXFCRFRLVERONTZmOFJyUHNrNGFiaFc3TWZjemZ1dzRHVHlDZTdsRC9FY2tpeHJUdmRnRmtMYlZ0cVd4d2pPN29MS2pyOG1KdElGRXNXMFBpQT0iLCJvcmdOYW1lIjoiSkFNRiBTb2Z0d2FyZSBVUyJ9' | python -mjson.tool | grep "\"nameRaw\"\:" | sed 's/.*\:\ \"//g' | sed 's/\"\,//g' )
			kind=$( curl -s -X GET "https://uclient-api.itunes.apple.com/WebObjects/MZStorePlatform.woa/wa/lookup?version=2&p=mdm-lockup&caller=MDM&platform=omni&cc=us&l=en&id=${uniqAdamIds[$i]}" -H "Accept: application/json" -H 'Cache-Control: no-cache' -H 'Content-Type: application/json' -H 'Cookie: itvt=eyJleHBEYXRlIjoiMjAyMC0wOS0yNVQxMDozMToxNC0wNzAwIiwidG9rZW4iOiJWajNsUDNKZGhKSnEycjZEVXhGRUVUbHBJbXFCRFRLVERONTZmOFJyUHNrNGFiaFc3TWZjemZ1dzRHVHlDZTdsRC9FY2tpeHJUdmRnRmtMYlZ0cVd4d2pPN29MS2pyOG1KdElGRXNXMFBpQT0iLCJvcmdOYW1lIjoiSkFNRiBTb2Z0d2FyZSBVUyJ9' | python -mjson.tool | grep "\"kind\"\:" | sed 's/.*\:\ \"//g' | sed 's/\"\,//g' )
		done
		if [ "$kind" == "iosSoftware" ]; then
			echo "iOS App: \"$name\"" >> "$outputLocation"/"$adamIdFile"
		elif [ "$kind" == "desktopApp" ]; then
			echo "Mac App: \"$name\"" >> "$outputLocation"/"$adamIdFile"
		elif [ "$kind" == "ibook" ]; then
			echo "Book: \"$name\"" >> "$outputLocation"/"$adamIdFile"
		else
			echo "Unable to get content information" >> "$outputLocation"/"$adamIdFile"
		fi
	elif [ "$check" == "{}" ]; then
		echo "No content found for Adam ID" >> "$outputLocation"/"$adamIdFile"
	fi
done

echo "Done!"

# echo "\nSerial Numbers:" >> "$outputLocation"/"$reportFile"

# for i in ${!uniqSerialNumbers[@]}; do
# 	echo "${uniqSerialNumbers[$i]}" >> "$outputLocation"/"$reportFile" 
# done

# echo "\nLicense IDs:" >> "$outputLocation"/"$reportFile"

# for i in ${!uniqLicenseIds[@]}; do
# 	echo "${uniqLicenseIds[$i]}" >> "$outputLocation"/"$reportFile" 
# done

#echo "\nFull report saved to $outputLocation/$reportFile"
