#!/bin/sh

# Input files
PATCH_FILE="$1"
TARGET_FILE="${2:-/mnt/SDCARD/RetroArch/retroarch.cfg}"


# Check if the files exist
for file in "$PATCH_FILE" "$TARGET_FILE"; do
    if [ ! -f "$file" ]; then
        echo "$file doesn't exist"
        exit 1
    fi
done

# Ensure the patch file ends with a newline
if [ "$(tail -c1 "$PATCH_FILE")" != "" ]; then
    echo >> "$patch"
fi

# Function to escape special characters for sed
escape_sed() {
    echo "$1" | sed -e 's/[&/|]/\\&/g'
}


# Apply patch modifications to the configuration file
count=0

# Read each key/value pair from the patch.cfg file
while IFS='=' read -r key patch_value; do
    # Skip empty lines or comments
    [ -z "$key" ] && continue
    Fulline="$key=$patch_value"
    key=$(echo "$key" | sed 's/^ *//;s/ *$//')
    patch_value=$(echo "$patch_value" | sed 's/^ *//;s/ *$//')
	# patch_value==$(escape_sed "$patch_value")

    # Escape the key for grep and sed
    escaped_key=$(escape_sed "$key")

    # Check if the key already exists in the target file
    line=$(grep "^$escaped_key[ ]*=" "$TARGET_FILE")
    if [ -n "$line" ]; then
        # Preserve spaces around the `=` and quotes if present
        case "$line" in *' ='*) spaces_before_equals=" " ;; *) spaces_before_equals="" ;; esac
        case "$line" in *'= '*) spaces_after_equals=" " ;; *) spaces_after_equals="" ;; esac

        case "$line" in
        *'"'*)
            # Syntax with quotes
            formatted_value="$patch_value"
            ;;
        *)
            # Syntax without quotes
            formatted_value=$(echo "$patch_value" | sed 's/^\"//;s/\"$//')
            ;;
        esac

        # Replace in the target file with the preserved syntax
sed -i "s|^$escaped_key[ ]*=.*|$key$spaces_before_equals=$spaces_after_equals$formatted_value|" "$TARGET_FILE"
    else
        line=$(grep -m1 '=' "$TARGET_FILE")
        if [ -n "$line" ]; then
        # If the key is not found, take a random line containing an `=`

        # Preserve spaces around the `=` and quotes if present
        case "$line" in *' ='*) spaces_before_equals=" " ;; *) spaces_before_equals="" ;; esac
        case "$line" in *'= '*) spaces_after_equals=" " ;; *) spaces_after_equals="" ;; esac

        case "$line" in
        *'"'*)
            # Syntax with quotes
            formatted_value="$patch_value"
            ;;
        *)
            # Syntax without quotes
            formatted_value=$(echo "$patch_value" | sed 's/^\"//;s/\"$//')
			formatted_value="$patch_value"
            ;;
        esac

        # Add the key/value with the format found
        echo "$key$spaces_before_equals=$spaces_after_equals$formatted_value" >> "$TARGET_FILE"
    else
        # If no line contains a `=`, add a new line with the default format
        echo "$Fulline" >> "$TARGET_FILE"
    fi
    fi
	count=$((count + 1))
done < "$PATCH_FILE"

echo "$count lines patched for $(basename "$(dirname "$TARGET_FILE")")/$(basename "$TARGET_FILE")"

# [ "$1" != "-d" ] && rm "$PATCH_FILE"
sync 