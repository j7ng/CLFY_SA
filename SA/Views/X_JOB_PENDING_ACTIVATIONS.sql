CREATE OR REPLACE FORCE VIEW sa.x_job_pending_activations (job_objid,job_title,x_old_esn,x_esn,x_min,x_program_objid,x_iccid,x_zip,case_objid,x_contact_objid) AS
SELECT objid           job_objid
        ,title           job_title
        ,x_old_esn
        ,x_esn
        ,x_min
        ,x_program_objid
        ,x_iccid
        ,x_zip
        ,job_result2case case_objid
        ,x_contact_objid
    FROM table_job
   WHERE s_title = 'ACTIVATION'
     AND job_sts2gbst_elm IN (SELECT elm.objid
                                FROM table_gbst_elm elm
                                    ,table_gbst_lst lst
                               WHERE gbst_elm2gbst_lst = lst.objid
                                 AND lst.title = 'Open'
                                 AND elm.title = 'Pending')
     AND x_program_objid IN (SELECT pp.objid
                               FROM x_program_parameters pp
                                   ,table_bus_org        bo
                              WHERE pp.prog_param2bus_org = bo.objid
                                AND bo.org_id = 'STRAIGHT_TALK');