CREATE OR REPLACE FORCE VIEW sa.table_com_to_template_view (employee_id,com_templ_id,commitment_id,title,"TIME",focus_lowid,focus_type,suppl_info) AS
SELECT table_time_bomb.cmit_creator2employee, table_time_bomb.trckr_info2com_tmplte,
 table_time_bomb.objid, table_time_bomb.title,
 table_time_bomb.escalate_time, table_time_bomb.focus_lowid,
 table_time_bomb.focus_type, table_time_bomb.suppl_info
 FROM table_time_bomb
 WHERE table_time_bomb.trckr_info2com_tmplte IS NOT NULL
 AND table_time_bomb.cmit_creator2employee IS NOT NULL;
COMMENT ON TABLE sa.table_com_to_template_view IS 'Joins employee and com_template information for use in notifications and escalations';
COMMENT ON COLUMN sa.table_com_to_template_view.employee_id IS 'Employee internal record number';
COMMENT ON COLUMN sa.table_com_to_template_view.com_templ_id IS 'Com_tmplte internal record number';
COMMENT ON COLUMN sa.table_com_to_template_view.commitment_id IS 'Time bomb internal record number';
COMMENT ON COLUMN sa.table_com_to_template_view.title IS 'Title of the time bomb';
COMMENT ON COLUMN sa.table_com_to_template_view."TIME" IS 'Elapsed time until the time bomb is scheduled to fire in seconds';
COMMENT ON COLUMN sa.table_com_to_template_view.focus_lowid IS 'Low ID of the time bomb s focus object';
COMMENT ON COLUMN sa.table_com_to_template_view.focus_type IS 'Object type of the time bomb s focus object';
COMMENT ON COLUMN sa.table_com_to_template_view.suppl_info IS 'Additional information for the time bomb';