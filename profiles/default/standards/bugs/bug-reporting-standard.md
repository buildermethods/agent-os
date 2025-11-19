# Bug Reporting Standard

High-quality bug reports reduce back-and-forth and speed up fixes. Follow this standard for all bug reports.

## 1. Bug Report Structure

| Field | Description |
| :--- | :--- |
| **Title** | `[Component] Short Description of the Issue` |
| **Severity** | Impact on the system (Blocker, Critical, Major, Minor) |
| **Priority** | Urgency of fix (P1, P2, P3, P4) |
| **Environment** | OS, Browser, Environment (Dev/Staging/Prod) |
| **Preconditions** | State before the bug occurred |
| **Steps to Reproduce** | Clear, numbered steps to trigger the bug |
| **Expected Result** | What *should* have happened |
| **Actual Result** | What *actually* happened |
| **Evidence** | Logs, Screenshots, Videos |

## 2. Severity Definitions

- **Blocker**: System unusable. Cannot proceed with testing.
- **Critical**: Major feature broken, no workaround. Data loss.
- **Major**: Major feature broken, but workaround exists.
- **Minor**: Minor annoyance, cosmetic issue.

## 3. Evidence Rules

- **Logs**: Always attach relevant log snippets or files.
- **Screenshots**: Required for UI issues. Annotate if possible.
- **Privacy**: Redact sensitive PII/credentials from evidence.

## 4. Example

```markdown
**Title**: [Checkout] Submit Order fails with 500 Error
**Severity**: Critical
**Priority**: P1
**Environment**: Staging, Chrome 120
**Steps to Reproduce**:
1. Add item to cart.
2. Proceed to checkout.
3. Click "Submit Order".
**Expected Result**: Order confirmation page is shown.
**Actual Result**: "Internal Server Error" toast message appears.
**Evidence**:
[Log Snippet]
Error: Transaction failed at PaymentGateway.process (line 45)
```
