## 1. Purpose of `creating_schema.sql` and `cumulative_table_analysis.sql`
The scripts aim to process player season statistics and maintain cumulative data for players in an efficient and consistent manner. This is achieved using a design based on **cumulative tables** and **complex data types** (such as arrays), enabling seamless data collection, aggregation, and analysis across multiple seasons.
## 2. Problem These Scripts Solve
Without cumulative tables, traditional database schema designs (e.g., normalized schemas) require frequent complex joins and window functions to:
- Aggregate a player's performance across multiple seasons.
- Compare a player's performance between specific seasons (e.g., first vs. most recent).
- Track and update player statistics for consecutive seasons.

Such approaches can be inefficient, hard to maintain, and prone to performance degradation as the size of the dataset increases.
The **cumulative table approach** solves these issues by consolidating all statistical data for a player across seasons into a single row. This avoids repetitive joins or aggregations and instead leverages array-based storage and processing to achieve efficient analysis.
## 3. What is a Cumulative Table?
A **cumulative table** is a database design pattern where historical and ongoing data for a given entity is aggregated and stored together in a single row. This is commonly implemented using **complex data types** like arrays and JSON. In this context:
- Each row in the `players` table contains all seasons' statistics for a single player as an array (`player_season_stats`).
- Updates are incremental, appending new season data to the existing array without altering the historical information.

### Advantages of Cumulative Tables:
1. **Efficiency**: Reduces the need for joins and window functions when analyzing multi-season data.
2. **Ease of Access**: Provides direct access to both historical and current data without expensive operations.
3. **Scalability**: Easy to integrate new data (e.g., next season's stats) into the table without impacting the existing structure.

## 4. Explanation of the `player_season_stats` Complex Data Type
The `player_season_stats` column in the `players` table is an array of a user-defined data type (`season_stats`). This data type enables structured and efficient storage of player statistics for multiple seasons. Each entry in the array is a row containing:
- `season`: The year of the season (e.g., 2001).
- `gp`: Games played by the player.
- `pts`: Points scored by the player during the season.
- `reb`: Rebounds made by the player.
- `ast`: Assists made by the player.

By storing these details in an array, we can:
- Easily append new season data without modifying the historical records.
- Directly access specific season statistics using array indexing.
- Efficiently analyze and compare performance trends, such as the ratio of points between the first and the most recent seasons.

## 5. How `cumulative_table_analysis.sql` Uses Cumulative Tables and Array-Based Operations
- The script dynamically inserts cumulative data into the `players` table.
- It uses **two CTEs** (`yesterday_cte` and `today_cte`):
    - `yesterday_cte`: Fetches player data from the cumulative `players` table for a historical season.
    - `today_cte`: Fetches current season data from the `player_seasons` table.

- A `FULL OUTER JOIN` ensures all players are included, even if data exists in only one of the sources.

### Key Features:
1. **Combining Player Data**:
    - Uses `COALESCE` to merge data from the historical (`yesterday_cte`) and current season (`today_cte`).
    - Ensures non-null values are prioritized based on availability.

2. **Appending Season Statistics**:
    - Appends the current season's stats as a new entry in the `player_season_stats` array using:
``` sql
     y.player_season_stats || ARRAY[ROW(t.season, t.gp, t.pts, t.reb, t.ast)::season_stats]
```
- This avoids overwriting historical data while maintaining continuity across seasons.
    1. **Tracking and Classifying Player Performance**:
        - Dynamically calculates `scoring_class` based on the `pts` column from the current season.
        - Tracks years since the player's last active season using incremental updates.
3. **The player cumulative table sample output**: 
![image](https://github.com/user-attachments/assets/d646a44d-62bb-4117-8103-4a2435232e48)

### Automated Loops for Extending Across Seasons:
The script automatically iterates over a range of seasons (e.g., 2001-2003) to dynamically insert data into the cumulative table. This eliminates the need for hardcoding multiple years and ensures scalability.
## 6. How `cumulative_table_analysis.sql` Uses Array Data to Calculate Points Ratio
This script demonstrates how to analyze historical and cumulative player statistics using the `player_season_stats` array.
### Purpose:
Calculates the ratio of points scored in a player's most recent season to their first season.
### Key Array-Based Operations:
1. **Access First-Season Stats**:
    - Uses array indexing to retrieve the player’s first-season statistics:
``` sql
     player_season_stats[1]::season_stats
```
2. **Access Most Recent Season Stats**:
    - Uses the `cardinality` function to retrieve the statistics for the most recent season:
``` sql
     player_season_stats[cardinality(player_season_stats)]::season_stats
```
3. **Handle Division by Zero**:
    - Ensures safe division by using a `CASE` statement to safeguard against a zero value in the first season’s points.
4. **The output from analysis query**:
   ![image](https://github.com/user-attachments/assets/478bc2bb-7a69-4068-807c-f31b0da85ce9)

### Efficiency:
By storing season statistics in a cumulative array, the script avoids joins and window functions, enabling direct comparisons in a single query.
## 7. Summary
These scripts demonstrate how cumulative tables and complex data types can simplify and optimize multi-season data aggregation and analysis. By leveraging PostgreSQL’s support for arrays and structured types:
- Historical and current data can coexist within a single row.
- Append-based updates ensure data integrity and scalability.
- Array indexing allows direct access to specific season data for comparisons and analysis.

### Core Benefits:
1. Reduces reliance on joins and window functions, improving query performance.
2. Streamlines the addition of new season data.
3. Facilitates complex analytical queries (e.g., trends, ratios) directly within the data model.
