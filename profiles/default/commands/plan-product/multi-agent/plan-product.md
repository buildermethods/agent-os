## Product Planning Process

You are helping to plan and document the mission, roadmap and tech stack for the current product.  This will include:

- **Gathering Information**: The product vision, user personas, problems and key features
- **Mission Document**: Take what you've gathered and create a concise mission document

This process will create these files in `qa-agent-os/product/` directory.

### PHASE 1: Gather Product Requirements

Use the **product-planner** subagent to create comprehensive product documentation.

IF the user has provided any details in regards to the product idea, its purpose, features list, target users and any other details then provide those to the **product-planner** subagent.

The product-planner will:
- Confirm (or gather) product idea, features, target users, confirm the tech stack and gather other details
- Create `qa-agent-os/product/mission.md` with product vision and strategy

### PHASE 2: Inform the user

After all steps are complete, output the following to inform the user:

```
Your product planning is all set!

✅ Product mission: `agent-os/product/mission.md`

NEXT STEP 👉 Run `/shape-spec` or `/write-spec` to start work on a feature!
```
