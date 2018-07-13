CREATE OR REPLACE PACKAGE BODY sa.ERROR_LOG_PKG
IS
  PROCEDURE SP_INSERT_ERROR_TABLE (
      IP_ACTION         IN   sa.ERROR_TABLE.ACTION%TYPE,
      IP_ERROR_DATE     IN   sa.ERROR_TABLE.ERROR_DATE%TYPE DEFAULT SYSDATE,
      IP_KEY            IN   sa.ERROR_TABLE.KEY%TYPE DEFAULT NULL,
      IP_PROGRAM_NAME   IN   sa.ERROR_TABLE.PROGRAM_NAME%TYPE,
      IP_ERROR_TEXT     IN   sa.ERROR_TABLE.ERROR_TEXT%TYPE
   )
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      INSERT INTO sa.ERROR_TABLE
        ( ERROR_TEXT
          , ERROR_DATE
          , ACTION
          , KEY
          , PROGRAM_NAME)
      VALUES
        ( IP_ERROR_TEXT
          , IP_ERROR_DATE
          , IP_ACTION
          , IP_KEY
          , IP_PROGRAM_NAME
          );
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         RAISE;
   END SP_INSERT_ERROR_TABLE;
   ----------------------------------------------------------------------------
   PROCEDURE SP_INSERT_PROGRAM_ERROR_LOG (
      IP_SOURCE           IN   sa.X_PROGRAM_ERROR_LOG.X_SOURCE%TYPE
      , IP_ERROR_CODE     IN   sa.X_PROGRAM_ERROR_LOG.X_ERROR_CODE%TYPE
      , IP_ERROR_MSG      IN   sa.X_PROGRAM_ERROR_LOG.X_ERROR_MSG%TYPE DEFAULT NULL
      , IP_DATE           IN   sa.X_PROGRAM_ERROR_LOG.X_DATE%TYPE  DEFAULT SYSDATE
      , IP_DESCRIPTION    IN   sa.X_PROGRAM_ERROR_LOG.X_DESCRIPTION%TYPE
      , IP_SEVERITY       IN   sa.X_PROGRAM_ERROR_LOG.X_SEVERITY%TYPE
   )
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      INSERT INTO sa.X_PROGRAM_ERROR_LOG
        ( X_SOURCE
          , X_ERROR_CODE
          , X_ERROR_MSG
          , X_DATE
          , X_DESCRIPTION
          , X_SEVERITY)
      VALUES
        ( IP_SOURCE
          , IP_ERROR_CODE
          , IP_ERROR_MSG
          , IP_DATE
          , IP_DESCRIPTION
          , IP_SEVERITY
          );
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         RAISE;
   END SP_INSERT_PROGRAM_ERROR_LOG;
   --------------------------------------
   PROCEDURE SP_DEBUG_INSERT_ERROR_TABLE (
      IP_X_PARAM_NAME   IN   sa.TABLE_X_PARAMETERS.X_PARAM_NAME%TYPE,
      IP_ACTION         IN   sa.ERROR_TABLE.ACTION%TYPE,
      IP_ERROR_DATE     IN   sa.ERROR_TABLE.ERROR_DATE%TYPE DEFAULT SYSDATE,
      IP_KEY            IN   sa.ERROR_TABLE.KEY%TYPE DEFAULT NULL,
      IP_PROGRAM_NAME   IN   sa.ERROR_TABLE.PROGRAM_NAME%TYPE,
      IP_ERROR_TEXT     IN   sa.ERROR_TABLE.ERROR_TEXT%TYPE
   )
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      LV_COUNT    PLS_INTEGER := 0;
   BEGIN
      SELECT  COUNT(*)
      INTO    LV_COUNT
      FROM    sa.TABLE_X_PARAMETERS
      WHERE   X_PARAM_NAME = UPPER(IP_X_PARAM_NAME)
      AND     X_PARAM_VALUE = 'Y';

      IF LV_COUNT > 0 THEN
        INSERT INTO sa.ERROR_TABLE
          ( ERROR_TEXT
            , ERROR_DATE
            , ACTION
            , KEY
            , PROGRAM_NAME)
        VALUES
          ( IP_ERROR_TEXT
            , IP_ERROR_DATE
            , IP_ACTION
            , IP_KEY
            , IP_PROGRAM_NAME
            );
        COMMIT;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         RAISE;
   END SP_DEBUG_INSERT_ERROR_TABLE;
END ERROR_LOG_PKG;
/