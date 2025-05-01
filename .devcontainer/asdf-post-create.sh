#!/usr/bin/env bash

sudo chown vscode:vscode /home/vscode/.asdf/installs

# find all .tool-versions within the repo, but ignore all hidden directories
/bin/find /workspace -type d -path '*/.*' -prune -o -name '*.tool-version*' -print | while read filePath; do
  echo "asdf setup for $filePath"

  # install all required plugins
  cat $filePath | cut -d' ' -f1 | grep "^[^\#]" | xargs -i asdf plugin add {}

  # install all required versions
  (cd $(dirname $filePath) && asdf install)
done

asdf reshim