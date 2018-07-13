CREATE OR REPLACE PROCEDURE sa."UPDATE_SCRIPTS" (source_pn in varchar2, target_pn in varchar2)
as
CURSOR C1 IS
SELECT  TS.objid ts_objid,ts.X_LANGUAGE, ts.X_SCRIPT_ID, ts.X_SCRIPT_TEXT, ts.X_SEQUENCE, ts.X_TYPE
FROM sa.TABLE_X_PART_SCRIPT TS, sa.TABLE_PART_NUM TN
WHERE TS.PART_SCRIPT2PART_NUM=TN.OBJID
AND PART_NUMBER  = source_pn;

cursor C2 is
SELECT  TS.objid  FROM sa.TABLE_X_PART_SCRIPT TS, sa.TABLE_PART_NUM TN
WHERE TS.PART_SCRIPT2PART_NUM=TN.OBJID
AND PART_NUMBER  = target_pn;

cursor c3 is
select objid from sa.table_part_num where PART_NUMBER  = target_pn;


 l3 c3%ROWTYPE;

BEGIN

    For L2 IN C2
    loop
        delete from sa.TABLE_X_PART_SCRIPT where objid = l2.objid;
    end loop;
    COMMIT;

    open c3;
    fetch c3 into l3;

    if c3%found then

       FOR L1 IN C1
       LOOP
        INSERT INTO sa.TABLE_X_PART_SCRIPT (OBJID,PART_SCRIPT2PART_NUM,X_SCRIPT_TEXT,X_SEQUENCE,X_TYPE,X_LANGUAGE,X_SCRIPT_ID)
        VALUES(SEQ('x_part_script'), l3.objid,l1.X_SCRIPT_TEXT,
        l1.X_SEQUENCE,l1.X_TYPE,l1.X_LANGUAGE,l1.X_SCRIPT_ID);


       END LOOP;
       commit;
    end if;

    close c3;
END update_scripts;
/