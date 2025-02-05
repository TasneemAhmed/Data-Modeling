-- Insert the summarized player season data into the players_scd_table (Slowly Changing Dimension table).
-- This script processes player scoring and activity data to detect any changes over seasons and generate streak identifiers,
-- which are used to group periods of consistency in player data throughout different seasons.

insert into players_scd_table
with 

-- Step 1: Derive "previous season" values for scoring_class and is_active for each player and season.
with_previous as (
    select
        player_name, -- Name of the player
        scoring_class, -- Current scoring class for the season
        -- The scoring_class of the previous season for the same player
        lag(scoring_class, 1) over (partition by player_name order by current_season) as prev_scoring_class, 
        is_active, -- Whether the player is active in the current season
        -- The is_active status of the previous season for the same player
        lag(is_active, 1) over (partition by player_name order by current_season) as prev_is_active, 
        current_season -- Current season year
    from players
    -- Filter to include only seasons before the year 2000.
    where current_season <= 2000
),

-- Step 2: Add a "change indicator" column to flag changes in scoring_class or is_active values between consecutive seasons.
with_indicators as (
    select *,
           -- Flag a change when either scoring_class or is_active differs from the previous season
           case when scoring_class != prev_scoring_class then 1
                when is_active != prev_is_active then 1
                else 0
           end as change_indicator -- 1 indicates a change; 0 means no change between seasons
    from with_previous
),

-- Step 3: Assign a unique "streak identifier" to each period of consistent scoring_class and is_active values.
-- For example, if a player has 3 consecutive seasons with no changes in scoring_class and is_active,
-- they will be part of the same streak group.
with_streaks as (
    select *,
           -- Compute a cumulative sum of change_indicator to create streak groups
           sum(change_indicator) over (partition by player_name order by current_season) as streak_identifier
    from with_indicators
)

-- Final Step: Generate the summarized data for insertion into the players_scd_table.
select
    player_name, -- Player's name
    scoring_class, -- Scoring class during the streak
    is_active, -- Player activity status during the streak
    -- Earliest season in the streak
    min(current_season) as start_season, 
    -- Latest season in the streak
    max(current_season) as end_season, 
    -- Static current season year (hardcoded as 2000)
    2000 as current_season 
from with_streaks
-- Group by player and streak properties to calculate start_season and end_season for each streak
group by player_name, scoring_class, is_active, streak_identifier
-- Order the results by player name and starting season in ascending order
order by player_name, start_season;
