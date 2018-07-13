CREATE OR REPLACE FORCE VIEW sa.adp_tbl_oid (type_id,obj_num) AS
select type_id, fn_adp_tbl_oid (type_id)
from   adp_tbl_oid_base;