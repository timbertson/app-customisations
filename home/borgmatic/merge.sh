#!bash -eux

gup -u common.yaml
gup -u "part-$2"
cat common.yaml "part-$2" > "$1"
