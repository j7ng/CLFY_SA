CREATE OR REPLACE PACKAGE BODY sa.POSA_KMART_161_PKG
AS
/*****************************************************************************/
/*    Copyright ) 2001 Tracfone  Wireless Inc. All rights reserved           */
/*                                                                           */
/* NAME:                                                                     */
/* PURPOSE:                                                                  */
/* FREQUENCY:    ad hoc                                                      */
/* PLATFORMS:    Oracle 8.0.6 AND newer versions.                            */
/*                                                                           */
/* REVISIONS:                                                                */
/*   VERSION  DATE        WHO               PURPOSE                          */
/*  -------  ----------  ---------------   --------------------------------  */
/*     1.0   07/24/01    SL                Create an posa 161 bytes file for */
/*                                         Kmart                             */
/*                                                                           */
/*     1.1   09/17/01    SL                Phoenix Project                   */
/*                                         Reading data from posa_swp_loc_ac */
/*                                         t_card                            */
/*                                                                           */
/*                                         instead of topp_oci_redeem_interf */
/*     1.2   11/02/01    SL                Fix: cost/sell value in header do */
/*                                         es not                            */
/*                                         match total of cost/sell in       */
/*                                                                           */
/*     1.3   01/24/02    Miguel Leon       Changes table posa_swp_loc_act_car*/
/*                                         to x_posa_card                    */
/*****************************************************************************/
   FUNCTION P_From_Varchar2 (p_varchar2 VARCHAR2,  p_width NUMBER)
      RETURN VARCHAR2;

   FUNCTION P_From_Number (p_number NUMBER,  p_width NUMBER)
      RETURN VARCHAR2;PROCEDURE get_part_info (
      p_part_num              VARCHAR2,
      p_cost            OUT   NUMBER,
      p_sell_value      OUT   NUMBER,
      p_mops_item_num   OUT   VARCHAR2
   );
/*****************************************************************************/
/*                                                                           */
/* Procedures       : create_161_file                                        */
/*                                                                           */
/* Tables           :   x_posa_card                                          */
/*                                                                           */
/*                                                                           */
/* Parameter        :   create_161_file                                      */
/*                      1.start date                                         */
/*                      2.end date                                           */
/*                      3.number of date that will be used to                */
/*                        calculate due date ( number of date + sysdate)     */
/*****************************************************************************/
   PROCEDURE create_161_file (
      p_start_date    DATE,
      p_end_date      DATE,
      p_date_adjust   NUMBER
   )
   IS
      v_start_date             DATE               := p_start_date;
      v_end_date               DATE               := p_end_date + 1;
      v_debug                  VARCHAR2 (1)       := 'Y';
      v_output_file            UTL_FILE.FILE_TYPE;
      --v_output_path    VARCHAR2(100) := '/b01/invfile'; -- clfydev1 only
      v_output_path            VARCHAR2 (100)     := '/f01/invfile';   -- production only
      v_file_name              VARCHAR2 (80)
            := 'trac_kmart' || to_char (sysdate, 'MMDDYYHH24MI');
      v_h_rec_type             VARCHAR2 (1)       := 'H';
      v_ind                    VARCHAR2 (1)       := 'I';
      v_ind1                   VARCHAR2 (1)       := ' ';
      v_dun_num                VARCHAR2 (11)      := '00946783222';
      v_store_id               VARCHAR2 (5)       := null;
      v_doc_date               VARCHAR2 (6)
            := to_char (sysdate, 'MMDDYY');
      v_doc_num                VARCHAR2 (15);
      v_cost_amt               VARCHAR2 (11)      := '0';
      v_l_cost_amt             VARCHAR2 (11)      := '0';
      v_po_num                 VARCHAR2 (10)      := '0000000000';
      v_dept_num               VARCHAR2 (3)       := '018';
      v_doc_due                VARCHAR2 (6)       := null;
      v_filler2                VARCHAR2 (6);
      v_filler4                VARCHAR2 (6);
      v_filler6                VARCHAR2 (6);
      v_filler15               VARCHAR2 (15);
      v_filler27               VARCHAR2 (27);
      v_filler35               VARCHAR2 (35);
      v_filler112              VARCHAR2 (112);
      v_sell_val               VARCHAR2 (7)       := '0';
      v_tax                    VARCHAR2 (11);
      v_freight_amt            VARCHAR2 (11);
      v_mis_charge             VARCHAR2 (11);
      v_add_discount           VARCHAR2 (11);

      v_d_rec_type             VARCHAR2 (1)       := 'D';
      v_mops_item_num          VARCHAR2 (17);
      v_vendor_item_num        VARCHAR2 (13)      := '';
      v_quantity               VARCHAR2 (5);
      v_cost_per_item          VARCHAR2 (11)      := NULL;
      v_cost_extension         VARCHAR2 (11)      := NULL;
      v_sell_value_per_item    VARCHAR2 (7);
      v_sell_value_extension   VARCHAR2 (7);
      v_pack_desc              VARCHAR2 (11)      := '';

      v_t_rec_type             VARCHAR2 (1)       := 'T';
      v_trans_date             VARCHAR2 (6)
            := to_char (sysdate, 'MMDDYY');
      v_total_ind              VARCHAR2 (5)       := 'TOTAL';
      v_total_cost             VARCHAR2 (12)      := NULL;
      v_total_head_rec         VARCHAR2 (7);
      v_total_head_cost        VARCHAR2 (12)      := 0;

      v_h_line                 VARCHAR2 (1000);
      v_d_line                 VARCHAR2 (1000);
      v_t_line                 VARCHAR2 (1000);


      TYPE line_rec IS RECORD(
         store_id                      VARCHAR2 (5),
         mops_item_num                 VARCHAR2 (17),
         vendor_item_num               VARCHAR2 (13),
         cost_per_item                 NUMBER,
         sell_val_per_item             NUMBER,
         quantity                      NUMBER
      );

      TYPE head_summary_rec IS RECORD(
         store_id                      VARCHAR2 (5),
         total_cost_amt                NUMBER,
         total_sell_val                NUMBER
      );

      /* 09/17/01 Added for Phoenix Project */
      /* 01/24/02 Changes posa_swp_loc_act_card for x_posa_card*/
      CURSOR posa_item
      IS
         SELECT substr (toss_att_location, length (toss_att_location) - 4, 5)
                      store_id,
                xref.trac_item_num mops_item_num,
                tf_part_num_parent vendor_item_num, count (1) sum1
           FROM x_trac_kmart_cross_ref xref, x_posa_card ps
          WHERE ps.tf_part_num_parent = xref.trac_item_num
            AND ps.toss_posa_date =
                   (SELECT max (toss_posa_date)
                      FROM x_posa_card ps2
                     WHERE ps2.toss_posa_action = 'SWIPE'
                       AND ps.toss_site_id = ps2.toss_site_id
                       AND ps.tf_part_num_parent = ps2.tf_part_num_parent
                       AND ps.tf_serial_num = ps2.tf_serial_num)
            AND ps.toss_site_id IN ('8461',  '5461')
            AND ps.toss_posa_action = 'SWIPE'
            AND ps.toss_posa_date BETWEEN v_start_date AND v_end_date
          GROUP BY toss_att_location,  xref.trac_item_num,  tf_part_num_parent;
