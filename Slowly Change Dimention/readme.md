## Slowly Changing Dimension (SCD)
This repository contains two SQL scripts that showcase the implementation of **Slowly Changing Dimensions (SCD)** to handle historical and incremental updates of player records. These scripts are designed to process data for a `players_scd_table` that maintains a history of player attributes across different seasons.
#### What is Slowly Changing Dimension (SCD)?
Slowly Changing Dimension (SCD) refers to a method in data warehousing to manage and track changes in data attributes over time without overwriting historical data. It allows organizations to:
- Maintain a complete history of data changes.
- Perform temporal analyses of data attributes across periods.
- Update records incrementally to reflect new changes.

In this context, the `players_scd_table` represents an SCD table that tracks changes in player attributes such as:
- `scoring_class`: The player’s scoring classification for a given season.
- `is_active`: Whether the player was active in that season.
- The start and end seasons during which the attributes remained constant.

#### Files
1. **`SCD_table.sql`**: Sets up the initial data for the Slowly Changing Dimension (SCD) table by processing historical player data up to the year 2000.
2. **`SCD_Incremental_Load.sql`**: Handles the incremental update of the `players_scd_table` by detecting changes in player data for the 2001 season and updating the SCD table accordingly.

### Script Details
#### 1. `SCD_table.sql`
**Purpose**: The `SCD_table.sql` script initializes the `players_scd_table` by processing player data up to the year 2000. It groups player records into "streaks" of unchanged attributes and writes aggregated data to the SCD table.
**How It Solves the Problem**:
- **Detecting Changes**: Compares `scoring_class` and `is_active` for each season using the `lag()` function to identify changes compared to previous seasons.
- **Grouping Streaks**: Uses a `change_indicator` column and a cumulative sum to assign a unique streak identifier for each group of consistent attributes.
- **Output**: Aggregates records for each streak (based on the streak identifier), calculating the `start_season` and `end_season`. This ensures historical continuity up to the year 2000.

**Key Steps**:
- Extracts records for each player up to the year 2000.
- Flags changes in attributes between consecutive seasons.
- Groups identical attributes into streaks for efficient storage.
- Inserts the aggregated output into the `players_scd_table`.

**Example Use Case**: Given raw player data for multiple seasons up to 2000, the script generates the initial historical records for the SCD table, ensuring the SCD table is populated with a clean, aggregated history.
![image](https://github.com/user-attachments/assets/d5f0637c-0e21-4749-8d60-dcbcb60b91b5)

#### 2. `SCD_Incremental_Load.sql`
**Purpose**: The `SCD_Incremental_Load.sql` script updates the `players_scd_table` with records for the 2001 season. It detects changes to player attributes, distinguishes unchanged and changed records, and handles new players that did not appear in previous seasons.
**How It Solves the Problem**:
- **Historical Data**: Extracts previous records from the `players_scd_table` for the 2000 season (`last_season_scd`) and earlier (`historica_scd`).
- **Unchanged Records**: Identifies players with no changes to their `scoring_class` or `is_active` attributes in 2001 compared to 2000.
- **Changed Records**: Detects attributes that have changed and creates new SCD entries to reflect these updates.
- **New Players**: Detects players introduced in the 2001 season who were not present in 2000 and adds them as new entries in the table.

**Key Steps**:
1. Extracts records for the most recent season (`2000`) and historical data before that.
2. Compares player attributes for the 2001 season with those from 2000 to classify records as:
    - **Unchanged Records**: No changes in `scoring_class` or `is_active`.
    - **Changed Records**: Attributes that have been updated.
    - **New Records**: Players that did not exist in prior data.

3. Combines historical, unchanged, changed, and new records into a single dataset for updating the SCD table incrementally.

**Example Use Case**: If player attributes like `scoring_class` change in the new season, the script creates new records to capture the changes while preserving the historical values in the SCD table.
![image](https://github.com/user-attachments/assets/f9f28b1d-8abe-4b77-99d9-1f6ec4535377)

### Benefits
1. **Historical Accuracy**: Both scripts ensure that historical data in the `players_scd_table` remains accurate and preserved, even as new data is added or updated.
2. **Incremental Updates**: The `SCD_Incremental_Load.sql` script efficiently processes only the data for the new season (2001), making it highly scalable for handling new records or changes.
3. **Structured History**: By grouping data into streaks of unchanged attributes, the `SCD_table.sql` script optimizes storage while maintaining a structured history of player records.
4. **Separation of Logic**: Each script is modular and serves a specific purpose—either the initialization of the SCD table or its incremental updates. This separation allows for better maintainability and reusability.

### Example Use Case in Data Pipelines
- **Analytics**: These scripts can feed a data warehouse where analysts need to track changes in player performance (e.g., when a player moved to a different scoring class or became inactive).
- **ETL Pipelines**: The SCD logic in these scripts can be part of an Extract-Transform-Load (ETL) pipeline ensuring consistent updates to downstream systems.

### How to Use These Scripts
1. Run the `SCD_table.sql` script to initialize the `players_scd_table` with player history up to the year 2000.
2. For each new season, use the `SCD_Incremental_Load.sql` script to add the new data and update the historical records in the SCD table.

### Schema Requirements
The tables creation will be found in **Data-Modeling/creating_schema.sql**
- Table: `players_scd_table`
    - Must store columns such as `player_name`, `scoring_class`, `is_active`, `start_season`, `end_season`, and `current_season`.

- Table: `players`
    - Must contain the latest data for player attributes per season.
