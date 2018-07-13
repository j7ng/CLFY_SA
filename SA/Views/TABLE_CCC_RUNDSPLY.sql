CREATE OR REPLACE FORCE VIEW sa.table_ccc_rundsply (objid,create_date,end_time,node_key,result,s_result,score,start_time,title,s_title,o_type,s_o_type,bug_rel,borg_rel,camp_rel,case_rel,contact_rel,contract_rel,contritm_rel,demdtl_rel,empl_rel,lsrce_rel,opp_rel,probd_rel,site_rel,sitep_rel,subcase_rel,task_rel) AS
select table_scr_run.objid, table_scr_run.create_date,
 table_scr_run.end_time, table_scr_run.node_key,
 table_scr_run.result, table_scr_run.S_result, table_scr_run.score,
 table_scr_run.start_time, table_scr_run.title, table_scr_run.S_title,
 table_scr_run.title, table_scr_run.S_title, table_scr_run.scr_run2bug,
 table_scr_run.scr_run2bus_org, table_scr_run.scr_run2campaign,
 table_scr_run.scr_run2case, table_contact.objid,
 table_scr_run.scr_run2contract, table_scr_run.scr_run2contr_itm,
 table_scr_run.scr_run2demand_dtl, table_scr_run.scr_run2employee,
 table_scr_run.scr_run2lead_source, table_scr_run.scr_run2opportunity,
 table_scr_run.scr_run2probdesc, table_scr_run.scr_run2site,
 table_scr_run.scr_run2site_part, table_scr_run.scr_run2subcase,
 table_scr_run.scr_run2task
 from table_scr_run, table_contact
 where table_scr_run.scr_run2opportunity IS NOT NULL
 AND table_scr_run.scr_run2site_part IS NOT NULL
 AND table_scr_run.scr_run2task IS NOT NULL
 AND table_scr_run.scr_run2contract IS NOT NULL
 AND table_scr_run.scr_run2demand_dtl IS NOT NULL
 AND table_scr_run.scr_run2contr_itm IS NOT NULL
 AND table_scr_run.scr_run2subcase IS NOT NULL
 AND table_scr_run.scr_run2site IS NOT NULL
 AND table_scr_run.scr_run2campaign IS NOT NULL
 AND table_scr_run.scr_run2lead_source IS NOT NULL
 AND table_scr_run.scr_run2case IS NOT NULL
 AND table_scr_run.scr_run2bug IS NOT NULL
 AND table_scr_run.scr_run2bus_org IS NOT NULL
 AND table_scr_run.scr_run2probdesc IS NOT NULL
 AND table_scr_run.scr_run2employee IS NOT NULL
 ;
COMMENT ON TABLE sa.table_ccc_rundsply IS 'Used internally to select script run information';
COMMENT ON COLUMN sa.table_ccc_rundsply.objid IS 'Scr_run internal record number';
COMMENT ON COLUMN sa.table_ccc_rundsply.create_date IS 'The create date and time of the scr_run object';
COMMENT ON COLUMN sa.table_ccc_rundsply.end_time IS 'Ending date and time of the call script run';
COMMENT ON COLUMN sa.table_ccc_rundsply.node_key IS 'The sequence of objid of the script runs within a single user session';
COMMENT ON COLUMN sa.table_ccc_rundsply.result IS 'Result of the script: e.g.,  was it completed, abandoned,  and why?';
COMMENT ON COLUMN sa.table_ccc_rundsply.score IS 'Total score attained during the run of the call script';
COMMENT ON COLUMN sa.table_ccc_rundsply.start_time IS 'Starting date and time of the call script run';
COMMENT ON COLUMN sa.table_ccc_rundsply.title IS 'Name of the script that was run';
COMMENT ON COLUMN sa.table_ccc_rundsply.o_type IS 'This field is used to display the object type which initiated the script run';
COMMENT ON COLUMN sa.table_ccc_rundsply.bug_rel IS 'Bug internal record number';
COMMENT ON COLUMN sa.table_ccc_rundsply.borg_rel IS 'Bus_org internal record number';
COMMENT ON COLUMN sa.table_ccc_rundsply.camp_rel IS 'Campaign internal record number';
COMMENT ON COLUMN sa.table_ccc_rundsply.case_rel IS 'Case internal record number';
COMMENT ON COLUMN sa.table_ccc_rundsply.contact_rel IS 'Contact internal record number';
COMMENT ON COLUMN sa.table_ccc_rundsply.contract_rel IS 'Contract internal record number';
COMMENT ON COLUMN sa.table_ccc_rundsply.contritm_rel IS 'Contr_itm internal record number';
COMMENT ON COLUMN sa.table_ccc_rundsply.demdtl_rel IS 'Demand_dtl internal record number';
COMMENT ON COLUMN sa.table_ccc_rundsply.empl_rel IS 'Employee internal record number';
COMMENT ON COLUMN sa.table_ccc_rundsply.lsrce_rel IS 'Lead_source internal record number';
COMMENT ON COLUMN sa.table_ccc_rundsply.opp_rel IS 'Opportunity internal record number';
COMMENT ON COLUMN sa.table_ccc_rundsply.probd_rel IS 'Probdesc internal record number';
COMMENT ON COLUMN sa.table_ccc_rundsply.site_rel IS 'Site internal record number';
COMMENT ON COLUMN sa.table_ccc_rundsply.sitep_rel IS 'Site_part internal record number';
COMMENT ON COLUMN sa.table_ccc_rundsply.subcase_rel IS 'Subcase internal record number';
COMMENT ON COLUMN sa.table_ccc_rundsply.task_rel IS 'Task internal record number';