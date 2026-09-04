# Ad Astra for LazyCat

LazyCat LPK v2 packaging for [Ad Astra](https://github.com/gunerguner/AdAstra), an interactive, offline-capable real-time sky PWA.

## Reproducible source build

Version `1.0.0` is pinned to upstream commit `5d2ee707e45f3e5a765abcc54221ccd1fbfdc0fa`. GitHub Actions downloads that commit archive and verifies SHA256 before installing dependencies:

```text
b944f95fcd2cd44faaf086e585b227844c40ac2a608c269df27f8fa46a7e759c
```

The build runs `pnpm verify` and `pnpm build`. It deliberately does not run `build:release`, because upstream documents that the production catalog's data-license gate is not yet available and the Docker deployment uses the fixture catalog.

`scripts/build.sh` requires `GITHUB_ACTIONS=true`; local `lzc-cli project release` cannot download or build the upstream source.

## Runtime

Ad Astra is packaged as static content with no runtime container, database, or persistent volume. The PWA and Service Worker are served over the LazyCat HTTPS application domain.

The icon is the upstream `public/icon-512.png` asset.

## GitHub Actions

- Pushes and pull requests automatically build and upload a validation LPK Artifact in GitHub Actions.
- The publish workflow creates a versioned GitHub Release asset and publishes only to the MiaoMiao private store.
- Updating the application requires a new package version plus an explicitly reviewed upstream commit and archive SHA256 in `upstream-sources.txt`.

Required repository or organization Secrets:

- `APPSTORE_URL`
- `APPSTORE_TOKEN`

Optional Secrets:

- `APP_ID`
- `PRIVATE_STORE_GROUP_CODES`
