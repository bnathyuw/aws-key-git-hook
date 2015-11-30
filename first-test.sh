#! /bin/sh
# file: first-test.sh

root=`pwd`
workingDir=$root/foo

setUp()
{
    mkdir $workingDir
    cd $workingDir
    git init
    ln $root/pre-commit ./.git/hooks/pre-commit
}

tearDown()
{
    cd $workingDir
    git reset --hard
    cd $root
    rm -rf $workingDir
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

test_it_does_not_alert_when_no_aws_keys_are_committed()
{
    cp $root/i.do.not.have.keys.conf $workingDir
    git add -A

    message="This commit should succeed"
    git commit -m "$message" 2>&1 | (
        read result
        assertTrue "Expected a commit message, but got '$result'" "[[ '$result' =~ '$message' ]]"
    )
}
# load shunit
. shunit2
