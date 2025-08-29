WITH last_season_scd AS (
    -- last season open records (ended in 2021, may continue or change)
    SELECT * FROM players_scd
    WHERE current_season = 2021
      AND end_season = 2021
),
historical_scd AS (
    -- fully closed history before 2021
    SELECT
        player_name,
        scoring_class,
        is_active,
        start_season,
        end_season
    FROM players_scd
    WHERE current_season = 2021
      AND end_season < 2021
),
this_season_data AS (
    -- snapshot of 2022 season
    SELECT * FROM players
    WHERE current_season = 2022
),
unchanged_records AS (
    -- unchanged players: same attributes → extend end_season to 2022
    SELECT
        ts.player_name,
        ts.scoring_class,
        ts.is_active,
        ls.start_season,
        ts.current_season as end_season
    FROM this_season_data ts
    JOIN last_season_scd ls
      ON ls.player_name = ts.player_name
   WHERE ts.scoring_class = ls.scoring_class
     AND ts.is_active = ls.is_active
),
changed_records AS (
    -- changed players: close old record and open new one in 2022
    SELECT
        ts.player_name,
        UNNEST(ARRAY[
            ROW(
                ls.scoring_class,
                ls.is_active,
                ls.start_season,
                ls.end_season
            )::scd_type,
            ROW(
                ts.scoring_class,
                ts.is_active,
                ts.current_season,
                ts.current_season
            )::scd_type
        ]) as records
    FROM this_season_data ts
    LEFT JOIN last_season_scd ls
      ON ls.player_name = ts.player_name
   WHERE ts.scoring_class <> ls.scoring_class
      OR ts.is_active <> ls.is_active
),
unnested_changed_records AS (
    -- flatten unnested array of changed records
    SELECT
        player_name,
        (records::scd_type).scoring_class,
        (records::scd_type).is_active,
        (records::scd_type).start_season,
        (records::scd_type).end_season
    FROM changed_records
),

new_records AS (
    -- new players appearing in 2022 for the first time
    SELECT
        ts.player_name,
        ts.scoring_class,
        ts.is_active,
        ts.current_season AS start_season,
        ts.current_season AS end_season
    FROM this_season_data ts
    LEFT JOIN last_season_scd ls
           ON ts.player_name = ls.player_name
   WHERE ls.player_name IS NULL
)

-- final SCD output for 2022 season
SELECT *, 2022 AS current_season FROM (
    SELECT * FROM historical_scd
    UNION ALL
    SELECT * FROM unchanged_records
    UNION ALL
    SELECT * FROM unnested_changed_records
    UNION ALL
    SELECT * FROM new_records
) a;
