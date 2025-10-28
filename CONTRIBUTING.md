# Contributing to Agent-OS Profiles

Thank you for contributing to our shared coding standards\!

## Philosophy

Our standards follow these principles:

1. **Subtract First** - Remove complexity before adding
2. **Explicit over Implicit** - Clear is better than clever
3. **Examples over Explanation** - Show, don't just tell
4. **Why over What** - Explain rationale, not just rules
5. **Practical over Theoretical** - Based on real problems we've faced

## How to Propose Changes

### 1. Identify the Need

Good reasons to change standards:
- ✅ Discovered a better pattern through experience
- ✅ Found a common mistake that needs guidance
- ✅ Language/tool version changed (e.g., Zig 0.15.1 → 0.16.0)
- ✅ Clarify ambiguous guidance
- ✅ Add missing guidance for common scenarios

Poor reasons:
- ❌ Personal preference without clear benefit
- ❌ Theoretical "best practice" without real-world validation
- ❌ Copying from another project without context
- ❌ Adding complexity without clear value

### 2. Create a Branch

```bash
cd ~/agent-os/profiles/agent-os-profiles
git checkout master
git pull
git checkout -b descriptive-branch-name
```

Branch naming:
- `update-cpp-smart-pointers` - Updating existing guideline
- `add-zig-testing-patterns` - Adding new guideline
- `fix-just-typos` - Documentation fix

### 3. Make Your Changes

**For guideline updates:**
- Edit the relevant `.md` file in `pas-clients/standards/`
- Use clear, concise language
- Provide code examples (✅ DO / ❌ DON'T format)
- Explain WHY, not just WHAT

**For new guidelines:**
- Consider: Is this really needed? (Subtract First)
- Place in appropriate file (backend/cpp-guidelines.md, etc.)
- Follow existing format and style
- Provide multiple examples

**Always update CHANGELOG.md:**
```markdown
## [Unreleased]

### Changed
- **C++ Guidelines**: Updated smart pointer guidance to prefer `std::unique_ptr` 
  over `std::shared_ptr` for single ownership. Rationale: Clearer ownership 
  semantics and better performance.
```

### 4. Self-Review Checklist

Before creating PR:
- [ ] Read your changes out loud - does it make sense?
- [ ] Check spelling and grammar
- [ ] Verify code examples compile (if applicable)
- [ ] Ensure consistency with existing standards
- [ ] Updated CHANGELOG.md
- [ ] Considered impact on existing code
- [ ] Provided clear rationale

### 5. Create Pull Request

```bash
git add .
git commit -m "Update C++ guidelines: Prefer unique_ptr for single ownership"
git push origin your-branch-name
```

Then on GitHub:
1. Create pull request
2. Fill out the PR template completely
3. Request review from relevant code owners
4. Be responsive to feedback

### 6. Review Process

**What reviewers look for:**
- Is the rationale clear and compelling?
- Are examples correct and helpful?
- Is this consistent with our philosophy?
- What's the impact on existing code?
- Are there edge cases not covered?

**Expected timeline:**
- Initial review: 2-3 business days
- Discussion/iteration: As needed
- Approval and merge: When consensus reached

**Consensus building:**
- At least 1 approval required
- No unresolved objections
- Code owners must approve changes to their areas

## Types of Changes

### Minor Changes (Fast Track)

Can be merged quickly with 1 approval:
- Typo fixes
- Formatting improvements
- Clarifying existing guidance (no semantic change)
- Adding examples to existing guidelines

### Major Changes (Full Review)

Require thorough review and discussion:
- New guidelines
- Changing existing recommendations
- Deprecating patterns
- Language version updates

### Breaking Changes

Require team meeting/discussion:
- Removing guidelines
- Reversing previous recommendations
- Changes that require refactoring existing code

## Writing Good Standards

### Structure

```markdown
### Topic Name

Brief explanation of what this is about.

**✅ DO:**
\`\`\`cpp
// Good example with comments explaining why
const auto result = calculateValue();
\`\`\`

**❌ DON'T:**
\`\`\`cpp
// Bad example with comments explaining the problem
auto result = calculateValue();  // Missing const
\`\`\`

**Why:** Clear explanation of the rationale. Reference authoritative sources
when applicable (C++ Core Guidelines, Zig documentation, etc.)
```

### Good Examples

**Clear and specific:**
```markdown
**✅ DO:** Use `std::unique_ptr` for single ownership
**❌ DON'T:** Use `std::shared_ptr` when ownership is not shared
```

**Vague and unhelpful:**
```markdown
**✅ DO:** Use smart pointers
**❌ DON'T:** Use raw pointers
```

### Rationale

Always explain WHY:
- "Prevents memory leaks" ✅
- "Better performance" ✅
- "Clearer intent" ✅
- "Industry best practice" ❌ (too vague)
- "Everyone does it this way" ❌ (appeal to popularity)

## Reviewing PRs

### As a Reviewer

**Your responsibilities:**
1. Understand the proposed change
2. Evaluate the rationale
3. Consider impact on existing code
4. Check for consistency
5. Suggest improvements
6. Approve or request changes

**Good review comments:**
```
"Great addition\! Could you add an example showing how this handles 
error cases?"

"I'm concerned this might conflict with our existing guidance on X. 
Can we clarify the relationship?"

"The rationale makes sense, but I think we should also mention the 
performance implications."
```

**Poor review comments:**
```
"I don't like this." (no rationale)
"We've always done it the other way." (appeal to tradition)
"This is too complicated." (without suggesting alternative)
```

### Resolving Disagreements

1. **Discuss in PR comments** - Most issues resolved here
2. **Bring data** - Real code examples, performance measurements
3. **Seek compromise** - Can we meet in the middle?
4. **Escalate if needed** - Team meeting for major disagreements
5. **Document decision** - Record rationale in PR or issue

## Maintenance

### Regular Reviews

Standards should be reviewed periodically:
- **Quarterly**: Quick review of recent changes
- **Annually**: Comprehensive review of all standards
- **Version updates**: When languages/tools update

### Deprecation Process

When deprecating a guideline:
1. Mark as deprecated in the standard
2. Explain why it's deprecated
3. Provide migration path
4. Keep deprecated guidance for 6 months
5. Remove after grace period

Example:
```markdown
### ~~Old Pattern~~ (Deprecated)

**This pattern is deprecated as of 2025-10-28.**

**Migration:** Use [new pattern] instead. See [link to new guidance].

**Rationale:** [Why we're moving away from this]

**Old guidance preserved for reference:**
[...]
```

## Questions?

- Check existing issues for similar discussions
- Ask in team chat
- Open an issue for discussion before major changes
- Tag relevant code owners

## Thank You\!

Your contributions make our codebase better for everyone. We appreciate your time and expertise\!
