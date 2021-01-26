cd ../../
git diff --cached --name-only --diff-filter=ACM -z | grep '\.gd$' | xargs -0 ./format.sh
