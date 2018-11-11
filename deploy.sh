[[ $# -eq 2 ]] || {
	echo "Usage: $0 <address> <abiFile> < <evmas source>"
	exit 1
}

address="$1"
abiFile="$2"

./evmas | node deploy.js "$address" "$abiFile"
