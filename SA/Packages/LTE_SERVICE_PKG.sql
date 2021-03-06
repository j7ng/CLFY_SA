CREATE OR REPLACE PACKAGE sa."LTE_SERVICE_PKG" AS
FUNCTION IS_LTE_4G_SIM_REM (P_ESN   IN     VARCHAR2)
return number ;

FUNCTION DLL_LTE_4G(P_ESN IN VARCHAR2)
RETURN VARCHAR2 ;

FUNCTION PN_SIM_LTE_4G(p_DLL IN VARCHAR2, p_carrier_id in varchar2 )
RETURN VARCHAR2 ;

FUNCTION IS_LTE_4G_INACTIVE(P_ESN IN VARCHAR2)
RETURN NUMBER;


PROCEDURE IS_LTE_COMPATIBLE (P_X_ICCID IN VARCHAR2, P_ESN IN VARCHAR2, P_ERROR_CODE OUT NUMBER);

PROCEDURE IS_LTE_MARRiAGE(P_ESN IN VARCHAR2,
                         P_SIM_STATUS OUT VARCHAR2,
                         P_X_ICCID    OUT VARCHAR2,
                         P_ESN_STATUS OUT VARCHAR2,
                         P_ERROR_CODE OUT NUMBER);
PROCEDURE LTE_MARRiAGE(P_ESN        IN VARCHAR2,
                     P_X_ICCID    in VARCHAR2,
                     P_ERROR_CODE out number);

FUNCTION IS_LTE_SINGLE (P_X_ICCID  IN     VARCHAR2)
return number;


FUNCTION IS_ESN_LTE_CDMA(P_ESN IN VARCHAR2)
RETURN NUMBER;

END LTE_SERVICE_PKG;
/