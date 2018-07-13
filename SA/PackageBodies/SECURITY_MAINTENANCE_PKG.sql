CREATE OR REPLACE PACKAGE BODY sa."SECURITY_MAINTENANCE_PKG"
AS
/************************************************************/
/* Author       : Gerald Pintado
/* Date         : 02/26/2004
/* Purpose      : Maintains User Security Groups, Functions,
/*                and thresholds
/*
/*
/* Revisions: Version Date     Who      Purpose
/*            ------ -------- -------   ---------------------
/*               1.0 07/21/04 Gpintado  Initial Release
/*
/************************************************************/

/************************************************************/
/*
/* Associates Users to Groups by inserting into MTM table.
/*
/************************************************************/
PROCEDURE SP_AddUser2Group
     (ip_UserObjid IN   NUMBER,
      ip_GrpObjid  IN   NUMBER,
      op_msg       OUT  VARCHAR2,
      op_result    OUT  NUMBER )
IS

CURSOR c_exists
 IS
   SELECT *
     FROM MTM_USER125_X_SEC_GRP1
    WHERE user2x_sec_grp = ip_UserObjid;

r_exists c_exists%rowtype;

BEGIN

OPEN c_exists;
FETCH c_exists INTO r_exists;

  IF c_exists%NOTFOUND THEN

    INSERT INTO MTM_USER125_X_SEC_GRP1
      (USER2X_SEC_GRP,
       X_SEC_GRP2USER)
    VALUES
      (ip_UserObjid,
       ip_GrpObjid);
  ELSE
    UPDATE MTM_USER125_X_SEC_GRP1
       SET x_sec_grp2user = ip_GrpObjid
     WHERE user2x_sec_grp = ip_UserObjid;
  END IF;

CLOSE c_exists;

op_result := 0;
op_msg := 'Completed';

EXCEPTION
   WHEN OTHERS THEN
        OP_RESULT := -1;
        OP_MSG    := SQLERRM;
END SP_ADDUSER2GROUP;


/************************************************************/
/*
/* Delete Users from Groups by Deleting from MTM table.
/*
/************************************************************/
PROCEDURE SP_RemoveUser2Group
     (ip_UserObjid IN   NUMBER,
      ip_GrpObjid  IN   NUMBER,
      op_msg       OUT  VARCHAR2,
      op_result    OUT  NUMBER )
IS
BEGIN

 DELETE
   FROM MTM_USER125_X_SEC_GRP1
  WHERE USER2X_SEC_GRP = ip_UserObjid
    AND X_SEC_GRP2USER = ip_GrpObjid;

op_result := 0;
op_msg := 'Completed';

EXCEPTION
   WHEN OTHERS THEN
        OP_RESULT := -1;
        OP_MSG    := SQLERRM;
END SP_RemoveUser2Group;


/************************************************************/
/*
/* Adds Functions to Groups
/*
/************************************************************/

PROCEDURE SP_AddGroup2Func
     (ip_GrpObjid  IN   NUMBER,
      ip_FuncObjid IN   NUMBER,
      op_msg       OUT  VARCHAR2,
      op_result    OUT  NUMBER )
IS

CURSOR c_exists
 IS
   SELECT *
     FROM MTM_X_SEC_GRP2_X_SEC_FUNC0
    WHERE X_SEC_GRP2X_SEC_FUNC = ip_GrpObjid
      AND X_SEC_FUNC2X_SEC_GRP = ip_FuncObjid;


r_exists c_exists%rowtype;

BEGIN

OPEN c_exists;
FETCH c_exists INTO r_exists;

  IF c_exists%NOTFOUND THEN
     INSERT INTO MTM_X_SEC_GRP2_X_SEC_FUNC0
         (X_SEC_GRP2X_SEC_FUNC,X_SEC_FUNC2X_SEC_GRP)
     VALUES
         (ip_GrpObjid,ip_FuncObjid);
  END IF;

CLOSE c_exists;
op_result := 0;
op_msg := 'Completed';

