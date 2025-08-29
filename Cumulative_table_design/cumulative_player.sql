/*
===============================================================================
DML Script: Insert Player Data into 'players' Table
===============================================================================
Script Purpose:
    This script inserts aggregated player-season data into the 'players' table.
    It computes per-season statistics arrays, scoring classification, active status,
    and years since last active for each player.
===============================================================================
*/

-- Insert data into players table
INSERT INTO players
WITH years AS (
    -- Generate all NBA seasons from 1996 to 2022
    SELECT *
    FROM GENERATE_SERIES(1996, 2022) AS season
), p AS (
    -- Determine the first season of each player
    SELECT
        player_name,
        MIN(season) AS first_season
    FROM player_seasons
    GROUP BY player_name
), players_and_seasons AS (
    -- Generate one row per player per season from their first season onward
    SELECT *
    FROM p
    JOIN years y
        ON p.first_season <= y.season
), windowed AS (
    -- Aggregate season stats into an array of season_stats
    SELECT
        pas.player_name,
        pas.season,
        ARRAY_REMOVE(
            ARRAY_AGG(
                CASE
                    WHEN ps.season IS NOT NULL THEN
                        ROW(
                            ps.season,
                            ps.pts,
                            ps.ast,
                            ps.reb,
                            ps.weight
                        )::season_stats
                END
            ) OVER (PARTITION BY pas.player_name ORDER BY COALESCE(pas.season, ps.season)),
            NULL
        ) AS seasons
    FROM players_and_seasons pas
    LEFT JOIN player_seasons ps
        ON pas.player_name = ps.player_name
        AND pas.season = ps.season
    ORDER BY pas.player_name, pas.season
), static AS (
    -- Pull static player information (height, college, draft info, etc.)
    SELECT
        player_name,
        MAX(height) AS height,
        MAX(college) AS college,
        MAX(country) AS country,
        MAX(draft_year) AS draft_year,
        MAX(draft_round) AS draft_round,
        MAX(draft_number) AS draft_number
    FROM player_seasons
    GROUP BY player_name
)
-- Final select: combine aggregated stats with static info
SELECT
    w.player_name,
    s.height,
    s.college,
    s.country,
    s.draft_year,
    s.draft_round,
    s.draft_number,
    seasons AS season_stats,
    CASE
        WHEN (seasons[CARDINALITY(seasons)]::season_stats).pts > 20 THEN 'star'
        WHEN (seasons[CARDINALITY(seasons)]::season_stats).pts > 15 THEN 'good'
        WHEN (seasons[CARDINALITY(seasons)]::season_stats).pts > 10 THEN 'average'
        ELSE 'bad'
    END::scoring_class AS scoring_class,
    w.season - (seasons[CARDINALITY(seasons)]::season_stats).season AS years_since_last_active,
    (seasons[CARDINALITY(seasons)]::season_stats).season = w.season AS is_active,
    w.season
FROM windowed w
JOIN static s
    ON w.player_name = s.player_name;
