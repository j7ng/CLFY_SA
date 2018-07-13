CREATE OR REPLACE PROCEDURE sa."INBOUND_CARDS_INV_PRC"
AS
------------------------------------------------------------------------
--$RCSfile: inbound_cards_inv_prc.sql,v $
--$Revision: 1.10 $
--$Author: tbaney $
--$Date: 2018/04/16 15:26:17 $
--$Log: inbound_cards_inv_prc.sql,v $
--Revision 1.10  2018/04/16 15:26:17  tbaney
--Added AND inv_rec.toss_extract_flag <> 'NOV' check.
--
--Revision 1.9  2018/04/16 14:45:10  tbaney
--CR57012_OFS_to_CLFY_Inbound_Code
--
--Revision 1.8  2015/08/28 17:58:03  skota
--added new block to check the cards are swipped or not
--
--Revision 1.7  2014/05/08 08:28:10  cpannala
--Cr25490 B2b changes merged with Production version
--
--Revision 1.6  2013/12/09 20:10:14  akuthadi
--CR22623 - B2B Initiative - Get SITE_ID using SHIP_TO_ID as well.
--Merged with production.
--
--Revision 1.4  2013/05/07 22:32:10  akhan
--fixed a bug
--
--Revision 1.3  2013/03/01 21:08:55  akhan
--Latest
--
--Revision 1.2  2013/01/15 22:50:35  akhan
--adding family plan changes
--
--
------------------------------------------------------------------------
   --Local Variables
   l_action VARCHAR2 (100) := ' ';
   l_requested_card_status VARCHAR2 (20);
   l_serial_num VARCHAR2 (50);
   l_send_location_code varchar2(50);
   l_inner_excep_flag BOOLEAN := FALSE;
   l_part_inst2part_mod NUMBER;
   l_creation_date DATE;
   l_current_site_id table_site.site_id%TYPE;
   l_previous_site_id table_site.site_id%TYPE;
   l_inv_bin_objid table_inv_bin.objid%TYPE;
   l_procedure_name VARCHAR2 (80) := 'INBOUND_CARD_INV_PRC';
   l_start_date DATE := SYSDATE;
   l_recs_processed NUMBER := 0;
   l_status_code_objid NUMBER;
   l_invalid_status_code_objid NUMBER;
   l_promo_objid NUMBER;
   l_pn_tobe_update VARCHAR2(30);

   l_card_loc varchar2(20);
   POSA_CARD CONSTANT varchar2(2) := '45';
   NONPOSA_CARD CONSTANT varchar2(2) := '42';
   INVALID_CARD  CONSTANT varchar2(2) := '44';

   -- CR57012_OFS_to_CLFY_Inbound_Code
   l_ct_suspended      NUMBER;

   --EXCEPTIONS Variables
   no_site_id_exp EXCEPTION;
   no_part_num_exp EXCEPTION; -- CR4659
   distributed_trans_time_out EXCEPTION;
   no_valid_posa_type EXCEPTION;
   record_locked EXCEPTION;
   no_ml_excep EXCEPTION;
   ------------- LOCAL VARIABLES TO AVOID UNNECESSARY TRIPS ---------
   l_previous_part_number VARCHAR2 (100);
   l_current_part_number VARCHAR2 (100);
   --
   l_current_retailer VARCHAR2 (100);
   l_previous_retailer VARCHAR2 (100);
   --
   l_current_ff_center VARCHAR2 (100);
   l_previous_ff_center VARCHAR2 (100);
   --
   l_current_manf VARCHAR2 (100);
   l_previous_manf VARCHAR2 (100);
   l_data_phone NUMBER :=0;
   l_conv_rate NUMBER :=0;
   l_domain_objid number;
   l_user_objid number;
   v_data_conf_objid NUMBER;
   --
   PRAGMA EXCEPTION_INIT (distributed_trans_time_out, - 2049);
   PRAGMA EXCEPTION_INIT (record_locked, - 54);
   --
