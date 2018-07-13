CREATE OR REPLACE PACKAGE sa.INVALIDATE_CACHE_PKG
AS

  PROCEDURE SP_EXPIRE_CACHE_BY_ESN
    ( IP_MIN              IN VARCHAR2,
      IP_ESN              IN VARCHAR2,
      OP_ERROR_CODE       OUT NUMBER,
      OP_ERROR_MESSAGE    OUT VARCHAR2);

END INVALIDATE_CACHE_PKG;
/