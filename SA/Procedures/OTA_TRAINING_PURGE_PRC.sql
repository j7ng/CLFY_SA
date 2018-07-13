CREATE OR REPLACE PROCEDURE sa.OTA_TRAINING_PURGE_PRC
/******************************************************************************/
/* Name         :   SA.OTA_TRAINING_PURGE_PRC
/* Purpose      :   DBMS_JOB: run every 5 days.
/*                  Purges records in table (x_ota_refill_training_log) that
/*                  are older than 3 days from the current date.
/* Author       :   Gerald Pintado
/* Date         :   06/10/2005
/* Revisions    :
/* Version  Date       Who        Purpose
/* -------  --------   --------   -------------------------------------
/* 1.0     06/10/2005  Gpintado   CR4173 - Initial revision
/******************************************************************************/
is

 Cursor c1
 Is
  Select  a.rowid,a.*
    From sa.X_OTA_REFILL_TRAINING_LOG a
   Where x_date_time <= Sysdate -3;

counter number := 0;
v_esn varchar2(20);

Begin
 For c1_rec in c1 Loop

    v_esn := c1_rec.x_esn;

    Delete sa.X_OTA_REFILL_TRAINING_LOG
     Where rowid = c1_rec.rowid;

    counter := counter + 1;

	 If mod(counter,100) = 0 Then
	    commit;
	 End if;
 End Loop;
 commit;
Exception
 When others Then
    DBMS_OUTPUT.put_line('Oracle Error: '||sqlerrm);
    rollback;
    Toss_Util_Pkg.insert_error_tab_proc (
    'Failed Deleting OTA training log', v_esn,
    'SA.OTA_TRAINING_PURGE_PRC' );
    commit;
End;
/