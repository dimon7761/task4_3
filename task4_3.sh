#!/bin/bash
#Dmitriy Litvin 2018
#CONFIG
dest='/tmp/backups'

OLD_IFS=$IFS
IFS=$'\n'

#ARG
if (( "$#" != "2" )); then echo "Error: few or many arguments" >&2; exit 0; fi
num=$(echo "$2" |  sed 's/^[/]*//;s/[/]*$//')
if ! (echo "$num" | grep -E -q "^?[0-9']+$"); then echo "Error: invalid argument $2" >&2; exit 0; fi

#PATCHES
patch=$(echo "$1")
if ! [ -d "$dest" ]; then  mkdir -p  "$dest"; echo "$dest create."; fi
if ! [ -d "$patch" ]; then echo "Error: directory $patch does not exist" >&2; exit 0; fi

#FILE
filename=$(echo "$patch" | sed 's/^[/]*//;s/[/]*$//' | awk '{ gsub("/","-"); print }' ) #| awk '{ gsub(" ","_"); print }')

#DELETE
if [ $num -gt "1" ]; then 
filelist=($(ls -t $dest | grep -e $filename | grep -v $filename.tar.gz))
filecount=${#filelist[@]}
for ((i=$num-2; i<$filecount; i++)); do
rm $dest/${filelist[$i]}
done
else rm $dest/$filename*  >> /dev/null 2>&1
fi

#ROTATE
if [ $num -gt "1" ]; then
filecount=$(ls -f "$dest" | grep -e "$filename" | grep -v "$filename".tar.gz | wc -l)
for ((i=$filecount; i>0; i--)); do
mv $dest/$filename.$i.tar.gz $dest/$filename.$(($i+1)).tar.gz
done
if  [ -f $(echo $dest/$filename.tar.gz) ]; then `mv $dest/$filename.tar.gz $dest/$filename.1.tar.gz`; fi
fi
if  [ -f $(echo $dest/$filename.tar.gz) ]; then `rm $dest/$filename.tar.gz`; fi

#CREATE 
tar  -czpf "$dest"/"$filename".tar.gz "$patch" >> /dev/null 2>&1
exit $?







