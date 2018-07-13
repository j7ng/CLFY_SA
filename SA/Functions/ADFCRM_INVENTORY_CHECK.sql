CREATE OR REPLACE FUNCTION sa."ADFCRM_INVENTORY_CHECK" (
      ip_case_id VARCHAR2)
    RETURN VARCHAR2
  AS
    --PRAGMA AUTONOMOUS_TRANSACTION;
    --Part Request
    CURSOR pr_cur
    IS
      SELECT pr.*,
        c.x_esn,
        c.objid case_objid,
        c.CASE_ORIGINATOR2USER user_objid,
        c.CASE_TYPE_LVL2 brand,
        gb.title sts_title
      FROM table_case c,
        table_x_part_request pr,
        sa.table_gbst_elm gb,
        sa.table_condition ge
      WHERE c.id_number    = ip_case_id
      AND pr.request2case  = c.objid
      AND pr.x_status NOT IN ('CANCELLED','CANCEL_REQUEST','SHIPPED')
      AND gb.objid = c.casests2gbst_elm
      AND ge.objid = c.case_state2condition
      AND ge.title <> 'Closed';

    --Dummy Replacement
    CURSOR dummy_cur (ip_dummy_pn VARCHAR2, ip_brand varchar2)
    IS
      SELECT repl_part_num,new_model
      FROM adfcrm_dummy_exchange
      WHERE dummy_part = ip_dummy_pn
      and brand = ip_brand
      ORDER BY options ASC;

    --Inventory check
    CURSOR inv_cur (ip_repl_pn VARCHAR2)
    IS
      SELECT part_number,
             ff,
             SUM(on_hand) available
      FROM  sa.FF_DAILY_INVENTORY
      WHERE part_number = ip_repl_pn
      AND insert_date = TRUNC(SYSDATE)
      AND warehouse in ('EX_IO','TFX7')
      GROUP BY part_number, ff;
    --consumption check

    v_ff_center VARCHAR2(30):='';
    v_part_num  VARCHAR2(30):='NOT FOUND';
    v_backorder boolean:= false;
    v_case_objid number;
    v_creator_objid number;
    v_user_objid number;
    v_error_num varchar2(200);
    v_error_msg varchar2(200);
    v_return varchar2(200):='NOT MODIFIED';
    v_inv_threshold number := 100;
    v_orders number:=0;
    v_available number:=0;

  BEGIN
    FOR pr_rec IN pr_cur
    LOOP
      v_ff_center := '';
      v_part_num  := '';
      v_case_objid:=pr_rec.case_objid;
      v_user_objid:=pr_rec.user_objid;

      dbms_output.put_line('pr_rec.x_repl_part_num: '||pr_rec.x_repl_part_num);
      dbms_output.put_line('pr_rec.brand: '||pr_rec.brand);

      FOR dummy_rec IN dummy_cur(pr_rec.x_repl_part_num,pr_rec.brand)
        LOOP
          IF v_part_num <> 'NOT FOUND' THEN
               EXIT;
          END IF;
          v_backorder:=true;
          dbms_output.put_line('dummy_rec.repl_part_num: '||dummy_rec.repl_part_num);
          dbms_output.put_line('dummy_rec.new_model: '||dummy_rec.new_model);

          FOR inv_rec IN inv_cur(dummy_rec.repl_part_num)
          LOOP
              IF v_part_num <> 'NOT FOUND'  THEN
                EXIT;
              END IF;
              dbms_output.put_line('Inv Check: '||nvl(inv_rec.available,0));

              SELECT count('1') orders
              into v_orders
              FROM table_x_part_request,
                table_case
              WHERE table_case.objid                   = table_x_part_request.request2case
              AND table_case.creation_time            >= TRUNC(sysdate) + 9/24
              AND table_x_part_request.x_repl_part_num = dummy_rec.new_model
              AND table_x_part_request.x_status       IN ('PROCESSED','PENDING','SHIPPED')
              AND table_x_part_request.x_ff_center     = inv_rec.ff;

              v_available:= (nvl(inv_rec.available,0) - nvl(v_orders,0) - nvl(v_inv_threshold,0));

              IF v_available > 0 THEN
                v_ff_center   := inv_rec.ff;
                v_part_num    := dummy_rec.new_model;
                v_backorder   := false;

                dbms_output.put_line('Updating');
                dbms_output.put_line('v_ff_center:'||v_ff_center);
                dbms_output.put_line('v_part_num: '||v_part_num);
                dbms_output.put_line('pr_rec.objid: '||pr_rec.objid);

                UPDATE table_x_part_request
                SET x_ff_Center   = v_ff_center,
                  x_repl_part_num = v_part_num,
                  x_courier = 'FEDEX',
                  x_shipping_method = '2nd DAY',
                  x_status = 'PENDING'
                WHERE objid = pr_rec.objid;
                --COMMIT;

                sa.CLARIFY_CASE_PKG.LOG_NOTES(
                  P_CASE_OBJID => v_CASE_OBJID,
                  P_USER_OBJID => v_USER_OBJID,
                  P_NOTES => ' INVENTORY CHECK PART NUMBER UPDATED FROM: '||pr_rec.x_repl_part_num||' TO '||v_part_num||' AVAILABLE: '||v_available ,
                  P_ACTION_TYPE => NULL,
                  P_ERROR_NO => v_error_num,
                  P_ERROR_STR => v_error_msg
                );
                IF pr_rec.sts_title = 'Back Order' then
                  sa.CLARIFY_CASE_PKG.UPDATE_STATUS(
                    P_CASE_OBJID => v_case_objid,
                    P_USER_OBJID => v_user_objid,
                    P_NEW_STATUS => 'Exception Released',
                    P_STATUS_NOTES => 'INVENTORY CHECK',
                    P_ERROR_NO => v_error_num,
                    P_ERROR_STR => v_error_msg);
                END IF;

                v_return:= v_ff_center||':'||v_part_num;
              END IF;
          END LOOP;
        END LOOP;

      --IF v_backorder and  v_part_num = 'NOT FOUND' then
      IF v_backorder then

        sa.CLARIFY_CASE_PKG.LOG_NOTES(
          P_CASE_OBJID => v_CASE_OBJID,
          P_USER_OBJID => v_USER_OBJID,
          P_NOTES => ' INVENTORY CHECK FAILED - BACK ORDER',
          P_ACTION_TYPE => NULL,
          P_ERROR_NO => v_error_num,
          P_ERROR_STR => v_error_msg
        );

        sa.CLARIFY_CASE_PKG.UPDATE_STATUS(
          P_CASE_OBJID => v_case_objid,
          P_USER_OBJID => v_user_objid,
          P_NEW_STATUS => 'Back Order',
          P_STATUS_NOTES => 'INVENTORY CHECK',
          P_ERROR_NO => v_error_num,
          P_ERROR_STR => v_error_msg);

          v_return:='BACK ORDER';
      end if;

    END LOOP;

    return v_return;

  EXCEPTION
  WHEN OTHERS THEN
      return SQLERRM;
  END adfcrm_inventory_check;
/