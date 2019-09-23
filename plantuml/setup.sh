#!/usr/bin/env bash
set -ux

echo "[INFO] Setup plantuml"

case "${os}" in
"Darwin")
	brew cask install java
	brew install plantuml
	;;
"CentOS")
	echo "To be implemented.."
	;;
esac
