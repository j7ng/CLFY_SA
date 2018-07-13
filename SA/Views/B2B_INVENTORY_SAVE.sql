CREATE OR REPLACE FORCE VIEW sa.b2b_inventory_save (item_no,inventory) AS
SELECT item_no,SUM(available) inventory
FROM tf.tf_iday@ofsprd
WHERE warehouse ='BP_TFD8_SS'
group by item_no ;