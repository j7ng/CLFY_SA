CREATE OR REPLACE FORCE VIEW sa.ppe_pn ("NAME",pc_obj,part_number,pn_obj,description,s_domain) AS
SELECT distinct PC.NAME  , PC.OBJID pc_obj , pn.part_number, pn.objid pn_obj, PN.DESCRIPTION,PN.S_DOMAIN
FROM TABLE_X_PART_CLASS_PARAMS TP,
            TABLE_PART_CLASS PC, table_part_Num pn,
            TABLE_X_PART_CLASS_VALUES TV
WHERE TV.VALUE2CLASS_PARAM=TP.OBJID
      AND TV.VALUE2PART_CLASS=PC.OBJID
and x_param_name='NON_PPE' and x_param_value='0'
and PN.PART_NUM2PART_CLASS=pc.objid;