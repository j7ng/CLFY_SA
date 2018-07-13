CREATE OR REPLACE TRIGGER sa."T_CALL_TRANS"
   --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: T_CALL_TRANS.sql,v $
  --$Revision: 1.44 $
  --$Author: skota $
  --$Date: 2016/12/07 20:42:10 $
  --$ $Log: T_CALL_TRANS.sql,v $
  --$ Revision 1.44  2016/12/07 20:42:10  skota
  --$ removed the logic for w3ci inv cache
  --$
  --$ Revision 1.43  2016/11/01 13:22:29  skota
  --$ Removed the updating group table logic
  --$
  --$ Revision 1.42  2016/10/27 14:08:17  skota
  --$ added new logic to campture the base plan cos into call trans ext table
  --$
  --$ Revision 1.41  2016/10/13 15:26:27  skota
  --$ removed pragma in call trans trigger
  --$
  --$ Revision 1.39  2016/10/10 19:33:11  skota
  --$ modified to get the cos value of addons and insert into call trans ext table
  --$
  --$ Revision 1.38  2015/06/22 17:55:00  jarza
  --$ CR34869 - ILD auto recurring changes
  --$
  --$ Revision 1.37  2015/06/16 01:45:11  aganesan
  --$ CR35396 - Super carrier changes for 06/23 release.
  --$
  --$ Revision 1.35  2015/05/29 19:04:30  aganesan
  --$ CR34909 - Changes.
  --$
  --$ Revision 1.34  2015/05/11 18:47:48  aganesan
  --$ CR34081 - Super Carrier Changes to invoke the new update_pcrf_subscriber procedure call.
  --$
  --$ Revision 1.33  2015/01/20 19:12:03  clinder
  --$ CR31242
  --$
  --$ Revision 1.30  2014/09/05 13:05:48  clinder
  --$ CR29939
  --$
  --$ Revision 1.29  2014/08/27 14:54:36  clinder
  --$ CR30019
  --$
  --$ Revision 1.28  2014/06/05 16:12:34  clinder
  --$ CR29265
  --$
  --$ Revision 1.27  2014/06/03 21:56:49  clinder
  --$ CR28075
  --$
  --$ Revision 1.26  2014/06/02 21:49:50  clinder
  --$ CR28075
  --$
  --$ Revision 1.25  2014/06/02 13:15:00  clinder
  --$ CR28075
  --$
  --$ Revision 1.24  2014/05/29 16:46:55  clinder
  --$ CR28075
  --$
  --$ Revision 1.23  2014/05/29 15:20:21  clinder
  --$ CR28075
  --$
  --$ Revision 1.22  2014/05/28 14:47:05  clinder
  --$ CR28066
  --$
  --$ Revision 1.21  2014/05/16 19:57:52  clinder
  --$ CR28479
  --$
  --$ Revision 1.20  2014/04/29 16:46:50  clinder
  --$ CR26625
  --$
  --$ Revision 1.19  2014/04/11 21:37:40  clinder
  --$ CR26625
  --$
  --$ Revision 1.18  2014/02/25 16:30:00  clinder
  --$ CR27757
  --$
  --$ Revision 1.17  2014/02/24 19:40:28  clinder
  --$ CR27757
  --$
  --$ Revision 1.16  2014/02/24 19:23:05  clinder
  --$ CR27757
  --$
  --$ Revision 1.15  2014/02/24 14:46:55  clinder
  --$ CR27757
  --$
  --$ Revision 1.13  2013/06/11 19:15:10  ymillan
  --$ CR24776
  --$
  --$ Revision 1.8  2012/08/31 13:21:57  icanavan
  --$ TELCEL change cursor and condition to org_flow
  --$
 --$ Revision 1.7  2012/07/26 18:01:31  kacosta
  --$ CR21262 Update Stamp Field for TABLE_X_CALL_TRANS
  --$
  --$ Revision 1.6  2012/01/24 15:52:06  kacosta
  --$ CR19738 Modify Port Credit Records to Log the Correct Action Type
  --$
  --$
  ---------------------------------------------------------------------------------------------
  --
