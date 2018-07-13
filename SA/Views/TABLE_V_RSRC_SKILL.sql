CREATE OR REPLACE FORCE VIEW sa.table_v_rsrc_skill (objid,rsrc_objid,skill_objid,rsrc_focus_type,rsrc_focus_lowid) AS
select table_rsrc_skill.objid, table_rsrc.objid,
 table_rsrc_skill.rsrc_skill2skill, table_rsrc.focus_type,
 table_rsrc.focus_lowid
 from table_rsrc_skill, table_rsrc
 where table_rsrc.objid = table_rsrc_skill.rsrc_skill2rsrc
 AND table_rsrc_skill.rsrc_skill2skill IS NOT NULL
 ;
COMMENT ON TABLE sa.table_v_rsrc_skill IS 'Displays skills possessed by a routing resource (r_rsrc). Used by form __________';
COMMENT ON COLUMN sa.table_v_rsrc_skill.objid IS 'Rsrc_skill internal record number';
COMMENT ON COLUMN sa.table_v_rsrc_skill.rsrc_objid IS 'Rsrc internal record number';
COMMENT ON COLUMN sa.table_v_rsrc_skill.skill_objid IS 'Skill internal record number';
COMMENT ON COLUMN sa.table_v_rsrc_skill.rsrc_focus_type IS 'Type ID of the resource; i.e., 4=queue, 20=user';
COMMENT ON COLUMN sa.table_v_rsrc_skill.rsrc_focus_lowid IS 'Internal record number of the resource';