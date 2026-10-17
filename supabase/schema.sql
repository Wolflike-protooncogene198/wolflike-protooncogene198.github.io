-- Stream Zone private order-management schema.
-- Run in Supabase Dashboard > SQL Editor as project owner.
-- Add only the admin's Auth user UUID to public.admin_users after creating that user.
create table if not exists public.admin_users (
  id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  customer_name text not null check (char_length(trim(customer_name)) between 1 and 120),
  customer_phone text,
  product text not null check (char_length(trim(product)) between 1 and 120),
  plan text,
  amount numeric(12,2) not null check (amount >= 0),
  payment_status text not null default 'Pending'
    check (payment_status in ('Pending','Paid','Refunded')),
  activation_status text not null default 'Pending'
    check (activation_status in ('Pending','Active','Failed','Expired')),
  renewal_date date,
  order_date date not null default current_date,
  notes text check (notes is null or char_length(notes) <= 2000),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists orders_created_at_idx on public.orders (created_at desc);
create index if not exists orders_renewal_date_idx on public.orders (renewal_date);

alter table public.admin_users enable row level security;
alter table public.orders enable row level security;

-- Remove broad defaults, then grant only authenticated operations needed by the dashboard.
revoke all on table public.admin_users from anon, authenticated;
revoke all on table public.orders from anon, authenticated;
grant select on table public.admin_users to authenticated;
grant select, insert, update, delete on table public.orders to authenticated;

drop policy if exists "Admin can read own allowlist entry" on public.admin_users;
create policy "Admin can read own allowlist entry"
  on public.admin_users for select to authenticated
  using (id = (select auth.uid()));

drop policy if exists "Only allowlisted admins can read orders" on public.orders;
create policy "Only allowlisted admins can read orders"
  on public.orders for select to authenticated
  using (exists (select 1 from public.admin_users a where a.id = (select auth.uid())));

drop policy if exists "Only allowlisted admins can insert orders" on public.orders;
create policy "Only allowlisted admins can insert orders"
  on public.orders for insert to authenticated
  with check (exists (select 1 from public.admin_users a where a.id = (select auth.uid())));

drop policy if exists "Only allowlisted admins can update orders" on public.orders;
create policy "Only allowlisted admins can update orders"
  on public.orders for update to authenticated
  using (exists (select 1 from public.admin_users a where a.id = (select auth.uid())))
  with check (exists (select 1 from public.admin_users a where a.id = (select auth.uid())));

drop policy if exists "Only allowlisted admins can delete orders" on public.orders;
create policy "Only allowlisted admins can delete orders"
  on public.orders for delete to authenticated
  using (exists (select 1 from public.admin_users a where a.id = (select auth.uid())));

-- Do not create an admin_users insert/update/delete policy.
-- Provision or revoke admins only from the trusted Supabase SQL Editor.
-- Never put a Supabase service_role/secret key in website files.
