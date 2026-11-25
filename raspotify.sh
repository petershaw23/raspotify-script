#!/usr/bin/env bash

# Host-Definitionen
declare -A HOSTS=(
  [denon]="root@10.0.0.xy"
  [waveshare]="pi@10.0.0.xx"
)
declare -A PORTS=(
  [denon]="2223"
  [waveshare]="2223"
)
declare -A PASSES=(
  [denon]="passwort"
  [waveshare]="passwort"   # anpassen, falls das Passwort ein anderes ist
)
SERVICE="raspotify"

run() {
  local name="$1" cmd="$2"
  echo "[$name]"
  sshpass -p "${PASSES[$name]}" ssh -p "${PORTS[$name]}" -o ConnectTimeout=5 -o StrictHostKeyChecking=accept-new "${HOSTS[$name]}" "$cmd"
}

usage() {
  echo "Benutzung: $0 {denon|waveshare|all} {start|stop|restart|status|update|version}"
  exit 1
}

TARGET="$1"
ACTION="$2"

[ -z "$TARGET" ] || [ -z "$ACTION" ] && usage

if [ "$TARGET" = "all" ]; then
  TARGETS=("${!HOSTS[@]}")
elif [ -n "${HOSTS[$TARGET]}" ]; then
  TARGETS=("$TARGET")
else
  usage
fi

case "$ACTION" in
  start|stop|restart|status)
    CMD="systemctl $ACTION $SERVICE"
    ;;
  update)
    CMD="apt-get update && apt-get install --only-upgrade -y -o Dpkg::Options::=--force-confold $SERVICE && systemctl restart $SERVICE"
    ;;
  version)
    CMD="dpkg -s $SERVICE | grep -E '^(Package|Version)'"
    ;;
  *)
    usage
    ;;
esac

for t in "${TARGETS[@]}"; do
  run "$t" "$CMD"
done
