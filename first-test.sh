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
    rm -r $root/foo
}

testEquality()
{
    assertEquals 1 1
}

# load shunit
. shunit2
