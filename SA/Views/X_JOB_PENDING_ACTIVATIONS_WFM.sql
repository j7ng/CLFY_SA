CREATE OR REPLACE FORCE VIEW sa.x_job_pending_activations_wfm (job_objid,job_title,x_old_esn,x_esn,x_min,x_program_objid,x_iccid,x_zip,case_objid,x_contact_objid) AS
SELECT objid job_objid,
          title job_title,
          x_old_esn,
          x_esn,
          x_min,
          x_program_objid,
          x_iccid,
          x_zip,
          job_result2case case_objid,
          x_contact_objid
     FROM table_job
    WHERE s_title IN ('ACTIVATION', 'EXPRESS ACTIVATION')
          AND job_sts2gbst_elm IN
                 (SELECT elm.objid
                    FROM table_gbst_elm elm, table_gbst_lst lst
                   WHERE     gbst_elm2gbst_lst = lst.objid
                         AND lst.title = 'Open'
                         AND elm.title = 'Pending')
          AND EXISTS
                 (SELECT org_id
                    FROM table_part_inst
                         INNER JOIN table_mod_level ml
                            ON (n_part_inst2part_mod = ml.objid)
                         INNER JOIN table_part_num pn
                            ON (part_info2part_num = pn.objid)
                         INNER JOIN table_bus_org
                            ON pn.part_num2bus_org = table_bus_org.objid
                   WHERE org_id = 'WFM' AND x_esn = part_serial_no);