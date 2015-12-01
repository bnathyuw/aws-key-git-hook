## DONE
- Intercepts commit when an AWS key is present in the staged files
- Does not intercept commit when no key or secret is present in the staged files

## TO DO

- Intercepts commit when an AWS secret is present in the staged files
- Matches keys and secrets in newly added files
- Matches keys and secrets in edited files
- Matches keys and secrets at the end of a line
- Matches keys and secrets enclosed in single quotes
- Matches keys and secrets enclosed in double quotes
- Matches keys and secrets surrounded by whitespace
- Displays to the user a single key found
- Displays to the user a single secret found
- Displays to the user multiple keys and secrets found
- Prompts for confirmation: ‘Do you want to commit anyway? (y/N)’
- Does not commit when user types n
- Does not commit when user hits return
- Commits changes when user types y
- Asks again when user types anything else
- Works on master
- Works on a branch

