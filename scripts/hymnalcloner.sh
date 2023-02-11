#!/bin/bash


git clone "git@github.com:adventHymnals/$1.git" "/tmp/tests/$1"
cd "/tmp/tests/$1"
git push origin master:gh-pages
cp -r /tmp/millenial-harp-csycms/hymnals.yaml ./
echo "" > hymnals.yaml
cp -r /tmp/millenial-harp-csycms/.github/ ./
nano  hymnals.yaml
git add . && git commit -m "added quarto" && git push origin master
