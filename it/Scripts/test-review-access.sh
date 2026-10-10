#!/bin/sh
set -eu
REVIEW_APP_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
REVIEW_ACCESS_DIR=$(mktemp -d "${TMPDIR:-/tmp}/review-access-tests.XXXXXX")
trap 'rm -rf "$REVIEW_ACCESS_DIR"' EXIT HUP INT TERM
xcrun swiftc \
  "$REVIEW_APP_ROOT/Quiz/QuizQuestion.swift" \
  "$REVIEW_APP_ROOT/Quiz/HomeLearningActivity.swift" \
  "$REVIEW_APP_ROOT/Quiz/DailyReviewStore.swift" \
  "$REVIEW_APP_ROOT/Quiz/DailyQuickQuizStore.swift" \
  "$REVIEW_APP_ROOT/Quiz/LearningEntryContext.swift" \
  "$REVIEW_APP_ROOT/Quiz/ReviewAccessPolicy.swift" \
  "$REVIEW_APP_ROOT/Tests/ReviewAccessPolicyTests.swift" \
  -o "$REVIEW_ACCESS_DIR/review-access-tests"
"$REVIEW_ACCESS_DIR/review-access-tests"
