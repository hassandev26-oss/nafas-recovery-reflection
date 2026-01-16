
-- Trigger to automatically create a profile entry when a new user signs up via Supabase Auth.
-- Run this in the Supabase SQL Editor to handle profile creation robustly,
-- especially if email confirmation is enabled which prevents client-side RLS inserts during signup.

create or replace function public.handle_new_user() 
returns trigger as $$
begin
  insert into public.profiles (id, nickname, email)
  values (
    new.id, 
    new.raw_user_meta_data->>'nickname', 
    new.email
  );
  return new;
end;
$$ language plpgsql security definer;

-- Trigger the function every time a user is created
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