-------------------------------------------------------------------------------
   CURSOR inv_cur
   IS
   SELECT a.ROWID,
      a.*,
      '' v_objid
   FROM tf_toss_interface_cards_inv a
   order by tf_ret_location_code,tf_ff_location_code,tf_manuf_location_code;
   inv_rec inv_cur%ROWTYPE;
-------------------------------------------------------------------------------
   CURSOR item_cur(part_no_in IN VARCHAR2)
   IS
   SELECT *
   FROM tf_of_item_v_cards_inv
   WHERE part_number = part_no_in;
   item_rec item_cur%ROWTYPE;
   r_chkitempromo item_cur%ROWTYPE;

   CURSOR multibrand_cur(part_no_in IN VARCHAR2) is
   select x_param_value
   FROM table_x_part_class_values v,
     table_x_part_class_params n,
     table_part_num pn
   WHERE value2class_param = n.objid
   AND n.x_param_name = 'PRODUCT_SELECTION'
   AND v.value2part_class=pn.part_num2part_class
   AND pn.part_number = part_no_in;

   multibrand_rec multibrand_cur%rowtype;


-------------------------------------------------------------------------------
--------------- PRIVATE PROCEDURES
-------------------------------------------------------------------------------
PROCEDURE clean_up_prc
-------------------------------------------------------------------------------
   IS
   BEGIN
      IF item_cur%ISOPEN
      THEN
         CLOSE item_cur;
      END IF;
   END clean_up_prc;
-------------------------------------------------------------------------------
procedure insert_pi_hist_rec(v_change_reason in varchar2,
                             p_objid in number) is
-------------------------------------------------------------------------------
begin
   INSERT INTO TABLE_X_PI_HIST(objid,
                               X_CHANGE_DATE            ,
                               X_CHANGE_REASON           ,
                               X_PI_HIST2PART_INST,
                               X_PART_SERIAL_NO,
                               X_DOMAIN         ,
                               X_RED_CODE,
                               X_PART_INST_STATUS,
                               X_INSERT_DATE,
                               X_CREATION_DATE,
                               X_PO_NUM,
                               X_ORDER_NUMBER,
                               X_LAST_MOD_TIME,
                               X_PI_HIST2USER,
                               STATUS_HIST2X_CODE_TABLE,
                               X_PI_HIST2PART_MOD,
                               X_PI_HIST2INV_BIN)
       select seq('x_pi_hist'),
              SYSDATE,
              v_change_reason ,
              objid,
              part_serial_no,
              x_domain,
              x_red_code,
              x_part_inst_status,
              x_insert_date,
              x_creation_date,
              x_po_num,
              x_order_number,
              last_mod_time,
              created_by2user,
              status2x_code_table,
              n_part_inst2part_mod,
              part_inst2inv_bin
      from table_part_inst
      where objid = p_objid;
