## DONE
- Intercepts commit when an AWS key is present in the staged files
- Intercepts commit when an AWS secret is present in the staged files
- Does not intercept commit when no key or secret is present in the staged files
- Matches keys and secrets in newly added files
- Matches keys and secrets in edited files
- Matches keys and secrets at the end of a line
- Matches keys and secrets enclosed in single quotes
- Matches keys and secrets enclosed in double quotes
- Matches keys and secrets surrounded by whitespace
- Doesn't complain when no files have been staged 
- Can handle several staged files
- Displays to the user a single key found
- Displays to the user a single secret found
- Displays to the user multiple keys and secrets found
- Works on master
- Works on a branch
- Works with Git Gui

## TO DO
- Doesn't match strings of characters of not quite the right length
- Only search lines that have changed. (At the moment it will spot pre-existing credentials in a file you have changed.)
