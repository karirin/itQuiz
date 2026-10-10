#!/bin/sh
set -eu
REVIEW_APP_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
REVIEW_HOME_DIR=$(mktemp -d "${TMPDIR:-/tmp}/review-home-tests.XXXXXX")
trap 'rm -rf "$REVIEW_HOME_DIR"' EXIT HUP INT TERM
xcrun swiftc \
  "$REVIEW_APP_ROOT/Quiz/QuizQuestion.swift" \
  "$REVIEW_APP_ROOT/Quiz/HomeLearningActivity.swift" \
  "$REVIEW_APP_ROOT/Quiz/DailyReviewStore.swift" \
  "$REVIEW_APP_ROOT/Quiz/DailyQuickQuizStore.swift" \
  "$REVIEW_APP_ROOT/Quiz/LearningEntryContext.swift" \
  "$REVIEW_APP_ROOT/Quiz/ReviewAccessPolicy.swift" \
  "$REVIEW_APP_ROOT/Quiz/ReviewHomeState.swift" \
  "$REVIEW_APP_ROOT/Quiz/ReviewDailyActivityLog.swift" \
  "$REVIEW_APP_ROOT/Quiz/ReviewSessionOutcome.swift" \
  "$REVIEW_APP_ROOT/Tests/ReviewHomeStateTests.swift" \
  -o "$REVIEW_HOME_DIR/review-home-tests"
"$REVIEW_HOME_DIR/review-home-tests"
