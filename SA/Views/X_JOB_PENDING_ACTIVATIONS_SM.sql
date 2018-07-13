CREATE OR REPLACE FORCE VIEW sa.x_job_pending_activations_sm (job_objid,job_title,x_old_esn,x_esn,x_min,x_program_objid,x_iccid,x_zip,case_objid,x_contact_objid) AS
SELECT Objid Job_Objid,
    Title Job_Title,
    X_old_esn,
    X_Esn,
    X_Min,
    X_Program_Objid,
    X_Iccid,
    X_Zip,
    Job_Result2case Case_Objid,
    x_contact_objid
  FROM Table_Job
  WHERE S_Title         = 'ACTIVATION'
  AND Job_Sts2gbst_Elm IN
    (SELECT elm.objid
    FROM table_gbst_elm elm,
      table_gbst_lst lst
    WHERE GBST_ELM2GBST_LST = lst.objid
    AND Lst.Title           = 'Open'
    AND Elm.Title           = 'Pending'
    )
  AND X_Program_Objid IN
    (SELECT pp.objid
    FROM x_program_parameters pp,
      table_bus_org bo
    WHERE PP.PROG_PARAM2BUS_ORG=BO.OBJID
    AND bo.org_id              ='SIMPLE_MOBILE'
    );