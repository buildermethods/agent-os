# QA Standard – Test Case Structure

This standard defines the required structure for all test cases to ensure consistency, reproducibility, and clarity.

## Required Fields

| Field | Description | Example |
| :--- | :--- | :--- |
| **ID** | Unique identifier | `TC-LOGIN-001` |
| **Title** | Concise summary of the test | `Verify user can login with valid credentials` |
| **Description** | Detailed explanation of what is being tested | `Ensure that a registered user can access the dashboard after entering valid username and password.` |
| **Preconditions** | State of the system before testing | `1. User is registered. 2. Login page is open.` |
| **Test Data** | Specific data used | `Username: testuser, Password: Password123` |
| **Steps** | Numbered list of actions | `1. Enter username. 2. Enter password. 3. Click Login.` |
| **Expected Result** | Measurable outcome | `User is redirected to Dashboard. "Welcome" message is displayed.` |
| **Postconditions** | State of the system after testing | `User session is active.` |
| **Priority** | Importance of the test | `High / Medium / Low` |
| **Type** | Category of test | `Functional, UI, API, Security, Performance` |

## Writing Guidelines

1.  **Atomic Steps**: Each step should be a single action.
2.  **Clear Expectations**: Avoid vague results like "it works". Be specific: "Button turns green", "Modal closes".
3.  **Independence**: Test cases should be as independent as possible.
4.  **Edge Cases**: Always consider boundary values and invalid inputs.
    *   *Example*: Empty fields, max character limits, special characters.

## Example

```markdown
**ID**: TC-CART-005
**Title**: Verify item count updates when adding product
**Preconditions**: User is on product page. Cart is empty.
**Steps**:
1. Click "Add to Cart" button.
2. Observe the cart icon in the header.
**Expected Result**: Cart icon badge updates from 0 to 1. Toast message "Item added" appears.
```
