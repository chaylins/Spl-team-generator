-- PROCEDURE: public.sp_process_games()

-- DROP PROCEDURE IF EXISTS public.sp_process_games();

CREATE OR REPLACE PROCEDURE public.sp_process_games(
	)
LANGUAGE 'plpgsql'
AS $BODY$
	DECLARE
		BEGIN

			CREATE TABLE INVALID_GAMES
			AS
			SELECT g.BATTLE_QUEUE_ID_1 FROM SPL_GAMES g
			LEFT OUTER JOIN SPL_GAMES_ARCHIVE ga ON GA.BATTLE_QUEUE_ID_1 = G.BATTLE_QUEUE_ID_1
			WHERE ga.BATTLE_QUEUE_ID_1 IS NOT NULL;

			DELETE FROM SPL_GAMES g
			WHERE g.BATTLE_QUEUE_ID_1 IN(
				SELECT BATTLE_QUEUE_ID_1
				FROM INVALID_GAMES);

			DROP TABLE INVALID_GAMES;

			INSERT INTO WIN_RATES (TEAM_ID, COLOR, RULESET, GAMES_WON, GAMES_LOST)
			SELECT PLAYER_TEAM, PLAYER_COLOUR, RULESET, SUM(WIN), SUM(LOSS) 
			FROM (
			SELECT PLAYER_1_TEAM AS PLAYER_TEAM,
					PLAYER_1_COLOUR AS PLAYER_COLOUR,
					RULESET,
					CASE
						WHEN (PLAYER_1_NAME = WINNER) THEN 1
						ELSE 0
					END AS WIN,
					CASE
						WHEN (PLAYER_1_NAME <> WINNER) THEN 1
						ELSE 0
					END AS LOSS
			FROM SPL_GAMES

			UNION ALL

			SELECT PLAYER_2_TEAM AS PLAYER_TEAM,
					PLAYER_2_COLOUR AS PLAYER_COLOUR,
					RULESET,
					CASE
						WHEN (PLAYER_2_NAME = WINNER) THEN 1
						ELSE 0
					END AS WIN,
					CASE
						WHEN (PLAYER_2_NAME <> WINNER) THEN 1
						ELSE 0
					END AS LOSS
			FROM SPL_GAMES)
			GROUP BY PLAYER_TEAM, PLAYER_COLOUR, RULESET
			ON CONFLICT (team_id, color, ruleset) DO UPDATE
				SET GAMES_WON = WIN_RATES.GAMES_WON + EXCLUDED.GAMES_WON,
					GAMES_LOST = WIN_RATES.GAMES_LOST + EXCLUDED.GAMES_LOST;
		END;
$BODY$;
ALTER PROCEDURE public.sp_process_games()
    OWNER TO postgres;
