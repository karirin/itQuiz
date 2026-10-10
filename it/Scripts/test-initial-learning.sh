#!/bin/sh
set -eu
ONBOARDING_APP_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
ONBOARDING_TEST_DIR=$(mktemp -d "${TMPDIR:-/tmp}/initial-learning-tests.XXXXXX")
trap 'rm -rf "$ONBOARDING_TEST_DIR"' EXIT HUP INT TERM
xcrun swiftc \
  "$ONBOARDING_APP_ROOT/App/InitialLearningFlow.swift" \
  "$ONBOARDING_APP_ROOT/Quiz/QuizQuestion.swift" \
  "$ONBOARDING_APP_ROOT/Quiz/InitialPracticeContent.swift" \
  "$ONBOARDING_APP_ROOT/Tests/InitialLearningFlowTests.swift" \
  -o "$ONBOARDING_TEST_DIR/initial-learning-tests"
"$ONBOARDING_TEST_DIR/initial-learning-tests"
