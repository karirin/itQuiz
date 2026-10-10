#!/bin/sh
set -eu
ADVENTURE_APP_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
ADVENTURE_TEST_DIR=$(mktemp -d "${TMPDIR:-/tmp}/story-adventure-tests.XXXXXX")
trap 'rm -rf "$ADVENTURE_TEST_DIR"' EXIT HUP INT TERM
xcrun swiftc \
  "$ADVENTURE_APP_ROOT/Story/AdventureWorld.swift" \
  "$ADVENTURE_APP_ROOT/Story/AdventureStory.swift" \
  "$ADVENTURE_APP_ROOT/Story/AdventureProgress.swift" \
  "$ADVENTURE_APP_ROOT/Tests/AdventureProgressTests.swift" \
  -o "$ADVENTURE_TEST_DIR/adventure-tests"
"$ADVENTURE_TEST_DIR/adventure-tests"
xcrun swiftc -D DEBUG \
  "$ADVENTURE_APP_ROOT/Story/AdventureWorld.swift" \
  "$ADVENTURE_APP_ROOT/Story/AdventureStory.swift" \
  "$ADVENTURE_APP_ROOT/Story/AdventureProgress.swift" \
  "$ADVENTURE_APP_ROOT/Tests/AdventureProgressTests.swift" \
  -o "$ADVENTURE_TEST_DIR/adventure-debug-tests"
"$ADVENTURE_TEST_DIR/adventure-debug-tests"
xcrun swiftc \
  "$ADVENTURE_APP_ROOT/Story/AdventureWorld.swift" \
  "$ADVENTURE_APP_ROOT/Story/AdventureMapGeometry.swift" \
  "$ADVENTURE_APP_ROOT/Tests/AdventureMapGeometryTests.swift" \
  -o "$ADVENTURE_TEST_DIR/map-geometry-tests"
"$ADVENTURE_TEST_DIR/map-geometry-tests"
