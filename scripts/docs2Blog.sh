#!/bin/bash
#
# Use google docs and sheets to update a jekyll website and blog hosted on github pages
#
# Function for template option
template_func() {
    echo "Running template function"
    # Add your code for the template function here
}

# Function for ssh option
ssh_func() {
    echo "Running SSH function"
    # Add your code for the SSH function here
}

# Function for docId option
docId_func() {
    echo "Running docId function with argument: $1"
    # Add your code for the docId function here
}

# Function for all option
all_func() {
    echo "Running all function"
    # Add your code for the all function here
}

# Main script
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 [template|ssh|docId <argument>|all]"
    exit 1
fi

case $1 in
    "template")
        template_func
        ;;
    "ssh")
        ssh_func
        ;;
    "docId")
        if [[ $# -lt 2 ]]; then
            echo "Please provide an argument for docId option"
            exit 1
        fi
        docId_func "$2"
        ;;
    "all")
        all_func
        ;;
    *)
        echo "Invalid option"
        echo "Usage: $0 [template|ssh|docId <argument>|all]"
        exit 1
        ;;
esac