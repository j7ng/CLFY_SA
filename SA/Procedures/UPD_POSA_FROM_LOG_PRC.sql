CREATE OR REPLACE PROCEDURE sa.upd_posa_from_log_prc as
  --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: UPD_POSA_FROM_LOG_PRC.sql,v $
  --$Revision: 1.2 $
  --$Author: kacosta $
  --$Date: 2011/12/08 14:47:20 $
  --$ $Log: UPD_POSA_FROM_LOG_PRC.sql,v $
  --$ Revision 1.2  2011/12/08 14:47:20  kacosta
  --$ CR19147 BATCH JOB UPD_POSA_FROM_LOG_PRC, facing ORA 1555 (query #7)
  --$
  --$
  ---------------------------------------------------------------------------------------------
  --
  cursor c1 is
select pl.x_serial_num,
           pl.x_toss_att_location,
           pl.x_toss_att_customer,
           pl.objid pl_objid,
           pc.SOURCESYSTEM,
           pc.toss_posa_action,
           pc.objid pc_objid
      from sa.x_posa_card pc,
           sa.x_posa_log pl
     where 1=1
       and pc.TF_SERIAL_NUM(+) = pl.X_SERIAL_NUM
       and pl.X_POSA_UPDATE_flag = 'N'
              and pl.x_toss_posa_date ||'' >= trunc(sysdate)-1
       and pc.toss_posa_date >= trunc(sysdate)-1
       and pc.sourcesystem in ('POSA_FLAG_ON','TOSSUTILITY','WEBCSR')
--CR19147 Start 12/8/2011
--Query modified by Curt Lindner
       and rownum < 200001;
     --order by pl.x_serial_num,x_posa_log_date;
     --CR19147 End 12/8/2011
  cnt1 number := 0;
  cnt2 number := 0;
begin
  for c1_rec in c1 loop
    if c1_rec.sourcesystem = 'POSA_FLAG_ON' and
       c1_rec.toss_posa_action in ('SWIPE','Make Card Redeemable') then
      update sa.x_posa_card
         set TOSS_ATT_CUSTOMER = c1_rec.x_toss_att_customer,
             TOSS_ATT_LOCATION = c1_rec.x_toss_att_location,
             tf_extract_flag = 'N'
       where tf_serial_num =c1_rec.x_serial_num
and objid = c1_rec.pc_objid;
      update sa.x_posa_log
         set x_posa_update_flag = 'Y',
     X_POSA_UPDATE_DATE = sysdate
       where x_serial_num=c1_rec.x_serial_num
and objid = c1_rec.pl_objid;
      cnt1 := cnt1 +1;
      --CR19147 Start 12/8/2011
      --commit;
      --exit;
      --CR19147 End 12/8/2011
    else
      cnt2 := cnt2 +1;
      update sa.x_posa_log
         set x_posa_update_flag = 'F',
     X_POSA_UPDATE_DATE = sysdate
       where x_serial_num=c1_rec.x_serial_num
and objid = c1_rec.pl_objid;
    end if;
    commit;
  end loop;
  dbms_output.put_line('cnt1:'||cnt1);
  dbms_output.put_line('cnt2:'||cnt2);
end;
/