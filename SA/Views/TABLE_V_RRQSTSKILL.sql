CREATE OR REPLACE FORCE VIEW sa.table_v_rrqstskill (objid,r_rqst_objid,skill_objid) AS
select table_rqst_skill.objid, table_rqst_skill.rqst_skill2r_rqst,
 table_rqst_skill.rqst_skill2skill
 from table_rqst_skill
 where table_rqst_skill.rqst_skill2r_rqst IS NOT NULL
 AND table_rqst_skill.rqst_skill2skill IS NOT NULL
 ;
COMMENT ON TABLE sa.table_v_rrqstskill IS 'Used by skills based routing server';
COMMENT ON COLUMN sa.table_v_rrqstskill.objid IS 'R_rqst_skill internal record number';
COMMENT ON COLUMN sa.table_v_rrqstskill.r_rqst_objid IS 'r_rqst Internal record number';
COMMENT ON COLUMN sa.table_v_rrqstskill.skill_objid IS 'Skill internal record number';