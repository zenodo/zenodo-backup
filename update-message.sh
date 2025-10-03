#!/bin/bash
# Script to update the Zenodo backup page message

set -e

SITE_DIR="$(cd "$(dirname "$0")" && pwd)/site"
INDEX_FILE="$SITE_DIR/index.html"

# Check if index.html exists
if [ ! -f "$INDEX_FILE" ]; then
    echo "Error: $INDEX_FILE not found"
    exit 1
fi

# Function to show current message
show_current() {
    echo "Current message:"
    echo "================"
    sed -n '/<!-- MESSAGE_START -->/,/<!-- MESSAGE_END -->/p' "$INDEX_FILE" | \
        grep '<p class="lead"' | \
        sed 's/.*<p class="lead"[^>]*>//; s/<\/p>.*//'
}

# Function to set default message
set_default() {
    # Replace everything between MESSAGE_START and MESSAGE_END with default message
    awk '
    /<!-- MESSAGE_START -->/ { print; print "          <p class=\"lead\" align=\"left\">The site is experiencing unexpected problems. Our admins have been alerted, and are looking into the problem.</p>"; skip=1; next }
    /<!-- MESSAGE_END -->/ { skip=0 }
    !skip { print }
    ' "$INDEX_FILE" > "$INDEX_FILE.tmp" && mv "$INDEX_FILE.tmp" "$INDEX_FILE"

    echo "Set default message"
}

# Function to validate and format datetime
validate_datetime() {
    local datetime="$1"

    # Check if it matches YYYY-MM-DD HH:MM format
    if echo "$datetime" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}$'; then
        echo "${datetime} UTC:"
        return 0
    fi

    echo "Error: Invalid datetime format. Expected: YYYY-MM-DD HH:MM (in UTC)" >&2
    echo "Example: 2025-10-06 06:30" >&2
    return 1
}

# Function to set custom message
set_custom_message() {
    local datetime="$1"
    local message="$2"

    # Format the message with datetime if provided
    local formatted_msg
    if [ -n "$datetime" ]; then
        local validated_datetime
        validated_datetime=$(validate_datetime "$datetime") || exit 1
        formatted_msg="<strong>$validated_datetime</strong> $message"
    else
        formatted_msg="$message"
    fi

    # Replace everything between MESSAGE_START and MESSAGE_END with custom message
    awk -v msg="$formatted_msg" '
    /<!-- MESSAGE_START -->/ { print; print "          <p class=\"lead\" align=\"left\">" msg "</p>"; skip=1; next }
    /<!-- MESSAGE_END -->/ { skip=0 }
    !skip { print }
    ' "$INDEX_FILE" > "$INDEX_FILE.tmp" && mv "$INDEX_FILE.tmp" "$INDEX_FILE"

    echo "Set custom message"
}

# Main logic
case "${1:-}" in
    show)
        show_current
        ;;
    default)
        set_default
        show_current
        ;;
    set)
        if [ -z "$2" ]; then
            echo "Usage: $0 set <datetime> <message>"
            echo "       $0 set <message>  (without datetime)"
            echo ""
            echo "Datetime format: YYYY-MM-DD HH:MM (in UTC)"
            echo "Note: UTC will be automatically appended to the datetime"
            echo ""
            echo "Examples:"
            echo "  $0 set '2025-10-06 06:30' 'Zenodo will be unavailable for 1-2 minutes to perform an upgrade to our compute cluster.'"
            echo "  $0 set 'Zenodo is currently experiencing issues.'"
            exit 1
        fi

        # Check if we have a datetime (2 args) or just a message (1 arg)
        if [ -n "$3" ]; then
            # Two arguments: datetime and message
            set_custom_message "$2" "$3"
        else
            # One argument: just message
            set_custom_message "" "$2"
        fi
        show_current
        ;;
    *)
        echo "Usage: $0 {show|default|set <datetime> <message>}"
        echo ""
        echo "Commands:"
        echo "  show                      - Show current message"
        echo "  default                   - Reset to default message"
        echo "  set <datetime> <message>  - Set custom message with datetime (UTC)"
        echo "  set <message>             - Set custom message without datetime"
        echo ""
        echo "Examples:"
        echo "  $0 show"
        echo "  $0 default"
        echo "  $0 set '2025-10-06 06:30' 'Zenodo will be unavailable for 1-2 minutes.'"
        echo "  $0 set 'Zenodo is currently down.'"
        exit 1
        ;;
esac
