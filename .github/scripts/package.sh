#!/usr/bin/env bash
# Cross-platform packaging helper for the SubTrack release workflow.
# Invoked by .github/workflows/release.yml with the following env vars:
#   RUNNER_OS    - Linux / macOS / Windows
#   OUT_DIR      - path to the Flutter build output (relative to repo root)
#   ARTIFACT_DIR - name of the staged dir and resulting archive basename
#   ARCHIVE_FMT  - "tar" or "zip"
#
# IMPORTANT: this file MUST be pure ASCII. Non-ASCII bytes (em-dashes,
# smart quotes, etc.) get mojibake-corrupted by PowerShell's default
# Windows-1251 codepage on some Windows runners and break the bash parser.
set -euo pipefail

if [ -z "${OUT_DIR:-}" ] || [ -z "${ARTIFACT_DIR:-}" ] || [ -z "${ARCHIVE_FMT:-}" ]; then
  echo "::error::OUT_DIR, ARTIFACT_DIR, and ARCHIVE_FMT must be set"
  exit 1
fi

echo "Packaging $ARTIFACT_DIR from $OUT_DIR (runner=$RUNNER_OS fmt=$ARCHIVE_FMT)"

STAGE="release/$ARTIFACT_DIR"
rm -rf release
mkdir -p "$STAGE"

# Copy the build output into a clean staging directory. The trailing "."
# makes cp -R copy the *contents* of OUT_DIR into STAGE rather than nesting
# OUT_DIR inside STAGE.
#
# On the Windows runner the workflow uses shell: bash which runs under
# git-bash (MSYS). MSYS auto-converts POSIX-style paths to native Windows
# paths for cp, so the same cp -R invocation works for POSIX and Windows.
# Using cmd.exe / xcopy here was tried and rejected because of fragile
# quoting inside double-quoted bash strings.
cp -R "$OUT_DIR/." "$STAGE/"

# Sanity check: STAGE must contain at least one file.
if [ ! -d "$STAGE" ] || [ -z "$(ls -A "$STAGE" 2>/dev/null)" ]; then
  echo "::error::No files were copied into $STAGE (source: $OUT_DIR)"
  echo "::error::STAGE listing:"
  ls -la "$STAGE" || true
  exit 1
fi

echo "Staged contents:"
ls -la "$STAGE"

cd release
case "$ARCHIVE_FMT" in
  tar)
    # -h follows symlinks so macOS .app bundles (which contain symlinks in
    # Frameworks/) archive correctly.
    tar -czhf "$ARTIFACT_DIR.tar.gz" "$ARTIFACT_DIR"
    ;;
  zip)
    # Windows runners ship with 7-Zip but not the Info-ZIP 'zip' CLI.
    # Use 7z to produce a standard .zip archive.
    if command -v 7z >/dev/null 2>&1; then
      # -r recursive, -bb1 minimal progress, -sccUTF-8 console codepage,
      # -snl preserve symlinks (matches Windows tar -h behavior).
      # -mx=5 is a reasonable default; -tzip selects the zip container.
      7z a -tzip -mx=5 -r -bb0 "$ARTIFACT_DIR.zip" "$ARTIFACT_DIR" >/dev/null
    elif command -v zip >/dev/null 2>&1; then
      zip -r "$ARTIFACT_DIR.zip" "$ARTIFACT_DIR"
    else
      echo "::error::Neither 7z nor zip is available on this runner"
      exit 1
    fi
    ;;
  *)
    echo "::error::Unknown ARCHIVE_FMT: $ARCHIVE_FMT"
    exit 1
    ;;
esac
cd ..

echo "Final artifacts:"
ls -la release/