end ;
-------------------------------------------------------------------------------
procedure posa_rec(p_action in varchar2)
-------------------------------------------------------------------------------
is
begin
  if ( p_action = 'INSERT') then
    begin
       INSERT INTO TABLE_X_POSA_CARD_INV(OBJID ,
              X_PART_SERIAL_NO               ,
              X_DOMAIN                       ,
              X_RED_CODE                     ,
              X_POSA_INV_STATUS              ,
              X_INV_INSERT_DATE              ,
              X_LAST_SHIP_DATE               ,
              X_TF_PO_NUMBER                 ,
              X_TF_ORDER_NUMBER              ,
              X_LAST_UPDATE_DATE             ,
              X_CREATED_BY2USER              ,
              X_LAST_UPDATE_BY2USER          ,
              X_POSA_STATUS2X_CODE_TABLE     ,
              X_POSA_INV2PART_MOD            ,
              X_POSA_INV2INV_BIN             )
       VALUES( seq('x_posa_card_inv')        ,
             inv_rec.TF_SERIAL_NUM           ,
             item_rec.clfy_domain            ,
             inv_rec.tf_card_pin_num         ,
             l_requested_card_status         ,
             inv_rec.creation_date           ,
             NVL(inv_rec.retailer_ship_date  ,
                 NVL(inv_rec.creation_date   ,
                     inv_rec.FF_RECEIVE_DATE)),
             inv_rec.TF_PO_NUM               ,
             inv_rec.tf_order_num            ,
             SYSDATE                         ,
             l_user_objid                    ,
             l_user_objid                    ,
             l_status_code_objid             ,
             l_part_inst2part_mod            ,
             l_inv_bin_objid)                ;
    exception
       when dup_val_on_index then
         posa_rec('UPDATE');
    end;
   elsif ( p_action = 'UPDATE') then
      UPDATE TABLE_X_POSA_CARD_INV
       SET X_PART_SERIAL_NO       = inv_rec.TF_SERIAL_NUM,
       X_DOMAIN                   = item_rec.clfy_domain,
       X_RED_CODE                 = inv_rec.tf_card_pin_num,
       X_POSA_INV_STATUS          = l_requested_card_status,
       X_INV_INSERT_DATE          = inv_rec.creation_date,
       X_LAST_SHIP_DATE           = NVL(inv_rec.retailer_ship_date,
                                        NVL(inv_rec.creation_date,
                                            inv_rec.FF_RECEIVE_DATE)),
       X_TF_PO_NUMBER             = inv_rec.TF_PO_NUM,
       X_TF_ORDER_NUMBER          = inv_rec.tf_order_num,
       X_LAST_UPDATE_DATE         = SYSDATE,
       X_CREATED_BY2USER          = X_CREATED_BY2USER,
       X_LAST_UPDATE_BY2USER      = l_user_objid,
       X_POSA_STATUS2X_CODE_TABLE = l_status_code_objid,
       X_POSA_INV2PART_MOD        = l_part_inst2part_mod,
       X_POSA_INV2INV_BIN         = l_inv_bin_objid
     WHERE X_PART_SERIAL_NO           = inv_rec.TF_SERIAL_NUM;
   elsif ( p_action = 'DELETE') then
       delete table_x_posa_card_inv
        where objid = inv_rec.v_objid;
   end if;
end;
-------------------------------------------------------------------------------
procedure red_card_rec( p_action in varchar2)
-------------------------------------------------------------------------------
is
begin
  if p_action = 'INSERT' then
    null;
  elsif p_action = 'UPDATE' then
     UPDATE  TABLE_X_RED_CARD
      SET x_inv_insert_date   = inv_rec.creation_date,
          x_last_ship_date    =  NVL(inv_rec.retailer_ship_date,
                                  NVL(inv_rec.creation_date,
                                      inv_rec.FF_RECEIVE_DATE)),
          x_order_number      = inv_rec.tf_order_num,
          x_po_num            = inv_rec.TF_PO_NUM,
          x_created_by2user   = x_created_by2user,
          x_red_card2part_mod = l_part_inst2part_mod,
          x_red_card2inv_bin  = l_inv_bin_objid
     WHERE objid = inv_rec.v_objid;
  elsif p_action = 'DELETE' then
    delete table_x_red_card
    where objid = inv_rec.v_objid;
  end if;
end;
-------------------------------------------------------------------------------
function swiped return boolean is
-------------------------------------------------------------------------------
v_serial_no varchar2(30);
begin
  select tf_serial_num
  into v_serial_no
  from x_posa_card
  where tf_serial_num = inv_rec.tf_serial_num;
  return true;
exception
  when others then
   return false;
