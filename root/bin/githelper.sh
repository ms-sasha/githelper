#!/usr/bin/env sh

set -e

ROOT_DIRECTORY="${ROOT_DIRECTORY:-/srv}"

GIT_REFERENCE="${GIT_REFERENCE:-master}"

GIT_AUTOUPDATE="${GIT_AUTOUPDATE:-true}"
GIT_AUTOUPDATE_INTERVAL="${GIT_AUTOUPDATE_INTERVAL:-5m}"

GIT_USE_LFS="${GIT_USE_LFS:-no}"

if [ -z "${GIT_ORIGIN}" ]; then
  echo "GIT_ORIGIN variable must be set to a proper Git URI, exiting..."
  exit 1
fi

echo "Starting GitHelper for ${GIT_ORIGIN} / ${GIT_REFERENCE}"

if [ x"${GIT_PROVIDER}" != x"" ]; then
  mkdir -p ~/.ssh
  chmod -R 700 ~/.ssh
  ssh-keyscan -t rsa -H ${GIT_PROVIDER} >> ~/.ssh/known_hosts
fi

if [ x"${SSH_KEY_FILE_PATH}" != x"" ]; then
  echo -e "\nHost ${GIT_PROVIDER}\n  IdentityFile ${SSH_KEY_FILE_PATH}\n" >> ~/.ssh/config
fi

mkdir -p "${ROOT_DIRECTORY}"
cd "${ROOT_DIRECTORY}" || exit 1

if [ ! -d ".git" ]; then
  echo "Cloning..."
  git clone "${GIT_ORIGIN}" .
fi

if [ x"${GIT_USE_LFS}" = x"yes" ]; then
  echo "Git LFS configuration update..."
  echo " ... install"
  git lfs install
  echo " ... lfs pull"
  git lfs pull
fi

while true; do
  echo "Start periodic update..."
  echo " ... resetting"
  git reset --hard HEAD
  echo " ... cleaning"
  git clean -f -d -x
  echo " ... pull"
  git pull

  if [ x"${GIT_USE_LFS}" = x"yes" ]; then
    echo " ... LFS fetch"
    git lfs fetch
    echo " ... LFS pull"
    git lfs pull
  fi

  echo "Sleeping..."
  sleep "$GIT_AUTOUPDATE_INTERVAL"
done
