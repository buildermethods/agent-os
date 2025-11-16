# Task Breakdown Examples

This document shows real-world examples of task breakdowns for different types of features. Use these as reference when creating your own task lists.

## Example 1: Simple CRUD Feature

**Feature**: User Profile Management

**Complexity**: Low (12 tasks)

**Stack**: Rails + React

```markdown
# Task Breakdown: User Profile Management

## Overview
Total Tasks: 12
Estimated Complexity: Low
Primary Stack: Rails + React

## Task List

### Database Layer

#### Task Group 1: Profile Model
**Dependencies:** None

- [ ] 1.0 Complete profile data model
  - [ ] 1.1 Write 3 focused tests for Profile model
    - Test profile creation with valid attributes
    - Test biography length validation (max 500 chars)
    - Test association with User model
  - [ ] 1.2 Create Profile model
    - Fields: user_id (integer), biography (text), location (string), website (string)
    - Validations: biography max length 500, website URL format
    - Reuse pattern from: app/models/user.rb
  - [ ] 1.3 Create migration for profiles table
    - Add index for user_id
    - Foreign key to users table
    - Add timestamps
  - [ ] 1.4 Ensure database tests pass
    - Run the 3 tests from 1.1
    - Verify migration runs successfully

**Acceptance Criteria:**
- All 3 tests pass
- Migration creates table successfully
- Profile belongs_to User association works

### API Layer

#### Task Group 2: Profile API
**Dependencies:** Task Group 1

- [ ] 2.0 Complete profile API endpoints
  - [ ] 2.1 Write 4 focused tests for ProfilesController
    - Test GET /api/v1/profile returns current user's profile
    - Test PATCH /api/v1/profile updates profile successfully
    - Test PATCH with invalid data returns 422 error
    - Test unauthorized access returns 401
  - [ ] 2.2 Create ProfilesController
    - Actions: show, update
    - Route: /api/v1/profile (singular resource)
    - Follow pattern from: app/controllers/api/v1/users_controller.rb
  - [ ] 2.3 Add authorization
    - Require authentication for all actions
    - Users can only access their own profile
  - [ ] 2.4 Ensure API tests pass
    - Run the 4 tests from 2.1
    - Verify CRUD operations work

**Acceptance Criteria:**
- All 4 tests pass
- Profile can be retrieved and updated via API
- Proper authorization enforced

### Frontend

#### Task Group 3: Profile UI
**Dependencies:** Task Group 2

- [ ] 3.0 Complete profile user interface
  - [ ] 3.1 Write 3 focused tests for Profile component
    - Test profile displays user data correctly
    - Test edit form submission updates profile
    - Test form validation for max biography length
  - [ ] 3.2 Create ProfileView component
    - Location: src/components/ProfileView.jsx
    - Props: profile, onEdit
    - Display: biography, location, website
  - [ ] 3.3 Create ProfileEditForm component
    - Fields: biography (textarea), location (text), website (url)
    - Client-side validation: biography max 500 chars
    - Submit to PATCH /api/v1/profile
  - [ ] 3.4 Ensure UI tests pass
    - Run the 3 tests from 3.1
    - Verify profile displays and updates

**Acceptance Criteria:**
- All 3 tests pass
- Profile displays correctly
- Edit form validates and submits successfully

## Execution Order
1. Database Layer (Task Group 1) - 1 hour
2. API Layer (Task Group 2) - 2 hours
3. Frontend (Task Group 3) - 2 hours
```

---

## Example 2: Integration Feature

**Feature**: Stripe Payment Integration

**Complexity**: Medium (20 tasks)

**Stack**: Node.js + Express + React