EXCEPTION
   WHEN OTHERS THEN
        OP_RESULT := -1;
        OP_MSG    := SQLERRM;
END SP_AddGroup2Func;


/************************************************************/
/*
/* Removes function from Groups
/*
/************************************************************/
PROCEDURE SP_RemoveGroup2Func
     (ip_GrpObjid  IN   NUMBER,
      ip_FuncObjid IN   NUMBER,
      op_msg       OUT  VARCHAR2,
      op_result    OUT  NUMBER )
IS

BEGIN

     DELETE MTM_X_SEC_GRP2_X_SEC_FUNC0
     WHERE X_SEC_GRP2X_SEC_FUNC = ip_GrpObjid
      AND X_SEC_FUNC2X_SEC_GRP = ip_FuncObjid;

op_result := 0;
op_msg := 'Completed';

EXCEPTION
   WHEN OTHERS THEN
        OP_RESULT := -1;
        OP_MSG    := SQLERRM;
END SP_RemoveGroup2Func;

/************************************************************/
/*
/* Saves and Inserts records for Groups and Threshold Data
/*
/************************************************************/
PROCEDURE SP_SaveGroupInfo(
               ip_GrpObjid IN varchar,
               ip_GrpID IN varchar,
               ip_GrpValidFlag IN varchar,
               ip_GrpName IN varchar,
               ip_GrpDesc IN varchar,
               ip_Threshold_name IN varchar,
               ip_Threshold_desc IN varchar,
               ip_UnitsPerDay IN varchar,
               ip_UnitsPerESN IN varchar,
               ip_UnitsPerTrans IN varchar,
               op_msg       OUT  VARCHAR2,
               op_result    OUT  NUMBER )
IS

v_grpObjid NUMBER := 0;
v_THObjid NUMBER := 0;

BEGIN
  IF TO_NUMBER(IP_GrpObjid) >0 THEN
      UPDATE TABLE_X_SEC_GRP
         SET X_GRP_VALIDATE_FLAG = ip_GrpValidFlag,
             X_GRP_NAME = ip_GrpName,
             X_GRP_DESC = ip_GrpDesc
       WHERE OBJID = TO_NUMBER(IP_GrpObjid);

       UPDATE TABLE_X_SEC_THRESHOLD
          SET X_THRESHOLD_NAME = ip_Threshold_name,
              X_THRESHOLD_DESC = ip_Threshold_desc,
              X_UNITS_PER_DAY = ip_UnitsPerDay,
              X_UNITS_PER_ESN = ip_UnitsPerESN,
              X_UNITS_PER_TRAN = ip_UnitsPerTrans
       WHERE OBJID = (SELECT X_SEC_GRP2X_THRESHOLD
                        FROM TABLE_X_SEC_GRP
                       WHERE OBJID = TO_NUMBER(IP_GrpObjid)
                      );

  ELSE
       SP_SEQ('X_SEC_GRP',v_grpObjid);
       SP_SEQ('X_SEC_THRESHOLD',v_THObjid);

       INSERT INTO TABLE_X_SEC_GRP
         (OBJID,
          DEV,
          X_GRP_ID,
          X_GRP_NAME,
          X_GRP_DESC,
          X_CREATE_DATE,
          X_GRP_VALIDATE_FLAG,
          X_SEC_GRP2X_THRESHOLD)
       VALUES
         (v_grpObjid,
          0,
          ip_GrpID,
          ip_GrpName,
          ip_GrpDesc,
          SYSDATE,
          ip_GrpValidFlag,
          v_THObjid
         );

       INSERT INTO TABLE_X_SEC_THRESHOLD
         (OBJID,
          DEV,
          X_THRESHOLD_NAME,
          X_THRESHOLD_DESC,
          X_CREATE_DATE,
          X_UNITS_PER_DAY,
          X_UNITS_PER_ESN,
          X_UNITS_PER_TRAN
          )
       VALUES
         (v_THObjid,
          0,
          ip_Threshold_name,
          ip_Threshold_desc,
          SYSDATE,
          ip_UnitsPerDay,
          ip_UnitsPerESN,
          ip_UnitsPerTrans
          );

  END IF;
 op_result := 0;
 op_msg := 'Completed';
 COMMIT;
