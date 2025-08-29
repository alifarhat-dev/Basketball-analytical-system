/*
===============================================================================
CTE: Filter Players for 2022 Season AND make some queries to prove the 
performance.
===============================================================================
Purpose:
===============================================================================
*/
WITH CTE AS (
    SELECT *
    FROM players
    WHERE current_season = 2022
),
unnest_players AS (
    SELECT 
        player_name,
        height,
        college,
        country,
        draft_year,
        draft_round,
        draft_number,
        (UNNEST(seasons)::season_stats).*  -- Expand each season into separate columns
    FROM players
    WHERE current_season = 2022
)

--============================================================--
-- Ratio: Most Recent Season Points / First Season Points
--============================================================--
SELECT 
    player_name,
    (seasons[cardinality(seasons)]::season_stats).pts /
    CASE 
        WHEN (seasons[1]::season_stats).pts = 0 THEN 1  -- Avoid division by zero
        ELSE (seasons[1]::season_stats).pts
    END AS ratio_most_recent_to_first
FROM CTE;

--============================================================--
-- Average Heights of Players
--============================================================--
SELECT 	
    ROUND(
        AVG(
            (CAST(SPLIT_PART(height, '-', 1) AS DECIMAL) * 12   -- Feet to inches
             + CAST(SPLIT_PART(height, '-', 2) AS DECIMAL))    -- Add inches
             * 0.0254                                         -- Convert inches to meters
        ), 2
    ) AS average_height_in_metre
FROM CTE;

--============================================================--
-- First and Last Season for Each Player
--============================================================--
SELECT 
    player_name,
    (seasons[1]::season_stats).season AS first_season,  -- First season 
    (seasons[array_length(seasons, 1)]::season_stats).season AS last_season  -- Last season
FROM CTE;

--============================================================--
-- Total Seasons per Player
--============================================================--
SELECT 
    player_name,
    total_seasons
FROM CTE
ORDER BY 2 DESC;  -- Order by total_seasons descending

--============================================================--
-- Active Players (years_since_last_active = 0)
--============================================================--
SELECT *
FROM CTE
WHERE years_since_last_active = 0;

--============================================================--
-- Inactive Players (years_since_last_active > 0)
--============================================================--
SELECT *
FROM CTE
WHERE years_since_last_active > 0;

