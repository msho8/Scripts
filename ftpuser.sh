#!/bin/bash
####################################################### clear_uniqname_file function ###################################################
# clear uniqname file in /temp/ directory.
clear_uniqname_file(){
        if [ -f /tmp/uniqname ];then
        rm -rf /tmp/uniqname;fi
}
###################################################### get_uniqname function ##########################################################
# this function fetch uniq username of the bind-fstab-file. This helps to create the first while of fstab_append_while function.
get_uniqname(){
        awk '{print $2}' ./bind-fstab-file | awk -F"/" '{print$3}' | uniq  >> /tmp/uniqname
}
get_uniqname
while read user;do
	#echo user=$user
	#group=$(ls -la -d /home/$user | awk '{print$4}')
	#echo group=$group
	find "/home/$user" -maxdepth 1 -type d ! -path "/home/$user" >> homepath
	#for i in $homepath;do
	while read path;do 
		#group=$(ls -la -d "$i" | awk '{print$4}')
		#echo group=$group
		#if test "$user" != "$group"; then
		#	usermod -aG $group $user;fi
		path=$(echo ${path//" "/\\" "})
		path=$(echo ${path//\(/\\(})
		path=$(echo ${path//\)/\\)})
		path=$(echo ${path//&/\\&})
		group=$(echo $path | xargs ls -la -d | awk '{print$4}')
		#echo "PATH=$group"
		if test "$user" != "$group"; then
			usermod -aG $group $user;fi
		#echo "$path" >> echoi
	done < ./homepath
	rm -rf ./homepath
done < /tmp/uniqname
#for i in $(find /ftp/* -type d ); do
#cat /tmp/uniqname
trap clear_uniqname_file exit	
#done
