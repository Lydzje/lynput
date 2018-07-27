#!/bin/bash
printf "\n[CLEANING...]\n\n"
rm lynput.love -v
printf "\n[CLEANING COMPLETED]\n\n"

printf "\n[BUILDING LOVE PROJECT...]\n\n"
zip -r ./lynput.love ./ -x "**/.*" ".*" "**/*.md" "*.love" "*.md" "*.sh" "*#"
printf "\n[BUILDING COMPLETED]\n\n"
