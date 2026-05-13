#! /usr/bin/env bash
# SPDX-FileCopyrightText: 2022 Oxhead Alpha
# SPDX-License-Identifier: LicenseRef-MIT-OA

# Note: if you modify this file, check if its usage in docs/distros/macos.md
# needs to be updated too.

set -eo pipefail

if [ -z "$1" ] ; then
    echo "Please call this script with the name of the binary for which to build the bottle."
    exit 1
fi

# shellcheck disable=SC2046
# Homebrew lowercases formula names in bottle filenames
lower_name="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
brew install --formula --build-bottle "mavryk-network/mavryk-packaging/$1"
# Newer brew versions fail when checking for a rebuild version of non-core taps.
# So for now we skip the check with '--no-rebuild'
brew bottle --force-core-tap --no-rebuild "mavryk-network/mavryk-packaging/$1"
brew uninstall "$1"
# https://github.com/Homebrew/brew/pull/4612#commitcomment-29995084
# Rename double-dash to single-dash if needed, using lowercased name for glob
for f in "$lower_name"*.bottle.*; do
  newname="$(echo "$f" | sed 's/--/-/')"
  # Rename to use original (mixed-case) formula name
  newname="$(echo "$newname" | sed "s/^$lower_name/$1/")"
  if [ "$f" != "$newname" ]; then
    mv "$f" "$newname"
  fi
done
