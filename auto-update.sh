#!/bin/bash
# 0 9 * * * bash /Users/maxc/xcode/Auth0SPM/auto-update.sh > /tmp/a0update.log 2>&1

set -e

run_date="$(date +%s)"

# Get the latest changes to Auth0.swift
cd ~/xcode/Auth0.swift
git reset --hard
git checkout master
git fetch
git pull 
recent_tag="$(git describe --abbrev=0)"

# Ensure the SPM Auth0.swift mirror is updated
cd ~/xcode/Auth0SPM
git checkout master
git pull --rebase

# Run the conversion script
ruby Auth0toSPM.rb

# Check that the project still builds
# Ideally we should check all platforms etc, this is just easy for me for now

tmp_location="/tmp/a0_$(uuidgen)"
mkdir -p "$tmp_location"
cp -R . "$tmp_location/."
cd "$tmp_location"
# swift build TODO build and test
cd -

# Commit the changes
git add .
git commit -am "[Auto Update] Sync master at $run_date"
git push

# Sync latest tag if possible (only if the tag doesn't exist here yet)
git tag -l | grep -v "$recent_tag" # only continue executing if the tag doesn't exist
cd ~/xcode/Auth0.swift
git checkout "$recent_tag"
cd ~/xcode/Auth0SPM
git checkout -b "auto-tags/$recent_tag"
ruby Auth0toSPM.rb
#TODO clean this up, make sure we build here too
git add .
git commit -am "[Auto Update] Sync $recent_tag at $run_date"
git push
tag "$recent_tag"
git push --tags

