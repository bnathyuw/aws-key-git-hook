#! /bin/sh
# file: first-test.sh

root=`pwd`
workingDir=$root/foo

oneTimeSetUp()
{
    mkdir $workingDir
    cd $workingDir
    git init
    ln $root/pre-commit ./.git/hooks/pre-commit
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
    cd $workingDir
    git reset --hard
    cd $root
}

test_it_displays_an_alert_when_an_aws_key_is_committed()
{
    cp $root/i.have.aws.keys.conf $workingDir
    git add -A

    git commit -m "This commit should fail" 2>&1 | ( 
        read result
        assertEquals "AWS key found. Aborting commit." "$result" 
    )
}

# load shunit
. shunit2
