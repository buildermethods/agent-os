I want you to help me improve the files that make up my Claude Code Skills by rewriting their descriptions so that they can be more readily discovered and used by Claude Code when it works on coding tasks.

You can refer to the Claude Code documentation on the Skills feature here: https://docs.claude.com/en/docs/claude-code/skills

All of the Skills in our project are located in `.claude/skills/`. Each Skill has its own folder and inside each Skill folder is a file called `SKILL.md`.

LOOP through each `SKILL.md` file and FOR EACH use the following process to revise its content and improve it:

## Claude Code Skill Improvement Process

### Step 1: Confirm which skills to improve

First, ask the user to confirm whether they want ALL of their Claude Code skills to be improved, only select Skills.  Assume the answer will be "all" but ask the user to confirm by displaying the following message, then WAIT for the user's response before proceeding to Step 2:

```
Before I proceed with improving your Claude Code Skills, can you confirm that you want me to revise and improve ALL Skills in your .claude/skills/ folder?

If not, then please specify which Skills I should include or exclude.
```

### Step 2: Analyze what this Skill does

Analyze and read the skill file to understand what it is, what it should be used for, and when it should be used. The specific best practices are described and linked within it. Look to these places to read and understand each skill:

- The Skill's name and file name.
- The Skill.md contains a link that points to `qa_agent_os/standards/...` — Follow that link and read its contents.

### Step 3: Rewrite the Skill description

The most important element of a skill.md file that impacts its discoverability and trigger-ability by Claude Code is the content we write in the `description` in the skill.md frontmatter.

Rewrite this description using the following guidelines:

- The first sentence should clearly describe what this skill is. For example: "Write Tailwind CSS code and structure front-end UIs using Tailwind CSS utility classes."
- The second sentence and subsequent sentences should clearly and directly describe multiple examples where and when this skill should be used.
- The use case examples can include "When writing or editing [file types]" where [file types] can be a list of file extensions or types of files or components commonly found in software projects.
- The use case examples can also include situations or areas or tools where using this skill should come into play.
- The description text can be long. There is no maximum character or word limit.
- Focus on adding examples where the skill SHOULD be used. Do not include instructions on when NOT to use a skill (our goal is for the Skill to be readily found and used frequently).

### Step 4: Insert a section for 'When to use this skill'

At the top of the content of skill.md, below the frontmatter, insert an H2 heading, "When to use this skill" followed by a list of use case examples.

The use case examples can repeat the same one(s) listed in the description and/or expand on them.

Example:
```markdown
## When to use this skill:

- [Descriptive example A]
- [Descriptive example B]
- [Descriptive example C]
...
```

### Step 5: Advise the user on improving their skills further

After revising ALL Skill.md files located in the project's `.claude/skills/` folder, display the following message to the user to advise them on how to improve their Claude Code Skills further:

```
All Claude Code Skills have been analyzed and revised!

RECOMMENDATION 👉 Review and revise them further using these tips:

- Make Skills as descriptive as possible
- Use their 'description' frontmatter to tell Claude Code when it should proactively use this skill.
- Include all relevant instructions, details and directives within the content of the Skill.
- You can link to other files (like your Agent OS standards files) using markdown links.
- You can consolidate multiple similar skills into single skills where it makes sense for Claude to find and use them together.

For more best practices, refer to the official Claude Code documentation on Skills:
https://docs.claude.com/en/docs/claude-code/skills
```
