CREATE OR REPLACE type sa.typ_aps_info AS object (
Alt_Pymt_Source            VARCHAR2(50),
Alt_Pymt_Source_Type       VARCHAR2(50),
Application_Key            VARCHAR2(100),
constructor FUNCTION typ_aps_info RETURN self AS result );
/
CREATE OR REPLACE type body sa.typ_APS_info IS constructor FUNCTION typ_APS_info RETURN self AS result IS
BEGIN
RETURN;
END;
END;
/