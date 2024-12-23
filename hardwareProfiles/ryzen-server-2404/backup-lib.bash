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
    exit 1
  fi

  if zfs list -H -t volume,fs -o name | grep -qxF "${target_volume}"; then
    target_snap=$(zfs list -H -t snapshot -o name "${target_volume}" | tail -n1)
    echo "latest in target: $target_snap"
    source_snap_name=${target_snap#"$target_volume"}
    target_snap_name=${target_snap#"$target_volume"}

    if [[ "$source_snap_name" == "$target_snap_name" ]]; then
      echo "Target already has up-to-date snapshot!"
      exit 0
    fi

    echo $ zfs send -RI "${target_snap_name}" "${source_snap}" \| zfs receive -Fvu "${target_volume}"
    zfs send -RI "${target_snap_name}" "${source_snap}" | zfs receive -Fvu "${target_volume}"
  else
    echo "Target volume doesn't exist! Creating from a full stream..."
    echo $ zfs send -R "${source_snap}" \| zfs receive -Fvu "${target_volume}"
    zfs send -R "${source_snap}" | zfs receive -Fvu "${target_volume}"
  fi
}
