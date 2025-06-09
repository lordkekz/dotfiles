create_recursive_snapshot() {
  source=$1
  new_snap_name=$2
  echo $ zfs snapshot -r "${source}@${new_snap_name}"
  zfs snapshot -r "${source}@${new_snap_name}"
}

destroy_unwanted_snapshot() {
  excluded_dataset=$1
  new_snap_name=$2
  echo $ zfs destroy "${excluded_dataset}@${new_snap_name}"
  zfs destroy "${excluded_dataset}@${new_snap_name}"
}

# Transfer snapshots of volumes to backup pool
backup_volume() {
  source=$1
  target=$2
  volume_name=$3
  echo "### backup_volume of $volume_name from $source to $target ###"
  source_volume=${source}/${volume_name}
  target_volume=${target}/${volume_name}
  source_snap=$(zfs list -H -t snapshot -o name "${source_volume}" | tail -n1)
  echo "latest in source: $source_snap"
  if [[ -z "$source_snap" ]]; then
    echo "WTF: source with no snap"
    return 1
  fi

  if zfs list -H -t volume,fs -o name | grep -qxF "${target_volume}"; then
    target_snap=$(zfs list -H -t snapshot -o name "${target_volume}" | tail -n1)
    echo "latest in target: $target_snap"
    source_snap_name=${source_snap#"$source_volume"}
    target_snap_name=${target_snap#"$target_volume"}

    if [[ "$source_snap_name" == "$target_snap_name" ]]; then
      echo "Target already has up-to-date snapshot!"
      return 0
    fi

    echo $ zfs send -RI "${target_snap_name}" "${source_snap}" \| zfs receive -Fvu "${target_volume}"
    zfs send -RI "${target_snap_name}" "${source_snap}" | zfs receive -Fvu "${target_volume}"
  else
    echo "Target volume doesn't exist! Creating from a full stream..."
    echo $ zfs send -R "${source_snap}" \| zfs receive -Fvu "${target_volume}"
    zfs send -R "${source_snap}" | zfs receive -Fvu "${target_volume}"
  fi
}

prune_automatic_snapshots() {
  pool_name=$1
  max_age_days=$2

  # Get the current date in seconds since epoch
  current_date=$(date +%s)

  # Loop through each snapshot of a dataset starting with $pool_name and containing "autobackup"
  for snapshot in $(zfs list -t snapshot -H -o name | grep -P "^$pool_name(/[^@]+)?@\d{4}-\d{2}-\d{2}-\d{4}-autobackup\$"); do
    # Extract the date from the snapshot name (format: YYYY-MM-DD)
    snapshot_datetime=$(echo "$snapshot" | grep -oP '\d{4}-\d{2}-\d{2}-\d{4}')

    # Convert the snapshot date to seconds since epoch
    # date = first 10 characters; time = last 4 characters
    snapshot_epoch=$(date -d "${snapshot_datetime:0:10} ${snapshot_datetime:11:4}" +%s)

    # Calculate the age of the snapshot in days
    age_days=$(( (current_date - snapshot_epoch) / 86400 ))

    # Check if the snapshot is older than 4 days
    if [ $age_days -gt "$max_age_days" ]; then
      echo "DROP snapshot: $snapshot"
      zfs destroy "$snapshot"
    # else
      # echo "KEEP snapshot: $snapshot"
    fi
  done
}
