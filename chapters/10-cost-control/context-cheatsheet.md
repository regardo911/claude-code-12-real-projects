<!-- Written for this repo from chapter 10 (ch10:74-112). The chapter names this cheatsheet (ch10:231) but prints it in pieces. Quoted lines are the book's. The chapter's `--add-dir` tip is left out on purpose (BOOK-FIXES.md). -->

# Context cheatsheet

Read it before a session. The numbers are the author's (ch10:74-76): the context gets crowded after 20 to 30 exchanges, Claude Code is confused by 40, and by 60 a fresh session is cheaper.

## Five moves (ch10:82-90)

Every 10 to 15 exchanges, the checkpoint prompt:

```
Summarize what we've accomplished so far, what's left to do, and what decisions we've made. Then continue with the next task.
```

At the start, scope the session to named files:

```
we're only working on src/api/billing.ts and src/api/billing.test.ts in this session. Don't read or modify any other files unless I specifically ask.
```

Switching tasks: a new session that opens with a one-paragraph briefing (the book's example):

```
I'm working on a Next.js SaaS app. The auth system is complete. The billing system is in src/api/billing.ts and uses Stripe. I need you to add a webhook handler for subscription cancellations. The webhook secret is in .env as STRIPE_WEBHOOK_SECRET.
```

Every 15 to 20 exchanges, or when Claude Code repeats itself: `/compact`.

When the session is noisy:

```
Ignore all previous discussion. The only thing that matters right now is: [specific task]. Read [specific file] and [do specific thing].
```

Five exchanges on one problem without a fix: stop and read the error yourself. "Let me try a different approach" three times in a session means a loop; `/clear` and write a better prompt (ch11:41-47).

## Cheap prompts (ch10:96-112)

Expensive (ch10:96):

```
Make the user profile page look better.
```

Cheap, the same task (ch10:100):

```
In src/components/UserProfile.tsx, change the avatar to a 64px circle with a 2px solid border in #E5E7EB. Remove the bio section. Left-align the username.
```

- **Name the files.** "Edit src/api/users.ts" is cheaper than "find where the user API calls are and edit them." File discovery costs tokens.
- **Specify the change type.** "Add a function" vs "refactor the module." Adding is surgical. Refactoring means Claude reads everything, plans broadly, and writes extensively.
- **Set output constraints.** "Only show the changed lines" or "Don't explain, just make the change." Claude Code defaults to being helpful, which means verbose. Override that default when you don't need the explanation.
- **Break big tasks into small ones.** Instead of "build the entire checkout flow," use separate prompts: "Create the cart component," "Add the Stripe payment form," "Wire up the order confirmation email." Each prompt stays focused, and you can catch problems between steps instead of after a massive code dump.
