CREATE OR REPLACE FORCE VIEW sa.x_active_min_esn_change_view (x_transaction_id,x_attached_date,x_min,x_old_esn,x_detach_dt,x_new_esn) AS
select
    x_transaction_id,
    x_attached_date,
    x_min,
    x_old_esn,
    x_detach_dt,
    x_new_esn
  from
    x_min_esn_change
  where
    x_new_esn is not Null
  and
    x_Attached_Date is not Null
;