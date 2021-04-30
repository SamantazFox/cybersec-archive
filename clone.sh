#!/bin/sh


DGREY='\033[1;30m'
RED='\033[0;31m'
GREEN='\033[1;32m'
RESET='\033[0m'


usage() { echo "Usage: $0 <Repository URL>"; exit 0; }

url=$1


# Sanity check
if [ -z $url ]; then echo "${RED}Error: Clone URL to clone is required${RESET}"; usage; fi

dest=$(echo "$url" | sed -E 's=^(https?\://)?(www\.)?github.com/==')
_vld=$(echo "$dest" | sed -E 's=^([A-Za-z0-9_-]+)/([A-Za-z0-9_-]+)$=\1/\2=')

if ! [ "$dest" = "$_vld" ]; then
	echo ${RED}"Error: URL parsing error: '$dest'"${RESET}; exit 1;
fi


# determine where to clone, and create parent directories if required
user=$(echo "$dest" | sed -E 's=^([A-Za-z0-9_-]+)/([A-Za-z0-9_-]+)$=\1=')
repo=$(echo "$dest" | sed -E 's=^([A-Za-z0-9_-]+)/([A-Za-z0-9_-]+)$=\2=')

# Force .git at the end of repo name. This is needed if the
# name comes from an URL not ending with '.git'
repo=$(basename $repo .git).git

if [ -d $user/$repo ]; then
	echo ${RED}"Error: mirror of '$dest' already exists"${RESET}; exit 1;
fi



# Mirror repository
if ! [ -d $user ]; then mkdir $user; fi

echo
echo "Start: $(date '+%Y-%m-%d %H:%M:%S')"
echo

echo ${GREEN}"Cloning $url to $(pwd)/$user/$repo"${RESET}
echo ${DGREY}"git clone --mirror $url $user/$repo" ${RESET}
git clone --mirror $url $user/$repo

echo ${RESET}
echo "End: $(date '+%Y-%m-%d %H:%M:%S')"
echo

if ! [ -d $user/$repo ]; then echo ${RED}"Error: cloning failed"${RESET}; exit 2; fi


# Add description and prepare for tarball archive
cd $user/$repo
echo "Mirror of $url" > description
rm -f hooks/*
rm info/exclude 
