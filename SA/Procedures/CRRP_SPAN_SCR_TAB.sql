CREATE OR REPLACE PROCEDURE sa.CRRP_SPAN_SCR_TAB AS

CURSOR CL IS

SELECT a.rowid, a.* FROM SPAN_SCR_TAB a
WHERE  a.rowid in (select head_rowid from chained_rows);

V_REC      CL%ROWTYPE;
V_COUNTER  NUMBER:=0;

BEGIN

  OPEN CL;
    LOOP
      FETCH CL INTO V_REC;
      EXIT WHEN CL%NOTFOUND;
         V_COUNTER := V_COUNTER + 1;

         delete from SPAN_SCR_TAB
         where  rowid = v_rec.rowid;

         insert into SPAN_SCR_TAB values(
                                   v_rec.ENG_OBJID
                                 , v_rec.SPAN_TEXT
                                 , v_rec.DUP_STATUS
                                 , v_rec.SPAN_OBJID
                                 , v_rec.SCRIPT_TYPE
                                 , v_rec.SOURCE
                                 , v_rec.SCR_STATUS
                                 , v_rec.MTM_STATUS
                                 );

    END LOOP;
  CLOSE CL;
    DBMS_OUTPUT.PUT_LINE(V_COUNTER);
EXCEPTION
   WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/