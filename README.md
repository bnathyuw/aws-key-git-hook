# AWS Key Git Hook

## Purpose

The purpose of this project is to create a well tested git pre-commit hook to spot AWS keys and secrets in git commits and check with the committer that they are indeed meant to be there.

## Installing the Hook

Run `instal.sh` to instal this as a global pre-commit hook.

Execute `git init` in an existing repository to add this hook.

Note that if you already have a pre-commit hook installed, this will not work; you will have to do something cleverer.

## Working on this Project

You will need [shunit2](https://github.com/kward/shunit2). Clone this project and add `{cloneLocation}/shunit2/source/2.1/src/` to your `PATH` variable.

## Running the Tests

From the root of this project, run `./first-test.sh`

## Acknowledgements

Many thanks to [Aniket Panse](https://gist.github.com/czardoz) who created [this pre-commit hook](https://gist.github.com/czardoz/b8bb58ad10f4063209bd), which acted as my starting point.
Also to [Matt Venables](https://coderwall.com/venables) whose instructions on [creating a global git commit hook](https://coderwall.com/p/jp7d5q/create-a-global-git-commit-hook) are the basis of the installation instructions.
