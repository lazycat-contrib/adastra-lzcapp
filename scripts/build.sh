#!/bin/sh
set -eu

if [ "${GITHUB_ACTIONS:-}" != "true" ]; then
  printf 'Ad Astra source builds are restricted to GitHub Actions\n' >&2
  exit 1
fi

project_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
version=${LAZYCAT_VERSION:-$(awk '/^version:/ { print $2; exit }' "$project_root/package.yml")}
source_line=$(awk -v version="$version" '$1 == version { print; exit }' "$project_root/upstream-sources.txt")
commit=$(printf '%s\n' "$source_line" | awk '{ print $2 }')
expected_sha=$(printf '%s\n' "$source_line" | awk '{ print $3 }')

if [ -z "$commit" ] || [ -z "$expected_sha" ]; then
  printf 'Missing pinned source commit or checksum for version %s\n' "$version" >&2
  exit 1
fi

build_root=$(mktemp -d)
trap 'find "$build_root" -mindepth 1 -delete; rmdir "$build_root"' EXIT HUP INT TERM
archive="$build_root/source.tar.gz"
source_dir="$build_root/source"
mkdir -p "$source_dir"

curl --fail --location --silent --show-error \
  --retry 3 --connect-timeout 15 --max-time 180 \
  "https://api.github.com/repos/gunerguner/AdAstra/tarball/${commit}" \
  --output "$archive"
printf '%s  %s\n' "$expected_sha" "$archive" | sha256sum --check --status
tar -xzf "$archive" -C "$source_dir" --strip-components=1

cd "$source_dir"
corepack enable
corepack prepare pnpm@10.20.0 --activate
pnpm install --frozen-lockfile
pnpm verify
pnpm build

content_dir="$project_root/content/dist"
mkdir -p "$content_dir"
find "$content_dir" -mindepth 1 -delete
cp -R "$source_dir/dist/." "$content_dir/"
