#!/bin/sh -e

# List of modules to load
modules=/etc/modules

# Silently exit if the kernel does not support modules.
[ -f /proc/modules ] || exit 0
[ -x /sbin/modprobe  ] || exit 0

case "$1" in
  start)
  echo "Loading modules..."
  grep -h '^[^#]' $modules |
  while read module args; do
    [ "$module" ] || continue
    modprobe $module $args || true
    echo "Module $module loaded"
  done
  ;;

  stop|restart|reload|force-reload)
  echo "Action '$1' is meaningless for this init script"
  exit 0
  ;;

  *)
  echo "Usage: $0 start"
  exit 1
esac
