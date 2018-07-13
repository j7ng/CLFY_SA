CREATE TABLE sa.table_act_entry (
  objid NUMBER,
  act_code NUMBER,
  entry_time DATE,
  addnl_info VARCHAR2(255 BYTE),
  "PROXY" VARCHAR2(30 BYTE),
  removed NUMBER,
  dev NUMBER,
  act_entry2case NUMBER(*,0),
  act_entry2subcase NUMBER(*,0),
  act_entry2probdesc NUMBER(*,0),
  act_entry2workaround NUMBER(*,0),
  act_entry2user NUMBER(*,0),
  act_entry2reject_msg NUMBER(*,0),
  act_entry2notes_log NUMBER(*,0),
  act_entry2phone_log NUMBER(*,0),
  act_entry2resrch_log NUMBER(*,0),
  act_entry2commit_log NUMBER(*,0),
  act_entry2escalation NUMBER(*,0),
  act_entry2onsite_log NUMBER(*,0),
  act_entry2email_log NUMBER(*,0),
  act_entry2site_part NUMBER(*,0),
  act_entry2site NUMBER(*,0),
  act_entry2bug NUMBER(*,0),
  entry_name2gbst_elm NUMBER(*,0),
  act_entry_child2parent NUMBER(*,0),
  act_entry2biz_cal_hdr NUMBER(*,0),
  act_entry2schedule NUMBER(*,0),
  act_entry2disptchfe NUMBER(*,0),
  act_entry2employee NUMBER(*,0),
  act_entry2demand_dtl NUMBER(*,0),
  act_entry2doc_inst NUMBER(*,0),
  act_entry2part_trans NUMBER(*,0),
  act_entry2opportunity NUMBER(*,0),
  act_entry2contract NUMBER(*,0),
  act_entry2job NUMBER(*,0),
  act_entry2contact NUMBER(*,0),
  act_entry2task NUMBER(*,0),
  act_entry2exchange NUMBER(*,0),
  act_entry2exch_log NUMBER(*,0),
  act_entry2contr_itm NUMBER(*,0),
  act_entry2count_setup NUMBER,
  focus_lowid NUMBER,
  focus_type NUMBER
);
ALTER TABLE sa.table_act_entry ADD SUPPLEMENTAL LOG GROUP dmtsora1010008757_0 (act_code, act_entry2biz_cal_hdr, act_entry2bug, act_entry2case, act_entry2commit_log, act_entry2demand_dtl, act_entry2disptchfe, act_entry2doc_inst, act_entry2email_log, act_entry2employee, act_entry2escalation, act_entry2notes_log, act_entry2onsite_log, act_entry2opportunity, act_entry2part_trans, act_entry2phone_log, act_entry2probdesc, act_entry2reject_msg, act_entry2resrch_log, act_entry2schedule, act_entry2site, act_entry2site_part, act_entry2subcase, act_entry2user, act_entry2workaround, act_entry_child2parent, addnl_info, dev, entry_name2gbst_elm, entry_time, objid, "PROXY", removed) ALWAYS;
ALTER TABLE sa.table_act_entry ADD SUPPLEMENTAL LOG GROUP dmtsora1010008757_1 (act_entry2contact, act_entry2contract, act_entry2contr_itm, act_entry2count_setup, act_entry2exchange, act_entry2exch_log, act_entry2job, act_entry2task, focus_lowid, focus_type) ALWAYS;
COMMENT ON TABLE sa.table_act_entry IS 'Activity log object which acts as the audit trail of cases, subcases, solutions, parts, sites, employees, part requests and change requests';
COMMENT ON COLUMN sa.table_act_entry.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_act_entry.act_code IS 'Activity code for the activity log entry; internally assigned with a unique code for each type of activity';
COMMENT ON COLUMN sa.table_act_entry.entry_time IS 'Date and time of entry into activity log';
COMMENT ON COLUMN sa.table_act_entry.addnl_info IS 'Additional information about activity log entry';
COMMENT ON COLUMN sa.table_act_entry."PROXY" IS 'Login name of the user that performed the activity on behalf of another user via the Switch User feature';
COMMENT ON COLUMN sa.table_act_entry.removed IS 'Contains encoded information used by DWE transport server. Reserved; future';
COMMENT ON COLUMN sa.table_act_entry.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_act_entry.act_entry2case IS 'Activity log entries for the case';
COMMENT ON COLUMN sa.table_act_entry.act_entry2subcase IS 'Activity log entries for the subcase';
COMMENT ON COLUMN sa.table_act_entry.act_entry2probdesc IS 'Activity log entries for the solution';
COMMENT ON COLUMN sa.table_act_entry.act_entry2workaround IS 'Activity log entries for the workaround';
COMMENT ON COLUMN sa.table_act_entry.act_entry2user IS 'User that performed the logged activity';
COMMENT ON COLUMN sa.table_act_entry.act_entry2reject_msg IS 'Activity log entries for the case, bug, subcase, etc., rejection';
COMMENT ON COLUMN sa.table_act_entry.act_entry2notes_log IS 'Activity log entries for the notes log entry';
COMMENT ON COLUMN sa.table_act_entry.act_entry2phone_log IS 'Activity log entries for the phone log entry';
COMMENT ON COLUMN sa.table_act_entry.act_entry2resrch_log IS 'Activity log entries for the research log entry';
COMMENT ON COLUMN sa.table_act_entry.act_entry2commit_log IS 'Activity log entries for the commitment log';
COMMENT ON COLUMN sa.table_act_entry.act_entry2escalation IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_act_entry.act_entry2onsite_log IS 'Activity log entries for the T&E summary';
COMMENT ON COLUMN sa.table_act_entry.act_entry2email_log IS 'Activity log entries for the email log';
COMMENT ON COLUMN sa.table_act_entry.act_entry2site_part IS 'Activity log entries for the installed part';
COMMENT ON COLUMN sa.table_act_entry.act_entry2site IS 'Activity log entries for the site';
COMMENT ON COLUMN sa.table_act_entry.act_entry2bug IS 'Activity log entries for the change request';
COMMENT ON COLUMN sa.table_act_entry.entry_name2gbst_elm IS 'Type of activity log entry from Clarify-defined pop up list';
COMMENT ON COLUMN sa.table_act_entry.act_entry_child2parent IS 'For subcase close and subcase open, the links from the activity log entry on the subcase to the duplicate activity log entry in the parent case';
COMMENT ON COLUMN sa.table_act_entry.act_entry2biz_cal_hdr IS 'Activity log entries for the business calendar';
COMMENT ON COLUMN sa.table_act_entry.act_entry2schedule IS 'Activity log entries for changes to the employee or installed part schedule';
COMMENT ON COLUMN sa.table_act_entry.act_entry2disptchfe IS 'Activity log entries for the engineer dispatch';
COMMENT ON COLUMN sa.table_act_entry.act_entry2employee IS 'Activity log entries for the employee; change to work group or site';
COMMENT ON COLUMN sa.table_act_entry.act_entry2demand_dtl IS 'Activity log entries for the part request detail';
COMMENT ON COLUMN sa.table_act_entry.act_entry2doc_inst IS 'Activity log entries for the document.  Reserved; future';
COMMENT ON COLUMN sa.table_act_entry.act_entry2part_trans IS 'Activity log entries for the part transaction';
COMMENT ON COLUMN sa.table_act_entry.act_entry2opportunity IS 'Activity log entries for the opportunity';
COMMENT ON COLUMN sa.table_act_entry.act_entry2contract IS 'Activity log entries for the contract';
COMMENT ON COLUMN sa.table_act_entry.act_entry2job IS 'Activity log entries for the job';
COMMENT ON COLUMN sa.table_act_entry.act_entry2contact IS 'Activity log entries for the contact';
COMMENT ON COLUMN sa.table_act_entry.act_entry2task IS 'Activity log entries for the task';
COMMENT ON COLUMN sa.table_act_entry.act_entry2exchange IS 'Activity log entries for the exchange';
COMMENT ON COLUMN sa.table_act_entry.act_entry2exch_log IS 'The exchange_log  which holds additional details about the event';
COMMENT ON COLUMN sa.table_act_entry.act_entry2contr_itm IS 'Services authorized by contract for the related case';
COMMENT ON COLUMN sa.table_act_entry.act_entry2count_setup IS 'Related physical inventory count profile';
COMMENT ON COLUMN sa.table_act_entry.focus_lowid IS 'Internal record number of the the default drill down object for the event';
COMMENT ON COLUMN sa.table_act_entry.focus_type IS 'Object type ID of the default drill down object for the event';