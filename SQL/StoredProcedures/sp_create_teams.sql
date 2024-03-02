-- PROCEDURE: public.sp_create_teams()

-- DROP PROCEDURE IF EXISTS public.sp_create_teams();

CREATE OR REPLACE PROCEDURE public.sp_create_teams(
	)
LANGUAGE 'sql'
AS $BODY$

-- Create temp table to hold all the new teams
CREATE TEMPORARY TABLE NEW_TEAMS as ( 
	SELECT tmp.PLAYER_TEAM, tmp.PLAYER_COLOUR
	FROM (
		SELECT PLAYER_1_TEAM AS PLAYER_TEAM,
			   PLAYER_1_COLOUR AS PLAYER_COLOUR
				FROM spl_games
		GROUP BY PLAYER_1_TEAM, PLAYER_1_COLOUR
		UNION ALL
		SELECT PLAYER_2_TEAM AS PLAYER_TEAM,
					PLAYER_2_COLOUR AS PLAYER_COLOUR
				FROM spl_games
		GROUP BY PLAYER_2_TEAM, PLAYER_2_COLOUR) as tmp
		GROUP BY tmp.PLAYER_TEAM, tmp.PLAYER_COLOUR
		ORDER BY 1
);

-- Create teams
INSERT INTO TEAMS (TEAM_ID, COLOR)
SELECT PLAYER_TEAM, PLAYER_COLOUR
FROM NEW_TEAMS
ON CONFLICT DO NOTHING;

-- Calculate Mana
UPDATE teams
SET mana_cost = final_table.team_mana
FROM
	(SELECT PLAYER_TEAM,
						split_ids.PLAYER_COLOUR AS PLAYER_COLOUR,
						SUM(spl_cards.mana) AS TEAM_MANA
				FROM
					(SELECT PLAYER_TEAM,
							PLAYER_COLOUR,
							unnest(string_to_array(PLAYER_TEAM, ',')) AS "card_id"
						FROM NEW_TEAMS) as split_ids
		INNER JOIN spl_cards on spl_cards.card_id = CAST(split_ids.card_id AS integer)
		GROUP BY PLAYER_TEAM, PLAYER_COLOUR) final_table
WHERE teams.TEAM_ID = final_table.PLAYER_TEAM;

-- Create teams_cards
INSERT INTO TEAM_CARDS (TEAM_ID, CARD_ID, CARD_POSITION)
SELECT sub_query.PLAYER_TEAM,
		sub_query.CARD_ID,
		sub_query.CARD_POSITION
FROM(
	SELECT PLAYER_1_TEAM AS PLAYER_TEAM,
			CARD_ID,
			array_position(string_to_array(PLAYER_1_TEAM, ','), CAST(CARD_ID AS TEXT)) AS CARD_POSITION
		FROM (
			SELECT PLAYER_1_TEAM,
				CAST(unnest(string_to_array(PLAYER_1_TEAM, ',')) as INTEGER) AS "card_id"
			FROM SPL_GAMES_ARCHIVE)
	UNION ALL
	SELECT PLAYER_2_TEAM AS PLAYER_TEAM,
		CARD_ID,
		array_position(string_to_array(PLAYER_2_TEAM, ','), CAST(CARD_ID AS TEXT)) AS CARD_POSITION
		FROM (
			SELECT PLAYER_2_TEAM,
				CAST(unnest(string_to_array(PLAYER_2_TEAM, ',')) as INTEGER) AS "card_id"
			FROM SPL_GAMES_ARCHIVE)
) as sub_query
LEFT OUTER JOIN TEAM_CARDS tc on TC.TEAM_ID = sub_query.PLAYER_TEAM
WHERE tc.TEAM_ID IS NULL
GROUP BY sub_query.PLAYER_TEAM, sub_query.CARD_ID, sub_query.CARD_POSITION;

DROP TABLE NEW_TEAMS;

$BODY$;
ALTER PROCEDURE public.sp_create_teams()
    OWNER TO postgres;