end;
-------------------------------------------------------------------------------
procedure part_inst_rec( p_action in varchar2)
-------------------------------------------------------------------------------
is
begin
   if ( p_action = 'INSERT') then
     begin
       INSERT INTO TABLE_PART_INST
                   (objid,
                    part_serial_no,
                    x_part_inst_status,
                    x_sequence,
                    x_red_code,
                    x_order_number,
                    x_creation_date,
                    created_by2user,
                    x_domain,
                    n_part_inst2part_mod,
                    part_inst2inv_bin,
                    part_status,
                    x_insert_date,
                    status2x_code_table,
                    last_pi_date,
                    last_cycle_ct,
                    next_cycle_ct,
                    last_mod_time,
                    last_trans_time,
                    date_in_serv,
                    repair_date,
                    x_parent_part_serial_no)
            VALUES( seq('part_inst'),
                    inv_rec.tf_serial_num,
                    l_requested_card_status,
                    0,
                    inv_rec.tf_card_pin_num,
                    inv_rec.tf_order_num,
                    l_creation_date,   -- changed from sysdate G.P. 12-15-2000
                    l_user_objid,
                    item_rec.clfy_domain,
                    l_part_inst2part_mod,
                    l_inv_bin_objid,
                    'Active',
                    inv_rec.creation_date,   --SYSDATE,
                    l_status_code_objid,
                    TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                    TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                    TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                    TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                    TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                    TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                    TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                    inv_rec.tf_master_serial_num);
     exception
        when dup_val_on_index then
          part_inst_rec('UPDATE');
     end;
   elsif (p_action = 'UPDATE') then
       UPDATE table_part_inst
       SET x_part_inst_status= case
                                when x_part_inst_status not in ( '263','400') then
                                   l_requested_card_status
                                else
                                   x_part_inst_status
                               end,
           status2x_code_table=case
                                when x_part_inst_status not in ( '263','400') then
                                   l_status_code_objid
                                else
                                   status2x_code_table
                               end,
           x_creation_date      = l_creation_date,
           x_order_number       = inv_rec.tf_order_num,
           created_by2user      = l_user_objid,
           x_domain             = item_rec.clfy_domain,
           last_pi_date         = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
           last_cycle_ct        = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
           next_cycle_ct        = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
           last_mod_time        = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
           last_trans_time      = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
           date_in_serv         = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
           repair_date          = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
           n_part_inst2part_mod = l_part_inst2part_mod,
           part_inst2inv_bin    = l_inv_bin_objid,
           x_parent_part_serial_no = inv_rec.TF_MASTER_SERIAL_NUM
       WHERE part_serial_no  = inv_rec.tf_serial_num
         AND x_domain     = item_rec.clfy_domain;
elsif ( p_action = 'DELETE') then
     DELETE table_part_inst
     where objid = inv_rec.v_objid;
end if;

end;
-------------------------------------------------------------------------------
FUNCTION get_site_idninv_bin(p_fin_cust_id   IN  VARCHAR2,
                             p_ship_loc_id   IN  NUMBER,
                             p_site_id       OUT VARCHAR2, -- CR22623
                             p_inv_bin_objid OUT NUMBER) RETURN BOOLEAN IS
-------------------------------------------------------------------------------
BEGIN
   --
   SELECT site_id, ib.objid
    INTO p_site_id, p_inv_bin_objid
   FROM table_site s, table_inv_bin ib
   WHERE TYPE = 3
    AND bin_name = s.site_id
    AND nvl(s.x_ship_loc_id, -1) = nvl(p_ship_loc_id, -1) -- CR22623
    AND x_fin_cust_id = p_fin_cust_id;
   --
   RETURN TRUE;
   --
EXCEPTION
   WHEN OTHERS THEN
      RETURN FALSE;
END get_site_idninv_bin;

-------------------------------------------------------------------------------
function find_card_location(p_serial_num in varchar2,
                            p_clfy_domain in varchar2,
                            p_objid out number )
return varchar2 is
-------------------------------------------------------------------------------
 location varchar2(20);
begin
    select 'PART_INST_TABLE',
           objid
    into location,
         p_objid
    from table_part_inst
    where x_domain||''= p_clfy_domain
    and part_serial_no = p_serial_num;
    return location;
exception
when others then
   begin
      select 'POSA_CARD_TABLE',
             objid
      into location,
             p_objid
      from table_x_posa_card_inv
      where x_part_serial_no = p_serial_num;
      return location;
   exception
   when others then
      begin
         select 'RED_CARD_TABLE',
                 objid
         into location,
              p_objid
         from table_x_red_card
         where x_result||'' = 'Completed'
         AND x_smp = p_serial_num;
         return location;
      exception
      when others then
         return 'NOTFOUND';
      end;
   end;
end;

