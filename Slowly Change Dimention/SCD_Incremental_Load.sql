-- create type public.scd_type as
-- (
--     scoring_class scoring_class,
--     is_active     boolean,
--     start_season  integer,
--     end_season    integer
-- );

-- This script generates a unified view of historical, unchanged, changed, and new player records for the 2001 season, based on the historical records from the 2000 season.
-- It is designed to update a Slowly Changing Dimension (SCD) table (`players_scd_table`) with the latest player data changes for each season.

-- Step 1: Identify records from the most recent completed season (2000) where the player streak is active.
with last_season_scd as (
    select *
    from players_scd_table
    where current_season = 2000 -- Filter for the 2000 season
      and end_season = 2000 -- Only include records where the player's streak ended in the 2000 season
),

-- Step 2: Identify all historical SCD records (before the 2000 season).
historica_scd as (
    select
        player_name,
        scoring_class,
        is_active,
        start_season,
        end_season
    from players_scd_table
    where current_season = 2000 -- Filter for records up to the 2000 season
      and end_season < 2000 -- Exclude records active in the current (2000) season
),

-- Step 3: Identify player records from the current season (2001).
this_season as (
    select *
    from players
    where current_season = 2001 -- Only include players for the current 2001 season
),

-- Step 4: Determine "unchanged records" where the player's attributes (scoring class and active status) have NOT changed between seasons.
unchanged_records as (
    select
        ts.player_name, -- Player name
        ts.scoring_class, -- Current scoring class
        ts.is_active, -- Current active/inactive status
        ts.current_season as start_season, -- Start season remains as the current season
        ts.current_season as end_season -- End season remains as the current season
    from this_season ts
    join last_season_scd ls
      on ts.player_name = ls.player_name -- Match players already in the last season
    where ts.scoring_class = ls.scoring_class -- No change in scoring class
      and ts.is_active = ls.is_active -- No change in active status
),

-- Step 5: Identify "changed records" where either scoring class or active status has changed since the last season.
changed_records as (
    select
        ts.player_name, -- Player name
        unnest(array [
          -- Uncomment this if you want to track both old and new changed records
          -- row(ls.scoring_class, ls.is_active, ls.start_season, ls.end_season)::scd_type,
          row(ts.scoring_class, ts.is_active, ts.current_season, ts.current_season)::scd_type
        ]) as unnested_old_changed -- Unnest rows for old vs. new states
    from this_season ts
    left join last_season_scd ls
      on ts.player_name = ls.player_name -- Match players already in the last season
    where ts.scoring_class <> ls.scoring_class -- Detect a change in scoring class
       or ts.is_active <> ls.is_active -- Detect a change in active status
),

-- Step 6: Extract old and new attributes of the changed records, treating each as a separate row.
unnest_changed_records as (
    select
        player_name, -- Player name
        (unnested_old_changed::scd_type).scoring_class, -- Scoring class from the new state
        (unnested_old_changed::scd_type).is_active, -- Active status from the new state
        (unnested_old_changed::scd_type).start_season, -- Start season from the new state
        (unnested_old_changed::scd_type).end_season -- End season from the new state
    from changed_records
),

-- Step 7: Identify "new records" where the player did not exist in the previous seasons (newly added players).
new_records as (
    select
        ts.player_name, -- Player name
        ts.scoring_class, -- Scoring class
        ts.is_active, -- Active/inactive status
        ts.current_season as start_season, -- Start season for the new player
        ts.current_season as end_season -- End season for the new player
    from this_season ts
    left join last_season_scd ls
      on ts.player_name = ls.player_name -- Check if the player already existed
    where ls.player_name is null -- Include only players not found in the last season
)

-- Step 8: Combine all the historical, unchanged, changed, and new records into a single unified result set.
select *
from historica_scd

union all

select *
from unchanged_records

union all

select *
from unnest_changed_records

union all

select *
from new_records;
