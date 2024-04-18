#!/bin/bash

# Set the path to ABQLauncher
abaqus_path="/home/abaqus/SIMULIA/CAE/2018/linux_a64/code/bin/ABQLauncher"


# Function to print a fancy border with a message inside a rectangle
print_border() {
    local msg="$1"
    local msg_len="${#msg}"
    local total_len=$((msg_len + 6))
    local top_bottom="$(printf "%${total_len}s" | tr ' ' '-')"
    local sides="$(printf "* %s *" "$msg")"
    echo ""
    echo "$(tput setaf 4)$top_bottom"
    echo "$(tput setaf 4)$sides$(tput sgr0)"
    echo "$(tput setaf 4)$top_bottom$(tput sgr0)"
    echo ""
}



# Get the list of .inp files in the current directory
files=$(find . -maxdepth 1 -type f -name "*.inp" -exec basename {} \;)
# Check if the current directory has *inp files
if [ -z "$files" ]; then
    echo "No .inp files found in the current directory. Exiting!..."
    exit 1
fi

# Print the input files found
echo "The following .inp files were found in the current directory"
for file in $files; do
    printf "\t%s\n" "$file"
done

# Prompt user for confirmation before running the loop
read -p "Do you want to continue? (y/n) " choice
if [[ ! $choice =~ ^[Yy]$ ]]; then
    exit 0
fi

# Loop over every .inp file in the current directory
for filename in "${files[@]}"
do
    # Display a fancy border with a message before starting job
    print_border "Starting abaqus for $filename"

    # Remove file extension from filename
    basename="${filename%.*}"
    
    # Run the command for the current filename and wait for it to finish
    "$abaqus_path" job="$basename" int cpus=64
    
    # Display a fancy border with a message after the job finishes
    print_border "Finished running abaqus for $filename"
done


# Check if the user wants to move the files to their respective directories
read -p "Do you want to move the files to their respective directories? (y/n) " move_files_choice
if [[ $move_files_choice =~ ^[Yy]$ ]]; then
    # Loop over every .inp file in the current directory
    for filename in "${files[@]}"
    do
        # Remove file extension from filename
        basename="${filename%.*}"
	
	if [ -z "$basename" ]; then
    		echo "No files were processed."
	else
		# create a directory with same name
		mkdir -p "$basename"
		# Loop over every file with the same name as the processed .inp file
		# in the current directory
		for file in "${basename}"*
		do
		    if [ -f "$file" ]; then

			# Move the output files to their respective directories
			mv "${file}" "${basename}/" -v

		    fi
		done
		
		echo "	Done moving files of Job ${filename%.*} to directory ${basename}/"
	fi
    done
echo "Done Executing Script"
fi
