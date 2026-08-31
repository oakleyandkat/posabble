# Poseable

A pretend Instagram for dolls. Several doll accounts share one feed and
comment on each other's posts. One HTML file, no build step.

**Live:** https://oakleyandkat.github.io/posabble/

## Turning on the shared world

Right now every device keeps its own posts. Fill in two values and they
all share one feed instead — post on the laptop, it shows up on the iPad
a few seconds later.

1. Make a free account at [supabase.com](https://supabase.com) and create
   a project. (You have to do this part yourself — it needs your email
   and a password.)
2. Open **SQL Editor**, paste in everything from [`schema.sql`](schema.sql),
   and hit Run. That builds the two tables and locks them down.
3. Go to **Project Settings → API** and copy two things:
   - the **Project URL** (looks like `https://abcdefgh.supabase.co`)
   - the key labelled **`anon` `public`**
4. Open `index.html`, find the `CLOUD` block at the top of the `<script>`,
   and paste them in:

   ```js
   const CLOUD = {
     url:'https://abcdefgh.supabase.co',
     key:'paste-the-anon-public-key-here'
   };
   ```

5. Commit and push. Wait a minute for GitHub Pages to rebuild.

## How the sharing works

Open the site and it gives you a **world code** tucked into the address,
like `…/posabble/#w=w8zodv9h4kx2`. Everyone who opens *that whole link*
lands in the same world — every doll, every post, every comment, on any
device. The plain site address with no `#w=` on the end starts a fresh
empty world instead.

So the link is the key. Share it with whoever you want in; don't post it
somewhere public.

The database backs this up rather than trusting the app: each request
carries its world code in a header, and Postgres only returns rows that
match it. Someone poking at the database without a code gets an empty
list, not your photos.

Posts still save to your own device too, so the app works with the wifi off
and catches up next time it connects.

## Notes

- Photos are shrunk before saving — 1000px for posts, 300px for avatars.
- Two devices editing the same post at once: the newer edit wins.
- Delete a post on one device and it disappears from the others.
- The fake followers (`glitter.gem` and friends) are invented and local.
  Only the device that made a post schedules its fake reactions, so they
  don't pile up once several devices are connected.
