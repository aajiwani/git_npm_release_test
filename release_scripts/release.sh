#!/bin/bash

if [[ -z "${TRAVIS_TAG}" ]]; then
   # If not tagged build, halt!
   exit 0
fi

setup_git() {
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "Travis CI"
}

commit_dist_folder() {
  git checkout -b "${TRAVIS_TAG}-revisited"

  # Add everything present in the dist folder
  # As a result of the compiling effort
  git add -f dist/*

  dateAndMonth=`date "+%b %Y"`
  git commit -m "Travis update: $dateAndMonth (Build $TRAVIS_BUILD_NUMBER)" -m "[skip ci]"
  git push -u origin "${TRAVIS_TAG}-revisited"
}

make_space_for_new_tag() {
  git push --delete origin ${TRAVIS_TAG}
  git fetch -p
}

create_the_same_old_tag() {
    git tag ${TRAVIS_TAG}
    git push origin --tags
}

setup_git
commit_dist_folder

if [ $? -eq 0 ]; then
  make_space_for_new_tag
  create_the_same_old_tag
  echo "And the freshly baked tag is here!"
  upload_files
else
  echo "Git setup failed :("
fi
