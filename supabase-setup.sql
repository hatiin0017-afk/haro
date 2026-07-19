-- ============================================================
--  haro 프로필 사이트 — Supabase 초기 스키마 (멱등 · 재실행 안전)
--  ⚠️ 업보(upbo) 스키마는 표시 방식(시즌/코인/항목) 확정 후 별도 추가
-- ============================================================

-- ── 1. 일정 (월 캘린더 + 다가오는 일정) ─────────────────────
create table if not exists public.schedule_events (
  id          bigserial primary key,
  date        date not null,
  time        time,                              -- NULL 허용 (휴방 등)
  title       text not null,
  description text,                              -- 메모
  event_type  text default 'broadcast',         -- 유형(색 매핑 키)
  color       text,                             -- 유형색 캐시(선택)
  is_hidden   boolean default false,
  created_at  timestamptz default now()
);
create index if not exists idx_schedule_date on public.schedule_events(date);
alter table public.schedule_events add column if not exists event_type text default 'broadcast';
alter table public.schedule_events add column if not exists color text;

alter table public.schedule_events enable row level security;
drop policy if exists "public read schedule" on public.schedule_events;
drop policy if exists "auth all schedule"   on public.schedule_events;
create policy "public read schedule" on public.schedule_events
  for select using (is_hidden = false);
create policy "auth all schedule" on public.schedule_events
  for all to authenticated using (true) with check (true);

-- ── 2. 노래책 ───────────────────────────────────────────────
create table if not exists public.songs (
  id         bigserial primary key,
  title      text not null,
  artist     text,
  tags       text,                              -- 장르/분류 (검색·필터)
  sort_order int default 0,
  created_at timestamptz default now()
);
create index if not exists idx_songs_sort on public.songs(sort_order, title);

alter table public.songs enable row level security;
drop policy if exists "public read songs" on public.songs;
drop policy if exists "auth all songs"   on public.songs;
create policy "public read songs" on public.songs
  for select using (true);
create policy "auth all songs" on public.songs
  for all to authenticated using (true) with check (true);

-- ── 3. 사이트 설정 (탭 온/오프 + 프로필 동적 필드) ──────────
create table if not exists public.site_settings (
  key   text primary key,
  value text
);
alter table public.site_settings enable row level security;
drop policy if exists "public read settings" on public.site_settings;
drop policy if exists "auth all settings"   on public.site_settings;
create policy "public read settings" on public.site_settings
  for select using (true);
create policy "auth all settings" on public.site_settings
  for all to authenticated using (true) with check (true);

-- 공개 탭 기본값 (홈=항상표시)
insert into public.site_settings (key, value) values
  ('nav_song','on'),
  ('nav_upbo','on'),
  ('nav_schedule','on')
on conflict (key) do nothing;

-- 스키마 캐시 리로드
notify pgrst, 'reload schema';
