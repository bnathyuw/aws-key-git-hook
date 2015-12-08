#!/bin/sh
git config --global init.templatedir '~/.git-templates'
mkdir -p ~/.git-templates/hooks
wget https://raw.githubusercontent.com/bnathyuw/aws-key-git-hook/master/pre-commit -P ~/.git-templates/hooks/
chmod a+x ~/.git-templates/hooks/pre-commit
