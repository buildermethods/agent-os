# Progress Log Validation Tests

Manual and automated validation procedures for the progress log system.

---

## Installation Validation

### Test 1.1: Directory Structure Created
**When**: After running `./setup/project.sh --claude-code`
**Verify**:
```bash
# Check directories exist
test -d .agent-os/progress && echo "PASS: progress directory exists" || echo "FAIL"
test -d .agent-os/progress/archive && echo "PASS: archive directory exists" || echo "FAIL"
```

### Test 1.2: Initial Progress Files Created
**When**: After fresh installation
**Verify**:
```bash
# Check files exist
test -f .agent-os/progress/progress.json && echo "PASS: progress.json exists" || echo "FAIL"
test -f .agent-os/progress/progress.md && echo "PASS: progress.md exists" || echo "FAIL"

# Check JSON is valid
jq empty .agent-os/progress/progress.json && echo "PASS: valid JSON" || echo "FAIL"

# Check initial entry exists
jq '.entries | length' .agent-os/progress/progress.json | grep -q "1" && echo "PASS: initial entry exists" || echo "FAIL"
```

### Test 1.3: Progress Log Preserved on Upgrade
**When**: After running `./setup/project.sh --claude-code --upgrade`
**Verify**:
```bash
# Add a test entry before upgrade
echo '{"test": "entry"}' > /tmp/progress-backup.json
cp .agent-os/progress/progress.json /tmp/progress-backup.json

# Run upgrade
./setup/project.sh --claude-code --upgrade

# Verify progress preserved
diff .agent-os/progress/progress.json /tmp/progress-backup.json && echo "PASS: progress preserved" || echo "FAIL"
```

---

## Schema Validation

### Test 2.1: Progress JSON Schema
**Verify progress.json matches expected schema**:
```bash
# Required top-level fields
jq 'has("version")' .agent-os/progress/progress.json | grep -q "true" || echo "FAIL: missing version"
jq 'has("project")' .agent-os/progress/progress.json | grep -q "true" || echo "FAIL: missing project"
jq 'has("entries")' .agent-os/progress/progress.json | grep -q "true" || echo "FAIL: missing entries"
jq 'has("metadata")' .agent-os/progress/progress.json | grep -q "true" || echo "FAIL: missing metadata"

# Required metadata fields
jq '.metadata | has("total_entries")' .agent-os/progress/progress.json | grep -q "true" || echo "FAIL: missing total_entries"
jq '.metadata | has("last_updated")' .agent-os/progress/progress.json | grep -q "true" || echo "FAIL: missing last_updated"
```

### Test 2.2: Entry Schema Validation
**Each entry should have required fields**:
```bash
# Check first entry has required fields
jq '.entries[0] | has("id")' .agent-os/progress/progress.json | grep -q "true" || echo "FAIL: entry missing id"
jq '.entries[0] | has("timestamp")' .agent-os/progress/progress.json | grep -q "true" || echo "FAIL: entry missing timestamp"
jq '.entries[0] | has("type")' .agent-os/progress/progress.json | grep -q "true" || echo "FAIL: entry missing type"
jq '.entries[0] | has("data")' .agent-os/progress/progress.json | grep -q "true" || echo "FAIL: entry missing data"
```

---

## Append Operation Tests

### Test 3.1: Session Started Entry
**Simulate session start logging**:
```bash
# Create test entry
cat > /tmp/test-entry.json << 'EOF'
{
  "id": "entry-test-001",
  "timestamp": "2025-12-08T10:00:00Z",
  "type": "session_started",
  "spec": "test-feature",
  "data": {
    "description": "Test session start",
    "focus_task": "1.1",
    "context": "Testing progress log"
  }
}
EOF

# Append to progress (manual verification)
# In actual usage, this would be done by the execute-tasks command
```

### Test 3.2: Task Completed Entry
**Verify task completion logging structure**:
```javascript
// Expected entry structure
{
  "id": "entry-YYYYMMDD-HHMMSS-XXX",
  "timestamp": "ISO8601",
  "type": "task_completed",
  "spec": "feature-name",
  "task_id": "1.2",
  "data": {
    "description": "Implemented feature X",
    "duration_minutes": 30,
    "notes": "Key accomplishments",
    "next_steps": "Task 1.3"
  }
}
```

### Test 3.3: Metadata Update on Append
**Verify metadata updates after each append**:
```bash
# Get initial count
INITIAL_COUNT=$(jq '.metadata.total_entries' .agent-os/progress/progress.json)

# After append (simulated)
NEW_COUNT=$(jq '.metadata.total_entries' .agent-os/progress/progress.json)

# Verify count increased
[ "$NEW_COUNT" -gt "$INITIAL_COUNT" ] && echo "PASS: count increased" || echo "FAIL"
```

---

## Markdown Generation Tests

### Test 4.1: Markdown File Exists
```bash
test -f .agent-os/progress/progress.md && echo "PASS" || echo "FAIL"
```

### Test 4.2: Markdown Contains Expected Sections
```bash
grep -q "# Agent OS Progress Log" .agent-os/progress/progress.md && echo "PASS: header exists" || echo "FAIL"
grep -q "## " .agent-os/progress/progress.md && echo "PASS: date sections exist" || echo "FAIL"
```

