#!/bin/bash

ver=$(git describe --abbrev=0 --dirty)
dir=$1
pkgname=zjuthesis-overleaf-$ver

if [ -z $dir ]
then
  echo "No output dir specified"
  exit 1
fi

if [[ $(git diff --stat) != '' ]]; then
  echo "Git repo dirty, abort packaging"
  exit 1
fi

mkdir -p $dir

bash ./script/ci/setup.sh
rm -f .gitignore
rm -f .latexmkrc

rm -rf fonts
mkdir -p fonts
pushd fonts
cat <<EOF>README.md
# Setup fonts

You have to manually upload the fonts here.

Refer to this script for more help:
https://github.com/TheNetAdmin/zjuthesis/blob/master/script/ci/setup.sh

You need to download all the font files (.ttf/.ttc) mentioned in above script:
  - FangSong.ttf
  - TimesNewRoman.ttf
  - TimesNewRomanBold.ttf
  - TimesNewRomanItalic.ttf
  - TimesNewRomanBoldItalic.ttf
  - SimSun.ttc

Download these fonts to your local computer and upload them to this folder (fonts/).
EOF
popd
git add fonts/README.md

echo "Packaging $dir/$pkgname.zip"
stash_name=`git stash create`
git archive --format=zip -o $dir/$pkgname.zip $stash_name

echo "Reverse changes"
git stash pop
git reset fonts/README.md
rm -rf fonts
git checkout .gitignore
git checkout .latexmkrc
git checkout config/format/general/fonts.tex
git checkout config/format/major/cs/fonts.tex


if [[ $(git diff --stat) != '' ]]; then
  echo "The current script creates dirty repo, abort further operations"
  exit 1
fi