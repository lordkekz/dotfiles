REMOTE=${1:-origin}
echo "[MY GIT UPDATE] Operating with remote: $REMOTE"

echo "[MY GIT UPDATE] Fetching all remotes and pruning remote-tracking refs..."
git fap "$REMOTE"

BRANCH_CURRENT=$(git branch --no-color --show-current --format "%(refname:short)")
echo "[MY GIT UPDATE] Fast-forwarding branches with remote-tracking refs..."
git branch --no-color --list --format "%(refname:short)" | while read -r p; do
  if [[ "$p" == "$BRANCH_CURRENT" ]]; then
    # Current branch needs special case because fetch refuses to touch it
    (git -c advice.diverging=false pull --quiet --ff-only "$REMOTE" 2>&1 \
    || echo "[MY GIT UPDATE]     Can't fast-forward branch $p") | tail -n +2
  else
    (git -c advice.diverging=false fetch --quiet "$REMOTE" "$p:$p" 2>&1 \
    || echo "[MY GIT UPDATE]     Can't fast-forward branch $p") | tail -n +2
  fi
done

echo "[MY GIT UPDATE] Deleting merged local branches..."
git branch --no-color --list --format "%(refname:short)" --merged | while read -r p; do
  if [[ "$p" == "$BRANCH_CURRENT" ]]; then
    continue
  elif [[ "$p" == "main" || "$p" == "master" || "$p" == "trunk" ]]; then
    echo "[MY GIT UPDATE] Branch $p appears to be a default branch; skipping..."
    continue
  else
    echo "[MY GIT UPDATE] Branch $p is merged; deleting..."
    git branch -dv "$p" || continue
  fi
done

echo "[MY GIT UPDATE] Done!"
