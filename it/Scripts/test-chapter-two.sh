#!/bin/sh
set -eu
CHAPTER_TWO_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
CHAPTER_TWO_TEST_DIR=$(mktemp -d "${TMPDIR:-/tmp}/chapter-two-tests.XXXXXX")
trap 'rm -rf "$CHAPTER_TWO_TEST_DIR"' EXIT HUP INT TERM
xcrun swiftc \
  "$CHAPTER_TWO_ROOT/Story/AdventureWorld.swift" \
  "$CHAPTER_TWO_ROOT/Story/AdventureStory.swift" \
  "$CHAPTER_TWO_ROOT/Story/AdventureProgress.swift" \
  "$CHAPTER_TWO_ROOT/Story/ChapterTwoStory.swift" \
  "$CHAPTER_TWO_ROOT/Story/ChapterTwoProgress.swift" \
  "$CHAPTER_TWO_ROOT/Tests/ChapterTwoProgressTests.swift" \
  -o "$CHAPTER_TWO_TEST_DIR/chapter-two-tests"
"$CHAPTER_TWO_TEST_DIR/chapter-two-tests"
