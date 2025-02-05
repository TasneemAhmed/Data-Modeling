/*
The `player_seasons` table serves as a transactional table, storing historical data for players
as well as their seasonal statistics. Each row represents a single player's performance during
a specific season.

Columns:
- `player_name` (text, NOT NULL): The name of the player.
- `age` (integer): The age of the player during the season.
- `height` (text): Player's height (e.g., "6-6").
- `weight` (integer): Player's weight in pounds.
- `college` (text): The college the player attended.
- `country` (text): The player's country of origin.
- `draft_year` (text): The year the player was drafted.
- `draft_round` (text): The round in which the player was drafted.
- `draft_number` (text): The pick number for the player in the draft.
- `gp` (real): Games played during the season.
- `pts` (real): Points per game.
- `reb` (real): Rebounds per game.
- `ast` (real): Assists per game.
- `netrtg` (real): Net rating, showing the team's per 100 possessions performance while the player is on the court.
- `oreb_pct` (real): Offensive rebound percentage.
- `dreb_pct` (real): Defensive rebound percentage.
- `usg_pct` (real): Usage percentage, indicating how often a player is involved in offensive plays while on the court.
- `ts_pct` (real): True shooting percentage, a measure of overall scoring efficiency.
- `ast_pct` (real): Assist percentage.
- `season` (integer, NOT NULL): Represents the season year.

This table is suitable for querying individual player statistics for specific seasons.
 */
CREATE TABLE public.player_seasons (
    player_name text NOT NULL,
    age integer,
    height text,
    weight integer,
    college text,
    country text,
    draft_year text,
    draft_round text,
    draft_number text,
    gp real,
    pts real,
    reb real,
    ast real,
    netrtg real,
    oreb_pct real,
    dreb_pct real,
    usg_pct real,
    ts_pct real,
    ast_pct real,
    season integer NOT NULL
);
/*
The sample data includes statistics for notable players such as Kobe Bryant, Tim Duncan,
and Allen Iverson for select seasons. Each record captures their season-wise performance.

Notable examples:
- Kobe Bryant (1996-2003): Progressive growth in statistics over seasons.
- Tim Duncan (1997, 1998, etc.): Consistent performance as an elite-level big man.
- Allen Iverson (1996-1998): Early-career standout performances with high scoring and usage rates.
*/
INSERT INTO public.player_seasons (
    player_name, age, height, weight, college, country, draft_year, draft_round, draft_number,
    gp, pts, reb, ast, netrtg, oreb_pct, dreb_pct, usg_pct, ts_pct, ast_pct, season
) VALUES
    -- Kobe Bryant (1996-2003)
    ('Kobe Bryant', 18, '6-6', 200, 'None', 'USA', '1996', '1', '13', 71, 7.6, 1.9, 1.3, -1.4, 1.5, 6.0, 21.4, 51.4, 15.8, 1996),
    ('Kobe Bryant', 19, '6-6', 205, 'None', 'USA', '1996', '1', '13', 79, 15.4, 3.1, 2.5, 2.3, 2.1, 10.8, 25.2, 55.2, 22.1, 1997),
    ('Kobe Bryant', 20, '6-6', 210, 'None', 'USA', '1996', '1', '13', 50, 19.9, 5.3, 3.8, 3.2, 3.0, 12.3, 27.6, 56.8, 26.4, 1998),
    ('Kobe Bryant', 21, '6-6', 210, 'None', 'USA', '1996', '1', '13', 66, 22.5, 6.3, 4.9, 5.1, 3.4, 14.5, 28.7, 57.3, 28.7, 1999),
    ('Kobe Bryant', 22, '6-6', 212, 'None', 'USA', '1996', '1', '13', 68, 28.5, 5.9, 5.0, 6.3, 4.1, 15.9, 30.5, 58.6, 29.4, 2000),
    ('Kobe Bryant', 23, '6-6', 215, 'None', 'USA', '1996', '1', '13', 80, 25.2, 5.5, 5.5, 6.1, 3.7, 14.8, 31.3, 57.9, 30.5, 2001),
    ('Kobe Bryant', 24, '6-6', 220, 'None', 'USA', '1996', '1', '13', 82, 30.0, 6.9, 5.9, 7.0, 4.5, 17.1, 32.2, 58.3, 32.1, 2002),
    ('Kobe Bryant', 25, '6-6', 220, 'None', 'USA', '1996', '1', '13', 75, 27.3, 6.4, 5.8, 6.9, 4.2, 16.0, 31.7, 57.6, 31.0, 2003),

    -- Tim Duncan (1997, 1998, 2000, 2001, 2002, 2003)
    ('Tim Duncan', 21, '6-11', 250, 'Wake Forest', 'USA', '1997', '1', '1', 82, 21.1, 11.9, 2.7, 4.2, 3.6, 22.4, 24.1, 55.2, 16.8, 1997),
    ('Tim Duncan', 22, '6-11', 250, 'Wake Forest', 'USA', '1997', '1', '1', 50, 23.2, 12.4, 2.9, 5.1, 4.1, 23.8, 25.0, 56.0, 17.5, 1998),
    ('Tim Duncan', 24, '6-11', 250, 'Wake Forest', 'USA', '1997', '1', '1', 82, 22.2, 12.3, 3.5, 6.5, 4.2, 23.1, 26.0, 55.5, 18.7, 2000),
    ('Tim Duncan', 25, '6-11', 250, 'Wake Forest', 'USA', '1997', '1', '1', 82, 25.0, 12.7, 3.7, 7.0, 4.5, 24.6, 26.8, 56.2, 19.4, 2001),
    ('Tim Duncan', 26, '6-11', 250, 'Wake Forest', 'USA', '1997', '1', '1', 82, 25.5, 13.0, 4.0, 7.5, 4.8, 25.3, 27.1, 57.0, 20.2, 2002),
    ('Tim Duncan', 27, '6-11', 250, 'Wake Forest', 'USA', '1997', '1', '1', 81, 23.3, 12.9, 3.9, 7.1, 4.6, 24.5, 26.5, 56.5, 19.8, 2003),

    -- Allen Iverson (1996-1998)
    ('Allen Iverson', 21, '6-0', 165, 'Georgetown', 'USA', '1996', '1', '1', 76, 23.5, 4.1, 7.5, -1.2, 2.3, 8.7, 27.4, 52.0, 33.1, 1996),
    ('Allen Iverson', 22, '6-0', 165, 'Georgetown', 'USA', '1996', '1', '1', 80, 22.0, 3.7, 6.2, 0.5, 2.7, 9.2, 28.0, 53.1, 32.5, 1997),
    ('Allen Iverson', 23, '6-0', 165, 'Georgetown', 'USA', '1996', '1', '1', 48, 26.8, 4.2, 5.8, 1.2, 3.0, 10.5, 30.1, 54.5, 30.2, 1998),
    ('Allen Iverson', 24, '6-0', 165, 'Georgetown', 'USA', '1996', '1', '1', 70, 28.2, 3.8, 4.9, 2.3, 3.2, 11.0, 31.4, 55.3, 31.4, 1999);
