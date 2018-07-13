CREATE OR REPLACE FORCE VIEW sa.mtm_mapping_schema_info (rel_name,mtm_table_name) AS
SELECT REL_TABLE.REL_NAME,
   CASE
   WHEN REL_TABLE.TYPE_ID < INV_REL_TABLE.TYPE_ID
   THEN
   'mtm_' || REL_TABLE.type_name || REL_TABLE.SPEC_REL_ID || '_' ||
   INV_REL_TABLE.type_name || INV_REL_TABLE.SPEC_REL_ID
   ELSE
   'mtm_' || INV_REL_TABLE.type_name || INV_REL_TABLE.SPEC_REL_ID || '_' ||
   REL_TABLE.type_name || REL_TABLE.SPEC_REL_ID
   END AS MTM_TABLE_NAME
FROM (
   SELECT ADP_TBL_NAME_MAP.type_name,
      ADP_SCH_REL_INFO.*
   FROM ADP_SCH_REL_INFO, ADP_TBL_NAME_MAP
   WHERE ADP_TBL_NAME_MAP.type_id = ADP_SCH_REL_INFO.type_id
   AND ADP_SCH_REL_INFO.REL_TYPE = 5) REL_TABLE, (
   SELECT ADP_TBL_NAME_MAP.type_name,
      ADP_SCH_REL_INFO.*
   FROM ADP_SCH_REL_INFO, ADP_TBL_NAME_MAP
   WHERE ADP_TBL_NAME_MAP.type_id = ADP_SCH_REL_INFO.type_id
   AND ADP_SCH_REL_INFO.REL_TYPE = 5) INV_REL_TABLE
WHERE REL_TABLE.INV_REL_NAME = INV_REL_TABLE.REL_NAME;