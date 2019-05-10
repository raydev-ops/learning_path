# Usefull Commands 

# displays tree of resource utilization by cpu/mem
ps auxf  

# file count
find dirname –type f| wc –l   
find dirname –type f –exec chmod 666 {} \;
find ./ -name “.htaccess” -exec echo {} \;
find ./ -iname “.htaccess” |xargs -t -I [] cp [] [].bak2

# send text through a port
nc –l port + nc ip port 

# who is logged in
w

# Last user to login
last


# diff 2 directories
diff –r dir1 dir2
diff –r –x .git dir1 dir2

split -b 100M wicnss.tar.gz  /mnt/temp/wicnss

# STD Error
command 2>&1
echo $?


# SED
 sed s/search/replace/g
 sed 's/\/opt\/dir1/\/a\/apps\/opt\/dir2/g' files
 
# AWK
echo -e “begin/end/.htaccess” | awk -F “/” ‘{ aa=sprintf( “%s:%s”, “abcd”,$2);print( aa )}’
echo -e “begin/end/.htaccess” | awk -F “/” ‘{ aa=$0;sub( “begin”, “”, aa );print( aa )}’
echo -e “aa/bb/cc/dd/.htaccess” | awk -F “/” ‘{ full=$0;filename=$NF;dir=$0;sub($NF,””,dir);rel=dir;sub( “aa/bb”, “”, rel );print( full,filename,dir,rel )}’


# XARGS
ls|xargs -I {} echo {}
>junk.txt;echo -e “junk.txt”|awk ‘{print($0)}’|xargs -t -I {} cp {} junk2.txt


# Openssl connect
openssl s_client -connect YourDomainName:443 –showcerts


# Disk spped test
Write speed test   :  dd if=/dev/zero of=/tmp/test2.img bs=1G count=1 oflag=dsync
Write latency test :  dd if=/dev/zero of=/tmp/test2.img bs=512 count=1000 oflag=dsync

 
