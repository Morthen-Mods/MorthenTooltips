#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

destination_folder="./build"

# Find the first .properties file in the current directory (central metadata
# source; ${key} placeholders in the .toc files are resolved against it at
# build time, so the checked-in .toc files stay templates)
properties_file=$(find . -maxdepth 1 -name '*.properties' -type f | sort | head -n 1)
if [ -z "$properties_file" ]; then
    echo "Error: No .properties file found in the current directory. Task will be terminated." >&2
    exit 1
fi
echo "Found properties file: $(basename "$properties_file")"
echo "Reading metadata from '$(basename "$properties_file")'..."

declare -A props
while IFS='=' read -r key value || [ -n "$key" ]; do
    [ -z "$key" ] && continue
    [[ "$key" == \#* ]] && continue
    value="${value%$'\r'}"
    props["$key"]="$value"
done < "$properties_file"

substitute_placeholders() {
    local content="$1"
    local key
    for key in "${!props[@]}"; do
        content="${content//\$\{$key\}/${props[$key]}}"
    done
    printf '%s' "$content"
}

# Find the first .toc file in the current directory
toc_file=$(find . -maxdepth 1 -name '*.toc' -type f | sort | head -n 1)
if [ -z "$toc_file" ]; then
    echo "Error: No .toc file found in the current directory. Task will be terminated." >&2
    exit 1
fi
echo "Found TOC file: $(basename "$toc_file")"

resolved_toc=$(substitute_placeholders "$(cat "$toc_file")")

addon_name=$(grep -E '^[[:space:]]*##[[:space:]]*Title:' <<< "$resolved_toc" | head -n 1 | sed -E 's/^[^:]*:[[:space:]]*//; s/[[:space:]]+$//')
if [ -z "$addon_name" ]; then
    echo "Error: No '## Title:' found in .toc file. Cannot determine addon name. Task will be terminated." >&2
    exit 1
fi
echo "Addon name found: $addon_name"

# The archive filename is built from the .properties file's own 'title' and
# 'version' keys, independent of the (possibly differently formatted) values
# in the .toc file.
title="${props[title]:-}"
if [ -z "$title" ]; then
    echo "Error: No 'title' key found in '$(basename "$properties_file")'. Cannot determine archive name. Task will be terminated." >&2
    exit 1
fi

version="${props[version]:-}"
if [ -z "$version" ]; then
    echo "Error: No 'version' key found in '$(basename "$properties_file")'. Cannot determine archive name. Task will be terminated." >&2
    exit 1
fi
echo "Archive name: ${title}-${version}"

zip_file="$destination_folder/${title}-${version}.zip"
echo "ZIP archive name: '$zip_file'"

# Collect source files, excluding the build folder itself
mapfile -t source_files < <(find . -type f \
    \( -name '*.lua' -o -name '*.toc' -o -name '*.tga' -o -name '*.png' \) \
    -not -path './build/*')

# Reset the build folder
rm -rf "$destination_folder"
mkdir -p "$destination_folder"

target_root="$destination_folder/$addon_name"

echo "Copying files and preserving directory structure..."
for item in "${source_files[@]}"; do
    relative_path="${item#./}"
    destination_path="$target_root/$relative_path"
    mkdir -p "$(dirname "$destination_path")"
    if [[ "$item" == *.toc ]]; then
        substitute_placeholders "$(cat "$item")" > "$destination_path"
    else
        cp "$item" "$destination_path"
    fi
    echo "Copied '$relative_path'"
done

rm -f "$zip_file"

# Create the archive with the addon folder at its root
(cd "$destination_folder" && zip -r -q "${title}-${version}.zip" "$addon_name")

echo "Delete temporary data..."
rm -rf "$target_root"

echo "ZIP archive created: $zip_file"
