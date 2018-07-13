CREATE OR REPLACE FORCE VIEW sa.x_job_activations_v (job_objid,job_title,x_old_esn,x_esn,x_min,x_program_objid,x_iccid,x_zip,case_objid,table_gbst_elm_objid,job_status,x_contact_objid,x_idn_user_created,x_dte_created,x_idn_user_change_last,x_dte_change_last) AS
SELECT J.OBJID JOB_OBJID
    ,J.TITLE JOB_TITLE
    ,J.X_OLD_ESN
    ,J.X_ESN
    ,J.X_MIN
    ,J.X_PROGRAM_OBJID
    ,J.X_ICCID
    ,J.X_ZIP
    ,J.JOB_RESULT2CASE AS CASE_OBJID
    ,J.JOB_STS2GBST_ELM AS TABLE_GBST_ELM_OBJID
    ,(SELECT  ELM.TITLE
      FROM    sa.TABLE_GBST_ELM ELM,
              sa.TABLE_GBST_LST LST
      WHERE   ELM.GBST_ELM2GBST_LST = LST.OBJID
      AND     ELM.OBJID = J.JOB_STS2GBST_ELM
      ) AS JOB_STATUS
    ,J.X_CONTACT_OBJID
    ,J.X_IDN_USER_CREATED AS X_IDN_USER_CREATED
    ,J.X_DTE_CREATED AS X_DTE_CREATED
    ,J.X_IDN_USER_CHANGE_LAST AS X_IDN_USER_CHANGE_LAST
    ,J.X_DTE_CHANGE_LAST AS X_DTE_CHANGE_LAST
  FROM TABLE_JOB J
  WHERE J.S_TITLE = 'ACTIVATION'
  ;