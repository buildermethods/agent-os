# Test Case Standard

This standard defines the required structure and generation guidelines for all test cases to ensure consistency, reproducibility, and importability into tools like Testmo.

## 1. Test Case Structure

All test cases must contain the following fields:

| Field | Description | Example |
| :--- | :--- | :--- |
| **ID** | Unique identifier | `TC-LOGIN-001` |
| **Title** | Concise summary | `Login - Enter Invalid Password - Show Error Message` |
| **Type** | Category | `Functional`, `Regression`, `API`, `Security`, `Performance` |
| **Priority** | Importance | `Critical`, `High`, `Medium`, `Low` |
| **Preconditions** | State before testing | `User is on Login Page` |
| **Steps** | Numbered list of actions | `1. Enter username...` |
| **Expected Result** | Measurable outcome | `Error message 'Invalid credentials' appears.` |
| **Postconditions** | State after testing | `User remains on Login Page` |

### Title Format
`[Module] - [Action] - [Expected Outcome]`

## 2. Writing Guidelines

1.  **Atomic Steps**: Each step should be a single action.
2.  **Clear Expectations**: Avoid vague results like "it works". Be specific.
3.  **Independence**: Test cases should be as independent as possible.

## 3. Coverage Checklist

Ensure you have generated cases for:
- [ ] **Happy Path**: The standard success flow.
- [ ] **Negative Path**: Invalid inputs, error states.
- [ ] **Boundary Values**: Min/Max limits, empty states.
- [ ] **Security**: Permissions, auth checks (if applicable).

## 4. Example

```markdown
**ID**: TC-CART-005
**Title**: Cart - Add Item - Update Count
**Type**: Functional
**Priority**: High
**Preconditions**: User is on product page. Cart is empty.
**Steps**:
1. Click "Add to Cart" button.
2. Observe the cart icon in the header.
**Expected Result**: Cart icon badge updates from 0 to 1. Toast message "Item added" appears.
```
