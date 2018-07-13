CREATE OR REPLACE PROCEDURE sa.SP_CHECK_DEFECT_LIST
/***********************************************************************************/
/* Name         :   SA.SP_CHECK_DEFECT_LIST
/* Purpose      :   To check if given ESN is part of defect list and if its the
/*                  first time being checked.
/* Parameters   :   ip_esn, op_result
/* Author       :   Gerald Pintado
/* Date         :   04/01/2005
/* Revisions    :
/* Version  Date       Who        Purpose
/* -------  --------   --------   -------------------------------------
/* 1.0     04/01/2005  Gpintado   Initial revision
/*
/***********************************************************************************/
(
ip_esn IN VARCHAR2,
ip_update IN VARCHAR2, --YES=UPDATE, NO=ONLY CHECK
op_result OUT VARCHAR2
)
IS
 CURSOR c1
  IS
  SELECT A.ROWID,A.*
    FROM X_DEFECT_LIST A
   WHERE ESN = ip_esn;

BEGIN
 OP_RESULT := '0';
 FOR c1_rec IN c1 LOOP
       IF C1_REC.CHECKED_DATE IS NULL THEN

         IF ip_update = 'NO' THEN
            OP_RESULT := '1'; -- Exists in list
         ELSIF ip_update = 'YES' THEN

	         UPDATE X_DEFECT_LIST
	            SET CHECKED_DATE = SYSDATE
	          WHERE ROWID = c1_rec.ROWID;
              COMMIT;
              OP_RESULT := '1'; -- Exists in list
         END IF;
       ELSE
         OP_RESULT := '2'; -- Exists but has already been checked
       END IF;
 END LOOP;

EXCEPTION
 WHEN OTHERS THEN
    op_result := '3'; -- Error has occured
END;
/