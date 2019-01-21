#!/bin/bash

#echo "welcome to jdoodle"
#USER=`whoami`

echo "FILENAME : $0"


echo "hello var1 $1, Var2 $2"
#$$
#exit 0
echo "NUMBER OF VARIABLES : $#"


echo "all the argus supplyed script : $@" 

echo "most rescently executed process status: $?"


echo "process id current script : $$"

echo "currnet running user : $USER"

echo "currnet running hostname : $HOSTNAME"

echo "no of sec script started : $SECONDS"

echo "generate random Numbers : $RANDOM"
echo "CURRENT line no : $LINENO"


newvar="sample$HOSTNAME"
newvar="hell$newvar"
echo "$newvar"


#Substitutuion
test1=`ls`
echo "method1: $test1"

test2=$(ls)
echo "method2: $test2"

# IF 
if [ $? = 0 ]
then 
echo "working fine "
fi

if [ $1 -gt $2 ]
then 
echo "hey that is large number"
fi


# sting Comparision
if [ "$test1" = "$test2" ]
#if [ "$HOSTNAME" != "$USER" ]
then 
echo "sting Comparision $test1 and $test2  "
fi


# numbers Comparision
if [ $1 -eq $2 ]
#if [ $1 != $2 ]
then 
echo "numbers Comparision $1 and $2 "
fi

# file permission
if [  -e $0 ]

then 
echo "having execite permissions "
ls -ltr
fi