-------------------------------------------------------------------------------
PROCEDURE upd_ti_card_inv(p_extract_flag in varchar2,
                          p_pn_tobe_updated in varchar2,
                          p_rowid in varchar2 ) is
-------------------------------------------------------------------------------
BEGIN
  UPDATE tf_toss_interface_cards_inv
    SET toss_extract_flag = p_extract_flag,
        toss_extract_date = SYSDATE,
        last_update_date = SYSDATE,
        last_updated_by = l_procedure_name
  WHERE ROWID = p_rowid;
END;
-------------------------------------------------------------------------------
function get_conv_rate(ip_part_number in varchar2,
                       ip_domain_objid in number,
                       op_conv_rate out number ) return boolean is
-------------------------------------------------------------------------------
begin
    select decode(x_data_capable,1,decode(nvl(x_conversion,0),0,
           hc,x_conversion),hc)
    into op_conv_rate
    from (SELECT part_number,
             x_conversion,
             x_data_capable,
             decode(bus.org_id,'NET10',10,'TRACFONE',3,'STRAIGHT_TALK',1) HC
          FROM table_part_num pn, table_bus_org bus
          WHERE pn.part_num2bus_org=bus.objid
          AND pn.part_number = ip_part_number
          AND pn.part_num2domain = ip_domain_objid);
   return true;
exception
   when others then
     return false;
end;

-------------------------------------------------------------------------------
-------- MAIN/Main/main procedure starts here
-------------------------------------------------------------------------------

