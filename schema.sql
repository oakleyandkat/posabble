-- Poseable — the shared world.
-- Paste this whole file into Supabase → SQL Editor → Run.
-- It makes the two tables the app syncs to and locks them down so
-- a row is only reachable by someone who already knows its world code.

create table if not exists accounts (
  id         text primary key,
  room       text not null,
  name       text,
  handle     text,
  bio        text,
  avatar     text,
  followers  integer default 0,
  following  integer default 0,
  color      text,
  deleted    boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists posts (
  id         text primary key,
  room       text not null,
  author_id  text,
  img        text,
  caption    text,
  likes      integer default 0,
  liked_by   jsonb default '[]'::jsonb,
  comments   jsonb default '[]'::jsonb,
  date       text,
  deleted    boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists accounts_room_idx on accounts (room);
create index if not exists posts_room_idx    on posts (room);

-- Row level security: every request has to carry an X-World header,
-- and it only ever sees rows whose room matches that header. Without
-- the right world code you get an empty list, not somebody's photos.
alter table accounts enable row level security;
alter table posts    enable row level security;

create or replace function world_code() returns text
language sql stable as $$
  select nullif(current_setting('request.headers', true)::json ->> 'x-world', '')
$$;

drop policy if exists "read own world"   on accounts;
drop policy if exists "write own world"  on accounts;
drop policy if exists "update own world" on accounts;
drop policy if exists "read own world"   on posts;
drop policy if exists "write own world"  on posts;
drop policy if exists "update own world" on posts;

create policy "read own world" on accounts
  for select using (room is not distinct from world_code());
create policy "write own world" on accounts
  for insert with check (room is not distinct from world_code());
create policy "update own world" on accounts
  for update using (room is not distinct from world_code())
          with check (room is not distinct from world_code());

create policy "read own world" on posts
  for select using (room is not distinct from world_code());
create policy "write own world" on posts
  for insert with check (room is not distinct from world_code());
create policy "update own world" on posts
  for update using (room is not distinct from world_code())
          with check (room is not distinct from world_code());
