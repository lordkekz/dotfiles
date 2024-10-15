  echo "[MY GIT UPDATE] Fetching all remotes and pruning remote-tracking refs"
  git fap
  echo "[MY GIT UPDATE] Deleting merged local branches"
  BRANCH_CURRENT=$(git branch --no-color --show-current --format "%(refname:short)")
  git branch --no-color --list --format "%(refname:short)" --merged | while read -r p; do
    if [[ "$p" == "$BRANCH_CURRENT" ]]; then
            continue
    elif [[ "$p" == "main" || "$p" == "master" || "$p" == "trunk" ]]; then
      echo "[MY GIT UPDATE] Branch $p appears to be a default branch; skipping."
      continue
    else
      echo "[MY GIT UPDATE] Branch $p is merged; deleting."
      git branch -dv "$p"
    fi
  done