BEGIN
   l_previous_part_number := 'DUMMY_PART';
   l_current_part_number := 'DUMMY_PART';
   l_current_retailer := 'DUMMY_RET';
   l_previous_retailer := 'DUMMY_RET';
   l_current_ff_center := 'DUMMY_FF';
   l_previous_ff_center := 'DUMMY_FF';
   l_current_manf := 'DUMMY_MANF';
   l_previous_manf := 'DUMMY_MANF';
   l_previous_part_number:= 'DUMMY_PART';
   l_pn_tobe_update := NULL; --CR8548
   ---- GET USER ONLY ONCE
   BEGIN
         SELECT objid
         into l_user_objid
         FROM table_user
         WHERE login_name = 'ORAFIN';
   EXCEPTION
        when others then
          l_user_objid := NULL;
   END;
   OPEN inv_cur;
   LOOP
      FETCH inv_cur into inv_rec;
      EXIT when inv_cur%NOTFOUND;
      l_inner_excep_flag := FALSE; --CR3886
      l_recs_processed := l_recs_processed + 1;

      OPEN item_cur (inv_rec.tf_part_num_transpose);
      FETCH item_cur
      INTO r_chkitempromo;
      CLOSE item_cur;
      IF nvl(r_chkitempromo.promo_code,'NONE')  <> 'NONE'
      THEN
           inv_rec.tf_part_num_parent := inv_rec.tf_part_num_transpose;
      END IF;

      --End of CR5461 - TF PartNumber transpose
      l_current_part_number := inv_rec.tf_part_num_parent;
      l_current_retailer := inv_rec.tf_ret_location_code;
      l_current_ff_center := inv_rec.tf_ff_location_code;
      l_current_manf := inv_rec.tf_manuf_location_code;
      BEGIN
         -------- MAIN INNER BLOCK --------
         l_action := ' ';
         l_serial_num := inv_rec.tf_serial_num;
         l_creation_date := NULL;

         BEGIN
            SELECT part_num2x_data_config
            INTO v_data_conf_objid
            FROM table_part_num pn
            WHERE part_number = inv_rec.tf_part_num_parent;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               raise no_part_num_exp;
            WHEN OTHERS THEN
               null;
         END;
         l_send_location_code := null;
         IF inv_rec.tf_ret_location_code IS NOT NULL
         THEN
            l_creation_date := inv_rec.retailer_ship_date;
            l_current_ff_center  := 'USING_RET';
            l_current_manf       := 'USING_RET';
            IF (l_current_retailer != l_previous_retailer)
            THEN
               l_send_location_code := inv_rec.tf_ret_location_code;
            ELSE
               l_current_site_id := l_previous_site_id;
            END IF;

         ELSIF inv_rec.tf_ff_location_code IS NOT NULL
         THEN
            l_creation_date := inv_rec.ff_receive_date;
            l_current_retailer   := 'USING_FF';
            l_current_manf       := 'USING_FF';
            IF (l_current_ff_center != l_previous_ff_center)
            THEN
               l_send_location_code := inv_rec.tf_ff_location_code;
            ELSE
               l_current_site_id := l_previous_site_id;
            END IF;

         ELSIF inv_rec.tf_manuf_location_code IS NOT NULL
         THEN
            l_creation_date := inv_rec.creation_date;
            l_current_retailer   := 'USING_MANF';
            l_current_ff_center  := 'USING_MANF';
            IF (l_current_manf != l_previous_manf)
            THEN
               l_send_location_code := inv_rec.tf_manuf_location_code;
            ELSE
               l_current_site_id := l_previous_site_id;
            END IF;
         END IF;
         IF ( l_send_location_code is not null ) then
              IF get_site_idNinv_bin(l_send_location_code,
                                     inv_rec.ship_to_id, -- CR22623
                                     l_current_site_id,
                                     l_inv_bin_objid)
              THEN
                   l_previous_site_id := l_current_site_id;
              ELSE
                   RAISE no_site_id_exp;
              END IF;
         END IF;


         l_action := 'Checking for existance of SITE in TOSS';
         IF l_current_site_id IS NULL
         THEN
            RAISE no_site_id_exp;
         ELSE
            ------ CHECK IF THE PART NUMBER IS EQUAL -------
            IF l_previous_part_number   != l_current_part_number
            THEN
               OPEN item_cur (inv_rec.tf_part_num_parent);
               FETCH item_cur
               INTO item_rec;
               CLOSE item_cur;
               --FAMILY PLAN CHANGES
               if item_rec.clfy_domain = 'BUNDLE' then
                  item_rec.clfy_domain := 'REDEMPTION CARDS';
               end if;
               --FAMILY PLAN CHANGES

               IF item_rec.posa_type = 'POSA'
               THEN
                  l_requested_card_status := POSA_CARD;
               ELSIF item_rec.posa_type = 'NPOSA'
               THEN
                  l_requested_card_status := NONPOSA_CARD;
               ELSE
                  l_requested_card_status := NULL;
               END IF;

               IF l_requested_card_status is not null THEN

                   SELECT objid
                   INTO l_status_code_objid
                   FROM table_x_code_table
                   WHERE x_code_number = l_requested_card_status
                   AND x_code_type     =  'CS';

                   SELECT objid
                   INTO l_invalid_status_code_objid
                   FROM table_x_code_table
                   WHERE x_code_number = INVALID_CARD
                   AND x_code_type     =  'CS';

               ELSE
                   raise no_valid_posa_type;
               END IF;
               l_action := ' ';
               BEGIN
                  SELECT objid
                  INTO l_promo_objid
                  FROM table_x_promotion
                  WHERE x_promo_code = item_rec.promo_code;
               EXCEPTION
                  when others then
                    l_promo_objid := null;
               END;
               -- Get the domain object id
               BEGIN
                   SELECT objid
                   INTO l_domain_objid
                   FROM table_prt_domain
                   WHERE NAME = item_rec.clfy_domain;
               EXCEPTION
                   when others then null;
               END;
               l_action := 'Checking for existence of PART-'||
                       inv_rec.tf_part_num_parent||' in TOSS';

               if not get_conv_rate(inv_rec.tf_part_num_parent,
                                    l_domain_objid,
                                    l_conv_rate) then
                         raise no_part_num_exp;
               end if;
               BEGIN
                    SELECT a.objid
                    INTO l_part_inst2part_mod
                    FROM table_mod_level a, table_part_num b
                    WHERE a.mod_level = item_rec.redemption_units
                    AND a.part_info2part_num = b.objid
                    AND a.active = 'Active' --Digital
                    AND b.part_number = inv_rec.tf_part_num_transpose
                    AND b.domain = item_rec.clfy_domain;
               EXCEPTION
                  when NO_DATA_FOUND then
                     l_part_inst2part_mod:= null;
                     RAISE no_ml_excep;
               END;
            END IF; -- of same part number check
           --
            if (inv_rec.toss_extract_flag not in('NEWC','NO')) then
                l_card_loc := null;
                l_card_loc := find_card_location(
                                  inv_rec.tf_serial_num,
                                  item_rec.clfy_domain,
                                  inv_rec.v_objid);
                if l_card_loc = 'PART_INST_TABLE' then
                   if l_requested_card_status = POSA_CARD and
                     nvl(inv_rec.TF_MASTER_SERIAL_NUM,inv_rec.tf_serial_num) =
                                          inv_rec.tf_serial_num
                   then
                      if not swiped then
                         if inv_rec.toss_extract_flag = 'NOV' then
                           l_requested_card_status := INVALID_CARD;
                           l_status_code_objid     := l_invalid_status_code_objid;
                         end if;
                         posa_rec('INSERT');
                         insert_pi_hist_rec('NPOSA TO POSA',
                                        inv_rec.v_objid);
                         part_inst_rec('DELETE');
                      else
                         -- CR57012_OFS_to_CLFY_Inbound_Code
                         -- See if the card is 44 in part inst
                         -- if so then set back to then 45.
                         begin
                            SELECT count(*)
                              INTO l_ct_suspended
                              FROM table_part_inst
                             WHERE part_serial_no  = inv_rec.tf_serial_num
                               AND x_domain     = item_rec.clfy_domain
                               AND x_part_inst_status = INVALID_CARD;
                         exception when others then
                            l_ct_suspended := 0;
                         end;
                         if l_ct_suspended >= 0 AND inv_rec.toss_extract_flag <> 'NOV' then
                            l_requested_card_status   := NONPOSA_CARD;
                            l_status_code_objid       := l_invalid_status_code_objid;
                            part_inst_rec('UPDATE');
                         end if;  -- l_ct_suspended
                         -- END CR57012_OFS_to_CLFY_Inbound_Code
                      end if;
                   /*elsif l_requested_card_status = NONPOSA_CARD or
                         (l_requested_card_status = POSA_CARD and
                          nvl(inv_rec.TF_MASTER_SERIAL_NUM,inv_rec.tf_serial_num) <>
                                          inv_rec.tf_serial_num) */ --Check Asim
                   else

                      if inv_rec.toss_extract_flag = 'NOV' then
                        l_requested_card_status := INVALID_CARD;
                        l_status_code_objid     := l_invalid_status_code_objid;
                      end if;
                      part_inst_rec('UPDATE');
                   end if;
                elsif l_card_loc = 'POSA_CARD_TABLE' then
                   if l_requested_card_status = NONPOSA_CARD or
                      (l_requested_card_status = POSA_CARD and
                       nvl(inv_rec.TF_MASTER_SERIAL_NUM,inv_rec.tf_serial_num) <>
                                          inv_rec.tf_serial_num)
                   then
                      if inv_rec.toss_extract_flag = 'NOV' then
                        l_requested_card_status := INVALID_CARD;
                        l_status_code_objid     := l_invalid_status_code_objid;
                      end if;
                      part_inst_rec('INSERT');
                      posa_rec('DELETE');
                   else ---Check Asim
                      if inv_rec.toss_extract_flag = 'NOV' then
                        l_requested_card_status := INVALID_CARD;
                        l_status_code_objid     := l_invalid_status_code_objid;
                      end if;
                      posa_rec('UPDATE');
                   end if;
                elsif l_card_loc = 'RED_CARD_TABLE' then
                      red_card_rec('UPDATE');
                else
                     if l_requested_card_status = POSA_CARD then
                      if inv_rec.toss_extract_flag = 'NOV' then
                        l_requested_card_status    := INVALID_CARD;
                        l_status_code_objid        := l_invalid_status_code_objid;
                      end if;
                       posa_rec('INSERT');
                     elsif l_requested_card_status = NONPOSA_CARD then
                      if inv_rec.toss_extract_flag = 'NOV' then
                        l_requested_card_status := INVALID_CARD;
                        l_status_code_objid     := l_invalid_status_code_objid;
                      end if;
                       part_inst_rec('INSERT');
                     else
                        dbms_output.put_line('Unsupported');
                     end if;
                end if;
            else --it is NEWC or NO
                if l_requested_card_status = NONPOSA_CARD or
                   nvl(inv_rec.tf_master_serial_num,inv_rec.tf_serial_num)
                      != inv_rec.tf_serial_num then
                  part_inst_rec('INSERT');
                elsif l_requested_card_status = POSA_CARD then
						if  swiped then                      --CR35400 checking the card already existed in clarify
								toss_util_pkg.insert_error_tab_proc ('Card was exists in clarify',
                                                                      l_serial_num,
                                                                      l_procedure_name );
                        else
                                 posa_rec('INSERT');
                        end if;                             --end CR35400
                else
                   dbms_output.put_line('Unsupported');
                end if;
            end if; --end of NOT NEWC or NO
            upd_ti_card_inv('YES',
                            '',
                            inv_rec.rowid );
         END IF; -- end of site_id check
         EXCEPTION
         WHEN no_ml_excep
         THEN
            toss_util_pkg.insert_error_tab_proc (
                   'Inner Block : ' || l_action,
                   l_current_part_number,
                   l_procedure_name,
                   'MOD_LEVEL NOT EXISTS' );
            l_inner_excep_flag := TRUE;
         WHEN no_part_num_exp
         THEN
            toss_util_pkg.insert_error_tab_proc (
                   'Inner Block : ' || l_action,
                   l_serial_num,
                   l_procedure_name,
                   'PART_NUM NOT EXISTS ' );
            l_inner_excep_flag := TRUE;
         WHEN no_site_id_exp
         THEN
            toss_util_pkg.insert_error_tab_proc (
                   'NO SITE ID',
                   l_serial_num,
                   l_procedure_name,
                   'Inner Block Error no_site_id_exp');
            l_inner_excep_flag := TRUE;
         WHEN distributed_trans_time_out
         THEN
            toss_util_pkg.insert_error_tab_proc (
                  'Caught distributed_trans_time_out',
                  l_serial_num,
                  l_procedure_name,
                  'Inner Block Error distributed_trans_time_out'
            );
            l_inner_excep_flag := TRUE;
         WHEN record_locked
         THEN
            toss_util_pkg.insert_error_tab_proc
                 ('Caught distributed_trans_time_out',
                  l_serial_num,
                  l_procedure_name,
                  'Inner Block Error record_locked ');
            l_inner_excep_flag := TRUE;
         WHEN OTHERS
         THEN
            toss_util_pkg.insert_error_tab_proc (
                  'Inner Block Error -When others',
                  l_serial_num,
                  l_procedure_name );
            l_inner_excep_flag := TRUE;
      END;
      clean_up_prc;

      IF MOD (l_recs_processed, 5000) = 0
      THEN
         COMMIT;
      END IF;
      IF l_inner_excep_flag
      THEN
         l_previous_part_number := 'DUMMY_PART';
         l_inv_bin_objid     := -1;
         l_previous_retailer := 'DUMMY_RET';
         l_previous_ff_center:= 'DUMMY_FF';
         l_previous_manf     := 'DUMMY_MANF';
      ELSE
         ------------------ Set current to previous ------------------
         l_previous_part_number := l_current_part_number;
         l_previous_retailer := l_current_retailer;
         l_previous_ff_center := l_current_ff_center;
         l_previous_manf := l_current_manf;
      END IF;
   END LOOP; --Main loop
   CLOSE inv_cur;
   COMMIT;
   IF toss_util_pkg.insert_interface_jobs_fun (l_procedure_name,
                                               l_start_date,
                                               SYSDATE,
                                               l_recs_processed,
                                               'SUCCESS',
                                               l_procedure_name )
   THEN
      COMMIT;
   END IF;
   clean_up_prc;
END inbound_cards_inv_prc;
/