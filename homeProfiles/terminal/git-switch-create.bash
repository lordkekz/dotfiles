if (git rev-parse "$1" -- >/dev/null 2>&1); then
  git switch "$1"
else
  git switch -c "$1"
fi
