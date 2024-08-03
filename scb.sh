#!/bin/bash

# Default values
url=""
wordlist=""
header=""
prefix=""
suffix=""
output_file="output.txt"

# Function to display usage information
usage() {
    echo "Usage: $0 --url <url> --wordlist <wordlist> [--header <header>] [--prefix <prefix>] [--suffix <suffix>]"
    echo "  --url      : The target URL to enumerate"
    echo "  --wordlist : Path to the wordlist file"
    echo "  --header   : Optional header to include in the request"
    echo "  --prefix   : Optional prefix to add before each word"
    echo "  --suffix   : Optional suffix to add after each word"
    exit 1
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --url) url="$2"; shift ;;
        --wordlist) wordlist="$2"; shift ;;
        --header) header="$2"; shift ;;
        --prefix) prefix="$2"; shift ;;
        --suffix) suffix="$2"; shift ;;
        *) echo "Unknown parameter: $1"; usage ;;
    esac
    shift
done

# Check if required parameters are provided
if [[ -z "$url" || -z "$wordlist" ]]; then
    echo "Error: URL and wordlist are required parameters."
    usage
fi

# Check if wordlist file exists
if [[ ! -f "$wordlist" ]]; then
    echo "Error: Wordlist file not found: $wordlist"
    usage
    exit 1
fi

# Function to send POST request
send_request() {
    local word="$1"
    local payload="${prefix}${word}${suffix}"
    
    curl -s -X POST "$url" -H "$header" -d "$payload"
}

# Main loop to process each word in the wordlist
while IFS= read -r word; do
    echo "Processing: $word"
    response=$(send_request "$word")
    echo "$response\n\n" >> $output_file
done < "$wordlist"

echo "Done! Output saved ot $output_file"
