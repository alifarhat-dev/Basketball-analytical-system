/*
===============================================================================
PL/pgSQL Script: Update Players Table Year by Year
===============================================================================
Script Purpose:
    Loop over seasons from 1997 to 2022 and update the 'players' table with 
    stats from 'player_seasons'. If the player already exists, append the 
    new season stats and update scoring classification. If the player is new, 
    insert a new row.
===============================================================================
*/
DO $$
DECLARE
    yr INT;  -- Loop variable for NBA seasons
BEGIN
    -- Loop through each season from 1997 to 2022
    FOR yr IN 1997..2022 LOOP

        -- Create CTE for players from last season
        WITH last_season AS (
            SELECT * 
            FROM players
            WHERE current_season = yr - 1
        ),
        -- Create CTE for players from the current season
        this_season AS (
            SELECT * 
            FROM player_seasons
            WHERE season = yr
        )
        -- Insert or update players for the current year
        INSERT INTO players
        SELECT
            COALESCE(ls.player_name, ts.player_name) AS player_name,
            COALESCE(ls.height, ts.height) AS height,
            COALESCE(ls.college, ts.college) AS college,
            COALESCE(ls.country, ts.country) AS country,
            COALESCE(ls.draft_year, ts.draft_year) AS draft_year,
            COALESCE(ls.draft_round, ts.draft_round) AS draft_round,
            COALESCE(ls.draft_number, ts.draft_number) AS draft_number,
            COALESCE(ls.seasons, ARRAY[]::season_stats[]) || 
            CASE 
                WHEN ts.season IS NOT NULL THEN
                    ARRAY[ROW(ts.season, ts.pts, ts.ast, ts.reb, ts.weight)::season_stats]
                ELSE
                    ARRAY[]::season_stats[]
            END AS seasons,
            CASE
                WHEN ts.season IS NOT NULL THEN
                    (CASE 
                        WHEN ts.pts > 20 THEN 'star'
                        WHEN ts.pts > 15 THEN 'good'
                        WHEN ts.pts > 10 THEN 'average'
                        ELSE 'bad'
                     END)::scoring_class
                ELSE ls.scoring_class
            END AS scoring_class,
			CASE
				WHEN ts.season IS NOT NULL THEN 0
				ELSE ls.years_since_last_active + 1
			END AS years_since_last_active,
            ts.season IS NOT NULL AS is_active,
            COALESCE(ts.season, ls.current_season + 1) AS current_season,
            CASE 
                WHEN ts.season IS NOT NULL THEN COALESCE(ls.total_seasons,0) + 1 
                ELSE ls.total_seasons
            END AS total_seasons
        FROM last_season ls
        FULL OUTER JOIN this_season ts
        ON ls.player_name = ts.player_name;

    END LOOP;
END $$;

