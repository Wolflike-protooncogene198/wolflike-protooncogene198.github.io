# Stream Zone private order-management setup

The public website remains on GitHub Pages. The private dashboard lives at **https://streamzonepk.github.io/admin.html** and uses Supabase Auth + Postgres Row Level Security (RLS) so order records are not public. The dashboard is prepared in the repository, but it will not connect until you complete the one-time setup below.

## 1. Create a free Supabase project

1. Open https://supabase.com/ and sign in or create an account.
2. Create a project (choose a strong database password and keep it private).
3. In the project dashboard, open **Connect** or **Settings → API Keys** and copy the Project URL and publishable key (older projects may call it the anon key).
4. In this GitHub repository, edit `assets/js/supabase-config.js` and replace the two `PASTE_...` placeholders with those values. Commit the file.

The publishable/anon key is designed for browser use, but it is only safe here because the database tables have restrictive RLS policies. **Never put a service_role or secret key in this repository or any browser file.**

## 2. Create the database tables and security policies

1. In Supabase, open **SQL Editor → New query**.
2. Open this repository file: `supabase/schema.sql`; copy all of its SQL into the editor.
3. Run it. It creates the order table and admin allowlist with RLS policies that deny public and non-allowlisted access.

## 3. Create and authorize your admin account

1. In Supabase, open **Authentication → Users** and create/add a user using your own admin email and a strong password. Do not enable public sign-up for this project.
2. Copy that user's UUID from the Users page.
3. In SQL Editor, run the following statement, replacing the example UUID with your actual Auth user UUID:

```sql
insert into public.admin_users (id)
values ('PASTE-YOUR-AUTH-USER-UUID-HERE');
```

Only add people you trust. The allowlist can only be changed from the trusted SQL Editor, not through the public website/API.

## 4. Open and test the dashboard

1. Visit https://streamzonepk.github.io/admin.html after the latest GitHub Pages deployment finishes.
2. Sign in with the admin email/password you created in Supabase.
3. Add a test order, refresh the page, edit it, then delete the test order to confirm the workflow.
4. If you see a permissions error, check that the schema SQL ran and that the UUID in `admin_users` exactly matches your Auth user UUID.

## What the dashboard tracks

- Customer name and WhatsApp/phone
- Subscription and plan/device
- Order amount in PKR
- Payment status: Pending, Paid, Refunded
- Activation status: Pending, Active, Failed, Expired
- Renewal date, order date, and notes
- Summary counters for pending payment, pending activation, and active renewals in the next seven days

Orders are entered manually after a customer contacts you through WhatsApp. This does not automatically import WhatsApp chats or payment transactions.

## Privacy and operating notes

- Do not save card details, banking PINs, passwords, or one-time codes in customer notes.
- Use a unique strong password and secure the email account used for admin login.
- Keep the Supabase project URL and publishable key configured; never use a secret/service-role key in the front end.
- GitHub Pages serves static files and does not provide a private server by itself. Access control for the actual order records is enforced by Supabase Auth and RLS in the database, not by hiding the dashboard URL.
- Google Search setup still requires you to verify site ownership in Google Search Console and submit the sitemap; see the repository's `sitemap.xml` and `robots.txt`.
