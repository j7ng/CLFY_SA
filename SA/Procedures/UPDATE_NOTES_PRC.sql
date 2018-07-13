CREATE OR REPLACE PROCEDURE sa."UPDATE_NOTES_PRC" (
P_ID IN TABLE_INTERACT.INTERACT_ID%TYPE,
P_NOTES IN VARCHAR2,
P_OUT_ERR OUT NUMBER) IS

   /******************************************************************************/
   /*    COPYRIGHT  2008 TRACFONE  WIRELESS INC. ALL RIGHTS RESERVED             */
   /*                                                                            */
   /* NAME:         SA.SP_UPDATE_NOTES_PRC                                       */
   /* PURPOSE:      CONCAT TEXT AND UPDATE NOTES                                 */
   /* FREQUENCY:                                                                 */
   /* PLATFORMS:    ORACLE 9.0.6 AND NEWER VERSIONS.                             */
   /*  AUTHOR :     LSATULURI                                                    */
   /* REVISIONS:                                                                 */
   /* VERSION  DATE        WHO          PURPOSE                                  */
   /* -------  ---------- -----     ------------------------------------------   */
   /*  1.0     04/08/08    LS    CR5072-3INITIAL  REVISION                       */
   /*  1.1     06/09/08    LS    CR7259                                          */
   /*  1.2     06/10/08   LS  MODIFIED TO INSERT                                */
   /*  1.3     06/18/08   LS GRANTS                                             */
   /******************************************************************************/

V_NOTES VARCHAR2(2000);
ERRORMSG VARCHAR2(2000);
TXT_ID  NUMBER;
CURSOR C_NOTES IS
SELECT NOTES FROM TABLE_INTERACT_TXT TT
    WHERE TT.INTERACT_TXT2INTERACT = ( SELECT TI.OBJID
                                       FROM TABLE_INTERACT TI
                                       WHERE TI.INTERACT_ID = P_ID);
    CURSOR INTERACT IS ( SELECT TI.OBJID
                          FROM TABLE_INTERACT TI
                          WHERE TI.INTERACT_ID = P_ID) ;
 BEGIN
     OPEN C_NOTES;

    ---LOOP
       FETCH C_NOTES INTO V_NOTES;
       ------INSERT THE RECORD IF THERE IS NONE
       IF C_NOTES%NOTFOUND
        THEN
          OPEN INTERACT;
          FETCH INTERACT INTO TXT_ID;
         INSERT INTO TABLE_INTERACT_TXT(OBJID,NOTES,INTERACT_TXT2INTERACT)
         VALUES (sa.SEQ('INTERACT_TXT'),P_NOTES,TXT_ID);
         CLOSE INTERACT;
         DBMS_OUTPUT.PUT_LINE('ROW INSERTED FOR PID' || P_ID );
         COMMIT;
         --EXIT;
    ELSE
      UPDATE TABLE_INTERACT_TXT TT
      SET TT.NOTES = RTRIM(LTRIM(CONCAT(NVL(V_NOTES,' '),NVL(P_NOTES,' '))))
           ---TT.NOTES = CONCAT(V_NOTES,P_NOTES)
      WHERE TT.INTERACT_TXT2INTERACT = (SELECT TI.OBJID
                                 FROM TABLE_INTERACT TI
                                 WHERE TI.INTERACT_ID = P_ID);
    END IF;
   ---END LOOP;
CLOSE C_NOTES;


  IF SQL%ROWCOUNT >=1
  THEN
     P_OUT_ERR := 0;
     COMMIT;
   ELSE
     P_OUT_ERR := SQLCODE;
     ROLLBACK;
  END IF;

  EXCEPTION

   WHEN OTHERS
   THEN
   ERRORMSG:= SQLERRM;
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        INSERT INTO sa.ERROR_TABLE(ERROR_TEXT,ERROR_DATE,ACTION,KEY,PROGRAM_NAME)
        VALUES(ERRORMSG,SYSDATE,'UPDATE NOTES',P_ID,'SA.UPDATE_NOTES_PRC');
        COMMIT;
END;
/