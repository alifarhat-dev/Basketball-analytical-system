/*
===============================================================================
DDL Script: Players SCD Table
===============================================================================
Purpose:
    Create a Slowly Changing Dimension (SCD) style table to track changes
    in player attributes (`scoring_class`, `is_active`) across seasons.
    Each row represents a "streak" period where values remain constant.
===============================================================================
*/

-- Create table to hold SCD history for players
CREATE TABLE players_scd(
    player_name TEXT,                  -- Full name of the player (part of PK)
    scoring_class scoring_class,       -- Scoring classification during streak
    is_active BOOLEAN,                 -- Active status during streak
    current_season INTEGER,            -- Reference point season (e.g., snapshot year)
    start_season INTEGER,              -- First season of the streak
    end_season INTEGER,                -- Last season of the streak
    PRIMARY KEY(player_name, start_season, end_season)  -- Composite PK for uniqueness
);
CREATE TYPE scd_type AS (
    scoring_class scoring_class,  -- Classification during streak
    is_active BOOLEAN,            -- Active status during streak
    start_season INTEGER,         -- First season of streak
    end_season INTEGER            -- Last season of streak
);
