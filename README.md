# AWS Key Git Hook

## Purpose

The purpose of this project is to create a well tested git pre-commit hook to spot AWS keys and secrets in git commits and check with the committer that they are indeed meant to be there.

## Installation

You will need (shunit2)[https://github.com/kward/shunit2]. Clone this project and add shunit2/source/2.1/src/ to your `PATH` variable.

## Running the Tests

From the root of this project, run `./first-test.sh`
