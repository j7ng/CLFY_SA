CREATE OR REPLACE PROCEDURE sa."SP_RPK_FF_OUTBOUND"
IS
/******************************************************************************/
/*    Copyright   2002 Tracfone  Wireless Inc. All rights reserved            */
/*                                                                            */
/* NAME:         SP_RPK_FF_OUTBOUND                                           */
/* PURPOSE:      To create outbound records that will be sent to              */
/*               fulfillment center                                           */
/* FREQUENCY:                                                                 */
/* PLATFORMS:    Oracle 8.0.6 AND newer versions.                             */
/*                                                                            */
/* REVISIONS:                                                                 */
/* VERSION  DATE        WHO          PURPOSE                                  */
/* -------  ---------- -----  ---------------------------------------------   */
/*  1.0     09/16/02   SL     Initial  Revision                               */
/*  1.1     10/10/02   SL     change one product per record to                */
/*                            '|' delimitated multiple products per record    */
/*  1.2     10/14/02   SL     Return OS with error if unexpected occurred     */
/*  1.3     10/21/02   SL     Fix holding days calculation                    */
/*  1.4     10/23/02   SL     reduce holding days from 5 to 3 and use         */
/*                            business day to calculate                       */
/*  1.5     10/25/02   SL     Add logic to handle order cancellation          */
/*  1.6     12/09/02   SL     Add logic to handle different sourcesystem      */
/*                                                                            */
/******************************************************************************/
 l_program_name VARCHAR2(30) := 'SP_RPK_FF_OUTBOUND';
 l_holding_days NUMBER := 3; --10/04/02 ,10/23/02
 l_release_date DATE; --10/23/02
 l_cursorid INTEGER;
 l_rc INTEGER;
 l_sql_text VARCHAR2(2000);
 l_action VARCHAR2(100);
 l_error_reason VARCHAR2(1500);
 l_tech   VARCHAR2(10);
 l_transpose_code VARCHAR2(30);
 l_ff_name VARCHAR2(40) := 'BP'; -- Name of Fulfillment Center: Brightpoint
 l_today  DATE := sysdate;
 l_tot_out NUMBER := 0;
 l_dtl_out NUMBER := 0;
 l_ff_outbound_flag VARCHAR2(30) ;
 l_dummy NUMBER := 0;
 l_pipe_products VARCHAR2(150); -- 1.1     10/10/02

 CURSOR c_west_hdr IS
   SELECT * FROM x_republik_order_hdr
   WHERE  (
            ( last_order_status = 'NEW'
              AND UPPER(NVL(PAYMENT_METHOD,'CREDIT')) = 'CREDIT'
            )
           OR
            ( last_order_status = 'NEW'
              AND UPPER(PAYMENT_METHOD) <> 'CREDIT'  -- 12/09/02
              -- 12/09/02 AND call_date < l_release_date  --10/25/02 use call_date instead of created_date
              and   APPROVAL_STATUS = 1
            )
          )
   AND   sourcesystem <> 'WEB';  --12/09/02  sourcesystem = 'WEST'

  CURSOR c_west_dtl ( c_toss_order_id number) IS
    SELECT * FROM x_republik_order_dtl
    WHERE toss_order_id = c_toss_order_id;