```markdown
# Task Breakdown: Stripe Payment Integration

## Overview
Total Tasks: 20
Estimated Complexity: Medium
Primary Stack: Node.js + Express + React + Stripe

## Task List

### Configuration

#### Task Group 1: Stripe Setup
**Dependencies:** None

- [ ] 1.0 Complete Stripe configuration
  - [ ] 1.1 Add Stripe credentials to environment
    - STRIPE_SECRET_KEY for server
    - STRIPE_PUBLISHABLE_KEY for client
    - STRIPE_WEBHOOK_SECRET for webhooks
  - [ ] 1.2 Install Stripe SDK
    - Server: npm install stripe
    - Client: npm install @stripe/stripe-js @stripe/react-stripe-js
  - [ ] 1.3 Create Stripe client wrapper
    - Location: src/lib/stripe.js
    - Initialize with secret key
    - Reuse pattern from: src/lib/sendgrid.js

**Acceptance Criteria:**
- Environment variables configured
- Stripe SDKs installed
- Stripe client initialized successfully

### Database Layer

#### Task Group 2: Payment Data Models
**Dependencies:** Task Group 1

- [ ] 2.0 Complete payment models
  - [ ] 2.1 Write 4 focused tests for Payment model
    - Test payment creation with Stripe data
    - Test amount validation (must be positive)
    - Test status enum values
    - Test user association
  - [ ] 2.2 Create Payment model
    - Fields: user_id, stripe_payment_id, amount, currency, status, metadata (JSON)
    - Validations: amount > 0, status in ['pending', 'succeeded', 'failed']
    - Reuse pattern from: models/Order.js
  - [ ] 2.3 Create payments table migration
    - Add indexes for user_id and stripe_payment_id
    - Add foreign key to users table
    - Add timestamps
  - [ ] 2.4 Ensure database tests pass
    - Run the 4 tests from 2.1
    - Verify migration runs successfully

**Acceptance Criteria:**
- All 4 tests pass
- Migration creates table successfully
- Payment model validates correctly

### API Layer

#### Task Group 3: Payment API Endpoints
**Dependencies:** Task Group 2

- [ ] 3.0 Complete payment API
  - [ ] 3.1 Write 5 focused tests for payments API
    - Test POST /api/payments/intent creates payment intent
    - Test POST /api/payments/confirm confirms payment
    - Test unauthorized access returns 401
    - Test invalid amount returns 400
    - Test Stripe error handling
  - [ ] 3.2 Create PaymentsController
    - Actions: createIntent, confirmPayment, getPayments
    - Routes: POST /api/payments/intent, POST /api/payments/confirm, GET /api/payments
    - Follow pattern from: controllers/OrdersController.js
  - [ ] 3.3 Implement createIntent action
    - Call Stripe API to create payment intent
    - Save payment record with 'pending' status
    - Return client_secret to frontend
  - [ ] 3.4 Implement confirmPayment action
    - Verify payment with Stripe
    - Update payment status to 'succeeded' or 'failed'
    - Handle errors and retries
  - [ ] 3.5 Add error handling
    - Catch Stripe API errors
    - Return appropriate HTTP status codes
    - Log errors for debugging
  - [ ] 3.6 Ensure API tests pass
    - Run the 5 tests from 3.1
    - Verify all endpoints work

**Acceptance Criteria:**
- All 5 tests pass
- Payment intents can be created
- Payments can be confirmed
- Proper error handling implemented

### Webhook Handling

#### Task Group 4: Stripe Webhooks
**Dependencies:** Task Group 3

- [ ] 4.0 Complete webhook handling
  - [ ] 4.1 Write 3 focused tests for webhook handler
    - Test payment_intent.succeeded updates status
    - Test payment_intent.failed updates status
    - Test invalid signature returns 400
  - [ ] 4.2 Create webhook endpoint
    - Route: POST /api/webhooks/stripe
    - Verify Stripe signature
    - Handle payment events
  - [ ] 4.3 Implement event handlers
    - payment_intent.succeeded: update payment status
    - payment_intent.failed: update payment status, notify user
    - Handle idempotency (don't process same event twice)
  - [ ] 4.4 Ensure webhook tests pass
    - Run the 3 tests from 4.1
    - Test with Stripe CLI webhook forwarding

**Acceptance Criteria:**
- All 3 tests pass
- Webhook verifies Stripe signature
- Payment status updates correctly
- Idempotent event processing

### Frontend

#### Task Group 5: Payment UI
**Dependencies:** Task Group 3

- [ ] 5.0 Complete payment UI
  - [ ] 5.1 Write 3 focused tests for payment components
    - Test payment form renders
    - Test successful payment submission
    - Test error display on payment failure
  - [ ] 5.2 Create PaymentForm component
    - Location: src/components/PaymentForm.jsx
    - Use Stripe Elements for card input
    - Props: amount, onSuccess, onError
  - [ ] 5.3 Implement payment flow
    - Create payment intent on mount
    - Submit payment with Stripe
    - Confirm payment with backend
    - Handle loading and error states
  - [ ] 5.4 Add payment status page
    - Location: src/pages/PaymentStatus.jsx
    - Show success or failure message
    - Display payment details
  - [ ] 5.5 Ensure UI tests pass
    - Run the 3 tests from 5.1
    - Test end-to-end flow in browser

**Acceptance Criteria:**
- All 3 tests pass
- Payment form works with Stripe
- Success and error states display correctly
- End-to-end payment flow works

## Execution Order
1. Configuration (Task Group 1) - 1 hour
2. Database Layer (Task Group 2) - 2 hours
3. API Layer (Task Group 3) - 4 hours
4. Webhook Handling (Task Group 4) - 3 hours
5. Frontend (Task Group 5) - 3 hours

## Notes
- Test with Stripe test mode keys
- Use Stripe CLI for local webhook testing
- Document test card numbers for QA
- Set up Stripe webhook endpoint in dashboard after deployment
```

