#!/usr/bin/bash

usage() {
	echo "That's not how you do it mate ..."
	echo "Example usage:"
	echo "\t./build.sh [cert|db|api|app|all] [k3s]"
}

build_images() {
	local component_dir="$1"
	local component_name="$2"
	local k3s_flag="$3"

	echo "Building: $component_name (at $component_dir)"
	docker build -t "$component_name" "$component_dir/."

	if [[ "$k3s_flag" == "k3s" ]]; then
		docker save "$component_name:latest" | k3s ctr images import -
	fi
}

process_components() {
	local component_type="$1"
	local k3s_flag="$2"

	for component in ../ync-${component_type}/*/; do
		build_images "$component" "$(basename "$component")" "$k3s_flag"
	done
}

main() {
	local target="$1"
	local k3s_flag="$2"

	if [[ "$target" == "all" ]]; then
		process_components "database" "$k3s_flag"
		process_components "api" "$k3s_flag"
		process_components "app" "$k3s_flag"
	elif [[ "$target" == "db" ]]; then
		process_components "database" "$k3s_flag"
	elif [[ "$target" == "api" ]]; then
		process_components "api" "$k3s_flag"
	elif [[ "$target" == "app" ]]; then
		process_components "app" "$k3s_flag"
	else
		usage
		exit 1
	fi
}

main "$@"