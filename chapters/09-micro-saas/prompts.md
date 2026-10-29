<!-- Chapter 9, verbatim from the book. The invoice-reminder Micro-SaaS, phase by phase.
     Not financial or business advice: the revenue figures in chapter 9 are the author's examples and do not predict yours. Twilio, Railway, Stripe fees and your domain cost real money. See DISCLAIMER.md. -->

# Chapter 9 prompts: a Micro-SaaS in a weekend

The running example is an SMS reminder tool for freelancers with overdue invoices. Swap in your own pain point from the validation step and keep the structure.

## Validation, 30 minutes

Needs a web-connected MCP server such as Playwright (ch09:19). Pain points (ch09:21), competition (ch09:39), price (ch09:49):

```
Search Reddit for posts in r/smallbusiness, r/freelance, r/entrepreneur, and r/SaaS where people describe manual processes they hate. Look for phrases like 'I spend hours doing', 'is there a tool for', 'I've been using spreadsheets to', and 'I wish there was'. Give me 10 specific pain points with links to the posts.
```

```
Search for existing tools that send automated invoice reminders via SMS for freelancers. Check Product Hunt, Google, and the Shopify/Zapier app stores. For each competitor, note: price, number of reviews, and any obvious gaps in their feature set.
```

```
Based on the competitor pricing for invoice reminder tools, what's a realistic price point for a standalone SMS invoice reminder tool for freelancers? Factor in: Twilio SMS costs (roughly $0.0079 per message), the target market's willingness to pay, and competitor pricing. Also estimate the number of potential customers based on the Reddit post engagement and market size.
```

The same competition check for a different idea (ch09:29):

```
Search for tools that send automated Google review requests to restaurant customers after their visit. Check Product Hunt and Google. Note price and gaps.
```

## Core feature, 3 hours

Hour 1 (ch09:67-75):

```
> Create a new Next.js project with TypeScript and Tailwind CSS.
> Set up Prisma with PostgreSQL.
> Create a schema with two models:
>   - User (id, email, name, createdAt)
>   - Invoice (id, userId, clientName, clientPhone, amount, dueDate, status, lastReminderSent)
> Run the initial migration.
> Create a CLAUDE.md with the project architecture and conventions.
```

Hour 2 (ch09:81-94), then the Twilio test (ch09:98). On a Twilio trial you can text only numbers you verified in the Twilio console; error 21608 is that (ch09:100).

```
> Build the core feature:
> 1. A simple form page at /dashboard where users can add invoices
>    (client name, phone, amount, due date)
> 2. A list view showing all invoices with their status
> 3. A "Send Reminder" button next to each overdue invoice that sends
>    an SMS via Twilio
> 4. The SMS should say: "Hi [name], this is a reminder that your
>    invoice for $[amount] was due on [date]. Please send payment
>    at your earliest convenience. Thanks, [user's name]"
> Use environment variables for Twilio credentials (TWILIO_ACCOUNT_SID,
> TWILIO_AUTH_TOKEN, TWILIO_PHONE_NUMBER).
> Keep the UI functional, not fancy. We'll polish later.
```

```
Run the app and test the Send Reminder flow with a real Twilio test number. Fix any errors.
```

Hour 3 (ch09:104-113):

```
> Audit the core feature for edge cases:
> - What happens if the phone number format is invalid?
> - What happens if Twilio is down?
> - What happens if the amount is negative or zero?
> - What happens if the due date is in the future (not actually overdue)?
> Fix all edge cases. Add input validation on both frontend and backend.
> Add a success/error toast notification after sending a reminder.
> Add a "last reminder sent" timestamp to each invoice row.
```

## Auth with Clerk (ch09:125-135)

```
> Add Clerk authentication to this project:
> 1. Install @clerk/nextjs
> 2. Set up ClerkProvider in the app layout
> 3. Add sign-in and sign-up pages using Clerk's prebuilt components
> 4. Protect the /dashboard route so only authenticated users can access it
> 5. Connect the Clerk user ID to the User model in Prisma
> 6. Filter all invoice queries by the authenticated user's ID
> Use environment variables for NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY and CLERK_SECRET_KEY.
> Add these to .env.example.
```

If Claude Code writes `authMiddleware()`, tell it to use `clerkMiddleware()` in `middleware.ts`: the old one was removed in the v6 SDK (ch09:139). Then sign in as two users and check that neither sees the other's invoices (ch09:143).

