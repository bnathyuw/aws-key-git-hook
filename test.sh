#!/bin/sh
# file: first-test.sh

. pre-commit &> /dev/null

ROOT=`pwd`
WORKING_DIR=$ROOT/foo
CREDENTIALS_FOUND="AWS credentials found. Aborting commit."
# THESE ARE NOT REAL AWS KEYS, OBVIOUSLY!
SAMPLE_AWS_KEY="ASIAJCKR244245IV4FHQ"
SAMPLE_AWS_SECRET="q6MVN9m0OSsNWUCWb5d7pnCjTEIHtiJT43SPk1Zy"

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

test_the_script_displays_an_alert_when_a_new_file_containing_an_aws_key_is_committed()
{
    echo 'foo.aws.key="'$SAMPLE_AWS_KEY'"' > $WORKING_DIR/new.conf
    cat $WORKING_DIR/new.conf
    git add -A

    git commit -m "This commit should fail" 2>&1 | assertPattern "$CREDENTIALS_FOUND"
}

test_the_script_displays_an_alert_when_an_aws_key_is_added_to_an_existing_file()
{
    echo "# No secrets in here" > $WORKING_DIR/existing.conf
    git add -A
    git commit -m "Preliminary commit"

    echo 'foo.aws.key="'$SAMPLE_AWS_KEY'"' >> $WORKING_DIR/existing.conf   
    git add -A

    git commit -m "This commit should fail" 2>&1 | assertPattern "$CREDENTIALS_FOUND"
}

test_the_script_displays_an_alert_when_a_new_file_containing_an_aws_secret_is_committed()
{
    echo 'foo.aws.secret="'$SAMPLE_AWS_SECRET'"' > $WORKING_DIR/new.conf
    git add -A

    git commit -m "This commit should fail" 2>&1 | assertPattern "$CREDENTIALS_FOUND"
}

test_the_script_displays_an_alert_when_an_aws_secret_is_added_to_an_existing_file()
{
    echo "# No secrets in here" > $WORKING_DIR/existing.conf
    git add -A
    git commit -m "Preliminary commit"

    echo 'foo.aws.secret="'$SAMPLE_AWS_SECRET'"' >> $WORKING_DIR/existing.conf   
    git add -A

    git commit -m "This commit should fail" 2>&1 | assertPattern "$CREDENTIALS_FOUND" 
}

test_the_script_does_not_alert_when_a_new_file_containing_no_aws_keys_are_committed()
{
    echo "# No secrets in here" > $WORKING_DIR/existing.conf
    git add -A

    message="This commit should succeed"
    git commit -m "$message" 2>&1 | assertPattern "$message"
}

test_findFilesChanged_returns_nothing_when_no_files_are_changed()
{
    findFilesChanged | (
        read files
        assertEquals "$files" ""
    )
}

test_findChanges_finds_key_surrounded_by_double_quotes()
{
    content='foo.aws.key="'$SAMPLE_AWS_KEY'"'
    echo "$content" > $WORKING_DIR/new.conf
    echo "$WORKING_DIR/new.conf" | findChanges | assertPattern "$content"
}

test_findChanges_finds_key_surrounded_by_single_quotes()
{
    content="foo.aws.key='$SAMPLE_AWS_KEY'"
    echo "$content" > $WORKING_DIR/new.conf
    echo "$WORKING_DIR/new.conf" | findChanges | assertPattern "$content"
}

test_findChanges_finds_key_surrounded_by_whitespace()
{
    content="foo.aws.key= $SAMPLE_AWS_KEY #comment to prevent whitespace collapse"
    echo "$content" > $WORKING_DIR/new.conf
    echo "$WORKING_DIR/new.conf" | findChanges | assertPattern "$content"
}

test_findChanges_finds_key_without_delimiter_at_end_of_line()
{
    content="foo.aws.key=$SAMPLE_AWS_KEY"
    echo "$content" > $WORKING_DIR/new.conf
    echo "$WORKING_DIR/new.conf" | findChanges | assertPattern "$content"
}

. shunit2

