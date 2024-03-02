-- PROCEDURE: public.sp_cleanup()

-- DROP PROCEDURE IF EXISTS public.sp_cleanup();

CREATE OR REPLACE PROCEDURE public.sp_cleanup(
	)
LANGUAGE 'sql'
AS $BODY$
CALL public.sp_create_new_users();

INSERT INTO SPL_GAMES_ARCHIVE
SELECT * FROM SPL_GAMES;

TRUNCATE SPL_GAMES;
$BODY$;
ALTER PROCEDURE public.sp_cleanup()
    OWNER TO postgres;
