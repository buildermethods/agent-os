# Requirement Analysis Workflow

This workflow guides the agent in performing a detailed analysis of the requirements for a specific ticket.

## Core Responsibilities

1.  **Context Gathering**: Understand the high-level product mission.
2.  **Input Analysis**: Process the BRD, PRD, or feature description provided by the user.
3.  **Clarification**: Ask targeted questions to resolve ambiguities and gather visual assets.
4.  **Documentation**: Save all gathered information into a structured `requirements.md` file within the ticket's directory.

**Note:** The placeholder `[ticket-path]` in this workflow refers to the full path to the ticket being analyzed, for example: `qa-agent-os/features/2025-11-19-feature-name/TICKET-123`.

---

## Workflow

### Step 1: Understand Product Context

Before analyzing the specific ticket, understand the broader product context. This will help you ask more relevant questions and ensure the feature aligns with overall product goals.

1.  **Read Product Mission**: Load and review `qa-agent-os/product/mission.md` to understand:
    -   The product's overall mission and purpose.
    -   Target users and their primary use cases.
    -   Core problems the product aims to solve.
    -   The **Product Areas & Team Ownership** table (e.g., Cows = Investments, Chicks = Cards & Onboarding) so you can route open questions to the right squad.

### Step 2: Analyze Initial Requirements

1.  Ask the user for the Product Requirements Document (PRD), feature description, or any other relevant information for the ticket.
2.  You can also search for a high-level BRD in the feature's parent `documentation/` folder.

### Step 3: Generate First Round of Questions

Based on the initial requirements, generate 4-8 targeted, **numbered** questions to explore the requirements and suggest reasonable defaults.

**CRITICAL: Always include the visual asset request at the end of your questions.**

**Guidelines for Questions:**
- Frame questions as "I'm assuming X, is that correct?" to make them easy to answer.
- Propose sensible assumptions based on best practices.
- Always end with an open-ended question about what might be out of scope.

**Required Output Format:**
```
Based on the requirements for this ticket, I have some clarifying questions:

1. I assume [specific assumption about a requirement]. Is that correct, or should [alternative approach] be considered?
2. I'm thinking [specific technical or user flow approach]. Should we proceed with this, or is there another preferred method?
3. (Continue with your numbered questions...)
[Last question about what is out of scope.]

---
**Visual Assets Request:**
Do you have any design mockups, wireframes, or screenshots that could help guide the testing for this ticket?

If yes, please place them in the ticket's documentation folder: `[ticket-path]/documentation/`
```

**After outputting these questions, STOP and wait for the user's response.**

### Step 4: Process User's Answers & Visuals

After receiving the user's answers:

1.  **Store the Answers**: Keep the user's exact answers for later documentation.
2.  **Check for Visuals**: Run the following `ls` command to check for visual assets in the ticket's documentation folder, even if the user didn't mention any.
    ```bash
    # List all image files in the ticket's documentation folder.
    ls -1 "[ticket-path]/documentation/" | grep -E '\.(png|jpg|jpeg|gif|svg|pdf)$' || echo "No visual files found"
    ```
3.  **Analyze Visuals**: If files are found, analyze each one and document your key observations. Note if they appear to be low-fidelity (e.g., wireframes, sketches).

### Step 5: Save Complete Requirements

After all questions are answered, compile all the information you have gathered into a single file named `requirements.md` inside the ticket's `planning` directory: `[ticket-path]/planning/requirements.md`.

Use the following Markdown structure for the file:

```markdown
# Requirements for Ticket: [Ticket ID]

## 1. Initial Description
(User's original description of the ticket requirements)

## 2. Requirements Discussion

### Round 1 Questions

**Q1:** (First question you asked)
**A:** (User's answer)

**Q2:** (Second question you asked)
**A:** (User's answer)

(Continue for all questions)

## 3. Visual Assets

### Files Found:
- `filename.png`: (Your description of what the image shows)
- `filename2.jpg`: (Key elements you observed from your analysis)

(If no files were found, state: "No visual assets were provided for this ticket.")

## 4. Final Requirements Summary
(Provide a concise, bulleted summary of the final, agreed-upon requirements for the ticket based on all the information gathered.)
```
