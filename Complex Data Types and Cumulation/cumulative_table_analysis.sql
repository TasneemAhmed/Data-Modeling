/*
 core components of cumulative  table :
 - 2 dataframes (yesterday/historical and today data)
 - Full outer join between 2 dataframes to get all data because maybe data not exist in historical data or vica verse
 - coalesce to get the not null value from history and today data
 */
 /*
  /*
### Purpose:
This script automates data insertion into the `players` table, populating cumulative statistics
for multiple seasons by iterating over a range of seasons (`yesterday_cte` and `today_cte` logic).

### Key Features:
1. Uses `PL/pgSQL` looping capabilities to iterate over multiple years dynamically, reducing redundancy.
2. Automates calculations of cumulative statistics for each player by combining data from:
   - Historical season data (`yesterday_cte`).
   - Current season data (`today_cte`).
3. Utilizes `FULL OUTER JOIN` to handle scenarios where player data exists only in either historical or current data.
4. Uses **`coalesce()`** to prioritize current season data over historical data where present.
5. Updates `player_season_stats` to include all past statistics combined with data from the current season.



### Steps:
1. Use a `FOR LOOP` to iterate through a range of years:
    - `yesterday_cte`: Fetches data from the `players` table for the current season in the loop.
    - `today_cte`: Fetches data from the `player_seasons` table for the next season.
2. Dynamically calculate new fields:
    - `player_season_stats`: Appends current season statistics to the cumulative array.
    - `scoring_class`: Dynamically classifies players based on current season points.
    - `years_since_last_season`: Tracks gaps between a player's last active season and the current season.
3. Insert the processed data into the `players` cumulative table for each season.
*/

  */
DO $$
DECLARE
    season_start INTEGER := 1995; -- Starting season
    season_end INTEGER := 2003;   -- Ending season for the loop
BEGIN
    FOR current_season_counter IN season_start..(season_end - 1) LOOP
        -- Dynamically insert data for each season combination
        INSERT INTO players
            -- yesterday_cte will get data from 1995 to 2002
        WITH yesterday_cte AS (
            SELECT *
            FROM players
            WHERE current_season = current_season_counter -- Historical data
        ),
            -- today_cte will get data from 1996 to 2003
        today_cte AS (
            SELECT *
            FROM player_seasons
            WHERE season = current_season_counter + 1 -- Data for the next season
        )
        SELECT
            COALESCE(t.player_name, y.player_name) AS player_name,
            COALESCE(t.height, y.height) AS height,
            COALESCE(t.college, y.college) AS college,
            COALESCE(t.country, y.country) AS country,
            COALESCE(t.draft_year, y.draft_year) AS draft_year,
            COALESCE(t.draft_round, y.draft_round) AS draft_round,
            COALESCE(t.draft_number, y.draft_number) AS draft_number,
            CASE
                WHEN y.player_season_stats IS NULL THEN
                    ARRAY[ROW(t.season, t.gp, t.pts, t.reb, t.ast)::season_stats]
                WHEN y.player_season_stats IS NOT NULL AND t.season IS NOT NULL THEN
                    y.player_season_stats || ARRAY[ROW(t.season, t.gp, t.pts, t.reb, t.ast)::season_stats]
                ELSE
                    y.player_season_stats
            END AS player_season_stats,
            CASE
                WHEN t.pts IS NOT NULL THEN
                    CASE
                        WHEN t.pts > 20 THEN 'star'
                        WHEN t.pts > 15 THEN 'good'
                        WHEN t.pts > 10 THEN 'average'
                        ELSE 'bad'
                    END::scoring_class
                ELSE
                    y.scoring_class
            END AS scoring_class,
            CASE
                WHEN t.season IS NOT NULL THEN 0
                ELSE y.years_since_last_season + 1
            END AS years_since_last_season,
            COALESCE(t.season, y.current_season + 1) AS current_season
        FROM
            today_cte AS t
        FULL OUTER JOIN
            yesterday_cte AS y
        ON
            t.player_name = y.player_name;

    END LOOP;
END $$;

/*
### Purpose:
This query calculates the ratio of a player's points scored in their most recent season (2001)
to their first season using cumulative data stored in the `player_season_stats` array.

### Key Features:
1. Leverages the cumulative design, avoiding the need for joins or window functions.
2. Extracts first-season and last-season statistics directly from the array:
    - `player_season_stats[1]`: Retrieves first-season stats.
    - `player_season_stats[cardinality(player_season_stats)]`: Retrieves stats for the most recent season.
3. Safeguards division by zero using a `CASE` statement.
*/

 select
     player_name,
     (player_season_stats[cardinality(player_season_stats)]::season_stats).pts/
     (case when (player_season_stats[1]::season_stats).pts =0 then 1 else (player_season_stats[1]::season_stats).pts end)

 from players
 where current_season=2001;

/*
 ### Explanation of Approach in Query 2
- **Why Use `player_season_stats` Array?**
The cumulative table design consolidates all seasons into a single row per player, storing statistics as an array. This enables efficient lookup of historical data without performing expensive joins with separate tables.
- **Array Indexing for First and Last Seasons:**
    - `player_season_stats[1]`: Retrieves the earliest recorded statistics for the player.
    - `player_season_stats[cardinality(player_season_stats)]`: Retrieves the latest statistics.

- **Advantages Over Normalized Schema:**
    - Eliminates the need for joins across multiple tables.
    - Negates the need for window functions, reducing query complexity.
    - Provides direct access to both first-season and last-season statistics in a single database row.

### General Benefits Documented:
1. **Cumulative Design Efficiency:**
By consolidating data into arrays, cumulative tables streamline queries that involve comparisons across time (e.g., first vs. last season). This eliminates the overhead of joins and multiple scans.
2. **Ease of Maintenance:**
Updates primarily focus on coalescing new data into arrays, which handles both historical retention and real-time addition efficiently.

These structures are ideal for scenarios where time-based analysis is common, and the data exhibits predictable progression paths (e.g., player career statistics). Let me know if additional details or refinements are required!

 */
