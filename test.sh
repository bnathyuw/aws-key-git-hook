#!/bin/sh
# file: first-test.sh

. pre-commit &> /dev/null

ROOT=`pwd`
WORKING_DIR=$ROOT/foo
CREDENTIALS_FOUND="AWS credentials found"
# THESE ARE NOT REAL AWS KEYS, OBVIOUSLY!
SAMPLE_AWS_KEY="ASIAJCKR244245IV4FHQ"
SAMPLE_AWS_SECRET="q6MVN9m0OS/NWUCWb5d=pnCjTE9HtiJT43SPk1Zy"

setUp()
{
    mkdir $WORKING_DIR
    cd $WORKING_DIR
    git init &> /dev/null
    git config user.name "AWS Key Git Hook Test"
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

test_the_script_catches_a_credential_in_a_new_file()
{
    echo 'foo.aws.key="'$SAMPLE_AWS_KEY'"' > new.conf
    git add -A

    git commit -m "This commit should fail" 2>&1 | assertPattern "$CREDENTIALS_FOUND"
}

test_the_script_catches_a_credential_in_a_modified_file()
{
    echo "# No secrets in here" > existing.conf
    git add -A
    git commit -m "Preliminary commit" &> /dev/null

    echo 'foo.aws.key="'$SAMPLE_AWS_KEY'"' >> existing.conf   
    git add -A

    git commit -m "This commit should fail" 2>&1 | assertPattern "$CREDENTIALS_FOUND"
}

test_the_script_does_not_prevent_commits_without_credentials()
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

test_findChanges_finds_secret_in_undelimited_bash_format()
{
    content="foo.aws.secret=$SAMPLE_AWS_SECRET"
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

test_findChanges_finds_credential_in_second_file()
{
    echo "# Nothing to see here" > old.conf
    content="$SAMPLE_AWS_SECRET"
    echo "$content" > new.conf
    echo "old.conf new.conf" | findChanges | assertPattern "$content"
}

test_findChanges_outputs_name_of_file_in_which_credential_was_found()
{
    echo "# Nothing to see here" > old.conf
    content="$SAMPLE_AWS_SECRET"
    echo "$content" > new.conf
    echo "old.conf new.conf" | findChanges | assertPattern "new.conf"
}

test_report_is_empty_when_no_credentials_are_found()
{
    echo "" | report | assertEmpty
}

test_report_exits_with_zero_when_no_credentials_are_found()
{
    echo "" | report
    assertEquals 0 $?
}

test_report_exits_non_zero_when_credentials_are_found()
{
    echo "one" | report &> /dev/null
    assertNotEquals 0 $?
}

test_report_shows_all_credentials()
{
    MATCHES="one\ntwo\nthree\nfour\nfive"
    echo $MATCHES | report | tr '\n' ' ' | assertPattern "one two three four five"
}

test_confirmAction_does_nothing_with_a_zero_exit_code()
{
    confirmAction 0
    assertEquals 0 $?
}

test_confirmAction_exits_with_zero_when_the_answer_is_y()
{
    echo "y" | confirmAction 1 &> /dev/null
    assertEquals 0 $?
}

test_confirmAction_exits_with_zero_when_the_answer_is_Y()
{
    echo "Y" | confirmAction 1 &> /dev/null
    assertEquals 0 $?
}

test_confirmAction_exits_with_one_when_the_answer_is_n()
{
    echo "n" | confirmAction 1 &> /dev/null
    assertEquals 1 $?
}

test_confirmAction_exits_with_one_when_the_answer_is_N()
{
    echo "N" | confirmAction 1 &> /dev/null
    assertEquals 1 $?
}

test_confirmAction_exits_with_one_when_the_default_answer_is_given()
{
    echo "" | confirmAction 1 &> /dev/null
    assertEquals 1 $?
}

test_confirmAction_asks_again_if_it_gets_unknown_input()
{
    (
        echo "b"
        echo "n"
    ) | confirmAction 1 &> /dev/null
    assertEquals 1 $?
}

test_confirmAction_asks_many_times_till_it_gets_a_valid_answer()
{
    (
        echo "b"
        echo "b"
        echo "b"
        echo "b"
        echo "b"
        echo "b"
        echo "y"
    ) | confirmAction 1 &> /dev/null
    assertEquals 0 $?
}

. shunit2