BEGIN

 --
 -- calculate release date
 -- 10/23/02
 l_release_date := l_today;
 if l_holding_days > 0 then

    FOR i in 1..l_holding_days  LOOP

      if to_number(to_char(l_release_date  ,'D')) = 7 then
         l_release_date := l_release_date - 1;
      elsif to_number(to_char(l_release_date ,'D')) = 1 then
         l_release_date := l_release_date - 2;
      end if;
      l_release_date := l_release_date - 1;
      if to_number(to_char(l_release_date  ,'D')) = 7 then
         l_release_date := l_release_date - 1;
      elsif to_number(to_char(l_release_date ,'D')) = 1 then
         l_release_date := l_release_date - 2;
      END IF;

    END LOOP;

 END IF;

 l_release_date := trunc(l_release_date+1);
 --
 -- Process order cancellation
 --
 sp_rpk_cancel_orders (l_release_date);

 --
 -- IF TEMP table exists, drop it
 --
 l_sql_text := 'DROP TABLE X_REPUBLIK_FF_OUTBOUND';
 l_cursorid := dbms_sql.open_cursor;
 BEGIN
   l_action := 'Parse sql:DROP TABLE X_REPUBLIK_FF_OUTBOUND';
   dbms_sql.parse(l_cursorid,l_sql_text ,dbms_sql.v7);
   l_action := 'Execute sql:DROP TABLE X_REPUBLIK_FF_OUTBOUND';
   l_rc := dbms_sql.execute(l_cursorid);
   --dbms_output.put_line('Temp table droped.');
 EXCEPTION
   WHEN OTHERS THEN
    IF dbms_sql.is_open(l_cursorid) THEN
       dbms_sql.close_cursor(l_cursorid);
    END IF;
 END;

 IF dbms_sql.is_open(l_cursorid) THEN
    dbms_sql.close_cursor(l_cursorid);
 END IF;


 --
 -- Create temp table
 --
 l_action := 'Create table X_REPUBLIK_FF_OUTBOUND';
 l_sql_text := 'CREATE TABLE X_REPUBLIK_FF_OUTBOUND '||
               ' ( order_id number, part_serial_no varchar2(20), '||
               '   shipment_tracking_id varchar2(50), transpose_part_no varchar2(150))';
               -- 1.1     10/10/02 change transpose_part_no size 40 - 150
 l_cursorid := dbms_sql.open_cursor;
 BEGIN
   l_action := 'Parse sql:Create table X_REPUBLIK_FF_OUTBOUND';
   dbms_sql.parse(l_cursorid,l_sql_text ,dbms_sql.v7);
   l_action := 'Execute sql:Create table X_REPUBLIK_FF_OUTBOUND';
   l_rc := dbms_sql.execute(l_cursorid);
 EXCEPTION
   WHEN OTHERS THEN
    IF dbms_sql.is_open(l_cursorid) THEN
       dbms_sql.close_cursor(l_cursorid);
    END IF;
    l_error_reason := substr(sqlerrm,1,1000);
    insert_error_tab_proc ( ip_action=>l_action,
                            ip_key=> l_program_name,
                            ip_program_name=>l_program_name,
                            ip_error_text=>l_error_reason);
    l_action :=NULL;
    l_error_reason := NULL;
    COMMIT;
    RETURN;
 END;
 dbms_sql.close_cursor(l_cursorid);
 --dbms_output.put_line('Temp table X_REPUBLIK_FF_OUTBOUND created.');

 --
 -- Get order detail
 --
 FOR c_west_hdr_rec IN c_west_hdr LOOP

   l_ff_outbound_flag := NULL;
   l_dtl_out := 0;
   l_dummy := 0;
   l_pipe_products := NULL; -- 1.1     10/10/02

   SAVEPOINT outbound;

   FOR c_west_dtl_rec IN c_west_dtl(c_west_hdr_rec.toss_order_id) LOOP

     SELECT COUNT(1) INTO l_dummy
     FROM table_part_num
     WHERE part_number = c_west_dtl_rec.transpose_part_no;

     IF l_dummy <> 1 THEN
       l_action := 'Validate transpose part no';
       l_error_reason := 'Unable to retrieve transpose part no '|| c_west_dtl_rec.transpose_part_no||
                         ' for toss order '|| c_west_hdr_rec.toss_order_id||' .';
       insert_error_tab_proc ( ip_action=>l_action,
                               ip_key=> c_west_hdr_rec.toss_order_id,
                               ip_program_name=>l_program_name,
                               ip_error_text=>l_error_reason);
       COMMIT;
       l_ff_outbound_flag := 'E';
       l_action :=NULL;
       l_error_reason := NULL;
       GOTO next_rec;
     END IF;

     IF l_pipe_products is NOT null THEN
       l_pipe_products := l_pipe_products ||'|'||c_west_dtl_rec.transpose_part_no; -- 1.1     10/10/02
     ELSE
       l_pipe_products := c_west_dtl_rec.transpose_part_no;
     END IF;
     l_dtl_out := l_dtl_out + 1;
   END LOOP;

   IF l_dtl_out > 0 THEN
      -- 1.1     10/10/02
      --l_pipe_products := substr(l_pipe_products,1,length(l_pipe_products)-1);
      l_sql_text := 'insert into x_republik_ff_outbound ( order_id, transpose_part_no) values'
                    ||' ('''||c_west_hdr_rec.toss_order_id||''','''
                    ||l_pipe_products||''')';
      l_cursorid := dbms_sql.open_cursor;

      BEGIN
        l_action := 'Create FF outbound record.';
        dbms_sql.parse(l_cursorid,l_sql_text ,dbms_sql.v7);
        l_rc := dbms_sql.execute(l_cursorid);
      EXCEPTION
        WHEN OTHERS THEN
         IF dbms_sql.is_open(l_cursorid) THEN
           dbms_sql.close_cursor(l_cursorid);
         END IF;
         ROLLBACK TO SAVEPOINT outbound;
         l_error_reason := substr(sqlerrm,1,1000);
         insert_error_tab_proc ( ip_action=>l_action,
                                 ip_key=> c_west_hdr_rec.toss_order_id,
                                 ip_program_name=>l_program_name,
                                 ip_error_text=>l_error_reason);
         COMMIT;
         l_ff_outbound_flag := 'E';
         l_action :=NULL;
         l_error_reason := NULL;
         GOTO next_rec;
      END;
      dbms_sql.close_cursor(l_cursorid);
      -- end 1.1     10/10/02
      l_ff_outbound_flag := 'Y';
      --l_tot_out := l_tot_out + l_dtl_out; -- 1.1     10/10/02
      l_tot_out := l_tot_out + 1; -- 1.1     10/10/02
   ELSE
      l_action := 'Validate number of detail records.';
      l_error_reason := 'No detail record exists for order ID '||c_west_hdr_rec.toss_order_id;
      l_ff_outbound_flag := 'E';
      insert_error_tab_proc ( ip_action=>l_action,
                              ip_key=> c_west_hdr_rec.toss_order_id,
                              ip_program_name=>l_program_name,
                              ip_error_text=>l_error_reason);
      COMMIT;
      l_action :=NULL;
      l_error_reason := NULL;
   END IF;

   <<next_rec>>
   BEGIN

     UPDATE x_republik_order_hdr
     SET LAST_UPDATED_DATE = l_today
        ,LAST_UPDATED_BY = l_program_name
        ,LAST_ORDER_STATUS = decode(l_ff_outbound_flag,'Y','SENT_TO_FF',last_order_status)
        ,FF_NAME = l_ff_name
        ,FF_OUTBOUND_FLAG = l_ff_outbound_flag
        ,FF_OUTBOUND_DATE = l_today
     WHERE toss_order_id = c_west_hdr_rec.toss_order_id;

   EXCEPTION
      WHEN others THEN
       ROLLBACK TO SAVEPOINT outbound;
       l_action := 'Update order header record after FF outbound created.';
       l_error_reason := substr(sqlerrm,1,1000);
       insert_error_tab_proc ( ip_action=>l_action,
                               ip_key=> c_west_hdr_rec.toss_order_id,
                               ip_program_name=>l_program_name,
                               ip_error_text=>l_error_reason);
       COMMIT;
   END;

   IF mod(l_tot_out,500) = 0 THEN
     COMMIT;
   END IF;

 END LOOP;

 COMMIT;
 dbms_output.put_line('Republik Order Outbound Process Completed.');
 dbms_output.put_line('Total Outbound Records Created: '||l_tot_out);
EXCEPTION
  WHEN others THEN
    l_action := 'ANY';
    l_error_reason := 'Unexpected error: '||substr(sqlerrm,1,1000);
    insert_error_tab_proc ( ip_action=>l_action,
                            ip_key=> l_program_name,
                            ip_program_name=>l_program_name,
                            ip_error_text=>l_error_reason);
    COMMIT;
    /* 10/14/02 return to OS with error */
    dbms_output.put_line('Error occurred when executing '||l_program_name||'. >> '||
                         substr(l_error_reason,1,100));
    raise_application_error(-20001,l_error_reason);
END;
/