-- CREATE TYPE season_stat AS (
--                      season INTEGER,
--                      gp INTEGER,
--                      pts REAL,
--                      reb REAL,
--                      ast REAL
--                                             )


-- create type scoring_class AS ENUM('star','good', 'average', 'bad');
--
-- CREATE TABLE players(
--                      player_name TEXT,
--                      height TEXT,
--                      college TEXT,
--                      country TEXT,
--                      draft_year TEXT,
--                      draft_round TEXT,
--                      draft_number TEXT,
--                      season_stats season_stats[],
--                     scoring_class scoring_class,
--     years_since_last_season INTEGER,
--                      current_season INTEGER,
--                      PRIMARY KEY (player_name, current_season)
--                  );


INSERT INTO players
                 WITH yesterday AS(
                     SELECT * FROM players
                              where current_season = 2000
                 ),
                     today AS (
                         SELECT * FROM player_seasons
                                  where season = 2001
                     )
                 select
                     COALESCE(t.player_name, y.player_name) AS player_name,
                     COALESCE(t.height, y.height) AS height,
                     COALESCE(t.college, y.college) AS college,
                     COALESCE(t.country, y.country) AS country,
                     COALESCE(t.draft_year, y.draft_year) AS draft_year,
                     COALESCE(t.draft_round, y.draft_round) AS draft_round,
                     COALESCE(t.draft_number, y.draft_number) AS draft_number,
                     CASE WHEN y.season_stats IS NULL
                 THEN ARRAY[ROW(
                     t.season,
                     t.gp,
                     t.pts,
                     t.reb,
                     t.ast
                             )::season_stats]
                     WHEN t.season IS NOT NULL THEN y.season_stats || ARRAY[ROW(
                         t.season,
                         t.gp,
                         t.pts,
                         t.reb,
                         t.ast
                         )::season_stats]
                     ELSE y.season_stats
                 END AS season_stats,
                     case when t.season IS NOT NULL then
                         CASE WHEN t.pts > 20 then 'star'
                             WHEN t.pts > 15 THEN 'good'
                             WHen t.pts >10 THEN 'average'
                             ELSE 'bad'
                         END::scoring_class
                         ELSE y.scoring_class
                             END,
                     CASE WHEN t.season IS NOT NULL THEN 0
                         ELSE y.years_since_last_season + 1
                             END as years_since_last_season,

                     COALESCE(t.season, y.current_season + 1) as current_season

                 from today t FULL OUTER JOIN yesterday y
                 ON t.player_name = y.player_name;


-- WITH unneseted AS (select player_name,
--                                            unnest(season_stats) AS season_stats
--                                     from players
--                                     where current_season = 2001
--
--                  )
--                  select player_name,
--                         (season_stats::season_stats).* from unneseted;
-- select * from players where players.current_season= 2000 and player_name = 'Michael Jordan'


select player_name,
       (season_stats[cardinality(season_stats)]::season_stats).pts/
       CASE WHEN (season_stats[1]::season_stats).pts =0 then 1 else (season_stats[1]::season_stats).pts END
from players
where current_season = 2001 and player_name = 'Don MacLean'
order by 2 desc
;

select player_name,
season_stats, years_since_last_season  from players
where current_season = 2001 and player_name = 'Don MacLean'