---

## Example 3: Frontend-Only Feature

**Feature**: Dark Mode Toggle

**Complexity**: Low (8 tasks)

**Stack**: React + CSS

```markdown
# Task Breakdown: Dark Mode Toggle

## Overview
Total Tasks: 8
Estimated Complexity: Low
Primary Stack: React + CSS Variables

## Task List

### Theme System

#### Task Group 1: Theme Infrastructure
**Dependencies:** None

- [ ] 1.0 Complete theme system setup
  - [ ] 1.1 Define CSS variables for themes
    - Location: src/styles/themes.css
    - Light theme: --bg-primary, --text-primary, etc.
    - Dark theme: --bg-primary-dark, --text-primary-dark, etc.
  - [ ] 1.2 Create ThemeProvider context
    - Location: src/contexts/ThemeContext.jsx
    - State: theme ('light' | 'dark')
    - Methods: toggleTheme()
    - Persist to localStorage
  - [ ] 1.3 Apply theme class to document
    - Add data-theme attribute to <html>
    - CSS reads from data-theme="light" or "dark"

**Acceptance Criteria:**
- CSS variables defined for both themes
- ThemeProvider context created
- Theme persists across page reloads

### UI Components

#### Task Group 2: Theme Toggle Component
**Dependencies:** Task Group 1

- [ ] 2.0 Complete theme toggle UI
  - [ ] 2.1 Write 2 focused tests for ThemeToggle
    - Test toggle switches theme
    - Test icon changes based on theme
  - [ ] 2.2 Create ThemeToggle component
    - Location: src/components/ThemeToggle.jsx
    - Display: Sun icon for light, Moon icon for dark
    - Style: Animated transition between states
  - [ ] 2.3 Add to navigation
    - Add ThemeToggle to Header component
    - Position: Top right corner
    - Reuse pattern from: other header buttons
  - [ ] 2.4 Ensure tests pass
    - Run the 2 tests from 2.1

**Acceptance Criteria:**
- Tests pass
- Toggle button displays correctly
- Clicking toggles theme
- Icon animates on change

### Styling

#### Task Group 3: Component Theme Support
**Dependencies:** Task Group 2

- [ ] 3.0 Update components to use theme variables
  - [ ] 3.1 Update global styles
    - Replace hardcoded colors with CSS variables
    - Ensure all backgrounds use --bg-* variables
    - Ensure all text uses --text-* variables
  - [ ] 3.2 Update component styles
    - Update Button, Card, Modal, Form components
    - Use CSS variables for all colors
    - Test in both light and dark modes
  - [ ] 3.3 Add transition effects
    - Add CSS transition for smooth theme changes
    - Duration: 200ms
    - Properties: background-color, color, border-color

**Acceptance Criteria:**
- All components render correctly in both themes
- No hardcoded colors remain
- Smooth transitions between themes
- Contrast ratios meet WCAG AA standards

## Execution Order
1. Theme System (Task Group 1) - 1 hour
2. UI Components (Task Group 2) - 1 hour
3. Styling (Task Group 3) - 2 hours

## Notes
- Test in different browsers (Chrome, Firefox, Safari)
- Verify system theme preference detection
- Ensure accessibility for theme toggle
```

---

## Example 4: Complex Multi-Layer Feature

**Feature**: Real-Time Notifications System

**Complexity**: High (35 tasks)

**Stack**: Rails + PostgreSQL + Redis + Action Cable + React

