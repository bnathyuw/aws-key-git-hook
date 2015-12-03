#!/bin/sh
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

assertPattern()
{
    read actual
    expected=$1
    assertTrue "Expected message matching '$expected' but got '$actual'" "[[ '$actual' =~ '$expected' ]]"
}

assertCredentialsSpotted()
{
    read result
    assertEquals "AWS credentials found. Aborting commit." "$result" 
}

test_it_displays_an_alert_when_a_new_file_containing_an_aws_key_is_committed()
{
    cp $root/i.have.an.aws.key.conf $workingDir
    git add -A

    git commit -m "This commit should fail" 2>&1 | assertCredentialsSpotted
}

test_it_displays_an_alert_when_an_aws_key_is_added_to_an_existing_file()
{
    cp $root/i.do.not.have.aws.credentials.conf $workingDir/to.be.edited.conf
    git add -A
    git commit -m "Preliminary commit"

    cat $root/i.have.an.aws.key.conf > $workingDir/to.be.edited.conf
    git add -A

    git commit -m "This commit should fail" 2>&1 | assertCredentialsSpotted
}

test_it_displays_an_alert_when_a_new_file_containing_an_aws_secret_is_committed()
{
    cp $root/i.have.an.aws.secret.conf $workingDir
    git add -A

    git commit -m "This commit should fail" 2>&1 | assertCredentialsSpotted
}

test_it_displays_an_alert_when_an_aws_secret_is_added_to_an_existing_file()
{
    cp $root/i.do.not.have.aws.credentials.conf $workingDir/to.be.edited.conf
    git add -A
    git commit -m "Preliminary commit"

    cat $root/i.have.an.aws.secret.conf > $workingDir/to.be.edited.conf
    git add -A

    git commit -m "This commit should fail" 2>&1 | assertCredentialsSpotted 
}

test_it_does_not_alert_when_a_new_file_containing_no_aws_keys_are_committed()
{
    cp $root/i.do.not.have.aws.credentials.conf $workingDir
    git add -A

    message="This commit should succeed"
    git commit -m "$message" 2>&1 | assertPattern "$message"
}
# load shunit
. shunit2
