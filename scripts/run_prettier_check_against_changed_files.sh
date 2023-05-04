#!/bin/bash

# Define constants;
baseRef=$1 #Mandatory parameter!
buildFolderName="./build"
srcFolderName="src"
srcFolderPath="$buildFolderName/$srcFolderName"
srcFilePrefix="$srcFolderName/"
changedFiles="changedFiles.txt"
changedFilesPath="$buildFolderName/$changedFiles"

printf "\n baseRef is [$baseRef] \n"

# Create 'build' folder;
mkdir -p "$buildFolderName"
# Create 'build/src' folder;
mkdir -p "$srcFolderPath"

# Grab HEAD commit SHA from source branch;
BASE=$(git merge-base $baseRef HEAD)

printf "\n BASE commit in [$baseRef] is [$BASE] \n"

# Extract changed files and save those names into the text file;
touch "$changedFilesPath"
git diff --name-only $BASE HEAD > "$changedFilesPath"

# Quick overview of changed files;
printf "\n <----- CHANGED FILES -----> \n"
cat "$changedFilesPath"

# Copy each SRC-changed file into a separate folder preserving folders hierarchy;
grep "$srcFilePrefix" "$changedFilesPath" | while read -r filepath; do
  if [ -f $filepath ]; then
    rsync -R "$filepath" "$buildFolderName"
  fi
done

printf "\n <----- BUILD FOLDER TREE -----> \n"
tree $buildFolderName

if ! [ "$(ls $srcFolderPath)" ]; then
  printf "\n<----- No changed files detected in [$srcFolderPath] folder! ----->\n"
  exit 0
fi

# Invoke prettier;
npm install -g prettier
printf "\n prettier version is $(prettier --version)\n"
printf "\n pwd is $(pwd)\n"
prettier --check "$srcFolderPath/**/*.{cmp,component,css,html,js,json,md,page,trigger,yaml,yml}"