#!/bin/sh
set -eu
ANALYSIS_APP_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
ANALYSIS_TEST_DIR=$(mktemp -d "${TMPDIR:-/tmp}/learning-analytics-tests.XXXXXX")
trap 'rm -rf "$ANALYSIS_TEST_DIR"' EXIT HUP INT TERM
xcrun swiftc \
  "$ANALYSIS_APP_ROOT/Quiz/LearningAnalytics.swift" \
  "$ANALYSIS_APP_ROOT/Tests/LearningAnalyticsTests.swift" \
  -o "$ANALYSIS_TEST_DIR/learning-analytics-tests"
"$ANALYSIS_TEST_DIR/learning-analytics-tests"
