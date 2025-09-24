#!/bin/bash

# Local GitHub Actions Workflow Tester
# Usage: ./test-workflow-local.sh <event-file>
# Example: ./test-workflow-local.sh .github/test-event-dev-stg.json

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Default event file
EVENT_FILE="${1:-.github/test-event-dev-stg.json}"
FILTERS_FILE=".github/file-filters.yml"

echo -e "${GREEN}=== GitHub Actions Workflow Local Tester ===${NC}"
echo

# Check if files exist
if [[ ! -f "$EVENT_FILE" ]]; then
    echo -e "${RED}Error: Event file '$EVENT_FILE' not found!${NC}"
    echo "Usage: $0 <event-file>"
    exit 1
fi

if [[ ! -f "$FILTERS_FILE" ]]; then
    echo -e "${RED}Error: Filters file '$FILTERS_FILE' not found!${NC}"
    exit 1
fi

echo -e "${YELLOW}1. Loading test event data from: $EVENT_FILE${NC}"

# Extract changed files from JSON
changed_files=$(jq -r '.commits[]? | (.added[]?, .modified[]?) | select(. != null and . != "")' "$EVENT_FILE" 2>/dev/null || echo "")

if [[ -z "$changed_files" ]]; then
    echo -e "${RED}No changed files found in event data${NC}"
    exit 1
fi

echo -e "${BLUE}   Changed files:${NC}"
echo "$changed_files" | while read -r file; do
    echo "     - $file"
done

echo
echo -e "${YELLOW}2. Loading filter patterns from: $FILTERS_FILE${NC}"

# Process filters and match files
matches=()
while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    
    # Read filter patterns and match
    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$line" ]] && continue
        
        # Extract filter name (before colon)
        if [[ "$line" =~ ^([^:]+): ]]; then
            filter_name="${BASH_REMATCH[1]}"
        fi
        
        # Extract pattern (lines starting with -)
        if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*[\'\"]*([^\'\"]*)[\'\"]* ]]; then
            pattern="${BASH_REMATCH[1]}"
            
            # Convert pattern to bash glob (remove ** and quotes)
            bash_pattern=$(echo "$pattern" | sed 's|\*\*/\*|*|g' | sed "s/['\"]//g")
            
            # Check if file matches pattern
            if [[ "$file" == $bash_pattern ]]; then
                echo -e "${CYAN}     ✓ File '$file' matches filter '$filter_name'${NC}"
                
                # Add to matches if not already present
                if [[ ! " ${matches[*]} " =~ " ${filter_name} " ]]; then
                    matches+=("$filter_name")
                fi
                break
            fi
        fi
    done < "$FILTERS_FILE"
done <<< "$changed_files"

echo
echo -e "${YELLOW}3. Filter matches found:${NC}"
if [[ ${#matches[@]} -eq 0 ]]; then
    echo -e "${RED}   No matches found${NC}"
    exit 0
fi

for match in "${matches[@]}"; do
    echo -e "${GREEN}     - $match${NC}"
done

# Convert to JSON array
changes_json="["
for i in "${!matches[@]}"; do
    if [[ $i -gt 0 ]]; then
        changes_json+=", "
    fi
    changes_json+="\"${matches[i]}\""
done
changes_json+="]"

echo
echo -e "${YELLOW}4. GitHub Actions outputs:${NC}"
echo -e "${CYAN}   changes: $changes_json${NC}"

# Extract unique environments
envs=($(printf '%s\n' "${matches[@]}" | cut -d'/' -f1 | sort -u))
envs_csv=$(IFS=,; echo "${envs[*]}")
echo -e "${CYAN}   envs: $envs_csv${NC}"

# Extract unique services
services=($(printf '%s\n' "${matches[@]}" | cut -d'/' -f2 | sort -u))
services_csv=$(IFS=,; echo "${services[*]}")
echo -e "${CYAN}   services: $services_csv${NC}"

echo
echo -e "${YELLOW}5. Deployment plan:${NC}"
for env in "${envs[@]}"; do
    for service in "${services[@]}"; do
        echo -e "${MAGENTA}   → Deploy $service to $env environment${NC}"
    done
done

echo
echo -e "${GREEN}=== Test Complete ===${NC}"