```markdown
# Task Breakdown: Real-Time Notifications System

## Overview
Total Tasks: 35
Estimated Complexity: High
Primary Stack: Rails + PostgreSQL + Redis + Action Cable + React

## Task List

### Database Layer

#### Task Group 1: Notifications Data Model
**Dependencies:** None

- [ ] 1.0 Complete notifications data model
  - [ ] 1.1 Write 5 focused tests for Notification model
    - Test notification creation
    - Test read/unread status
    - Test user association
    - Test notification types enum
    - Test query scopes (unread, recent)
  - [ ] 1.2 Create Notification model
    - Fields: user_id, type, title, body, read_at, related_type, related_id, metadata (JSON)
    - Validations: presence of user_id, type, title
    - Scopes: unread, recent (last 30 days)
  - [ ] 1.3 Create notifications table migration
    - Add indexes for user_id, created_at, read_at
    - Add composite index on (user_id, read_at)
    - Add foreign key to users table
  - [ ] 1.4 Set up polymorphic associations
    - Notification belongs_to :related, polymorphic: true
    - User has_many :notifications
  - [ ] 1.5 Ensure database tests pass

**Acceptance Criteria:**
- All 5 tests pass
- Notifications table created
- Associations work correctly
- Query scopes return correct results

### API Layer

#### Task Group 2: Notifications API
**Dependencies:** Task Group 1

- [ ] 2.0 Complete notifications API endpoints
  - [ ] 2.1 Write 6 focused tests for NotificationsController
    - Test GET /api/notifications returns user's notifications
    - Test GET /api/notifications/unread returns only unread
    - Test PATCH /api/notifications/:id/read marks as read
    - Test PATCH /api/notifications/read_all marks all as read
    - Test DELETE /api/notifications/:id deletes notification
    - Test unauthorized access returns 401
  - [ ] 2.2 Create NotificationsController
    - Actions: index, unread, mark_read, mark_all_read, destroy
    - Routes: /api/notifications with member and collection actions
    - Pagination: 20 notifications per page
    - Follow pattern from: app/controllers/api/v1/base_controller.rb
  - [ ] 2.3 Implement query optimizations
    - Eager load polymorphic associations
    - Use pagination to limit results
    - Order by created_at DESC
  - [ ] 2.4 Add response formatting
    - Include related object data in response
    - Format timestamps consistently
    - Include unread_count in response
  - [ ] 2.5 Ensure API tests pass

**Acceptance Criteria:**
- All 6 tests pass
- API returns paginated notifications
- Mark as read functionality works
- Proper authorization enforced
- Query performance < 100ms

### WebSocket Layer

#### Task Group 3: Real-Time Broadcasting
**Dependencies:** Task Group 2

- [ ] 3.0 Complete real-time notification broadcasting
  - [ ] 3.1 Write 4 focused tests for NotificationChannel
    - Test user subscribes to their notification channel
    - Test notification broadcast to subscribed user
    - Test user cannot subscribe to other user's channel
    - Test unsubscribe on disconnect
  - [ ] 3.2 Create NotificationChannel
    - Location: app/channels/notification_channel.rb
    - Stream: "notifications_user_#{user.id}"
    - Authorization: user can only subscribe to own channel
    - Follow pattern from: app/channels/application_cable/channel.rb
  - [ ] 3.3 Create NotificationBroadcastJob
    - Location: app/jobs/notification_broadcast_job.rb
    - Broadcast new notification to user's channel
    - Include full notification data with associations
  - [ ] 3.4 Add after_create callback to Notification
    - Trigger NotificationBroadcastJob after creation
    - Pass notification ID to job
  - [ ] 3.5 Configure Redis for Action Cable
    - Update cable.yml with Redis configuration
    - Use separate Redis database for cables
  - [ ] 3.6 Ensure WebSocket tests pass

**Acceptance Criteria:**
- All 4 tests pass
- Users receive notifications in real-time
- Broadcasts only to correct user
- Redis configured correctly

### Service Layer

#### Task Group 4: Notification Services
**Dependencies:** Task Group 3

- [ ] 4.0 Complete notification service layer
  - [ ] 4.1 Write 5 focused tests for NotificationService
    - Test create_notification creates and broadcasts
    - Test notify_user_of_comment creates correct notification type
    - Test notify_user_of_mention creates correct notification type
    - Test notify_user_of_follower creates correct notification type
    - Test batch notification creation
  - [ ] 4.2 Create NotificationService
    - Location: app/services/notification_service.rb
    - Methods: create_notification, notify_user_of_*
    - Handle different notification types
    - Reuse pattern from: app/services/base_service.rb
  - [ ] 4.3 Implement notification type handlers
    - comment: notify post author of new comment
    - mention: notify mentioned user
    - follower: notify user of new follower
    - like: notify content creator of new like
  - [ ] 4.4 Add notification grouping logic
    - Group similar notifications (e.g., "3 people liked your post")
    - Update existing notification instead of creating duplicate
  - [ ] 4.5 Ensure service tests pass

**Acceptance Criteria:**
- All 5 tests pass
- NotificationService creates typed notifications
- Notification grouping works correctly
- Service integrates with broadcast system

### Integration Points

#### Task Group 5: Trigger Notifications from Features
**Dependencies:** Task Group 4

- [ ] 5.0 Integrate notifications with existing features
  - [ ] 5.1 Add to Comments feature
    - After comment creation, notify post author
    - Call NotificationService.notify_user_of_comment
    - Location: app/controllers/comments_controller.rb
  - [ ] 5.2 Add to Mentions feature
    - After mention creation, notify mentioned user
    - Call NotificationService.notify_user_of_mention
    - Location: app/services/mention_parser.rb
  - [ ] 5.3 Add to Followers feature
    - After follow creation, notify followed user
    - Call NotificationService.notify_user_of_follower
    - Location: app/controllers/follows_controller.rb
  - [ ] 5.4 Add to Likes feature
    - After like creation, notify content creator
    - Call NotificationService.notify_user_of_like
    - Location: app/controllers/likes_controller.rb
  - [ ] 5.5 Test integration points
    - Verify notifications created when actions occur
    - Check notifications contain correct data

**Acceptance Criteria:**
- Notifications triggered by all integrated features
- Correct notification type for each action
- Related objects properly associated

### Frontend - Notifications List

#### Task Group 6: Notifications UI Components
**Dependencies:** Task Group 5

- [ ] 6.0 Complete notifications display UI
  - [ ] 6.1 Write 4 focused tests for notifications UI
    - Test NotificationsList renders notifications
    - Test marking notification as read
    - Test empty state display
    - Test notification grouping display
  - [ ] 6.2 Create NotificationsList component
    - Location: src/components/NotificationsList.jsx
    - Props: notifications, onMarkRead, onMarkAllRead
    - Display: List of notifications with avatars and actions
  - [ ] 6.3 Create NotificationItem component
    - Location: src/components/NotificationItem.jsx
    - Props: notification, onMarkRead
    - Display different layouts for different types
    - Include time ago, read/unread indicator
  - [ ] 6.4 Create NotificationsEmptyState component
    - Display when no notifications exist
    - Friendly message and icon
  - [ ] 6.5 Ensure UI tests pass

**Acceptance Criteria:**
- All 4 tests pass
- Notifications display correctly
- Empty state displays when no notifications
- Visual distinction between read/unread

### Frontend - Real-Time Updates

#### Task Group 7: WebSocket Connection
**Dependencies:** Task Group 6

- [ ] 7.0 Complete real-time notification updates
  - [ ] 7.1 Write 3 focused tests for WebSocket integration
    - Test connection to NotificationChannel
    - Test receiving notification updates UI
    - Test unread count updates
  - [ ] 7.2 Create useNotifications hook
    - Location: src/hooks/useNotifications.js
    - Connect to Action Cable NotificationChannel
    - Listen for new notifications
    - Update local state on receive
  - [ ] 7.3 Integrate with NotificationsList
    - Use useNotifications hook
    - Prepend new notifications to list
    - Show toast/badge for new notifications
    - Update unread count in real-time
  - [ ] 7.4 Add connection state handling
    - Show "connecting" state
    - Handle connection errors
    - Retry connection on failure
  - [ ] 7.5 Ensure WebSocket tests pass

**Acceptance Criteria:**
- All 3 tests pass
- WebSocket connects successfully
- New notifications appear in real-time
- Unread count updates without refresh

### Frontend - Notifications Dropdown

#### Task Group 8: Notifications Menu
**Dependencies:** Task Group 7

- [ ] 8.0 Complete notifications dropdown menu
  - [ ] 8.1 Write 3 focused tests for dropdown
    - Test dropdown opens on click
    - Test shows recent notifications
    - Test "See All" link navigates to full page
  - [ ] 8.2 Create NotificationsDropdown component
    - Location: src/components/NotificationsDropdown.jsx
    - Display: Recent 5 notifications
    - Include "See All" and "Mark All Read" actions
  - [ ] 8.3 Add NotificationBell icon to header
    - Location: src/components/Header.jsx
    - Show unread count badge
    - Trigger dropdown on click
    - Animate bell on new notification
  - [ ] 8.4 Style dropdown
    - Match existing dropdown style
    - Position: Right-aligned under bell icon
    - Include scrolling for long lists
  - [ ] 8.5 Ensure dropdown tests pass

**Acceptance Criteria:**
- All 3 tests pass
- Dropdown opens/closes correctly
- Badge shows unread count
- Bell animates on new notification

### Testing & QA

#### Task Group 9: Integration Testing
**Dependencies:** Task Groups 1-8

- [ ] 9.0 Complete end-to-end testing
  - [ ] 9.1 Review existing tests from all groups
    - Total: approximately 30 tests already written
  - [ ] 9.2 Identify critical workflow gaps
    - Full notification flow from trigger to display
    - Real-time delivery across multiple clients
    - Notification grouping behavior
  - [ ] 9.3 Write up to 10 additional integration tests
    - Test complete flow: action → notification → broadcast → display
    - Test multiple users receiving notifications
    - Test notification preferences (if implemented)
    - Test performance with many notifications
  - [ ] 9.4 Run all feature tests
    - Run approximately 40 total tests
    - Verify all pass
    - Check for race conditions in WebSocket tests

**Acceptance Criteria:**
- All ~40 tests pass consistently
- Critical workflows fully tested
- Real-time functionality verified
- Performance acceptable

## Execution Order
1. Database Layer (Task Group 1) - 3 hours
2. API Layer (Task Group 2) - 4 hours
3. WebSocket Layer (Task Group 3) - 5 hours
4. Service Layer (Task Group 4) - 4 hours
5. Integration Points (Task Group 5) - 3 hours
6. Frontend - Notifications List (Task Group 6) - 4 hours
7. Frontend - Real-Time Updates (Task Group 7) - 4 hours
8. Frontend - Notifications Menu (Task Group 8) - 3 hours
9. Testing & QA (Task Group 9) - 4 hours

## Notes
- Test WebSocket connections in multiple browsers
- Monitor Redis memory usage
- Set up notification cleanup job (delete old notifications)
- Consider rate limiting for notification creation
- Plan for notification preferences in future
```

