CREATE OR REPLACE PACKAGE sa.GET_ESN_INFO_PKG AS

  PROCEDURE SP_IS_ESN_MINC_ALLOWED
    (IP_ESN    IN VARCHAR2
    , OP_MINC_ALLOWED   OUT VARCHAR2
    , OP_MINC_COUNT     OUT NUMBER
    , OP_ERR_NUM        OUT VARCHAR2
	  , OP_ERR_STRING     OUT VARCHAR2);

END GET_ESN_INFO_PKG;
/