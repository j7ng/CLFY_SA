CREATE OR REPLACE PACKAGE sa."SECURITY_MAINTENANCE_PKG"
AS

PROCEDURE SP_AddUser2Group
     (ip_UserObjid IN   NUMBER,
      ip_GrpObjid  IN   NUMBER,
      op_msg       OUT  VARCHAR2,
      op_result    OUT  NUMBER );

PROCEDURE SP_RemoveUser2Group
     (ip_UserObjid IN   NUMBER,
      ip_GrpObjid  IN   NUMBER,
      op_msg       OUT  VARCHAR2,
      op_result    OUT  NUMBER );

PROCEDURE SP_AddGroup2Func
     (ip_GrpObjid  IN   NUMBER,
      ip_FuncObjid IN   NUMBER,
      op_msg       OUT  VARCHAR2,
      op_result    OUT  NUMBER );

PROCEDURE SP_RemoveGroup2Func
     (ip_GrpObjid  IN   NUMBER,
      ip_FuncObjid IN   NUMBER,
      op_msg       OUT  VARCHAR2,
      op_result    OUT  NUMBER );

PROCEDURE SP_SaveGroupInfo
     (ip_GrpObjid IN varchar,
      ip_GrpID    IN varchar,
      ip_GrpValidFlag IN varchar,
      ip_GrpName  IN varchar,
      ip_GrpDesc  IN varchar,
      ip_Threshold_name IN varchar,
      ip_Threshold_desc IN varchar,
      ip_UnitsPerDay IN varchar,
      ip_UnitsPerESN IN varchar,
      ip_UnitsPerTrans IN varchar,
      op_msg       OUT  VARCHAR2,
      op_result    OUT  NUMBER );

PROCEDURE SP_SaveFuncInfo
     (ip_FuncObjid  IN varchar,
      ip_FuncID     IN varchar,
      ip_FuncValidFlag IN varchar,
      ip_FuncName   IN varchar,
      ip_FuncDesc   IN varchar,
      ip_FuncType   IN varchar,
      ip_FuncApp    IN varchar,
      op_msg       OUT  VARCHAR2,
      op_result    OUT  NUMBER );

PROCEDURE SP_VerifyFunc
     (ip_UserID      IN   VARCHAR2,
      ip_FuncID      IN   NUMBER,
      op_msg         OUT  VARCHAR2,
      op_result      OUT  NUMBER);

END SECURITY_MAINTENANCE_PKG;
/