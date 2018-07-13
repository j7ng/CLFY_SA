CREATE OR REPLACE FORCE VIEW sa.open_view_cc_mon (x_cc_type,objid) AS
SELECT x_cc_type, objid FROM sa.table_x_credit_card;