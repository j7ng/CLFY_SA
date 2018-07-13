CREATE OR REPLACE TYPE sa.TYP_ESN_INFO_OBJ AS OBJECT
(
	X_ESN                                       VARCHAR2(30)
  , X_WEB_ACCT_OBJID                          NUMBER(30)
  , X_PROG_ENROLLED_OBJID                     NUMBER(30)
  , X_PRIMARY_PROG_ENROLL_OBJID               NUMBER(30)
  , X_PROGRAM_PARAM_OBJID                     NUMBER(30)
  , X_PROGRAM_NAME                            VARCHAR2(40)
  , X_PROMOTION_OBJID                         NUMBER(30)
  , X_NEXT_CHARGE_DATE                        DATE
  , X_CHARGE_TYPE	                            VARCHAR2(30)
);
/