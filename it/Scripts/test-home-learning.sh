#!/bin/sh
set -eu
REVIEW_APP_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
REVIEW_TEST_DIR=$(mktemp -d "${TMPDIR:-/tmp}/home-learning-tests.XXXXXX")
trap 'rm -rf "$REVIEW_TEST_DIR"' EXIT HUP INT TERM
xcrun swiftc \
  "$REVIEW_APP_ROOT/Quiz/HomeLearningActivity.swift" \
  "$REVIEW_APP_ROOT/Quiz/DailyReviewStore.swift" \
  "$REVIEW_APP_ROOT/Quiz/DailyQuickQuizStore.swift" \
  "$REVIEW_APP_ROOT/Quiz/LearningEntryContext.swift" \
  "$REVIEW_APP_ROOT/Tests/HomeLearningActivityTests.swift" \
  -o "$REVIEW_TEST_DIR/home-learning-tests"
"$REVIEW_TEST_DIR/home-learning-tests"