/*  commented out: 09/17/01 Phoenix Project Change */
--110201
/*    cursor posa_item is
    select substr(store_id,length(store_id)-4,5) store_id,
               part_number mops_item_num,
               part_number vendor_item_num,
              sum(quantity) sum1
        from topp_oci_redeem_interface a
        where a.redemp_date = ( select max(redemp_date)
                       from topp_oci_redeem_interface b
                       where a.part_number = b.part_number
                       and  a.serial_number = b.serial_number
             and b.icreate_by = 'POSA')
        and  store_id is not null
        and  redemp_date between v_start_date and v_end_date
        and  icreate_by = 'POSA'
        and  attribute4='SWIPE'
        and  customer_id in ('8461', '5461')
        group by store_id,part_number; */

      --line_rec posa_item%rowtype;
      TYPE line_rec_tab IS TABLE OF line_rec
         INDEX BY BINARY_INTEGER;

      line_tab                 line_rec_tab;

      TYPE head_summary_tab_t IS TABLE OF head_summary_rec
         INDEX BY BINARY_INTEGER;

      head_summary_tab         head_summary_tab_t;
      i                        NUMBER             := 0;
      j                        NUMBER             := 0;
   BEGIN
      --  dbms_output.disable;
      dbms_output.enable (1000000);
      v_doc_due := to_char (sysdate + p_date_adjust, 'MMDDYY');
      j := 0;
      v_store_id := null;
      v_filler2 := p_from_varchar2 (' ', 2);
      v_filler4 := p_from_varchar2 (' ', 4);
      v_filler6 := p_from_varchar2 (' ', 6);
      v_filler15 := p_from_varchar2 (' ', 15);
      v_filler27 := p_from_number (0, 27);
      v_filler35 := p_from_varchar2 (' ', 35);
      v_filler112 := p_from_varchar2 (' ', 112);
      v_po_num := p_from_number (0, 10);
      v_pack_desc := p_from_varchar2 (' ', 11);
      v_tax := p_from_number (0, 11);
      v_freight_amt := p_from_number (0, 11);
      v_mis_charge := p_from_number (0, 11);
      v_add_discount := p_from_number (0, 11);


      FOR posa_item_rec IN posa_item
      LOOP
         line_tab (i).store_id := posa_item_rec.store_id;
         line_tab (i).vendor_item_num := posa_item_rec.vendor_item_num;
         get_part_info (
            line_tab (i).vendor_item_num,
            line_tab (i).cost_per_item,
            line_tab (i).sell_val_per_item,
            line_tab (i).mops_item_num
         );
         line_tab (i).quantity := posa_item_rec.sum1;

         IF (   v_store_id IS NULL
             OR v_store_id <> posa_item_rec.store_id) THEN
            IF v_store_id IS NOT NULL THEN
               j := j + 1;
            END IF;

            v_store_id := posa_item_rec.store_id;
            head_summary_tab (j).store_id := v_store_id;
            head_summary_tab (j).total_cost_amt :=
               posa_item_rec.sum1 * line_tab (i).cost_per_item;
            head_summary_tab (j).total_sell_val :=
               posa_item_rec.sum1 * line_tab (i).sell_val_per_item;
         ELSIF v_store_id = posa_item_rec.store_id THEN
            head_summary_tab (j).total_cost_amt :=
               head_summary_tab (j).total_cost_amt +
               posa_item_rec.sum1 * line_tab (i).cost_per_item;
            head_summary_tab (j).total_sell_val :=
               head_summary_tab (j).total_sell_val +
               posa_item_rec.sum1 * line_tab (i).sell_val_per_item;
         END IF;

         v_total_head_cost :=
            to_char (
               to_number (v_total_head_cost) +
               (posa_item_rec.sum1 * line_tab (i).cost_per_item)
            );
         i := i + 1;
      END LOOP;

      -- 110201 v_cost_amt := replace(v_cost_amt,'.','');
      -- 110201 v_cost_amt := p_from_number(to_number(v_cost_amt),11);
      -- 110201 v_sell_val:= p_from_number(round(to_number(v_sell_val)),7);
      v_output_file := utl_file.fopen (v_output_path, v_file_name, 'w');

      v_store_id := NULL;
      j := 0;

      FOR i IN 0 .. line_tab.count - 1
      LOOP
         IF (   v_store_id IS NULL
             OR (v_store_id <> line_tab (i).store_id)) THEN
            IF v_store_id IS NOT NULL THEN
               j := j + 1;
            END IF;

            v_store_id := line_tab (i).store_id;
            v_doc_num := to_char (sysdate, 'YY') ||
                         to_char (v_start_date, 'MMDD') ||
                         to_char (v_end_date, 'MMDD') ||
                         v_store_id;
            v_doc_num := p_from_varchar2 (v_doc_num, 15);   --
            -- 110201 v_cost_amt := replace(head_summary_tab(j).total_cost_amt,'.','');
            -- 110201 v_cost_amt := p_from_number(v_cost_amt,11);
            v_cost_amt :=
               p_from_number (head_summary_tab (j).total_cost_amt, 11);
            v_sell_val :=
               p_from_number (
                  ceil (head_summary_tab (j).total_sell_val / 100),
                  7
               );
            v_h_line := v_h_rec_type ||
                        v_ind ||
                        v_dun_num ||
                        v_store_id ||
                        v_doc_num ||
                        v_doc_date ||
                        v_cost_amt ||
                        v_po_num ||
                        v_dept_num ||
                        v_doc_due ||
                        v_filler6 ||
                        v_sell_val ||
                        v_filler35 ||
                        v_tax ||
                        v_freight_amt ||
                        v_mis_charge ||
                        v_add_discount;
            utl_file.put_line (v_output_file, v_h_line);
         END IF;


         v_store_id := p_from_varchar2 (v_store_id, 5);
         v_doc_num := to_char (sysdate, 'YY') ||
                      to_char (v_start_date, 'MMDD') ||
                      to_char (v_end_date, 'MMDD') ||
                      v_store_id;
         v_doc_num := p_from_varchar2 (v_doc_num, 15);
         v_mops_item_num := p_from_varchar2 (line_tab (i).mops_item_num, 17);
         v_vendor_item_num :=
            p_from_varchar2 (line_tab (i).vendor_item_num, 13);
         v_quantity := P_from_number (to_char (line_tab (i).quantity), 5);
         -- 110201 v_cost_per_item  := replace(line_tab(i).cost_per_item,'.','');
         -- 110201 v_cost_per_item    := p_from_number(v_cost_per_item,11);
         -- 110201 v_cost_extension := replace(v_cost_extension,'.','');
         v_cost_per_item := p_from_number (line_tab (i).cost_per_item, 11);
         v_cost_extension := v_quantity * line_tab (i).cost_per_item;
         v_cost_extension := p_from_number (v_cost_extension, 11);
         /* v_sell_value_extension := v_quantity*v_sell_value_per_item; */
         /* v_sell_value_per_item := replace(line_tab(i).sell_val_per_item,'.',''); */
         /* v_sell_value_per_item := p_from_number(v_sell_value_per_item,7); */
         -- 110201 v_sell_value_per_item := replace(ceil(line_tab(i).sell_val_per_item),'.','');
         -- 110201 v_sell_value_extension := v_quantity*v_sell_value_per_item;
         -- 110201 v_sell_value_extension := replace(v_sell_value_extension,'.','');
         v_sell_value_extension :=
            ceil (v_quantity * line_tab (i).sell_val_per_item / 100);
         v_sell_value_per_item :=
            p_from_number (ceil (line_tab (i).sell_val_per_item / 100), 7);
         v_sell_value_extension := p_from_number (v_sell_value_extension, 7);
         v_pack_desc := p_from_varchar2 (v_pack_desc, 11);
         v_d_line := v_d_rec_type ||
                     v_ind ||
                     v_dun_num ||
                     v_store_id ||
                     v_doc_num ||
                     v_filler27 ||
                     v_mops_item_num ||
                     v_vendor_item_num ||
                     v_quantity ||
                     v_cost_per_item ||
                     v_cost_extension ||
                     v_sell_value_per_item ||
                     v_filler4 ||
                     v_sell_value_extension ||
                     v_pack_desc ||
                     v_filler15;
         utl_file.put_line (v_output_file, v_d_line);
      END LOOP;


      v_filler112 := p_from_varchar2 (' ', 112);
      dbms_output.put_line ('v_total_head_cost: ' || v_total_head_cost);
      -- 110201 v_total_head_cost := replace(v_total_head_cost,'.','');
      v_total_head_cost := p_from_number (v_total_head_cost, 12);
      v_total_head_rec := p_from_number (head_summary_tab.count, 7);

      IF line_tab.count > 0 THEN
         v_t_line := v_t_rec_type ||
                     v_ind1 ||
                     v_dun_num ||
                     v_trans_date ||
                     v_filler2 ||
                     v_total_ind ||
                     v_filler2 ||
                     v_total_head_rec ||
                     v_filler2 ||
                     v_total_head_cost ||
                     v_filler112;
      END IF;

      utl_file.put_line (v_output_file, v_t_line);
      utl_file.fclose (v_output_file);
      dbms_output.put_line (
         'Process Completed. Location of output: ' ||
         v_output_path ||
         '/' ||
         v_file_name
      );

   EXCEPTION
      WHEN utl_file.invalid_path THEN
         dbms_output.put_line ('invalid_path error');
         dbms_output.put_line (
            'file path:' || v_output_path || ' :  ' || v_file_name
         );
         NULL;
         utl_file.fclose (v_output_file);

      WHEN utl_file.invalid_operation THEN
         dbms_output.put_line (
            'invalid_operation for file ' || v_output_path || '/' || v_file_name
         );
         NULL;
         utl_file.fclose (v_output_file);
      --when invalid_length then
      --dbms_output.put_line('invalid_length: The line length read from file '
      --        || v_output_path ||'/'||v_file_name || ' is too long.');
      --null;
      WHEN OTHERS THEN
         dbms_output.put_line ('others' || sqlerrm || ' ' || sqlcode);
         utl_file.fclose (v_output_file);
   END create_161_file;
