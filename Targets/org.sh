#!/bin/bash

#ip list creater
#only class C subnet mask: 255.255.255.0
#enter as $1 a list that contains lines of paired ip's.
#each line contains the range desired, in first row the starting ip and in second row the ending ip.
#example: 10.0.0.10 10.0.0.20
#will output a list of ip in range of 10.0.0.10-10.0.0.20
#enter as $2 the output file.


list_enterd=$1
list_created=$2
while IFS= read -r line
do
	start=$(echo "$line" | awk '{print $1}')
	end=$(echo "$line" | awk '{print $2}')
	num1=$(echo "$start" | cut -d "." -f4)
	num2=$(echo "$end" | cut -d "." -f4)
	base=$(echo "$start" | cut -d "." -f1,2,3)
	for (( i=$num1; i<=$num2; i++ ))
	do
		echo "$base.$i" >> $list_created
	done
done < $list_enterd