## Stripe (ch09:151-165)

```
> Add Stripe subscription billing:
> 1. Create a pricing page at /pricing with one plan: $9/month
> 2. Implement a Stripe Checkout session that creates a subscription
> 3. Add a webhook handler at /api/webhooks/stripe that processes:
>    - checkout.session.completed (activate subscription)
>    - customer.subscription.deleted (deactivate subscription)
>    - invoice.payment_failed (flag account)
> 4. Add a 'subscriptionStatus' field to the User model
>    (free, active, past_due, cancelled)
> 5. Gate the "Send Reminder" feature behind active subscription status
> 6. Free users can add invoices but can't send reminders
> Use STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET, and
> NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY from environment variables.
```

The follow-ups, for when it skips a step: signature check (ch09:171), test mode (ch09:175), raw body (ch09:179), customer portal (ch09:185):

```
Make sure the Stripe webhook verifies the signature using STRIPE_WEBHOOK_SECRET. Never process an unverified webhook event.
```

```
Set up the Stripe integration for test mode. Add a note in .env.example about using Stripe test keys during development.
```

```
Make sure the Stripe webhook route reads the raw request body for signature verification. Do NOT parse it as JSON before verifying the signature.
```

```
Add a 'Manage Subscription' button on the dashboard that redirects to Stripe's Customer Portal. Configure the portal to allow cancellation and plan changes.
```

## The payment test, by hand (ch09:187-196)

1. Create a test user through Clerk
2. Verify they see the paywall (can add invoices but can't send reminders)
3. Click subscribe, use Stripe test card 4242 4242 4242 4242, any future expiry, any CVC
4. Verify the webhook fires and the user's status changes to "active"
5. Verify they can now send reminders
6. Go to Stripe's test dashboard, cancel the subscription manually
7. Verify the cancellation webhook fires and the user loses access
8. Test with the declining card (4000 0000 0000 0002) to make sure the failure path works

All eight pass, or you fix it before you go on (ch09:198).

## Landing page (ch09:218-240)

```
> Create a landing page at the root route (/). Include:
> 1. Headline: "Stop Chasing Late Payments. Send Invoice Reminders in One Click."
> 2. Subheadline: "Freelancers waste 2+ hours per week on overdue invoice follow-ups.
>    Automate it for $9/month."
> 3. Three benefit bullets (with icons):
>    - Send SMS reminders to clients in one click
>    - Track which invoices are overdue at a glance
>    - Clients pay faster when reminders are consistent
> 4. A "How It Works" section with 3 steps:
>    - Step 1: Add your overdue invoice (client name, amount, phone number)
>    - Step 2: Click "Send Reminder"
>    - Step 3: Your client gets a professional SMS. You get paid faster.
> 5. A demo screenshot section (use a placeholder image for now)
> 6. Pricing section: "$9/month. Cancel anytime. Free trial: 5 free reminders."
> 7. FAQ section with 4 questions: "How does the SMS work?",
>    "Can I customize the reminder message?", "What if my client doesn't pay?",
>    "Is there a contract?"
> 8. CTA button: "Start Free Trial" that links to /sign-up
> 9. Footer with links to terms and privacy policy (placeholder pages are fine)
> Keep the design clean and professional. Use Tailwind. Mobile-responsive.
> Use a single accent color throughout. No gradients. No stock photo vibes.
```

Replace the placeholder screenshot and the terms and privacy pages before you take a payment (ch09:244).

## Go live

Tests and a secrets audit (ch09:254-261), then Railway (ch09:267-274):

```
> Add tests for the critical paths:
> - Invoice creation and retrieval (filtered by user)
> - Stripe webhook processing (mock Stripe events)
> - Auth middleware (verify unauthenticated users get 401)
> Run all tests. Fix failures.
> Audit for hardcoded secrets. Verify .env.example is complete.
```

```
> Configure this project for Railway deployment:
> - Add a Dockerfile
> - Set up a start script for production mode
> - Document all required environment variables
> - Add a /health endpoint
> - Run `prisma migrate deploy` (not `db push`) on deploy so the production schema is migrated from your committed migration files
```

Done when the product is live at your own URL, takes a signup through Clerk, a test payment through Stripe, and sends an SMS through Twilio (ch09:284). The chapter puts the weekend at 10 to 12 hours (ch09:286).