--========================================================--
-- END OF create_161_file
--========================================================--
   FUNCTION P_From_Varchar2 (p_varchar2 VARCHAR2,  p_width NUMBER)
      RETURN VARCHAR2
   IS
      v_text   VARCHAR2 (2000);
   BEGIN
      v_text := rpad (nvl (ltrim (rtrim (p_varchar2)), ' '), p_width, ' ');
      RETURN (v_text);
   END P_From_Varchar2;
-- *******************
   FUNCTION P_From_Number (p_number NUMBER,  p_width NUMBER)
      RETURN VARCHAR2
   IS
      v_text   VARCHAR2 (2000);
   BEGIN
      v_text := lpad (nvl (to_char (p_number), ' '), p_width, '0');
      RETURN (v_text);
   END P_From_Number;
-- *******************
   PROCEDURE get_part_info (
      p_part_num              VARCHAR2,
      p_cost            OUT   NUMBER,
      p_sell_value      OUT   NUMBER,
      p_mops_item_num   OUT   VARCHAR2
   )
   IS
   BEGIN
      --110201
      -- trac_sell_price*100
      -- kmart_sell_price*100
      SELECT nvl (trac_sell_price * 100, 0),
             nvl (kmart_sell_price * 100, 0), kmart_item_num
        INTO p_cost,
             p_sell_value, p_mops_item_num
        FROM x_trac_kmart_cross_ref
       WHERE trac_item_num = p_part_num;
   EXCEPTION
      WHEN OTHERS THEN
         p_cost := 0;
         p_sell_value := 0;
         p_mops_item_num := NULL;
   END get_part_info;
END POSA_KMART_161_PKG;
/