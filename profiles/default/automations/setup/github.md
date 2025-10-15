# GitHub Automations Setup

Complete setup guide for GitHub Actions with Claude Code. Based on the [official documentation](https://github.com/anthropics/claude-code-action/blob/main/docs/setup.md).

## Prerequisites

- **GitHub repository** with Actions enabled
- **GitHub CLI** (`gh`) installed: https://cli.github.com/
- **Anthropic account** for API key or OAuth token
- **Repository admin access** to configure secrets

## Automatic Setup

The installation script will prompt you to run the setup script automatically. Choose "yes" to check your authentication status and get setup instructions.

## Authentication Methods

Choose ONE of the following methods:

### Option 1: API Key (Recommended)

Simple authentication using your Anthropic API key.

**Steps:**
1. Get your API key from Anthropic Console: https://console.anthropic.com/settings/keys
2. Set as repository secret:
   ```bash
   gh secret set ANTHROPIC_API_KEY
   # Paste your API key when prompted
   ```

**Pros:**
- Simple and straightforward
- Works for all users
- Easy to rotate

### Option 2: OAuth Token

For Claude Pro or Max users who want to use their Claude subscription.

**Steps:**
1. Get your OAuth token from Claude account settings
2. Set as repository secret:
   ```bash
   gh secret set CLAUDE_CODE_OAUTH_TOKEN
   # Paste your OAuth token when prompted
   ```

**Pros:**
- Uses your Claude Pro/Max subscription
- No additional API costs

### Option 3: GitHub App

Install the official Claude GitHub App for managed authentication.

**Steps:**
1. Install the app: https://github.com/apps/claude
2. Grant repository access
3. The app handles authentication automatically

**Pros:**
- Managed authentication
- Simpler setup for organizations
- Automatic token management

## Manual Setup

If you need to run setup manually:

```bash
# From your project root
PROJECT_ROOT=$(pwd) bash ~/.agent-os/profiles/default/automations/github/setup.sh
```

The script will:
- Check for existing authentication secrets
- Provide setup instructions if needed
- Display next steps

## Workflows Included

Two workflows are installed:

### 1. Claude Code (`claude.yml`)
- **Triggers**: @claude mentions in issues, PRs, comments, reviews
- **Purpose**: Respond to natural language requests, with awareness of .claude/ patterns
- **Permissions**: Read-only (contents, pull-requests, issues, id-token)
- **System Instructions**: Configured to look in .claude/commands/ and .claude/agents/

### 2. PR Review (`claude-review.yml`)
- **Triggers**: PR opened, synchronized, reopened, ready for review
- **Purpose**: Automated PR reviews with inline comments
- **Permissions**: Read contents, write pull-requests, id-token

## Usage

### Triggering Claude

In issue comments, PR comments, or PR reviews (natural language):

```
@claude help
@claude please create a new specification for the user authentication feature
@claude implement the feature described in spec-1234.md
@claude analyze this function and suggest improvements
```

**Note**: Claude will recognize patterns from `.claude/commands/` if they're version controlled and you use similar language. The system prompt instructs Claude to check these directories.

### PR Reviews

Reviews trigger automatically when PRs are opened or updated. Claude will:
- Review code changes
- Add inline comments on specific lines
- Suggest improvements
- Check for issues

## Verify Setup

1. **Check workflow files exist:**
   ```bash
   ls .github/workflows/claude.yml
   ls .github/workflows/claude-review.yml
   ```

2. **Verify secret is set:**
   ```bash
   gh secret list | grep -E "ANTHROPIC_API_KEY|CLAUDE_CODE_OAUTH_TOKEN"
   ```

3. **Test the integration:**
   - Create a test issue
   - Comment with `@claude help`
   - Check the Actions tab for workflow runs
   - Verify Claude responds in the issue

## Troubleshooting

### Workflow not triggering

**Check workflow status:**
```bash
# View recent workflow runs
gh run list --workflow=claude.yml

# Check for errors
gh run view [run-id]
```

**Common causes:**
- Workflows disabled in repository settings
- @claude mention not detected (check syntax)
- Workflow permissions insufficient
- Branch protection rules blocking workflow

### Authentication errors

**Symptoms:** "Authentication failed" or "Invalid API key"

**Solutions:**
- Verify secret is set correctly: `gh secret list`
- Check API key is valid in Anthropic Console
- Ensure secret name matches exactly (case-sensitive)
- Re-set the secret: `gh secret set ANTHROPIC_API_KEY`

### Permission errors

**Symptoms:** "Resource not accessible" or "Permission denied"

**Solutions:**
- Check workflow permissions in `.github/workflows/claude.yml`
- Verify repository settings allow Actions to create PRs/comments
- Ensure GitHub App (if used) has correct permissions
- Check organization settings don't restrict Actions

### Rate limiting

**Symptoms:** "Rate limit exceeded"

**Solutions:**
- If using API key: Check Anthropic Console for usage
- If using OAuth: May hit Claude Pro/Max rate limits
- Consider implementing caching or throttling
- Space out multiple @claude mentions

### No response from Claude

**Check:**
1. Workflow ran successfully (Actions tab)
2. Authentication working (check logs)
3. @claude mention detected (check conditional)
4. No errors in workflow output
5. Comment permissions working

**Debug:**
```bash
# View workflow logs
gh run view [run-id] --log

# Check failed runs
gh run list --workflow=claude.yml --status=failure
```

## Security Best Practices

1. **Never commit secrets** to the repository
   - Always use GitHub Secrets for API keys/tokens
   - Add `.env` and credential files to `.gitignore`

2. **Use minimal permissions** in workflows
   - Only request permissions actually needed
   - Prefer read-only when possible

3. **Rotate credentials regularly**
   - Generate new API keys periodically
   - Update secrets after team changes

4. **Monitor usage**
   - Review workflow runs regularly
   - Check Anthropic Console for unexpected usage
   - Set up alerts for excessive runs

5. **Restrict workflow triggers** if needed
   - Limit to specific branches
   - Require review before running on PRs
   - Use `pull_request_target` carefully

## Advanced Configuration

### Custom allowed tools

Modify `claude.yml` to restrict which bash commands Claude can run:

```yaml
with:
  anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
  claude_args: |
    --allowedTools "Bash(npm test),Bash(npm run lint)"
    --model "claude-opus-4-20250514"
```

### Custom prompts

Modify `claude-review.yml` to customize review behavior:

```yaml
with:
  anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
  prompt: "/review-pr with focus on security REPO: ${{ github.repository }} PR_NUMBER: ${{ github.event.pull_request.number }}"
```

## Additional Resources

- **Official Setup Guide**: https://github.com/anthropics/claude-code-action/blob/main/docs/setup.md
- **Claude Code Action Repository**: https://github.com/anthropics/claude-code-action
- **Anthropic API Documentation**: https://docs.anthropic.com/
- **GitHub Actions Documentation**: https://docs.github.com/en/actions
- **Agent OS Documentation**: See `agent-os/automations/README.md`

## Getting Help

1. Check the troubleshooting section above
2. Review workflow logs in Actions tab
3. Consult official documentation
4. Check Agent OS documentation: `agent-os/automations/README.md`