### Test 4.3: JSON/Markdown Sync
**Verify entry count matches**:
```bash
JSON_COUNT=$(jq '.metadata.total_entries' .agent-os/progress/progress.json)
MD_COUNT=$(grep -c "^### " .agent-os/progress/progress.md)

[ "$JSON_COUNT" -eq "$MD_COUNT" ] && echo "PASS: counts match" || echo "FAIL: JSON=$JSON_COUNT MD=$MD_COUNT"
```

---

## Archive Tests

### Test 5.1: Archive Directory Structure
```bash
# Archive directory should exist but be empty initially
test -d .agent-os/progress/archive && echo "PASS: archive dir exists" || echo "FAIL"
```

### Test 5.2: Archive Threshold (Manual Test)
**When entries exceed 500 and oldest > 30 days**:
1. Manually create 500+ test entries with old timestamps
2. Run any command that triggers progress logging
3. Verify entries older than 30 days moved to archive/YYYY-MM.json
4. Verify main progress.json only contains recent entries

---

## Cross-Session Tests

### Test 6.1: Progress Persistence
**Simulate multiple sessions**:
```bash
# Session 1: Create entry
# (Run execute-tasks, which logs session_started)

# Close session (context window ends)

# Session 2: Read progress
jq '.entries | last' .agent-os/progress/progress.json
# Should show entry from Session 1
```

### Test 6.2: Recent Progress Reading
**Verify getRecentProgress equivalent works**:
```bash
# Get last 20 entries
jq '.entries | .[-20:]' .agent-os/progress/progress.json

# Should return array of recent entries with full structure
```

### Test 6.3: Unresolved Blockers Detection
**Verify blocker detection works**:
```bash
# Find task_blocked entries without corresponding task_completed
jq '[.entries[] | select(.type == "task_blocked")] |
    map(select(.task_id as $tid |
        [.[] | select(.type == "task_completed" and .task_id == $tid)] | length == 0
    ))' .agent-os/progress/progress.json
```

---

## Integration Tests

### Test 7.1: Full Workflow Test
**Complete end-to-end validation**:

1. **Fresh Install**
   ```bash
   ./setup/project.sh --claude-code
   ```
   - Verify progress.json created with initial entry
   - Verify progress.md generated

2. **Run execute-tasks**
   - Verify session_started logged at Phase 1 completion
   - Verify task_completed logged for each parent task
   - Verify session_ended logged at Phase 3 completion

3. **New Session**
   - Verify progress log readable
   - Verify previous session context available
   - Verify unresolved blockers highlighted

### Test 7.2: Error Recovery Test
**Verify corruption recovery**:
```bash
# Corrupt progress.json
echo "invalid json" > .agent-os/progress/progress.json

# Run command that reads progress
# Should initialize fresh progress file

# Verify fresh file created
jq empty .agent-os/progress/progress.json && echo "PASS: recovered" || echo "FAIL"
```

---

## Validation Checklist

Use this checklist when testing progress log changes:

- [ ] Installation creates progress directory
- [ ] Installation creates initial progress.json
- [ ] Installation creates initial progress.md
- [ ] Upgrade preserves existing progress
- [ ] JSON schema is valid
- [ ] Entries have required fields
- [ ] Append updates metadata
- [ ] Markdown generated from JSON
- [ ] JSON/Markdown entry counts match
- [ ] Archive directory exists
- [ ] Cross-session persistence works
- [ ] Recent progress readable
- [ ] Blocker detection works
- [ ] Error recovery works

---

## Automated Test Script

Save as `test-progress-log.sh`:

```bash
#!/bin/bash
# Progress Log Automated Validation

PASS=0
FAIL=0

check() {
    if eval "$1"; then
        echo "✓ PASS: $2"
        ((PASS++))
    else
        echo "✗ FAIL: $2"
        ((FAIL++))
    fi
}

echo "=== Progress Log Validation ==="
echo ""

# Directory checks
check 'test -d .agent-os/progress' "Progress directory exists"
check 'test -d .agent-os/progress/archive' "Archive directory exists"

# File checks
check 'test -f .agent-os/progress/progress.json' "progress.json exists"
check 'test -f .agent-os/progress/progress.md' "progress.md exists"

# Schema checks
check 'jq empty .agent-os/progress/progress.json 2>/dev/null' "Valid JSON"
check 'jq -e ".version" .agent-os/progress/progress.json >/dev/null 2>&1' "Has version field"
check 'jq -e ".entries" .agent-os/progress/progress.json >/dev/null 2>&1' "Has entries field"
check 'jq -e ".metadata" .agent-os/progress/progress.json >/dev/null 2>&1' "Has metadata field"

# Entry checks
check 'jq -e ".entries | length > 0" .agent-os/progress/progress.json >/dev/null 2>&1' "Has at least one entry"

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo ""

if [ $FAIL -eq 0 ]; then
    echo "All tests passed!"
    exit 0
else
    echo "Some tests failed!"
    exit 1
fi
```
