CREATE OR REPLACE FORCE VIEW sa.x_job_pending_activations_nt10 (job_objid,job_title,x_old_esn,x_esn,x_min,x_program_objid,x_iccid,x_zip,case_objid,x_contact_objid) AS
SELECT  j.objid           job_objid
        ,J.TITLE           JOB_TITLE
        ,J.X_OLD_ESN
        ,J.X_ESN
        ,J.X_MIN
        ,j.x_program_objid
        ,J.X_ICCID
        ,J.X_ZIP
        ,J.JOB_RESULT2CASE CASE_OBJID
        ,j.X_CONTACT_OBJID
    FROM TABLE_JOB J, TABLE_CASE C , TABLE_PART_INST PI
   WHERE j.S_TITLE in ('ACTIVATION','EXPRESS ACTIVATION')
     AND J.JOB_RESULT2CASE = C.OBJID
     AND J.X_ESN =  PI.PART_SERIAL_NO
     AND PI.X_PART_INST_STATUS <> '52'
     and case_type_lvl2 = 'NET10'
     AND job_sts2gbst_elm IN (SELECT elm.objid
                                FROM table_gbst_elm elm
                                    ,table_gbst_lst lst
                               WHERE gbst_elm2gbst_lst = lst.objid
                                 AND LST.TITLE = 'Open'
                                 AND ELM.TITLE = 'Pending');