---

## Key Patterns Across Examples

### Consistent Structure

All examples follow the same pattern:

1. **Overview** - High-level summary
2. **Task Groups** - Organized by layer/responsibility
3. **Focused Testing** - 2-8 tests per group during development
4. **Acceptance Criteria** - Clear definition of done
5. **Execution Order** - Recommended sequence with time estimates

### Scaling Complexity

- **Simple features**: 1-3 task groups, 8-15 tasks total
- **Medium features**: 3-5 task groups, 15-25 tasks total
- **Complex features**: 6+ task groups, 25+ tasks total

### Task Group Dependencies

Always clearly state dependencies:

```markdown
**Dependencies:** None  # Can start immediately
**Dependencies:** Task Group 1  # Waits for one group
**Dependencies:** Task Groups 1-3  # Waits for multiple groups
```

### Testing Strategy

Consistent testing approach:

- **Development phase**: 2-8 focused tests per group
- **Run scope**: Only the tests for that specific group
- **Final phase**: Review all tests, add up to 10 more if needed
- **Total tests**: Generally 15-40 for entire feature

### Adaptation Flexibility

Notice how each example adapts the template:

- Backend-only feature removes frontend section
- Frontend-only feature removes database section
- Integration feature adds configuration and webhook sections
- Complex feature splits layers into multiple groups

## Tips for Using These Examples

1. **Don't copy blindly** - Use as inspiration, not templates
2. **Match your stack** - Adapt technology choices to your project
3. **Scale appropriately** - Simple features don't need complex breakdowns
4. **Be specific** - Replace generic placeholders with actual names
5. **Show patterns** - Reference existing code like the examples do
6. **Clear dependencies** - Make execution order obvious
7. **Realistic criteria** - Define achievable acceptance criteria
