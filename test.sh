#!/bin/sh
# file: first-test.sh

ROOT=`pwd`
WORKING_DIR=$ROOT/foo
CREDENTIALS_FOUND="AWS credentials found. Aborting commit."

setUp()
{
    mkdir $WORKING_DIR
    cd $WORKING_DIR
    git init
    ln $ROOT/pre-commit ./.git/hooks/pre-commit
}

tearDown()
{
    cd $WORKING_DIR
    git reset --hard
    cd $ROOT
    rm -rf $WORKING_DIR
}

assertPattern()
{
    read actual
    expected=$1
    assertTrue "Expected message matching '$expected' but got '$actual'" "[[ '$actual' =~ '$expected' ]]"
}

test_it_displays_an_alert_when_a_new_file_containing_an_aws_key_is_committed()
{
    cp $ROOT/i.have.an.aws.key.conf $WORKING_DIR
    git add -A

    git commit -m "This commit should fail" 2>&1 | assertPattern "$CREDENTIALS_FOUND"
}

test_it_displays_an_alert_when_an_aws_key_is_added_to_an_existing_file()
{
    cp $ROOT/i.do.not.have.aws.credentials.conf $WORKING_DIR/to.be.edited.conf
    git add -A
    git commit -m "Preliminary commit"

    cat $ROOT/i.have.an.aws.key.conf > $WORKING_DIR/to.be.edited.conf
    git add -A

    git commit -m "This commit should fail" 2>&1 | assertPattern "$CREDENTIALS_FOUND"
}

test_it_displays_an_alert_when_a_new_file_containing_an_aws_secret_is_committed()
{
    cp $ROOT/i.have.an.aws.secret.conf $WORKING_DIR
    git add -A

    git commit -m "This commit should fail" 2>&1 | assertPattern "$CREDENTIALS_FOUND"
}

test_it_displays_an_alert_when_an_aws_secret_is_added_to_an_existing_file()
{
    cp $ROOT/i.do.not.have.aws.credentials.conf $WORKING_DIR/to.be.edited.conf
    git add -A
    git commit -m "Preliminary commit"

    cat $ROOT/i.have.an.aws.secret.conf > $WORKING_DIR/to.be.edited.conf
    git add -A

    git commit -m "This commit should fail" 2>&1 | assertPattern "$CREDENTIALS_FOUND" 
}

test_it_does_not_alert_when_a_new_file_containing_no_aws_keys_are_committed()
{
    cp $ROOT/i.do.not.have.aws.credentials.conf $WORKING_DIR
    git add -A

    message="This commit should succeed"
    git commit -m "$message" 2>&1 | assertPattern "$message"
}
# load shunit
. shunit2
