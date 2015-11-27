#! /bin/sh
# file: first-test.sh

root=`pwd`

oneTimeSetUp()
{
    mkdir $root/foo
    cd $root/foo
    git init
    cd $root
}

oneTimeTearDown()
{
    cd $root
    rm -rf $root/foo
}

setUp()
{
    cd $root/foo
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
