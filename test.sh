#!/bin/sh
# file: first-test.sh

. pre-commit &> /dev/null

ROOT=`pwd`
WORKING_DIR=$ROOT/foo
CREDENTIALS_FOUND="AWS credentials found. Aborting commit."
# THESE ARE NOT REAL AWS KEYS, OBVIOUSLY!
SAMPLE_AWS_KEY="ASIAJCKR244245IV4FHQ"
SAMPLE_AWS_SECRET="q6MVN9m0OSsNWUCWb5d7pnCjTEIHtiJT43SPk1Zy"
ANOTHER_SAMPLE_AWS_SECRET="q6MVN9m0OS/NWUCWb5d=pnCjTE9HtiJT43SPk1Zy"

setUp()
{
    mkdir $WORKING_DIR
    cd $WORKING_DIR
    git init &> /dev/null
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

assertEmpty()
{
    read actual
    assertNull "$actual"
}

test_the_script_does_not_alert_when_no_files_have_been_changed()
{
    git commit -m "No commit will happen" 2>&1 | assertPattern "On branch master"
}

test_the_script_displays_an_alert_when_a_new_file_containing_an_aws_key_is_committed()
{
    echo 'foo.aws.key="'$SAMPLE_AWS_KEY'"' > new.conf
    git add -A

    git commit -m "This commit should fail" 2>&1 | assertPattern "$CREDENTIALS_FOUND"
}

test_the_script_displays_an_alert_when_an_aws_key_is_added_to_an_existing_file()
{
    echo "# No secrets in here" > existing.conf
    git add -A
    git commit -m "Preliminary commit" &> /dev/null

    echo 'foo.aws.key="'$SAMPLE_AWS_KEY'"' >> existing.conf   
    git add -A

    git commit -m "This commit should fail" 2>&1 | assertPattern "$CREDENTIALS_FOUND"
}

test_the_script_does_not_alert_when_a_new_file_containing_no_aws_keys_are_committed()
{
    echo "# No secrets in here" > existing.conf
    git add -A

    message="This commit should succeed"
    git commit -m "$message" 2>&1 | assertPattern "$message"
}

test_findFilesChanged_returns_nothing_when_no_files_are_changed()
{
    findFilesChanged | assertEmpty
}

test_findFilesChanged_finds_a_new_file()
{
    echo "# I am a new file" > new.conf
    git add -A
    findFilesChanged | assertPattern "new.conf"
}

test_findFilesChanged_finds_more_than_one_file()
{
    echo "# I am a new file" > new.conf
    git add -A
    git commit -m "Preliminary commit" &> /dev/null
    echo "# I now have some changes" >> new.conf
    echo "# I am a new file" > new2.conf
    git add -A

    findFilesChanged | assertPattern "new.conf new2.conf" 
}

test_findFilesChanged_finds_a_modified_file()
{
    echo "# I am an existing file" > existing.conf
    git add -A
    git commit -m "Preliminary commit" &> /dev/null

    echo "# I now have some changes" >> existing.conf
    git add -A
    findFilesChanged | assertPattern "existing.conf"
}

test_findChanges_finds_nothing_when_no_files_are_changed()
{
    echo "" | findChanges | assertEmpty
}

test_findChanges_finds_key_surrounded_by_double_quotes()
{
    content='foo.aws.key="'$SAMPLE_AWS_KEY'"'
    echo "$content" > new.conf
    echo "new.conf" | findChanges | assertPattern "$content"
}

test_findChanges_finds_key_surrounded_by_single_quotes()
{
    content="foo.aws.key='$SAMPLE_AWS_KEY'"
    echo "$content" > new.conf
    echo "new.conf" | findChanges | assertPattern "$content"
}

test_findChanges_finds_key_surrounded_by_whitespace()
{
    content="foo.aws.key= $SAMPLE_AWS_KEY #comment to prevent whitespace collapse"
    echo "$content" > new.conf
    echo "new.conf" | findChanges | assertPattern "$content"
}

test_findChanges_finds_key_in_undelimited_bash_format()
{
    content="foo.aws.key=$SAMPLE_AWS_KEY"
    echo "$content" > new.conf
    echo "new.conf" | findChanges | assertPattern "$content"
}

test_findChanges_finds_key_in_undelimited_yaml_format()
{
    content="foo.aws.key: $SAMPLE_AWS_KEY"
    echo "$content" > new.conf
    echo "new.conf" | findChanges | assertPattern "$content"
}

test_findChanges_finds_key_alone_on_line()
{
    content="$SAMPLE_AWS_KEY"
    echo "$content" > new.conf
    echo "new.conf" | findChanges | assertPattern "$content"
}

test_findChanges_finds_secret_surrounded_by_double_quotes()
{
    content='foo.aws.secret="'$SAMPLE_AWS_SECRET'"'
    echo "$content" > new.conf
    echo "new.conf" | findChanges | assertPattern "$content"
}

test_findChanges_finds_secret_surrounded_by_single_quotes()
{
    content="foo.aws.secret='$SAMPLE_AWS_SECRET'"
    echo "$content" > new.conf
    echo "new.conf" | findChanges | assertPattern "$content"
}

test_findChanges_finds_secret_surrounded_by_whitespace()
{
    content="foo.aws.secret= $SAMPLE_AWS_SECRET #comment to prevent whitespace collapse"
    echo "$content" > new.conf
    echo "new.conf" | findChanges | assertPattern "$content"
}

test_findChanges_finds_secret_in_undelimited_bash_format()
{
    content="foo.aws.secret=$SAMPLE_AWS_SECRET"
    echo "$content" > new.conf
    echo "new.conf" | findChanges | assertPattern "$content"
}

test_findChanges_finds_secret_in_undelimited_yaml_format()
{
    content="foo.aws.secret: $SAMPLE_AWS_SECRET"
    echo "$content" > new.conf
    echo "new.conf" | findChanges | assertPattern "$content"
}

test_findChanges_finds_secret_alone_on_line()
{
    content="$SAMPLE_AWS_SECRET"
    echo "$content" > new.conf
    echo "new.conf" | findChanges | assertPattern "$content"
}

test_findChanges_finds_secret_with_special_characters_surrounded_by_double_quotes()
{
    content='foo.aws.secret="'$ANOTHER_SAMPLE_AWS_SECRET'"'
    echo "$content" > new.conf
    echo "new.conf" | findChanges | assertPattern "$content"
}

test_findChanges_finds_secret_with_special_characters_surrounded_by_single_quotes()
{
    content="foo.aws.secret='$ANOTHER_SAMPLE_AWS_SECRET'"
    echo "$content" > new.conf
    echo "new.conf" | findChanges | assertPattern "$content"
}

test_findChanges_finds_secret_with_special_characters_surrounded_by_whitespace()
{
    content="foo.aws.secret= $ANOTHER_SAMPLE_AWS_SECRET #comment to prevent whitespace collapse"
    echo "$content" > new.conf
    echo "new.conf" | findChanges | assertPattern "$content"
}

test_findChanges_finds_secret_with_special_characters_in_undelimited_yaml_format()
{
    content="foo.aws.secret: $ANOTHER_SAMPLE_AWS_SECRET"
    echo "$content" > new.conf
    echo "new.conf" | findChanges | assertPattern "$content"
}

test_findChanges_finds_secret_with_special_characters_alone_on_line()
{
    content="$ANOTHER_SAMPLE_AWS_SECRET"
    echo "$content" > new.conf
    echo "new.conf" | findChanges | assertPattern "$content"
}

test_findChanges_finds_credential_in_second_file()
{
    echo "# Nothing to see here" > old.conf
    content="$SAMPLE_AWS_SECRET"
    echo "$content" > new.conf
    echo "old.conf new.conf" | findChanges | assertPattern "$content"
}

. shunit2
