CREATE OR REPLACE FORCE VIEW sa.redemption_history_view (x_transact_date,x_service_id,transaction_id,red_card_objid,red_code,smp,units,"DAYS",part_number,description,part_class) AS
Select ct.x_transact_date,
       ct.x_service_id,
       rc.Red_Card2call_Trans Transaction_Id,
       rc.Objid Red_Card_Objid,
       rc.X_Red_Code Red_Code,
       rc.X_Smp Smp,
       rc.X_Red_Units Units,
       rc.X_Access_Days Days,
       pn.Part_Number,
       pn.Description,
       pc.name part_class
  From
       table_x_call_trans ct,
       Table_X_Red_Card rc,
       Table_Mod_Level ml,
       Table_Part_Num pn,
       table_part_class pc
Where 1=1
and rc.Red_Card2call_Trans = ct.objid
And ml.Objid = rc.X_Red_Card2part_Mod
and pn.Objid = ml.Part_Info2part_Num
And pc.Objid = pn.Part_Num2part_Class
order by ct.x_transact_date desc ;