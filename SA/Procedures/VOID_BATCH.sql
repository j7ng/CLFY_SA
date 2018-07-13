CREATE OR REPLACE procedure sa.VOID_BATCH(day_id in number) as
CURSOR C_BATCH_ID IS
   SELECT *
      FROM X_PROGRAM_BATCH
     WHERE BATCH_STATUS ='SUBMITTED'
     -- BATCH_STATUS NOT IN('PROCESSED','Marked_FAILED_BY_DBAE')
     --AND    BATCH_SUB_DATE > SYSDATE-100;
     and (batch_sub_date > sysdate -day_id or X_BATCH_ID=day_id);
REC_BATCH C_BATCH_ID%ROWTYPE;
    V_BAT_ID NUMBER;
    PESN VARCHAR2(100);
    RECCOUNT NUMBER;
    CURSOR PURCH (BATCHID  NUMBER) IS
    SELECT PD.OBJID, PD.X_ESN
    FROM X_PROGRAM_PURCH_DTL PD,X_PROGRAM_PURCH_HDR PR
    WHERE  PD.PGM_PURCH_DTL2PROG_HDR = PR.OBJID
    AND PR.PROG_HDR2PROG_BATCH=BATCHID
    AND PR.X_PAYMENT_TYPE = 'RECURRING'
    AND PR.X_STATUS <>'PROCESSED';
    purch_rec purch%rowtype;
    CURSOR SP(VESN VARCHAR2) IS
      SELECT OBJID,X_EXPIRE_DT
      FROM TABLE_SITE_PART
      WHERE X_SERVICE_ID =VESN
      AND PART_STATUS     = 'ACTIVE'
        AND X_EXPIRE_DT > SYSDATE;
   SPREC   SP%ROWTYPE;
    no_inpd number;
 BEGIN
              FOR REC_BATCH IN C_BATCH_ID LOOP
                   V_BAT_ID:=REC_BATCH.X_BATCH_ID;
         --     DBMS_OUTPUT.PUT_LINE('THE BATCH WORKING ON : '||V_BAT_ID);
         --  dbms_output.put_line('deleting records from purchase Detail ');
            OPEN PURCH(V_BAT_ID);
                 no_inpd :=purch%ROWCOUNT;
            close PURCH;
       -- dbms_output.put_line('deleting  '||no_inpd  ||' records  from purchase Detail ');
             for purch_rec in purch(V_BAT_ID) loop
                    DELETE FROM X_PROGRAM_PURCH_DTL
                        WHERE OBJID = PURCH_REC.OBJID;
                    commit;
            --   Dbms_output.put_line('Deleted  : '|| no_inpd ||   '   ROWS from X_PROGRAM_PURCH_DTL   ' );
            ---------    UPDATE site_part if expire date is in future
                           OPEN SP(PURCH_REC.X_ESN);
                                FETCH SP INTO SPREC;
                                   IF SP%FOUND THEN
                                        UPDATE TABLE_SITE_PART
                                            SET X_EXPIRE_DT = SYSDATE -2
                                            WHERE X_SERVICE_ID= PURCH_REC.X_ESN
                                            AND PART_STATUS     = 'Active'
                                            AND X_EXPIRE_DT > SYSDATE
                                            AND OBJID=SPREC.OBJID;
                                     COMMIT;
                                    END IF;
                            CLOSE SP;
                    END LOOP;
            DELETE FROM X_PROGRAM_PURCH_HDR HD
              WHERE  PROG_HDR2PROG_BATCH = V_BAT_ID
               AND HD.X_PAYMENT_TYPE = 'RECURRING'
               AND HD.X_STATUS <>'PROCESSED';
            COMMIT;
        --   Dbms_output.put_line('Batch Deleted from X_PROGRAM_PURCH_HDR    :  '||v_bat_id||   '   ' );
                 UPDATE X_PROGRAM_BATCH
                     SET BATCH_STATUS =  'Marked_FAILED_BY_DBAE'
                     WHERE X_BATCH_ID=V_BAT_ID;
                 COMMIT;
       --     DBMS_OUTPUT.PUT_LINE('UPDATED  BATCH STATUS FOR     : '||V_BAT_ID||   '  ' );
        end loop;
          if c_batch_id%isopen then
                 close c_batch_id;
            end if;
end;
/