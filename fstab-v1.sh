#!/bin/bash
######################################################### Functions ###################################################################
############################################# BEGINandENDbind_fstab_append function #########################################
#Append EBGIN and END BIND in fstab
BEGINandENDbind_fstab_append(){
	BEGIN=$(grep -E "^#+\s*BEGINING|begining" /etc/fstab | wc -l)
	END=$(grep -E "^#+\s*END|end" /etc/fstab | wc -l)
	if test "$BEGIN" == "0"; then
		sed -i '$a#################################################### BEGINING OF BINDS #############################################################' /etc/fstab;fi
	if test "$END" == "0"; then
		sed -i '$a####################################################  END OF BINDS  #############################################################' /etc/fstab;fi
}
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
##################################################### Append_fstab_nested_while function #############################################
# Nested while for check usernames and append lines of bind-fstab-file in fstab file. 
Append_fstab_nested_while(){
# First while to read uniqname file.
while read line3; do
		#endlinenumber=$(grep -n "END" /etc/fstab | awk -F":" '{print$1}')
		#Find the "END of Bind" line number a the last line number in fstab file.
		endlinenumber=$(grep -En "^#+\s*END|end" /etc/fstab | awk -F":" '{print$1}')
		#userline=$(grep -E ".*$line3#" /etc/fstab | wc -l)
		# Find the "bind of username" line number in the fstab file.
  		userbind=$(grep -E "^#+\s*BINDS\s*for\s*$line3.*" /etc/fstab | wc -l)
		# test if $userbind is null, then append the following line to the fstab file.
		if test "$userbind" == "0"; then
		sed -i -e "$((endlinenumber - 1))a#################################################### BINDS for $line3 username ##############################################" /etc/fstab
		fi
	# second while to read "bind-fstab-file" file, then check condition and execute commands.
	while read line2 ;do
		# Find the $line2 line number to use in the following conditions.
		line2content=$(grep -E ".*$(echo "$line2")" /etc/fstab | wc -l)
		#Find the "END of Bind" line number a the last line number in fstab file.
		endlinenumber2=$(grep -En "^#+\s*END|end" /etc/fstab | awk -F":" '{print$1}')		
		# Fetch the username to check the following conditions.
		username2=$(echo $line2 | cut -f 2 -d " "  | cut -f3 -d "/")
		# Find the "bind of username" line number in the fstab file.
  		userbind2=$(grep -E "^#+\s*BINDS\s*for\s*$username2.*" /etc/fstab | wc -l)
		# Find the user line number to use in the sed command.
		userlinenumber=$(grep -En "^#+\s*BINDS\s*for\s*$username2.*" /etc/fstab | awk -F":" '{print$1}')
		# check if the line2content is null, then run the following sed command.
		if test "$line2content" == "0"; then 
				# Check if $line and $username2 is equal, then run the following commands.
				if [[ "$line3" == "$username2" ]]; then
				sed -ie "$userlinenumber a $line2" /etc/fstab
		                # check if the $line3 is not equal to $username2 and $userbind2 is null run the following command.
				# the following command prevent duplicate following lines in the fstab file.	
				elif [[ "$line3" != "$username2" && "$userbind2" == "0"  ]];then
 				sed -i -e "$((endlinenumber2 - 1)) a#################################################### BINDS for $username2 username ##############################################" /etc/fstab
				# Find the user line number to use in the sed command.
				userlinenumber=$(grep -En "^#+\s*BINDS\s*for\s*$username2.*" /etc/fstab | awk -F":" '{print$1}')
				sed -ie "$userlinenumber a $line2" /etc/fstab
				# the following condition check if there $line2 is not on the fstab,then append that.
				elif [[ "$line2content" == "0" ]]; then
		 		 	sed -ie "$userlinenumber a $line2" /etc/fstab
				# end of the nested(second) if
				fi
		# end of the first if
		fi
	# end of nested(second) while.
	done <./bind-fstab-file
# End of the first while.
done < /tmp/uniqname
#end of the Append_fstab_nested_while function.
}
############################################################ Begining of the Scripts #################################################
# create a backup of fstab before any changes.
cp /etc/fstab /etc/fstab-bak-script-$(date +%F-%R)
#Use the get_uniqname function.
get_uniqname
#Use the BEGINandENDbind_fstab_append function.
BEGINandENDbind_fstab_append
# Use the Append_fstab_nested_while function.
Append_fstab_nested_while
#Use clear_uniqname_file function to clear uniqname file in /tmp/ directory. 
trap clear_uniqname_file exit
############################################################### End of the script ######################################################
