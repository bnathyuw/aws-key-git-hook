#! /bin/sh
# file: first-test.sh

root=`pwd`
workingDir=$root/foo

oneTimeSetUp()
{
    mkdir $workingDir
    cd $workingDir
    git init
    cd $root
}

oneTimeTearDown()
{
    cd $root
    rm -rf $workingDir
}

setUp()
{
    cd $workingDir
}

tearDown()
{
    cd $root    
}

testEquality()
{
    echo Hello, world! > bar.txt
    git add -A
    git commit -m "Wotcha, world!"
}

# load shunit
. shunit2