/*
Using Composite Types (Similar to Structs)
A composite type is a user-defined data structure that can store multiple fields of different data types,
similar to a struct.


Fields:
- `season` (integer): The season year under review.
- `gp` (real): Games played in the season.
- `pts` (real): Points per game.
- `reb` (real): Rebounds per game.
- `ast` (real): Assists per game.

This is useful for handling player performance data as arrays of structured statistics.
 */

CREATE TYPE season_stats AS (
    season integer,
    gp real,
    pts real,
    reb real,
    ast real
);
/*
 CREATE TYPE scoring_class AS ENUM (...)

This creates a new data type named scoring_class.
The type is defined as an ENUM (enumeration), meaning it can only have specific values.
ENUM ('star', 'good', 'average', 'bad')

These are the allowed values for the scoring_class type.
Any column or variable using scoring_class can only store one of these values.
 */
create TYPE scoring_class as enum('star', 'good', 'average', 'bad');
/*
The `players` table is designed as a cumulative table to store consolidated player data,
including their seasonal statistics and derived metrics.

Cumulative Table Definition:
- A cumulative table (or accumulating snapshot) tracks the lifecycle of a specific entity
  with timestamps or values for important milestones.

Columns:
- `player_name` (text, NOT NULL): The name of the player.
- `height` (text): The player's height.
- `college` (text): The college the player attended.
- `country` (text): The player's country of origin.
- `draft_year` (text): The year the player was drafted.
- `draft_round` (text): The round in which the player was drafted.
- `draft_number` (text): The draft pick number.
- `player_season_stats` (season_stats[]): An array of `season_stats` composite type, storing the player's statistics
  for multiple seasons.
- `scoring_class` (scoring_class): A column classified into predefined scoring performance categories.
- `years_since_last_season` (integer): The number of years since the player appeared in their last recorded season.
- `current_season` (integer): The current season for the player.

Primary Key:
- (`player_name`, `current_season`): Ensures uniqueness based on player and current season.

Benefits of Cumulative Design:
1. **Performance**: Consolidates data for streamlined analysis.
2. **Simplified Analysis**: Facilitates tracking completion times, bottlenecks, and player progression over time.
3. **Historical Tracking**: Supports the analysis of player growth and achievements by season.

Use Cases:
- Best suited for well-defined, non-repetitive processes involving player-season records.
- Simplifies queries that require aggregate or historical performance at the player level.

Avoid using this design for:
1. Highly variable processes (e.g., stages that repeat or diverge unpredictably).
2. Tracking frequent, detailed updates within each stage.
3. Scenarios with insufficient storage (due to record growth over time).
*/
create  table players (
    player_name text NOT NULL,
    height text,
    college text,
    country text,
    draft_year text,
    draft_round text,
    draft_number text,
    player_season_stats season_stats[], --this column will be array of struct elemnts of season_stats
    scoring_class scoring_class, -- this column will be struct but with specified values
    years_since_last_season integer,
    current_season integer,
    is_active boolean,
    primary key (player_name, current_season)
)



