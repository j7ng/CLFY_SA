CREATE OR REPLACE PACKAGE sa.ERROR_LOG_PKG
IS
  PROCEDURE SP_INSERT_ERROR_TABLE (
      IP_ACTION         IN   sa.ERROR_TABLE.ACTION%TYPE,
      IP_ERROR_DATE     IN   sa.ERROR_TABLE.ERROR_DATE%TYPE DEFAULT SYSDATE,
      IP_KEY            IN   sa.ERROR_TABLE.KEY%TYPE DEFAULT NULL,
      IP_PROGRAM_NAME   IN   sa.ERROR_TABLE.PROGRAM_NAME%TYPE,
      IP_ERROR_TEXT     IN   sa.ERROR_TABLE.ERROR_TEXT%TYPE
   );
  PROCEDURE SP_INSERT_PROGRAM_ERROR_LOG (
      IP_SOURCE           IN   sa.X_PROGRAM_ERROR_LOG.X_SOURCE%TYPE
      , IP_ERROR_CODE     IN   sa.X_PROGRAM_ERROR_LOG.X_ERROR_CODE%TYPE
      , IP_ERROR_MSG      IN   sa.X_PROGRAM_ERROR_LOG.X_ERROR_MSG%TYPE DEFAULT NULL
      , IP_DATE           IN   sa.X_PROGRAM_ERROR_LOG.X_DATE%TYPE  DEFAULT SYSDATE
      , IP_DESCRIPTION    IN   sa.X_PROGRAM_ERROR_LOG.X_DESCRIPTION%TYPE
      , IP_SEVERITY       IN   sa.X_PROGRAM_ERROR_LOG.X_SEVERITY%TYPE
   );
   PROCEDURE SP_DEBUG_INSERT_ERROR_TABLE(
      IP_X_PARAM_NAME   IN   sa.TABLE_X_PARAMETERS.X_PARAM_NAME%TYPE,
      IP_ACTION         IN   sa.ERROR_TABLE.ACTION%TYPE,
      IP_ERROR_DATE     IN   sa.ERROR_TABLE.ERROR_DATE%TYPE DEFAULT SYSDATE,
      IP_KEY            IN   sa.ERROR_TABLE.KEY%TYPE DEFAULT NULL,
      IP_PROGRAM_NAME   IN   sa.ERROR_TABLE.PROGRAM_NAME%TYPE,
      IP_ERROR_TEXT     IN   sa.ERROR_TABLE.ERROR_TEXT%TYPE
   );
END ERROR_LOG_PKG;
/