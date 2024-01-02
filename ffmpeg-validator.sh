#!/bin/bash

inputDirectory="./"           # Set the path to the input directory containing video files (current directory)
validFilesDirectory="./valid_files"    # Set the path to the directory where valid files will be moved (current directory)
invalidFilesDirectory="./invalid_files"    # Set the path to the directory where invalid files will be moved (current directory)
errorLog="error.log"          # Set the error log file name

# Create output directories if they don't exist
mkdir -p "$validFilesDirectory"
mkdir -p "$invalidFilesDirectory"

echo "Starting validation..."

# Loop through all video files in the input directory
for inputFile in "$inputDirectory"/*.mkv; do
    # Extract the file name without extension
    fileName=$(basename -- "$inputFile")
    fileNameNoExt="${fileName%.*}"

    # Specify the output file for the null format
    nullOutput="$validFilesDirectory/$fileName"

    echo "Processing $fileName..."

    # Run ffmpeg to check for errors and create the null output
    ffmpeg -v error -i "$inputFile" -f null - 2>"$inputDirectory/$fileNameNoExt-$errorLog"

    # Check the exit code of ffmpeg
    exitCode=$?

    if [ $exitCode -eq 0 ]; then
        # Move valid .mkv files to the validFilesDirectory
        mv "$inputFile" "$validFilesDirectory/"
        echo "Validation successful for $fileName. No errors detected. File moved to $validFilesDirectory."
    else
        # Move invalid .mkv files to the invalidFilesDirectory
        mv "$inputFile" "$invalidFilesDirectory/"
        echo "Validation failed for $fileName. Check $inputDirectory/$fileNameNoExt-$errorLog for details. File moved to $invalidFilesDirectory."
    fi
done

echo "Validation complete. Check $validFilesDirectory and $invalidFilesDirectory for results."
