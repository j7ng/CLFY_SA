CREATE OR REPLACE PROCEDURE sa.sp_update_contact_info(
    p_error OUT VARCHAR2)
IS
  --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: sp_update_contact_info.SQL,v $
  --$Revision: 1.9 $
  --$Author: spokala $
  --$Date: 2017/03/29 13:36:45 $
  --$ $Log: sp_update_contact_info.SQL,v $
  --$ Revision 1.9  2017/03/29 13:36:45  spokala
  --$ CR47984 added grants from the previous version.
  --$
  --$ Revision 1.8  2017/03/22 15:00:42  spokala
  --$ Uncommented Update Count code
  --$
  --$ Revision 1.7  2017/03/22 14:51:01  spokala
  --$ CR47984 Commented Delete statement since the shell script which is calling this SP truncating the table
  --$
  --$ Revision 1.6  2015/12/21 15:23:00  ddevaraj
  --$ CR39624
  --$
  --$
  ---------------------------------------------------------------------------------------------
  --
  v_upd number:=0;
BEGIN
  FOR i IN
  (SELECT * FROM sa.X_UPDATE_CONTACT_INFO
  )
  LOOP
    BEGIN
      UPDATE table_x_contact_add_info
      SET X_DO_NOT_SMS=1
      WHERE objid    IN
        (SELECT cai.objid
        FROM sa.table_site_part sp,
          table_part_inst pi,
          sa.table_contact c,
          sa.table_x_contact_add_info cai
        WHERE 1                      =1
        AND sp.x_min                 = I.MIN
        AND pi.X_PART_INST2SITE_PART = sp.objid
        AND pi.x_part_inst2contact   = c.objid
        AND cai.add_info2contact     = c.objid
        );
        EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('sqlerrm'||sqlerrm);
      p_error := sqlerrm;
      RETURN;
    END;

    IF SQL%ROWCOUNT >0 THEN
    v_upd:=v_upd+1;
    --CR47984 Commented below code, since the shell script which is calling this SP, truncating the table.
     -- DELETE FROM sa.X_UPDATE_CONTACT_INFO WHERE MIN=i.min;


    END IF;
    COMMIT;
  END LOOP;
  dbms_output.put_line('updated '||v_upd);
    p_error := 'SUCCESS';

EXCEPTION
WHEN OTHERS THEN
  P_ERROR := SQLERRM;
END;
/