EXCEPTION
   WHEN OTHERS THEN
        ROLLBACK;
        OP_RESULT := -1;
        OP_MSG    := SQLERRM;
END SP_SaveGroupInfo;

/************************************************************/
/*
/* Saves and Inserts records for Function data
/*
/************************************************************/
PROCEDURE SP_SaveFuncInfo(
               ip_FuncObjid  IN varchar,
               ip_FuncID     IN varchar,
               ip_FuncValidFlag IN varchar,
               ip_FuncName   IN varchar,
               ip_FuncDesc   IN varchar,
               ip_FuncType   IN varchar,
               ip_FuncApp    IN varchar,
               op_msg       OUT  VARCHAR2,
               op_result    OUT  NUMBER )
IS
BEGIN
  IF TO_NUMBER(IP_FuncObjid) >0 THEN

      UPDATE TABLE_X_SEC_FUNC
         SET X_FUNC_VALIDATE_FLAG = ip_FuncValidFlag,
             X_FUNC_NAME = ip_FuncName,
             X_FUNC_DESC = ip_FuncDesc,
             X_FUNC_TYPE = ip_FuncType,
             X_FUNC_APP  = ip_FuncApp
       WHERE OBJID = TO_NUMBER(ip_FuncObjid);

  ELSE

       INSERT INTO TABLE_X_SEC_FUNC
         (OBJID,
          DEV,
          X_FUNC_ID,
          X_FUNC_NAME,
          X_FUNC_DESC,
          X_FUNC_TYPE,
          X_FUNC_APP,
          X_FUNC_CREATE_DATE,
          X_FUNC_VALIDATE_FLAG)
       VALUES
         (sa.SEQ('X_SEC_FUNC'),
          0,
          ip_FuncID,
          ip_FuncName,
          ip_FuncDesc,
          ip_FuncType,
          ip_FuncApp,
          SYSDATE,
          ip_FuncValidFlag
         );
  END IF;
 op_result := 0;
 op_msg := 'Completed';
 COMMIT;
EXCEPTION
   WHEN OTHERS THEN
        ROLLBACK;
        OP_RESULT := -1;
        OP_MSG    := SQLERRM;
END SP_SaveFuncInfo;


/************************************************************/
/*
/* Verify's if user has access to function
/*
/************************************************************/
PROCEDURE SP_VerifyFunc
        (ip_UserID      IN   VARCHAR2,
         ip_FuncID      IN   NUMBER,
         op_msg         OUT  VARCHAR2,
         op_result      OUT  NUMBER
         )
IS
CURSOR C1
IS
SELECT A.OBJID
  FROM TABLE_USER A,
       MTM_USER125_X_SEC_GRP1 B,
       MTM_X_SEC_GRP2_X_SEC_FUNC0 C,
       TABLE_X_SEC_FUNC D
 WHERE A.LOGIN_NAME = LOWER(ip_UserID)
   AND A.OBJID = B.USER2X_SEC_GRP
   AND B.X_SEC_GRP2USER = C.X_SEC_GRP2X_SEC_FUNC
   AND C.X_SEC_FUNC2X_SEC_GRP = D.OBJID
   AND D.X_FUNC_ID = ip_FuncID;

BEGIN

 OP_MSG := 'F';
 OP_RESULT := -1;

 FOR C1_REC IN C1 LOOP
   OP_MSG := 'T';
   OP_RESULT := 0;
 END LOOP;

EXCEPTION
   WHEN OTHERS THEN
        ROLLBACK;
        OP_RESULT := -1;
        OP_MSG    := SQLERRM;

END SP_VerifyFunc;

END SECURITY_MAINTENANCE_PKG;
/