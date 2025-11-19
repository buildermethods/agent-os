---
description: Commands for interacting with Jira API.
---

# Jira Integration Commands

These commands allow the agent to interact with Jira.
**Prerequisites**: `JIRA_BASE_URL`, `JIRA_USER_EMAIL`, and `JIRA_API_TOKEN` must be set in the environment.

## Create Issue

Create a new issue in Jira.

```bash
# Usage: create_jira_issue <project_key> <summary> <description> <issuetype>
create_jira_issue() {
    local project="$1"
    local summary="$2"
    local description="$3"
    local issuetype="${4:-Bug}"

    curl -s -X POST "$JIRA_BASE_URL/rest/api/3/issue" \
      -u "$JIRA_USER_EMAIL:$JIRA_API_TOKEN" \
      -H "Accept: application/json" \
      -H "Content-Type: application/json" \
      --data "{
        \"fields\": {
           \"project\": { \"key\": \"$project\" },
           \"summary\": \"$summary\",
           \"description\": {
             \"type\": \"doc\",
             \"version\": 1,
             \"content\": [
               {
                 \"type\": \"paragraph\",
                 \"content\": [
                   {
                     \"type\": \"text\",
                     \"text\": \"$description\"
                   }
                 ]
               }
             ]
           },
           \"issuetype\": { \"name\": \"$issuetype\" }
       }
    }"
}
```

## Add Comment

Add a comment to an existing issue.

```bash
# Usage: add_jira_comment <issue_key> <comment_body>
add_jira_comment() {
    local issue_key="$1"
    local comment="$2"

    curl -s -X POST "$JIRA_BASE_URL/rest/api/3/issue/$issue_key/comment" \
      -u "$JIRA_USER_EMAIL:$JIRA_API_TOKEN" \
      -H "Accept: application/json" \
      -H "Content-Type: application/json" \
      --data "{
        \"body\": {
          \"type\": \"doc\",
          \"version\": 1,
          \"content\": [
            {
              \"type\": \"paragraph\",
              \"content\": [
                {
                  \"type\": \"text\",
                  \"text\": \"$comment\"
                }
              ]
            }
          ]
        }
      }"
}
```
