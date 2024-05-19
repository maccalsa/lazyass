#!/bin/bash

echo "WARNING: This script will modify files and directories based on your input."
read -p "Enter the root directory for operations: " root_dir

# Ensure the directory exists
if [ ! -d "$root_dir" ]; then
    echo "The specified directory does not exist."
    exit 1
fi

# Choose the operation
echo "Select the operation to perform:"
echo "1) Delete directories by exact name"
echo "2) Delete directories by glob pattern"
echo "3) Delete files by exact name"
echo "4) Delete files by glob pattern"
echo "5) Append text to files by exact name"
echo "6) Replace text in files using a regex"
read -p "Enter your choice (1-6): " operation

case $operation in
    1|2|3|4)
        if [[ $operation == 1 ]] || [[ $operation == 3 ]]; then
            read -p "Enter the exact name to match: " name
            match_type="-name"
        else
            read -p "Enter the glob pattern to match: " name
            match_type="-iname"
        fi

        if [[ $operation == 1 ]] || [[ $operation == 2 ]]; then
            target_type="d"
        else
            target_type="f"
        fi

        # Preview
        echo "Matching items:"
        find "$root_dir" $match_type "$name" -type $target_type
        read -p "Confirm deletion of these items? (y/n): " confirm
        if [[ $confirm == "y" ]]; then
            find "$root_dir" $match_type "$name" -type $target_type -exec rm -rv {} +
        else
            echo "Operation cancelled."
        fi
        ;;

    5)
        read -p "Enter the exact filename to append text: " filename
        read -p "Enter the text to append: " text_to_append
        # Preview
        echo "Files to append text to:"
        find "$root_dir" -type f -name "$filename"
        read -p "Confirm appending text to these files? (y/n): " confirm
        if [[ $confirm == "y" ]]; then
            find "$root_dir" -type f -name "$filename" -exec sh -c "echo \"$text_to_append\" >> {}" \;
        else
            echo "Operation cancelled."
        fi
        ;;

    6)
        read -p "Enter the glob pattern for files to replace text: " pattern
        read -p "Enter the regular expression to find: " regex_find
        read -p "Enter the replacement text: " regex_replace
        # Preview
        echo "Files to replace text in:"
        find "$root_dir" -type f -iname "$pattern"
        read -p "Confirm replacement in these files? (y/n): " confirm
        if [[ $confirm == "y" ]]; then
            find "$root_dir" -type f -iname "$pattern" -exec sed -i "s/$regex_find/$regex_replace/g" {} +
        else
            echo "Operation cancelled."
        fi
        ;;
    *)
        echo "Invalid option selected."
        ;;
esac
