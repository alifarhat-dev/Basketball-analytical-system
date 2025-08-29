/*
===============================================================================
DDL Script: Create Players Table
===============================================================================
Script Purpose:
    Run this script to re-define the DDL structure of the 'players' table.
===============================================================================
*/

-- Drop and create composite type: season_stats
DROP TYPE IF EXISTS season_stats;
CREATE TYPE season_stats AS (
    season INTEGER,     -- NBA season year (e.g., 2022)
    pts REAL,           -- Points per game
    ast REAL,           -- Assists per game
    reb REAL,           -- Rebounds per game
    weight INTEGER      -- Player's weight in lbs or kg
);

-- Drop and create enum type: scoring_class
DROP TYPE IF EXISTS scoring_class;
CREATE TYPE scoring_class AS ENUM (
    'bad',      -- Poor scoring performance
    'average',  -- Decent, middle-level scorer
    'good',     -- Above-average scorer
    'star'      -- Elite scorer
);

-- Drop and create players table
DROP TABLE IF EXISTS players;
CREATE TABLE players (
    player_name TEXT,                  -- Full name of the player (part of PK)
    height TEXT,                       -- Height (e.g., '6 ft 7 in')
    college TEXT,                      -- College attended (NULL if none)
    country TEXT,                      -- Country of origin
    draft_year TEXT,                   -- Year player was drafted
    draft_round TEXT,                  -- Draft round
    draft_number TEXT,                 -- Draft pick number
    seasons season_stats[],            -- Array of per-season stats
    scoring_class scoring_class,       -- Scoring classification
    years_since_last_active INTEGER,   -- Years since player last played
    is_active BOOLEAN,                 -- Currently active
    current_season INTEGER,   -- Season year (part of PK)
	total_seasons INTEGER, --total seasons in each player career
    PRIMARY KEY (player_name, current_season)
);

