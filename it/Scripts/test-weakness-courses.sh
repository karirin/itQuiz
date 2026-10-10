#!/bin/sh
set -eu
COURSE_APP_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
COURSE_TEST_DIR=$(mktemp -d "${TMPDIR:-/tmp}/weakness-course-tests.XXXXXX")
trap 'rm -rf "$COURSE_TEST_DIR"' EXIT HUP INT TERM
xcrun swiftc -O \
  "$COURSE_APP_ROOT/Quiz/QuizQuestion.swift" \
  "$COURSE_APP_ROOT/Quiz/ITPassportQuestionBank.swift" \
  "$COURSE_APP_ROOT/Quiz/ITPassportQuestionBankBasic.swift" \
  "$COURSE_APP_ROOT/Quiz/ITPassportQuestionBankTechnology.swift" \
  "$COURSE_APP_ROOT/Quiz/ITPassportQuestionBankStrategy.swift" \
  "$COURSE_APP_ROOT/Quiz/ITPassportQuestionBankManagement.swift" \
  "$COURSE_APP_ROOT/Quiz/CourseCloudCodec.swift" \
  "$COURSE_APP_ROOT/Quiz/WeaknessCourse.swift" \
  "$COURSE_APP_ROOT/Quiz/WeaknessCourseCatalog.swift" \
  "$COURSE_APP_ROOT/Tests/CourseQuestionBenchmark.swift" \
  "$COURSE_APP_ROOT/Tests/WeaknessCourseTests.swift" \
  -o "$COURSE_TEST_DIR/weakness-course-tests"
"$COURSE_TEST_DIR/weakness-course-tests"
"$COURSE_TEST_DIR/weakness-course-tests" --dump-bank > "$COURSE_TEST_DIR/banks.json"
python3 - "$COURSE_APP_ROOT" "$COURSE_TEST_DIR/banks.json" <<'PY'
import pathlib, re, sys, json, hashlib
root = pathlib.Path(sys.argv[1])
catalog = (root / 'Quiz/WeaknessCourseCatalog.swift').read_text()
banks = '\n'.join((root / f'Quiz/ITPassportQuestionBank{name}.swift').read_text()
                  for name in ('Basic', 'Technology', 'Strategy', 'Management'))
source_questions = set(re.findall(r'question:\s*"((?:[^"\\]|\\.)*)"', banks))
linked = []
for section in re.findall(r'sourcePrompts: \[(.*?)\],\s*practice:', catalog, re.S):
    linked += re.findall(r'"((?:[^"\\]|\\.)*)"', section)
assert linked and all(q in source_questions for q in linked), [q for q in linked if q not in source_questions]
assert len(linked) == len(set(linked))
print(f'All {len(linked)} legacy question mappings exist in the IT Passport question banks')
banks = json.loads(pathlib.Path(sys.argv[2]).read_text())
fixtures = json.loads((root / 'Tests/Fixtures/it-passport-bank-digest.json').read_text())
for name, bank in banks.items():
    original = [[q['question'], q['choices'], q['correctAnswerIndex'], q['explanation']] for q in bank]
    digest = hashlib.sha256(json.dumps(original, ensure_ascii=False, separators=(',', ':')).encode()).hexdigest()
    assert len(bank) == fixtures[name]['count'] and digest == fixtures[name]['sha256'], f'Content changed: {name}'
    for q in bank:
        identity = [q['question'], q['choices'], q['correctAnswerIndex']]
        digest = hashlib.sha256(json.dumps(identity, ensure_ascii=False, separators=(',', ':')).encode()).hexdigest()[:24]
        assert q['id'] == 'it.' + digest, f'Unstable question ID: {q["id"]}'
print('All 844 question prompts, choices, answers, explanations, order, and stable IDs verified')
PY
if [ "${1:-}" = "--benchmark" ]; then
  "$COURSE_TEST_DIR/weakness-course-tests" --benchmark
fi
