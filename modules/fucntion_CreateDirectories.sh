# This function takes one or more directory paths as arguments
# For each directory, it checks if it exists. If it does, it informs the user.
# Otherwise, it attempts to create the directory.
create_directories() {
    for dir in "$@"; do
        if [ -d "$dir" ]; then
            echo "Directory $dir already exists."
        else
            mkdir -p "$dir"
            if [ $? -eq 0 ]; then
                echo "Directory $dir created successfully."
            else
                echo "Failed to create directory $dir."
            fi
        fi
    done
}

# Example usage:
# create_directories "$DIR_ONE" "$DIR_TWO" "$DIR_THREE"
