CREATE OR REPLACE procedure sa.PURGE_SUPR_TABLES as
   cursor spr_inq is
    select objid from  sa.x_spr_inquiry_log 
    where  update_timestamp < sysdate -15;    
    cursor spr_tran is
    select objid from sa.x_spr_transaction_log 
    where  update_timestamp < sysdate -15;   
     cursor SPR_HIST is      
    select objid from sa.X_SUBSCRIBER_SPR_HIST 
    where  update_timestamp < sysdate -3;
   cursor c1 is
    select rowid, transaction_id
    from   gw1.ig_transaction
    where  status in ('F','S','W','C','SS','FF')
    and    creation_date<trunc(sysdate-7);
      inqcount  number;
      Trancount  number;
       Histcount  number;
begin
        inqcount :=0; 
       Trancount :=0;  
        Histcount :=0;
    ---sa.x_spr_inquiry_log     
    for spr_inq_rec in spr_inq loop 
            inqcount := spr_inq%ROWCOUNT;  
         delete  from   sa.x_spr_inquiry_log  
          where objid=spr_inq_rec.objid;
          inqcount :=inqcount+1;
       commit;  
    end loop;
              dbms_output.put_line('Purged '||inqcount||' : records from x_spr_inquiry_log');
   -- sa.x_spr_transaction_log        
     for spr_tran_rec in spr_tran loop             
            delete  from   sa.x_spr_transaction_log 
            where objid=spr_tran_rec.objid;
            Trancount :=Trancount+1;
       commit;  
    end loop;   
            dbms_output.put_line('Purged '||Trancount||' : records from sa.x_spr_transaction_log');  
    ---X_SUBSCRIBER_SPR_HIST  
     for SPR_HIST_REC in SPR_HIST loop                  
          delete  from   sa.X_SUBSCRIBER_SPR_HIST
           where objid=SPR_HIST_REC.objid;
           Histcount :=Histcount+1;
       commit;  
    end loop;
              dbms_output.put_line('Purged '||Histcount||' : records from X_SUBSCRIBER_SPR_HIST ');
      for c1_rec in c1 loop
      insert into gw1.ig_transaction_history
       select * from ig_transaction
       where rowid = c1_Rec.rowid;
        delete from ig_transaction
        where rowid = c1_rec.rowid;
    -- Added by Juda on 6/6/2016 for CR31495 to delete the process log table for pcrf
      DELETE 
        FROM   sa.x_ig_pcrf_log
       WHERE  transaction_id = c1_rec.transaction_id;
    commit;
  end loop;     
   end;
/