BEFORE INSERT OR UPDATE ON sa.TABLE_X_CALL_TRANS REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE

 cursor group_curs is
   select agm.account_group_id group_id,
 	      agm.master_flag,
          ( select spsp.x_service_plan_id
            from x_service_plan_site_part spsp
            where spsp.table_site_part_id = :new.call_trans2site_part
            and rownum < 2 ) service_plan_id
   from   x_account_group_member agm
   where  1 = 1
   and    agm.esn = NVL(:NEW.x_service_id,:OLD.x_service_id)
   AND    UPPER(agm.status) <> 'EXPIRED';  -- Added by Juda Pena on 01/19/2015 to exclude expired members
 group_rec group_curs%rowtype;

 CURSOR cur_esn_dtl IS
   SELECT bo.objid bo_objid,
          bo.org_id,
          bo.org_flow,
          nvl(pn.x_data_capable,0) x_data_capable
   FROM   table_part_inst pi
          ,table_mod_level ml
          ,table_part_num  pn
          ,table_bus_org   bo
   WHERE ml.objid = pi.n_part_inst2part_mod
   AND pn.objid = ml.part_info2part_num
   AND bo.objid = pn.part_num2bus_org
   AND pi.part_serial_no = :new.x_service_id;
 rec_esn_dtl cur_esn_dtl%ROWTYPE;

 CURSOR c1 IS
   SELECT x_code_name
   FROM sa.table_x_code_table
   WHERE x_code_number = :new.x_action_type;

 CURSOR cur_trans_cos is
    select mv.cos
      from x_account_group_benefit gb,
           sa.service_plan_feat_pivot_mv mv
     where gb.call_trans_id   = :NEW.objid
       and gb.service_plan_id = mv.service_plan_objid;
    rec_trans_cos  cur_trans_cos%ROWTYPE;

  c1_rec c1%ROWTYPE;
  t_error_code number := 0;
  t_error_message varchar2(300):= null;
  t_step varchar2(30) := null;

  --Declaration of local variable for error handling.
  o_err_code NUMBER;
  o_err_msg VARCHAR2(2000);

gt group_type;
BEGIN --Trigger Main Section Starts

  IF (LENGTH(:new.x_service_id) <> 12) THEN
    IF (:new.x_action_text = 'PORT CREDIT' AND :new.x_reason = 'Internal Port Credit' AND :new.x_action_type = '1') THEN
        :new.x_action_type := '111';
    END IF;
    IF (     :new.x_action_type NOT IN (6,1,3))
         OR (:new.x_action_type IN (6,1,3) AND :new.x_action_text IS NULL) THEN
      OPEN c1;
        FETCH c1 INTO c1_rec;
        IF c1%FOUND THEN
          :new.x_action_text := c1_rec.x_code_name;
        end if;
      close c1;
    ELSIF (:new.x_action_type = 3 AND :new.x_action_text LIKE 'ACTSWEEP%') THEN
      :new.x_action_text := 'RE' || :new.x_action_text;
    ELSIF :new.x_action_type = 6 AND :new.x_reason != 'LOWBALANCE' then
      OPEN cur_esn_dtl;
        FETCH cur_esn_dtl INTO rec_esn_dtl;
        if cur_esn_dtl%found AND rec_esn_dtl.org_flow = '3' THEN
          :new.x_action_text := 'REDSWEEPALL';
        END IF;
      CLOSE cur_esn_dtl;
    END IF;
  END IF;
  :new.update_stamp := SYSDATE;

  -- Added by Juda Pena on 01/19/2015 to include updating logic
  IF inserting OR updating THEN
    OPEN group_curs;
    FETCH group_curs INTO group_rec;
    IF group_curs%FOUND THEN
        -- cos for the add on/redemptions
        if :new.x_result = 'Completed' then
           open  cur_trans_cos;
           fetch cur_trans_cos INTO rec_trans_cos;
           --
            if cur_trans_cos%NOTFOUND then
              --getting the cos for the base plans
              rec_trans_cos.cos := sa.get_cos (:NEW.x_service_id);
            end if;
           close cur_trans_cos;
        else
           rec_trans_cos.cos := null;
        end if;

	    BEGIN
          INSERT
		        INTO table_x_call_trans_ext
               ( objid,
                 call_trans_ext2call_trans,
                 x_total_days,
                 x_total_sms_units,
                 x_total_data_units,
                 insert_date,
                 account_group_id,
                 master_flag,
		             service_plan_id,
                 transaction_cos
               )
          VALUES
          ( (sequ_table_x_call_trans_ext.NEXTVAL),
            :new.objid,
            null,
            null,
            null,
            SYSDATE,
            group_rec.group_id,
            group_rec.master_flag,
		        group_rec.service_plan_id,
            rec_trans_cos.cos
          );
		 -- Added by Juda Pena on 01/19/2015 to include updating logic
         EXCEPTION
           WHEN DUP_VAL_ON_INDEX THEN
             UPDATE table_x_call_trans_ext
             SET    update_date      = SYSDATE,
                    account_group_id = group_rec.group_id,
                    master_flag      = group_rec.master_flag,
		     	          service_plan_id  = group_rec.service_plan_id,
                    transaction_cos  = rec_trans_cos.cos
             WHERE  call_trans_ext2call_trans = NVL(:new.objid,:OLD.objid);
        END;
    END IF;
    CLOSE group_curs;
  END IF;


 exception
   when others then

     t_error_message :=  'objid:'||:new.objid||':'||SQLCODE ||':'||SQLERRM;
     sa.ota_util_pkg.err_log(p_action       => 'check throttling'
                                   ,p_error_date   => SYSDATE
                                  ,p_key          => :new.x_service_id
                                  ,p_program_name => 'T_CALL_TRANS'
                                  ,p_error_text   => t_error_message);

END;
/