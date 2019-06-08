for file in logfile1 logfile2 logfile2 ... ; do
    truncate -s 0 $file 
    or
    dd if=/dev/null of=$file
    or
    :>$file
done
