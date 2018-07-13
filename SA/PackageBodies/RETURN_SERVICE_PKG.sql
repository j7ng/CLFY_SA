CREATE OR REPLACE PACKAGE BODY sa.RETURN_SERVICE_PKG
IS
/*******************************************************************************************************
 * --$RCSfile: RETURN_SERVICE_PKB.sql,v $
 --$Revision: 1.68 $
 --$Author: sinturi $
 --$Date: 2018/03/01 20:12:05 $
 --$ $Log: RETURN_SERVICE_PKB.sql,v $
 --$ Revision 1.68  2018/03/01 20:12:05  sinturi
 --$ update
 --$
 --$ Revision 1.67  2018/03/01 16:06:00  sinturi
 --$ updated
 --$
 --$ Revision 1.66  2018/02/28 17:52:32  sinturi
 --$ updated
 --$
 --$ Revision 1.64  2018/02/27 22:33:38  sinturi
 --$ updated logic
 --$
 --$ Revision 1.59  2018/01/16 19:00:17  sinturi
 --$ Added accessory condition to update biz drder table
 --$
 --$ Revision 1.58  2017/12/08 17:32:25  sinturi
 --$ Added else condition for one case
 --$
 --$ Revision 1.57  2017/11/24 21:41:56  sinturi
 --$ Added qty condition
 --$
 --$ Revision 1.56  2017/11/24 18:05:23  sinturi
 --$ Added accessory proc
 --$
 --$ Revision 1.55  2017/11/22 15:23:10  sinturi
 --$ accewssory changes merged
 --$
 --$ Revision 1.54  2017/11/22 14:51:51  sinturi
 --$ Accessory changes added
 --$
 --$ Revision 1.53  2017/11/22 03:07:26  sinturi
 --$ Merged
 --$
 --$ Revision 1.52  2017/11/22 02:58:45  sinturi
 --$ Get_sim_status proc added
 --$
 --$ Revision 1.46  2017/08/04 16:20:11  smeganathan
 --$ code fixes for returns
 --$
 --$ Revision 1.45  2017/08/01 21:58:11  smeganathan
 --$ code fixes for returns
 --$
 --$ Revision 1.44  2017/08/01 21:16:49  smeganathan
 --$ code fixes for returns
 --$
 --$ Revision 1.43  2017/08/01 19:47:17  smeganathan
 --$ code fixes for returns
 --$
 --$ Revision 1.42  2017/07/31 17:58:29  smeganathan
 --$ code fixes for returns
 --$
 --$ Revision 1.41  2017/07/26 14:41:34  smeganathan
 --$ code fixes for returns
 --$
 --$ Revision 1.40  2017/07/24 20:59:33  smeganathan
 --$ code fixes for returns
 --$
 --$ Revision 1.39  2017/07/17 14:56:25  smeganathan
 --$ Code changes for Automated return of SIM and SOFTPINs
 --$
 --$ Revision 1.38  2016/10/11 22:50:05  nmuthukkaruppan
 --$ CR45294  - Validate In_RefundItem array is not empty
 --$
 --$ Revision 1.37  2016/07/28 18:41:54  nmuthukkaruppan
 --$ CR39912 - Smart_Pay Tax changes
 --$
 --$ Revision 1.36  2016/07/06 19:01:25  nmuthukkaruppan
 --$ CR39912 - Update to  BIZ_ORDER_DTL table (for TAS) when refund is inited for an respective Item.
 --$
 --$ Revision 1.35  2016/07/03 23:01:07  nmuthukkaruppan
 --$ CR39912 - The value for x_ics_applications for Refund transcations should be 'ics_credit'
 --$
 --$ Revision 1.34  2016/07/01 14:22:46  nmuthukkaruppan
 --$ CR39912 - Changes made to return the surcharge only if it is FULL return.
 --$
 --$ Revision 1.33  2016/06/29 15:02:35  nmuthukkaruppan
 --$ CR39912 - Changes made to have a check to not to allow the duplicate refunds for an item
 --$
 --$ Revision 1.31  2016/06/27 14:55:55  nmuthukkaruppan
 --$ CR33912 - Changes made to send the Postive Refund amount to CyberSource
 --$
 --$ Revision 1.29  2016/06/10 17:42:59  nmuthukkaruppan
 --$ CR39912 - Merged with Ebay Production code.
 --$
 --$ Revision 1.28  2016/06/08 19:32:54  nmuthukkaruppan
 --$ CR39912 - Adding 'REAUTH' in the RETURN eligibility check.
 --$
 --$ Revision 1.27 2016/06/07 16:24:12 nmuthukkaruppan
 --$ CR42915 - Ebay Integration - Added Last_Mod_Time in VOID_PIN proc
 --$
 --$ Revision 1.26 2016/06/06 16:50:56 nmuthukkaruppan
 --$ CR42915 - Enabling the retriggering of the return process
 --$
 --$ Revision 1.25 2016/06/03 17:51:03 nmuthukkaruppan
 --$ CR38620 - Ebay Integration - Changes made on REFUND TAX calculation.
 --$
 --$ Revision 1.21 2016/05/23 18:55:27 nmuthukkaruppan
 --$ CR38620- eBay Changes - Adding ROLLBACK in the exception block.
 --$
 --$ Revision 1.20 2016/05/09 22:26:52 nmuthukkaruppan
 --$ CR38620 - Adding Credit_reason for RETURNS
 --$
 --$ Revision 1.18 2016/04/26 20:06:42 nmuthukkaruppan
 --$ CR 38620 - eBay Integration and Store Front Changes
 --$
 --$ Revision 1.17 2016/04/21 nmuthukkaruppan
 --$ CR 38620 - eBay Integration and Store Front
 --$
 --$ Revision 1.2 2015/10/20 nmuthukkaruppan
 --$ CR36886 - ST B2C Return Automation - Changes
 --$
 --$ Revision 1.1 2015/10/20 nmuthukkaruppan
 --$ CR33430 - ST B2C Return Automation - Initial Version
 * Description: This package is mainly for automating the Return process for B2C orders for Straight Talk, Ebay Integration
 * This package has five procedures is_tracfone, log_returntransaction, get_pin_status, process_refund, Void_PIN
 *
 * -----------------------------------------------------------------------------------------------------
 *******************************************************************************************************/
--This procedure will be called by SOA to find whether it is tracfone device.
PROCEDURE is_tracfone ( in_item        IN  RETURN_ITEM_TBL, --List of Items received for return
                        in_order_id    IN  VARCHAR2,
                        in_order_type  IN  VARCHAR2,
                        in_rma_id      IN  VARCHAR2,
                        in_stage       IN  VARCHAR2,
                        out_item       OUT RETURN_ITEM_TBL , --Is Tracfone (Y/N)
                        out_err_num    OUT NUMBER,
                        out_err_msg    OUT VARCHAR2,
                        out_warn_msg   OUT VARCHAR2 )
IS
  temp_arry      return_item_tbl := return_item_tbl ();
  l_sp_item      return_item_tbl := return_item_tbl (); -- CR51737
  input_validation_failed EXCEPTION;
  --
  CURSOR esn_cur (p_esn VARCHAR2)
  IS
    SELECT pi.part_serial_no as esn, 'Y' as is_tracfone
    FROM   table_part_num pn,
           table_mod_level ml,
           table_part_inst pi
    WHERE  1 = 1
    AND    ml.objid = pi.n_part_inst2part_mod
    AND    pn.objid = ml.part_info2part_num
    AND    pn.domain = 'PHONES'
    AND    pi.part_serial_no = p_esn;
  --
  CURSOR smp_cur (p_smp VARCHAR2)
  IS
    SELECT pi.part_serial_no as smp, 'Y' as is_tracfone
    FROM  table_part_inst pi,
          table_mod_level ml,
          table_part_num pn
    WHERE 1=1
    AND   pi.part_serial_no = p_smp
    AND   pi.x_domain||'' = 'REDEMPTION CARDS'
    AND   ml.objid = pi.n_part_inst2part_mod
    AND   pn.objid = ml.part_info2part_num
    AND   pn.domain = 'REDEMPTION CARDS'
    UNION
    SELECT pi.x_smp as smp, 'Y' as is_tracfone
    FROM  table_x_red_card pi,
          table_mod_level ml,
          table_part_num pn
    WHERE 1=1
    AND   pi.x_smp = p_smp
    AND   ml.objid = pi.x_red_card2part_mod
    AND   pn.objid = ml.part_info2part_num
    AND   pn.domain = 'REDEMPTION CARDS'
    UNION
    SELECT pi.x_part_serial_no as smp, 'Y' as is_tracfone
    FROM  table_x_posa_card_inv pi,
          table_mod_level ml,
          table_part_num pn
    WHERE 1=1
    AND   pi.x_part_serial_no = p_smp
    AND   ml.objid = pi.x_posa_inv2part_mod
    AND   pn.objid = ml.part_info2part_num
    AND   pn.domain = 'REDEMPTION CARDS';
  --
  CURSOR sim_cur  (p_sim  VARCHAR2)
  IS
    SELECT si.x_sim_serial_no  sim, 'Y' is_tracfone
    FROM   sa.table_x_sim_inv si,
           sa.table_mod_level ml,
           sa.table_part_num pn
    WHERE  si.x_sim_serial_no     = p_sim
    AND    si.X_sim_INV2PART_MOD  = ml.objid
    AND    ml.part_info2part_num  = pn.objid;
--
  esn_rec         esn_cur%ROWTYPE;
  smp_rec         smp_cur%ROWTYPE;
  sim_rec         sim_cur%ROWTYPE;
  p_Err_Num             NUMBER;
  p_Err_Msg             VARCHAR2 (500);
  l_status              NUMBER;
  l_isTracfoneCnt       NUMBER;
  -- CR51737 Starts..
  l_softpin_smp				  VARCHAR2(50);
  l_softpin_partnumber	VARCHAR2(50);
  l_esn						      VARCHAR2(50);
  l_sim						      VARCHAR2(50);
  l_softpin_unitprice   NUMBER  :=  0;
  l_lineitem_number    NUMBER  :=  0;
  -- CR51737 Ends.
  n_accessory_serial    VARCHAR2(50); -- CR54805
  type_pnt part_number_type := part_number_type(); -- CR54805
--
BEGIN
  l_isTracfoneCnt := 0;
  --
  /*SELECT SA.RETURN_ITEM_REC (NULL, NULL, NULL , NULL)
  BULK COLLECT INTO Out_Item
  FROM DUAL;*/
  out_item  :=  sa.return_item_tbl ();
  --NULL Check
  IF in_order_id IS NULL or in_rma_id IS NULL THEN
    out_err_num := 1;
    out_err_msg := 'Order id/RMA id cannot be NULL';
    raise input_validation_failed;
  ELSIF in_order_type IS NULL THEN
    out_err_num := 1;
    out_err_msg := 'Order Type cannot be NULL';
    raise input_validation_failed;
  ELSIF in_stage IS NULL THEN
    out_err_num := 1;
    out_err_msg := 'Stage cannot be NULL';
    raise input_validation_failed;
  END IF;
  --
  --Validating the List
  IF (in_item IS NULL OR in_item.count = 0) THEN
    out_err_num := 1;
    out_err_msg := 'List cannot be empty';
    raise input_validation_failed;
  ELSE
    FOR i_count IN in_item.FIRST .. in_item.LAST
    LOOP
      -- Reinitialize
      l_sp_item             :=  sa.return_item_tbl ();  -- CR51737
      l_softpin_smp				  :=  NULL;
      l_softpin_partnumber	:=  NULL;
      l_esn						      :=  NULL;
      l_sim						      :=  NULL;
      l_softpin_unitprice   :=  0;
      --
      l_lineitem_number  :=  l_lineitem_number + 1; -- CR51737
      --
      BEGIN

        IF in_item(i_count).esn IS NULL AND
           in_item(i_count).smp IS NULL AND
           in_item(i_count).sim IS NULL AND
           in_item(i_count).accessory_serial IS NULL -- CR54805
        THEN --Either ESN or SMP or SIM is required
          out_err_num := 1;
          out_err_msg := 'ESN, SIM and SMP cannot be NULL';
          raise input_validation_failed;
        -- Check if ESN belongs to Tracfone.
        ELSIF in_item(i_count).esn IS NOT NULL AND
              in_item(i_count).smp IS NULL  AND
              in_item(i_count).sim IS NULL AND
              in_item(i_count).accessory_serial IS NULL -- CR51737 CR54805
        THEN
          BEGIN
            IF esn_cur%ISOPEN THEN
              CLOSE esn_cur;
            END IF;
            --
            OPEN esn_cur (in_item(i_count).esn);
            FETCH esn_cur INTO esn_rec;
            --
            IF esn_cur%FOUND THEN
              l_istracfonecnt := l_istracfonecnt +1;
              --
              SELECT sa.return_item_rec (esn_rec.esn,             -- ESN
                                         NULL,                    -- SMP
                                         NULL,                    -- sim
                                         NULL,                    -- accessory number
                                         in_item(i_count).part_number,
                                         l_lineitem_number,
                                         esn_rec.is_tracfone,   -- is_tracfone
                                         0,                     -- softpin_unit_price
                                         in_item(i_count).softpin_check,
                                         'N'                    -- is_softpin
                                         )
              BULK COLLECT INTO out_item
              FROM DUAL;
              --
              CLOSE esn_cur;
              --
              -- CR51737 starts.. check for soft pin associated to ESN
              IF in_item(i_count).softpin_check = 'Y'
              THEN
                l_lineitem_number  :=  l_lineitem_number + 1;
                -- get the smp from order fullfilment table
                get_smp_details ( i_order_id      =>  in_order_id,
                                  io_sim          =>  l_sim,
                                  io_esn          =>  esn_rec.esn,
                                  o_smp           =>  l_softpin_smp,
                                  o_smp_partnum   =>  l_softpin_partnumber,
                                  o_smp_unitprice =>  l_softpin_unitprice,
                                  o_err_code      =>  out_err_num,
                                  o_err_msg       =>  out_err_msg);
                --
                SELECT sa.return_item_rec (NULL,                  -- ESN
                                           l_softpin_smp,         -- SMP
                                           NULL,                  -- sim
                                           NULL,                  -- Accessory Number
                                           l_softpin_partnumber,  -- part_number
                                           l_lineitem_number,
                                           'Y',                   -- is_tracfone
                                           l_softpin_unitprice,   -- softpin_unit_price
                                           In_Item(i_count).softpin_check,
                                           'Y'                    -- is_softpin
                                          )
                BULK COLLECT INTO l_sp_Item
                FROM DUAL;
              END IF;
              -- CR51737 ends.
              IF in_stage = 'PRE' THEN
                out_err_num := 0;
                out_err_msg := 'SUCCESS';
                EXIT ; -- Exit the loop if it find atleast one item belongs to Tracfone.
              END IF;
            ELSIF esn_cur%NOTFOUND AND in_stage = 'POST' THEN
              SELECT sa.return_item_rec (in_item(i_count).esn,       -- ESN
                                         NULL,                       -- SMP
                                         NULL,                       -- sim
                                         NULL,                       -- accessory number
                                         in_item(i_count).part_number,
                                         l_lineitem_number,
                                         'N',                         -- is_tracfone
                                         0,                           -- softpin_unit_price
                                         in_item(i_count).softpin_check,
                                         'N'                          -- is_softpin
                                         )
              BULK COLLECT INTO out_item
              FROM DUAL;
            ELSE
              SELECT sa.return_item_rec (in_item(i_count).esn,       -- ESN
                                         NULL,                       -- SMP
                                         NULL,                       -- sim
                                         NULL,                       -- accessory number
                                         in_item(i_count).part_number,
                                         l_lineitem_number,
                                         'N',                         -- is_tracfone
                                         0,                           -- softpin_unit_price
                                         in_item(i_count).softpin_check,
                                         'N'                          -- is_softpin
                                         )
              BULK COLLECT INTO out_item
              FROM DUAL;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              out_err_num := 1;
              out_err_msg := 'Error in ESN validation'|| (SUBSTR (SQLERRM, 1, 300));
              raise input_validation_failed;
          END;
        -- Check if SMP belongs to Tracfone.
        ELSIF in_item(i_count).smp IS NOT NULL AND
              in_item(i_count).esn IS NULL AND
              in_item(i_count).sim IS NULL AND
              in_item(i_count).accessory_serial IS NULL-- CR51737 CR54805
        THEN
          BEGIN
            IF smp_cur%ISOPEN THEN
              CLOSE smp_cur;
            END IF;
            --
            OPEN smp_cur (in_item(i_count).smp);
            FETCH smp_cur INTO smp_rec;
            --
            IF smp_cur%FOUND THEN
              l_istracfonecnt := l_istracfonecnt +1;
              SELECT sa.return_item_rec (NULL,                      -- ESN
                                         smp_rec.smp,               -- SMP
                                         NULL,                      -- sim
                                         NULL,                      -- accessory number
                                         in_item(i_count).part_number,
                                         l_lineitem_number,
                                         smp_rec.is_tracfone,   -- is_tracfone
                                         0,                     -- softpin_unit_price
                                         in_item(i_count).softpin_check,
                                         'N'                    -- is_softpin
                                         )
              BULK COLLECT INTO out_item
              FROM DUAL;

              CLOSE smp_cur;
              IF in_stage = 'PRE' THEN
                out_err_num := 0;
                out_err_msg := 'SUCCESS';
                EXIT ;
              END IF;
            ELSIF smp_cur%NOTFOUND AND in_stage = 'POST' THEN
              SELECT sa.return_item_rec (NULL,                     -- ESN
                                         in_item(i_count).smp,     -- SMP
                                         NULL,                     -- sim
                                         NULL,                     -- accessory number
                                         in_item(i_count).part_number,
                                         l_lineitem_number,
                                         'N',   -- is_tracfone
                                         0,                     -- softpin_unit_price
                                         in_item(i_count).softpin_check,
                                         'N'                    -- is_softpin
                                         )
              BULK COLLECT INTO out_item
              FROM DUAL;
            ELSE
              SELECT sa.return_item_rec (NULL,                     -- ESN
                                         in_item(i_count).smp,     -- SMP
                                         NULL,                     -- sim
                                         NULL,                     -- accessory number
                                         in_item(i_count).part_number,
                                         l_lineitem_number,
                                         'N',   -- is_tracfone
                                         0,                     -- softpin_unit_price
                                         in_item(i_count).softpin_check,
                                         'N'                    -- is_softpin
                                         )
              BULK COLLECT INTO out_item
              FROM DUAL;
            END IF;
          EXCEPTION
          WHEN OTHERS THEN
            out_err_num := 1;
            out_err_msg := 'Error in SMP validation'|| (SUBSTR (SQLERRM, 1, 300));
            raise input_validation_failed;
          END;
        -- CR51737 Check if sim belongs to Tracfone
        ELSIF in_item(i_count).smp IS NULL AND
              in_item(i_count).esn IS NULL AND
              in_item(i_count).sim IS NOT NULL AND
              in_item(i_count).accessory_serial IS NULL -- CR51737 CR54805
        THEN
          BEGIN
            IF sim_cur%ISOPEN THEN
              CLOSE sim_cur;
            END IF;
            --
            OPEN sim_cur (in_item(i_count).sim);
            FETCH sim_cur INTO sim_rec;
            --
            IF sim_cur%FOUND THEN
              l_istracfonecnt := l_istracfonecnt +1;
              SELECT sa.return_item_rec (NULL,                  -- ESN
                                         NULL,                  -- SMP
                                         sim_rec.sim,           -- sim
                                         NULL,                  -- accessory number
                                         in_item(i_count).part_number,
                                         l_lineitem_number,
                                         sim_rec.is_tracfone,   -- is_tracfone
                                         0,                     -- softpin_unit_price
                                         in_item(i_count).softpin_check,
                                         'N'                    -- is_softpin
                                         )
              BULK COLLECT INTO out_item
              FROM DUAL;
              --
              CLOSE sim_cur;
              --
              IF in_item(i_count).softpin_check = 'Y'
              THEN
                l_lineitem_number  :=  l_lineitem_number + 1;
                -- get the smp from order fullfilment table
                get_smp_details ( i_order_id      =>  in_order_id,
                                  io_sim          =>  sim_rec.sim,
                                  io_esn          =>  l_esn,
                                  o_smp           =>  l_softpin_smp,
                                  o_smp_partnum   =>  l_softpin_partnumber,
                                  o_smp_unitprice =>  l_softpin_unitprice,
                                  o_err_code      =>  out_err_num,
                                  o_err_msg       =>  out_err_msg);
                --
                SELECT sa.return_item_rec (NULL,                  -- ESN
                                           l_softpin_smp,         -- SMP
                                           NULL,                  -- sim
                                           NULL,                  -- Accessory Number
                                           l_softpin_partnumber,  -- part_number
                                           l_lineitem_number,
                                           'Y',                   -- is_tracfone
                                           l_softpin_unitprice,   -- softpin_unit_price
                                           in_item(i_count).softpin_check,
                                           'Y'                    -- is_softpin
                                          )
                BULK COLLECT INTO l_sp_Item
                FROM DUAL;
              END IF;
              --
              IF in_stage = 'PRE' THEN
                out_err_num := 0;
                out_err_msg := 'SUCCESS';
                EXIT ;
              END IF;
            ELSIF sim_cur%NOTFOUND AND In_Stage = 'POST' THEN
              SELECT sa.return_item_rec (NULL,                    -- ESN
                                         NULL,                    -- SMP
                                         in_item(i_count).sim,    -- sim
                                         NULL,                    -- accessory number
                                         in_item(i_count).part_number,
                                         l_lineitem_number,
                                         'N',
                                         0,
                                         in_item(i_count).softpin_check,
                                         'N'
                                         )
              BULK COLLECT INTO out_item
              FROM DUAL;
            ELSE
              SELECT sa.return_item_rec (NULL,                    -- ESN
                                         NULL,                    -- SMP
                                         in_item(i_count).sim,    -- sim
                                         NULL,                    -- accessory number
                                         in_item(i_count).part_number,
                                         l_lineitem_number,
                                         'N',
                                         0,
                                         in_item(i_count).softpin_check,
                                         'N'
                                         )
              BULK COLLECT INTO out_item
              FROM DUAL;
            END IF;
          EXCEPTION
          WHEN OTHERS THEN
            out_err_num := 1;
            out_err_msg := 'Error in SMP validation'|| (SUBSTR (SQLERRM, 1, 300));
            raise input_validation_failed;
          END;
	-- CR54805 Start
        ELSIF in_item(i_count).smp IS NULL AND
              in_item(i_count).esn IS NULL AND
              in_item(i_count).sim IS NULL AND
              in_item(i_count).accessory_serial IS NOT NULL
        THEN
          IF type_pnt.exist( i_part_number => in_item(i_count).part_number,
                             i_domain      => 'ACC' )
          THEN
		    l_istracfonecnt := l_istracfonecnt +1;
            SELECT sa.return_item_rec (NULL,                  -- ESN
                                       NULL,                  -- SMP
                                       NULL,                  -- sim
                                       in_item(i_count).accessory_serial,  -- accessory number
                                       in_item(i_count).part_number,
                                       l_lineitem_number,
                                       'Y',                   -- is_tracfone
                                       0,                     -- softpin_unit_price
                                       in_item(i_count).softpin_check,
                                       'N'                    -- is_softpin
                                      )
            BULK COLLECT INTO out_item
            FROM DUAL;
             --
            IF in_stage = 'PRE' THEN
               out_err_num := 0;
               out_err_msg := 'SUCCESS';
               EXIT ;
            END IF;
          ELSIF NOT type_pnt.exist( i_part_number => in_item(i_count).part_number,
                                      i_domain      => 'ACC' ) AND
                In_Stage = 'POST'
          THEN
            SELECT sa.return_item_rec (NULL,                  -- ESN
                                       NULL,                  -- SMP
                                       NULL,                  -- sim
                                       in_item(i_count).accessory_serial,  -- accessory number
                                       in_item(i_count).part_number,
                                       l_lineitem_number,
                                       'N',                   -- is_tracfone
                                       0,                     -- softpin_unit_price
                                       in_item(i_count).softpin_check,
                                       'N'                    -- is_softpin
                                       )
            BULK COLLECT INTO out_item
            FROM DUAL;
          ELSE
            SELECT sa.return_item_rec (NULL,                  -- ESN
                                       NULL,                  -- SMP
                                       NULL,                  -- sim
									   in_item(i_count).accessory_serial,  -- accessory number
                                       in_item(i_count).part_number,
                                       l_lineitem_number,
                                       'N',                   -- is_tracfone
                                       0,                     -- softpin_unit_price
                                       in_item(i_count).softpin_check,
                                       'N'                    -- is_softpin
                                       )
            BULK COLLECT INTO out_item
            FROM DUAL;
          END IF;
          -- CR54805 End
        END IF;
        --
        /*
        IF temp_Arry.count = 0 THEN
          temp_Arry.extend (In_Item.count);
        END IF;
        */
        temp_arry.extend; -- CR51737
        --
        --Collecting list of status in an array.
        --temp_Arry (i_count):= out_item (1);
        temp_arry (temp_arry.COUNT):= out_item (1);
        --
        -- CR51737 Changes starts..
        IF l_sp_Item  IS NOT NULL
        THEN
          IF l_sp_Item.COUNT > 0
          THEN
            temp_arry.extend;
            temp_arry (temp_arry.COUNT)  :=  l_sp_Item (1);
            out_item.extend;
            out_item (out_item.COUNT)    :=  l_sp_Item (1);
          END IF;
        END IF;
        -- CR51737 Changes ends.
        --Capturing the list of status in Log table
        IF In_Order_Type = 'RETURN' AND In_Stage = 'POST'
        THEN
          log_returntransaction (
                                in_order_id             => in_order_id ,
                                in_rma_id               => in_rma_id ,
                                in_request_payload      => NULL ,
                                in_return_stage_code    => in_stage ,
                                in_return_status_code   => NULL ,
                                in_response_payload     => NULL ,
                                in_retrigger_stage      => NULL ,
                                in_comments             => NULL ,
                                in_refund_payload       => NULL ,
                                in_refund_stage_code    => NULL ,
                                in_refund_status_code   => NULL ,
                                in_refund_resp_payload  => NULL ,
                                in_returns_dtl          => out_item ,
                                out_err_num             => p_err_num ,
                                out_err_msg             => p_err_msg );
          --
          --Logging errors are captured and shown in Out_Warn_Msg variable, it won't stop the return flow.
          IF p_err_num <> 0 THEN
            out_warn_msg := 'Error in Logging X_Return_Log_Dtl- POSTVAL - '|| p_Err_msg;
          END IF;
        END IF;
      END;
    END LOOP;
    --
    IF NVL(out_err_num,0) = 0 THEN
      l_status := 0; --Success
    ELSE
      l_status := 1; --Failure
    END IF;
    --
    --Failure staus for PRE Stage
    IF in_stage = 'PRE' AND l_istracfonecnt = 0 THEN
      l_status := 1;

      SELECT sa.return_item_rec (NULL, NULL, NULL ,NULL, NULL, NULL, 'N', 0, NULL, NULL)
      BULK COLLECT INTO Out_Item
      FROM DUAL;
    --Assigning list of statuses to Out variable.
    ELSIF in_stage = 'POST' THEN
      out_item := temp_arry ;
    END IF;
    --
    --Logging only if it 'RETURN'
    -- In_Return_Status_code NOT NULL indicates it just updates the STATUS alone in Log table.
    IF in_order_type = 'RETURN'
    THEN
      log_returntransaction (
                            in_order_id           => in_order_id ,
                            in_rma_id             => in_rma_id ,
                            in_request_payload    => NULL ,
                            in_return_stage_code  => in_stage ,
                            in_return_status_code => l_status ,
                            in_response_payload   => NULL ,
                            in_retrigger_stage    => NULL ,
                            in_comments           => NULL ,
                            in_refund_payload     => NULL ,
                            in_refund_stage_code  => NULL ,
                            in_refund_status_code => NULL ,
                            in_refund_resp_payload=> NULL ,
                            in_returns_dtl        => NULL ,
                            out_err_num           => p_err_num ,
                            out_err_msg           => p_err_msg
                            );
      --
      IF p_err_num <> 0 THEN
        out_warn_msg := 'Error in Logging X_Return_Log_Hdr - '|| p_err_msg;
      END IF;
    END IF;
  END IF;
  --
  out_err_num := 0;
  out_err_msg := 'SUCCESS';
  --
EXCEPTION
 WHEN input_validation_failed THEN
	UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => 'Input validation Failed', IP_KEY => 'OrderId:'||In_Order_id || ', RMA Id:'||In_RMA_Id , IP_PROGRAM_NAME => 'SA.RETURN_SERVICE_PKG.is_tracfone', ip_error_text => OUT_Err_MSg);
  ROLLBACK;
 WHEN OTHERS THEN
  out_err_num := 1;
  out_err_msg := 'Exception in Is_Tracfone Proc'||SUBSTR (SQLERRM, 1, 300);
  UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => NULL, IP_KEY => 'OrderId:'||In_Order_id || ', RMA Id:'||In_RMA_Id , IP_PROGRAM_NAME => 'RETURN_SERVICE_PKG.is_tracfone', ip_error_text => OUT_Err_MSg);
  ROLLBACK;
END is_tracfone;
--
--This procedure will be called by SOA/Internally by Db to log each return transaction, stage, status and the payload.
PROCEDURE log_returntransaction( in_order_id            IN  VARCHAR2,
                                 in_rma_id              IN  VARCHAR2,
                                 in_request_payload     IN  CLOB ,
                                 in_return_stage_code   IN  VARCHAR2,
                                 in_return_status_code  IN  VARCHAR2,
                                 in_response_payload    IN  VARCHAR2,
                                 in_retrigger_stage     IN  VARCHAR2,
                                 in_comments            IN  VARCHAR2,
                                 in_refund_payload      IN  CLOB,
                                 in_refund_stage_code   IN  VARCHAR2,
                                 in_refund_status_code  IN  VARCHAR2,
                                 in_refund_resp_payload IN  CLOB,
                                 in_returns_dtl         IN  RETURN_ITEM_TBL,
                                 out_err_num            OUT NUMBER,
                                 out_err_msg            OUT VARCHAR2 )
IS
  --
  CURSOR valid_cur (in_order_id VARCHAR2, in_rma_id VARCHAR2, in_return_stage_code VARCHAR2)
  IS
  SELECT s.description
  FROM  x_return_log_hdr h,x_return_stage s
  WHERE h.Return_stage_code = s.return_stage_code
  AND   Order_id = in_order_id
  AND   RMA_ID = in_rma_id
  AND   h.Return_stage_code = in_return_stage_code;
  --
  valid_rec       valid_cur%ROWTYPE;
  --
  l_logHdrObjid   x_return_log_hdr.objid%type;
  is_exist        NUMBER;
  input_validation_failed EXCEPTION;
  --
  PRAGMA AUTONOMOUS_TRANSACTION;
  --
BEGIN
  --NULL Check
  IF in_order_id IS NULL or in_rma_id IS NULL THEN
    out_err_num := 1;
    out_err_msg := 'Order id/RMA id cannot be NULL';
    raise Input_validation_Failed;
  ELSIF in_return_stage_code IS NULL AND in_refund_stage_code IS NULL THEN
    out_err_num := 1;
    out_err_msg := 'Both Return/Refund Stage cannot be NULL';
    raise Input_validation_Failed;
  END IF;
  --
  --Logging Return Response (payload)
  IF in_return_stage_code = 'RET' THEN
    BEGIN
      UPDATE x_return_log_hdr
      SET   response_payload = in_response_payload,
            comments = Decode (in_comments,NULL,comments,in_comments),
            modified_date = SYSDATE
      WHERE order_id = in_order_id
      AND   rma_id = in_rma_id;
      --
      IF SQL%ROWCOUNT = 0 THEN
        out_err_num := 1;
        out_err_msg := 'Record not available to update the Response_Payload - X_Return_Log_Hdr ';
        raise input_validation_failed;
      END IF;
    EXCEPTION
    WHEN OTHERS THEN
      out_err_num := 1;
      out_err_msg := 'Error in updating Response_Payload - X_Return_Log_Hdr'||SUBSTR (SQLERRM, 1, 300);
      raise input_validation_failed;
    END;
  --PRE or POST stage having Status will fall into this
  ELSIF in_return_status_code IS NOT NULL AND in_return_stage_code <> 'ELG' THEN
    BEGIN
      UPDATE x_return_log_hdr
      SET   return_stage_code = in_return_stage_code,
            return_status_code = In_Return_Status_code,
            modified_date = SYSDATE
      WHERE order_id = in_order_id
      AND   rma_id = in_rma_id;
      --
      IF SQL%ROWCOUNT = 0 THEN
        out_err_num := 1;
        out_err_msg := 'Record not available to update the status - X_Return_Log_Hdr ';
        raise Input_validation_Failed;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
        out_err_num := 1;
        out_err_msg := 'Error in updating Status - X_Return_Log_Hdr'||SUBSTR (SQLERRM, 1, 300);
        raise Input_validation_Failed;
     END;
  ELSE
    --Logging when the Stage is 'ELG'
    IF in_return_stage_code = 'ELG'
    THEN
      BEGIN
        INSERT INTO x_return_log_hdr (objid,
                                      order_id,
                                      rma_id,
                                      request_payload,
                                      return_stage_code,
                                      return_status_code,
                                      response_payload,
                                      retrigger_stage,
                                      comments,
                                      created_date,
                                      modified_date)
          VALUES (  seq_x_return_log_hdr.NEXTVAL,
                    in_order_id,
                    in_rma_id,
                    in_request_payload,
                    in_return_stage_code,
                    in_return_status_code,
                    in_response_payload ,
                    in_retrigger_stage,
                    in_comments,
                    SYSDATE,
                    SYSDATE);
      EXCEPTION
        WHEN OTHERS THEN
          UPDATE x_return_log_hdr
          SET   request_payload     = in_request_payload,
                return_stage_code   = in_return_stage_code,
                return_status_code  = in_return_status_code,
                response_payload    = in_response_payload,
                retrigger_stage     = retrigger_stage + 1,
                comments            = 'Process Retrigged',
                modified_date       = SYSDATE
          WHERE order_id  = in_order_id
          AND   rma_id    =  in_rma_id;
      END;
    -- Logging POST validation results for each return item.
    ELSIF  in_return_stage_code = 'POST' THEN
      BEGIN
        SELECT objid
        INTO   l_logHdrObjid
        FROM   X_Return_Log_Hdr
        WHERE  Order_id  = in_order_id
        AND    rma_id  = in_rma_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          out_err_num := 1;
          out_err_msg := 'No data found - X_Return_Log_Hdr ';
          raise Input_validation_Failed;
        WHEN OTHERS THEN
          out_err_num := 1;
          out_err_msg := 'Error in fetching logHdrObjid '||SUBSTR (SQLERRM, 1, 300);
          raise Input_validation_Failed;
      END;
      --
      FOR each_rec IN 1 .. in_returns_dtl.COUNT
      LOOP
        UPDATE x_return_log_dtl
        SET   is_tracfone_flag  = in_returns_dtl(1).is_tracfone,
              modified_date     = SYSDATE
        WHERE return_log_hdr_objid  = l_loghdrobjid
        AND   part_number = in_returns_dtl(1).part_number
        AND   (esn  =  in_returns_dtl(each_rec).esn
              OR smp = in_returns_dtl(each_rec).smp
              OR sim = in_returns_dtl(each_rec).sim  -- CR51737
             OR accessory_serial = in_returns_dtl(each_rec).accessory_serial
              );
        --
        IF SQL%ROWCOUNT = 0 THEN
           BEGIN
             INSERT INTO x_return_log_dtl (objid,
                                           return_log_hdr_objid,
                                           part_number,
                                           esn,
                                           smp,
                                           sim,   -- CR51737
                                           accessory_serial, -- CR54805
                                           is_tracfone_flag,
                                           created_date,
                                           modified_date)
             VALUES ( seq_x_return_log_dtl.NEXTVAL,
                      l_loghdrobjid,
                      in_returns_dtl(each_rec).part_number,
                      in_returns_dtl(each_rec).esn,
                      in_returns_dtl(each_rec).smp,
                      in_returns_dtl(each_rec).sim,  -- CR51737
                      in_returns_dtl(each_rec).accessory_serial, -- CR54805
                      in_returns_dtl(each_rec).is_tracfone,
                      SYSDATE,
                      SYSDATE);
           EXCEPTION
             WHEN OTHERS THEN
               out_err_num := 1;
               out_err_msg := 'Error during  Insert - X_Return_Log_Dtl '||SUBSTR (SQLERRM, 1, 300);
               raise Input_validation_Failed;
           END;
        END IF;
      END LOOP;
      --
    END IF;
  END IF;
  --
  --Logging status for Refund Initiation
  IF In_Refund_Stage_code = 'REF-I' THEN
    BEGIN
      UPDATE x_return_log_hdr
      SET  refund_payload    = in_refund_payload,
           refund_stage_code = in_refund_stage_code,
           refund_status_code = in_refund_status_code,
           refund_resp_payload  = in_refund_resp_payload,
           comments           = in_comments,
           modified_date  = SYSDATE
      WHERE  order_id  = in_order_id
      AND  rma_id    =  in_rma_id;
      --
      IF SQL%ROWCOUNT = 0 THEN
        out_err_num := 1;
        out_err_msg := 'Record not available to update the Refund status -REF-I- X_Return_Log_Hdr ';
        raise Input_validation_Failed;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        out_err_num := 1;
        out_err_msg := 'Error in updating Refund Status - X_Return_Log_Hdr'||SUBSTR (SQLERRM, 1, 300);
        raise Input_validation_Failed;
    END;
  --Logging status for Refund Post
  ELSIF in_refund_stage_code = 'REF-P' THEN
    BEGIN
      UPDATE x_return_log_hdr
      SET  refund_resp_payload  = in_refund_resp_payload,
           refund_stage_code    = in_refund_stage_code,
           refund_status_code = in_refund_status_code,
           comments           = in_comments,
           modified_date  = SYSDATE
      WHERE  order_id  = in_order_id
      AND    rma_id    =  in_rma_id;
      --
      IF SQL%ROWCOUNT = 0 THEN
        out_err_num := 1;
        out_err_msg := 'Record not available to update the Refund status - REF-P - X_Return_Log_Hdr ';
        raise input_validation_failed;
      END IF;
    EXCEPTION
        WHEN OTHERS THEN
          out_err_num := 1;
          out_err_msg := 'Error in updating Refund Status -REF-P- X_Return_Log_Hdr'||SUBSTR (SQLERRM, 1, 300);
          raise input_validation_failed;
    END;
  --Logging VOID Status
  ELSIF in_refund_stage_code = 'VOID' THEN
    BEGIN
      UPDATE x_return_log_hdr
      SET  refund_stage_code  = in_refund_stage_code,
           refund_status_code = in_refund_status_code,
           comments           = in_comments,
           modified_date  = SYSDATE
      WHERE  order_id  = in_order_id
      AND    rma_id    =  in_rma_id;

       IF SQL%ROWCOUNT = 0 THEN
          out_err_num := 1;
          out_err_msg := 'Record not available to update the Refund status - VOID - X_Return_Log_Hdr ';
          raise Input_validation_Failed;
       END IF;
    EXCEPTION
        WHEN OTHERS THEN
          out_err_num := 1;
          out_err_msg := 'Error in updating Refund Status -VOID- X_Return_Log_Hdr'||SUBSTR (SQLERRM, 1, 300);
          raise Input_validation_Failed;
    END;
  END IF;
  --
  COMMIT;
  --
  out_err_num  := 0 ;
  out_err_msg  :='SUCCESS';
EXCEPTION
WHEN Input_validation_Failed THEN
  UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => 'Input validation Failed', IP_KEY => 'OrderId:'||in_order_id || ', RMA Id:'||in_rma_id , IP_PROGRAM_NAME => 'RETURN_SERVICE_PKG.log_returntransaction', ip_error_text => out_err_msg);
  ROLLBACK;
  WHEN OTHERS THEN
    out_err_num  := 1  ;
    out_err_msg  :=  'Exception in log_returntransaction '||SUBSTR (SQLERRM, 1, 300);
    UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => NULL, IP_KEY => 'OrderId:'||in_order_id || ', RMA Id:'||in_rma_id , IP_PROGRAM_NAME => 'RETURN_SERVICE_PKG.log_returntransaction', ip_error_text => out_err_msg);
    ROLLBACK;
END log_returntransaction;
--
--This procedure will be called by SOA to get the pin_status before processsing the return.
PROCEDURE  get_pin_status( in_order_id         IN  VARCHAR2,
                           in_rma_id           IN  VARCHAR2,
                           in_order_type       IN  VARCHAR2,
                           in_pin_status       IN  refund_tbl,
                           out_pin_status      OUT refund_tbl,
                           out_err_num         OUT NUMBER,
                           out_err_msg         OUT VARCHAR2,
                           out_warn_msg        OUT VARCHAR2 )
IS
--
  temp_arry  refund_tbl := refund_tbl ();
  --
  CURSOR pin_status_cur  (p_smp IN VARCHAR2)
  IS
  SELECT rc.x_smp as smp,
         rc.x_red_code as red_code,
         'REDEEMED' as pin_status
  FROM   sa.table_x_red_card rc
  WHERE  rc.x_smp = p_smp
  UNION
  SELECT pi.part_serial_no as smp,
         pi.x_red_code as red_code,
         (SELECT ct.x_code_name
          FROM table_x_code_table ct
          WHERE ct.x_code_number = pi.x_part_inst_status
         ) pin_status
  FROM   table_part_inst pi,
         table_mod_level ml,
         table_part_num pn
  WHERE  1=1
  AND    pi.part_serial_no   = p_smp
  AND    pi.x_domain||''     = 'REDEMPTION CARDS'
  AND    ml.objid            = pi.n_part_inst2part_mod
  AND    pn.objid            = ml.part_info2part_num
  AND    pn.domain           = 'REDEMPTION CARDS'
  UNION
  SELECT pi.x_part_serial_no as smp,
         pi.x_red_code as red_code,
         (SELECT ct.x_code_name
          FROM table_x_code_table ct
          WHERE ct.x_code_number = pi.x_posa_inv_status
         ) pin_status
  FROM   table_x_posa_card_inv pi,
         table_mod_level ml,
         table_part_num pn
  WHERE 1=1
  AND   pi.x_part_serial_no = p_smp
  AND   ml.objid            = pi.x_posa_inv2part_mod
  AND   pn.objid            = ml.part_info2part_num
  AND   pn.domain           = 'REDEMPTION CARDS';
  --
  pin_status_rec            pin_status_cur%ROWTYPE;
  --
BEGIN
  --
  out_pin_status  :=   sa.refund_tbl ();
  --NULL Check
  IF in_order_id IS NULL or in_rma_id IS NULL  THEN
    out_err_num    := 1;
    out_err_msg    := 'Order id/RMA id cannot be NULL';
    RETURN;
  ELSIF in_order_type IS NULL THEN
    out_err_num    := 1;
    out_err_msg    := 'Order Type cannot be NULL';
    RETURN;
  END IF;
  --Validations
  IF In_PIN_Status.count = 0 THEN
    out_err_num :=  1;
    out_err_msg  := 'List cannot be empty';
    RETURN;
  ELSE
    FOR i_count IN in_pin_status.FIRST .. in_pin_status.LAST
    LOOP
      BEGIN
        IF in_pin_status(i_count).smp IS NULL THEN
          out_err_num := 1;
          out_err_msg :=  'SMP cannot be NULL';
          RETURN;
        ELSE
          BEGIN
            IF pin_status_cur%ISOPEN THEN
               CLOSE pin_status_cur;
            END IF;
            --Get the Status of the PIN
            OPEN pin_status_cur (in_pin_status(i_count).smp);
            FETCH pin_status_cur INTO pin_status_rec;
            --
            IF pin_status_cur%FOUND
            THEN
              SELECT sa.refund_type( NULL, --esn
                                     pin_status_rec.smp, --smp
                                     NULL, --sim
                                     NULL, --accessory number
                                     in_pin_status(i_count).line_number, --line_number
                                     NULL, --part_number
                                     NULL, --unit_price
                                     NULL, --quantity
                                     NULL, --sales_taxamount
                                     NULL, --e911_taxamount
                                     NULL, --usf_taxamount
                                     NULL, --rcrf_taxamount
                                     NULL, --total_taxamount
                                     NULL, --total_amount
                                     pin_status_rec.pin_status --status
                                    )
              BULK COLLECT INTO out_pin_status
              FROM DUAL;
              --
              IF temp_arry.count = 0 THEN
                temp_arry.extend (in_pin_status.count);
              END IF;
              --Collecting PIN status in an array
              temp_Arry (i_count)  := out_pin_status (1);
              --
              --Capturing the status in Log table
              IF in_order_type = 'RETURN' THEN
                BEGIN
                  UPDATE x_return_log_dtl ld
                  SET    ld.pin_status = pin_status_rec.pin_status,
                         ld.modified_date = SYSDATE
                  WHERE  ld.return_log_hdr_objid IN
                                                ( SELECT lh.objid
                                                    FROM x_return_log_hdr lh
                                                   WHERE lh.order_id  = in_order_id
                                                     AND lh.rma_id    = in_rma_id
                                                     )
                  AND ld.smp  = pin_status_rec.smp;
                  --
                  IF SQL%ROWCOUNT = 0 THEN
                    out_warn_msg := 'Unable to update the PIN status - X_Return_Log_dtl'; -- Just a warning message wont stop the flow
                  END IF;
                  --
                END;
              END IF;
              CLOSE pin_status_cur;
            ELSIF pin_status_cur%NOTFOUND THEN
              out_err_num := 1;
              out_err_msg  := 'PIN Status not found';
              RETURN;
            END IF;
          EXCEPTION
           WHEN  OTHERS THEN
              out_err_num := 1;
              out_err_msg  := 'Error in Get_PIN_STATUS'|| (SUBSTR (SQLERRM, 1, 300));
              RETURN;
          END;
        END IF;
      END;
    END LOOP;
    --
    out_pin_status := temp_arry;
  END IF;
  --
  out_err_num := 0;
  out_err_msg  := 'SUCCESS';
  --
EXCEPTION
  WHEN OTHERS THEN
    out_err_num  := 1  ;
    out_err_msg  :=  'Exception in get_pin_status '||SUBSTR (SQLERRM, 1, 300);
    --UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => NULL, IP_KEY => 'OrderId:'||In_Order_id || ', RMA Id:'||In_RMA_Id , IP_PROGRAM_NAME => 'RETURN_SERVICE_PKG.get_pin_status', ip_error_text => OUT_Err_MSg);
    --ROLLBACK;
END get_pin_status;
--
--This procedure will be called by SOA to calculate and the amount to be refunded to the customer.
PROCEDURE process_refund( In_Order_id              IN  VARCHAR2,
                          In_RMA_Id                IN  VARCHAR2,
                          In_RefundItem            IN  REFUND_TBL,
                          IN_ICS_RCODE             IN  x_biz_purch_hdr.X_ICS_RCODE%TYPE,
                          IN_ICS_RFLAG             IN  x_biz_purch_hdr.X_ICS_RFLAG%TYPE,
                          IN_ICS_RMSG              IN  x_biz_purch_hdr.X_ICS_RMSG%TYPE,
                          IN_BILL_RCODE            IN  x_biz_purch_hdr.X_BILL_RCODE%TYPE,
                          IN_BILL_RFLAG            IN  x_biz_purch_hdr.X_BILL_RFLAG%TYPE,
                          IN_BILL_RMSG             IN  x_biz_purch_hdr.X_BILL_RMSG%TYPE,
                          IN_AUTH_REQUEST_ID       IN  x_biz_purch_hdr.X_AUTH_REQUEST_ID %TYPE,
                          In_bill_trans_ref_no     IN  x_biz_purch_hdr.x_bill_trans_ref_no%TYPE,  --CR39912
                          In_refundsettlement_flag IN  VARCHAR2,
                          Out_Objid                OUT NUMBER,
                          Out_ICSApplication       OUT VARCHAR2,
                          Out_FirstName            OUT VARCHAR2,
                          Out_LastName             OUT VARCHAR2,
                          Out_Ship_Address1        OUT VARCHAR2,
                          Out_Ship_Address2        OUT VARCHAR2,
                          Out_Ship_Zip             OUT VARCHAR2,
                          Out_Ship_city            OUT VARCHAR2,
                          Out_Ship_Country         OUT VARCHAR2,
                          Out_Ship_State           OUT VARCHAR2,
                          Out_AuthRequestId        OUT VARCHAR2,
                          Out_MerchantId           OUT VARCHAR2,
                          Out_MerchantRefNumber    OUT  VARCHAR2,
                          Out_refundItem           OUT REFUND_TBL,
                          Out_Stax_Tot             OUT NUMBER,
                          Out_E911_Tot             OUT NUMBER,
                          Out_RCRF_Tot             OUT NUMBER,
                          Out_USF_Tot              OUT NUMBER,
                          Out_Tax_Tot              OUT NUMBER,
                          Out_Total_Refund         OUT NUMBER,
                          Out_Err_Num              OUT NUMBER,
                          Out_Err_Msg              OUT VARCHAR2,
                          Out_Warn_Msg             OUT VARCHAR2 )
IS
  CURSOR biz_hdr_cur
  IS
    SELECT *
    FROM x_biz_purch_hdr
    WHERE c_orderid = In_Order_id
    AND UPPER (x_payment_type) in ('SETTLEMENT','REAUTH')
    AND x_status = 'SUCCESS';

  biz_hdr_rec biz_hdr_cur%ROWTYPE;

  CURSOR valid_cur
  IS
    SELECT *
    FROM x_biz_purch_hdr
    WHERE c_orderid        = In_Order_id
      AND rma_id           = In_RMA_Id
      AND UPPER (x_payment_type) IN ('REFUND')  --CR39912
	  AND x_status in ('SUCCESS','FAILED');
  valid_rec valid_cur%ROWTYPE;

  CURSOR refundpost_cur (p_rma_id VARCHAR2)
  IS
    SELECT *
    FROM x_biz_purch_hdr
    WHERE c_orderid        = In_Order_id
      AND rma_id           = p_rma_id
      AND UPPER (x_payment_type) IN ('REFUND')   --CR39912
	  AND x_status = 'PENDING';
  refundpost_rec refundpost_cur%ROWTYPE;

  CURSOR duplicate_refund_cur (p_esn varchar2,p_smp varchar2, p_sim varchar2)
  IS
    SELECT c_orderid,rma_id,d.*
    FROM x_biz_purch_hdr h, x_biz_purch_dtl d
    WHERE h.objid = d.BIZ_PURCH_DTL2BIZ_PURCH_HDR
      AND h.c_orderid        = In_Order_id
      AND ( d.X_ESN          = p_esn OR
            d.SMP            = p_smp OR
            d.sim            = p_sim  -- CR51737
            )
    AND UPPER (h.x_payment_type) IN ('REFUND')
    AND h.x_status in ('SUCCESS','PENDING');
  duplicate_refund_rec  duplicate_refund_cur%ROWTYPE;

  dtls_result_set  Biz_refund_dtl_tbl;

  l_order_type          VARCHAR2(25);
  l_authrequest_id      x_biz_purch_hdr.x_auth_request_id%TYPE;
  l_ics_applications    x_biz_purch_hdr.x_ics_applications%TYPE;
  l_payment_type        x_biz_purch_hdr.x_payment_type%TYPE;
  l_hdrobj_id           x_biz_purch_hdr.objid%TYPE;

  l_domain              x_biz_purch_dtl.domain%TYPE;
  l_sales_rate          x_biz_purch_dtl.sales_rate%TYPE;
  l_e911_rate           x_biz_purch_dtl.e911_rate%TYPE;
  l_usf_rate            x_biz_purch_dtl.usf_rate%TYPE;
  l_rcrf_rate           x_biz_purch_dtl.rcrf_rate%TYPE;
  l_dtlobj_id           x_biz_purch_dtl.objid%TYPE;
  l_salestax_amount     x_biz_purch_dtl.salestax_amount%TYPE;
  l_e911_tax_amount     x_biz_purch_dtl.x_e911_tax_amount%TYPE;
  l_usf_taxamount       x_biz_purch_dtl.x_usf_taxamount%TYPE;
  l_rcrf_tax_amount     x_biz_purch_dtl.x_rcrf_tax_amount%TYPE;
  l_total_tax_amount    x_biz_purch_dtl.total_tax_amount%TYPE;
  l_amount              x_biz_purch_dtl.x_amount%TYPE;
  l_amount_tot          x_biz_purch_dtl.x_amount%TYPE;
  l_total_amount        x_biz_purch_dtl.total_amount%TYPE;
  l_merchant_ref_number x_biz_purch_hdr.x_merchant_ref_number%TYPE;
  l_status              x_biz_purch_hdr.x_status%TYPE;
  l_bill_zip            x_biz_purch_hdr.x_bill_zip%TYPE;
  l_e911_surcharge      x_biz_purch_dtl.x_e911_tax_amount%TYPE;
  l_rqst_type           x_biz_purch_hdr.x_rqst_type%TYPE;

  l_stax_tot            x_biz_purch_hdr.x_sales_tax_amount%TYPE;
  l_e911_tot            x_biz_purch_hdr.x_e911_tax_amount%TYPE;
  l_usf_tot             x_biz_purch_hdr.x_usf_taxamount%TYPE;
  l_rcrf_tot            x_biz_purch_hdr.x_rcrf_tax_amount%TYPE;
  l_tax_tot             x_biz_purch_dtl.total_tax_amount%TYPE;
  l_total_refund        x_biz_purch_dtl.total_amount%TYPE;

  l_refund_issued       x_biz_purch_hdr.x_auth_amount%TYPE;
  l_max_refund_allowed  x_biz_purch_dtl.total_amount%TYPE;
  -- CR51737 changes starts..
  /*
  l_softpin_smp				  VARCHAR2(50);
  l_softpin_partnumber	VARCHAR2(50);
  l_esn						      VARCHAR2(50);
  l_sp_domain					  x_biz_purch_dtl.domain%TYPE;
  l_sp_unit_price				NUMBER;
  l_sp_sales_rate				x_biz_purch_dtl.sales_rate%TYPE;
  l_sp_e911_rate				x_biz_purch_dtl.e911_rate%TYPE;
  l_sp_usf_rate				  x_biz_purch_dtl.usf_rate%TYPE;
  l_sp_rcrf_rate				x_biz_purch_dtl.rcrf_rate%TYPE;
  l_sp_salestax_amount	x_biz_purch_dtl.salestax_amount%TYPE;
  l_sp_e911_tax_amount	x_biz_purch_dtl.x_e911_tax_amount%TYPE;
  l_sp_usf_taxamount		x_biz_purch_dtl.x_usf_taxamount%TYPE;
  l_sp_rcrf_tax_amount	x_biz_purch_dtl.x_rcrf_tax_amount%TYPE;
  l_sp_total_tax_amount	x_biz_purch_dtl.total_tax_amount%TYPE;
  l_sp_amount					  x_biz_purch_dtl.x_amount%TYPE;
  l_sp_total_amount			x_biz_purch_dtl.total_amount%TYPE;
  */
  -- CR51737 changes ends.
  l_duplicate_refund    VARCHAR2(1);
  l_order_totalqty      NUMBER;
  l_full_refund         VARCHAR2(1);
  l_Smartpay_flag       VARCHAR2(1);

  Input_validation_Failed     EXCEPTION;
  n_count               NUMBER := 0;
  c_rma_id                VARCHAR2(50);
  n_status_check        NUMBER := 0;
BEGIN

  --Initialization
  l_stax_tot        := 0;
  l_e911_tot        := 0;
  l_usf_tot         := 0;
  l_rcrf_tot        := 0;
  l_tax_tot         := 0;
  l_total_refund    := 0;

  out_stax_tot      := 0;
  out_e911_tot      := 0;
  out_usf_tot       := 0;
  out_rcrf_tot      := 0;
  out_tax_tot       := 0;
  out_total_refund  := 0;
  l_amount_tot      := 0;
  l_e911_surcharge  := 0;
  --
  Out_refundItem  :=  sa.REFUND_TBL(); -- CR51737
  --
  /*SELECT SA.REFUND_OUT_REC(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
  BULK COLLECT INTO Out_refundItem
  FROM DUAL;*/
  --
  -- NULL Check
  IF In_Order_id IS NULL or In_RMA_Id IS NULL THEN
    Out_Err_Num    := 1;
    Out_Err_Msg    := 'Order id/RMA id cannot be NULL';
    raise Input_validation_Failed;			--CR39912
  ELSIF IN_REFUNDSETTLEMENT_FLAG IS NULL THEN
    Out_Err_Num    := 1;
    Out_Err_Msg    := 'Settlement Flag cannot be NULL';
    raise Input_validation_Failed;
  END IF;
  --
  --Refund Initiate
  IF In_refundsettlement_flag = 'I'
  THEN
    --
    OPEN biz_hdr_cur;
    FETCH biz_hdr_cur INTO biz_hdr_rec;
    --
    --> Validation rule 1 - Checking if Original order exists:
    IF biz_hdr_cur%NOTFOUND THEN
      Out_Err_Num    := 1;
      Out_Err_Msg    := 'Order is not Eligible for RETURN/REFUND';
      CLOSE biz_hdr_cur;
      raise Input_validation_Failed;
    ELSE
      -->  Checking if refund already processed.
      OPEN valid_cur ;
      FETCH valid_cur INTO valid_rec;
      --
      IF valid_cur%FOUND
      THEN
        CLOSE valid_cur;
        IF valid_rec.x_status = 'SUCCESS' THEN
          Out_Err_Num      := 1;
          Out_Err_Msg      := 'Refund already processed';
		  raise Input_validation_Failed;

        ELSE
		  BEGIN
          SELECT COUNT(*),
		           SUM( CASE
                          WHEN x_status = 'FAILED'  THEN 0
                          WHEN x_status = 'SUCCESS' THEN 1
		               END)
		  INTO   n_count,
		         n_status_check
		  FROM   x_biz_purch_hdr
		  WHERE  c_orderid = In_Order_id
		  AND    RMA_Id LIKE In_RMA_Id||'%'
		  AND UPPER (x_payment_type) IN ('REFUND');
          EXCEPTION
          WHEN OTHERS
          THEN
            n_count := 0;
		    n_status_check := 0;
          END;
          --
          IF n_status_check > 0
          THEN
		    Out_Err_Num      := 1;
		    Out_Err_Msg      := 'Refund already processed';
		    raise Input_validation_Failed;
          END IF;
          IF n_count > 0 THEN
            c_rma_id := in_rma_id || '_' || n_count;
		  ELSE
            c_rma_id := in_rma_id;
		  END IF;

		END IF;
	  ELSE
		CLOSE valid_cur;
	    c_rma_id := in_rma_id;
	  END IF;
      --
      OPEN refundpost_cur (NVL(c_rma_id,in_rma_id));
      FETCH refundpost_cur INTO refundpost_rec;

      IF refundpost_cur%FOUND THEN
        CLOSE refundpost_cur;
        Out_Err_Num      := 1;
        Out_Err_Msg      := 'Refund already Initiated';
        --
        raise Input_validation_Failed;
      END IF;
	    CLOSE refundpost_cur;
      --CR45294  - Validate In_RefundItem array is not empty - to process further
      IF In_RefundItem.count = 0 THEN
        Out_Err_Num    := 1;
        Out_Err_Msg    := 'In_RefundItem list cannot be empty ';
        raise Input_validation_Failed;
      END IF;
      --
      -- PREPARING TO INSERT THE "REFUND INITIATE" RECORD:
      l_order_type          := 'RETURN';
      l_authrequest_id      := NULL;
      --CR39912
      l_ics_applications    := 'ics_credit';
      l_merchant_ref_number := biz_hdr_rec.X_MERCHANT_REF_NUMBER||'_CR_'||c_rma_id ;
      l_rqst_type           := SUBSTR(biz_hdr_rec.X_RQST_TYPE, 1, instr(biz_hdr_rec.X_RQST_TYPE,'_',1))||'REFUND';
      l_payment_type        :=  'REFUND';
      l_status              := 'PENDING';  --CR39912
      l_hdrobj_id           := sequ_biz_purch_hdr.NEXTVAL;
      --
      BEGIN
        INSERT
        INTO x_biz_purch_hdr
          (
            objid,
            x_rqst_source,
            channel,
            ecom_org_id,
            order_type,
            c_orderid,
            account_id,
            x_auth_request_id,
            groupidentifier,
            x_rqst_type,
            x_rqst_date,
            x_ics_applications,
            x_merchant_id,
            x_merchant_ref_number,
            x_auth_code,
            x_ics_rcode,
            x_ics_rflag,
            x_ics_rmsg,
            x_request_id,
            x_auth_request_token,
            x_bill_rcode,
            x_bill_rflag,
            x_bill_rmsg,
            x_customer_firstname,
            x_customer_lastname,
            x_customer_phone,
            x_customer_email,
            x_status,
            x_bill_address1,
            x_bill_address2,
            x_bill_city,
            x_bill_state,
            x_bill_zip,
            x_bill_country,
            x_ship_address1,
            x_ship_address2,
            x_ship_city,
            x_ship_state,
            x_ship_zip,
            x_ship_country,
            purch_hdr2creditcard,
            purch_hdr2bank_acct,
            purch_hdr2other_funds,
            prog_hdr2x_pymt_src,
            prog_hdr2web_user,
            x_payment_type,
            x_process_date,
            x_credit_reason,		--CR39912
            purch_hdr2altpymtsource,
            RMA_Id
          )
        VALUES
        (
        l_hdrobj_id,
        biz_hdr_rec.X_RQST_SOURCE,
        biz_hdr_rec.CHANNEL,
        biz_hdr_rec.ECOM_ORG_ID,
        l_order_type,
        biz_hdr_rec.C_ORDERID,
        biz_hdr_rec.ACCOUNT_ID,
        l_authrequest_id,
        biz_hdr_rec.GROUPIDENTIFIER,
        l_rqst_type,			--CR39912
        sysdate,
        l_ics_applications,
        biz_hdr_rec.X_MERCHANT_ID,
        l_merchant_ref_number,		--CR39912
        NULL,
        in_ics_rcode,			--CR39912
        in_ics_rflag,
        in_ics_rmsg,
        l_authrequest_id,		--CR39912
        biz_hdr_rec.X_AUTH_REQUEST_TOKEN,
        in_bill_rcode,
        in_bill_rflag,
        in_bill_rmsg,
        biz_hdr_rec.x_customer_firstname,
        biz_hdr_rec.x_customer_lastname,
        biz_hdr_rec.x_customer_phone,
        biz_hdr_rec.x_customer_email,
        l_status,				--CR39912
        biz_hdr_rec.x_bill_address1,
        biz_hdr_rec.x_bill_address2,
        biz_hdr_rec.x_bill_city,
        biz_hdr_rec.x_bill_state,
        biz_hdr_rec.x_bill_zip,
        biz_hdr_rec.x_bill_country,
        biz_hdr_rec.x_ship_address1,
        biz_hdr_rec.x_ship_address2,
        biz_hdr_rec.x_ship_city,
        biz_hdr_rec.x_ship_state,
        biz_hdr_rec.x_ship_zip,
        biz_hdr_rec.x_ship_country,
        biz_hdr_rec.purch_hdr2creditcard,
        biz_hdr_rec.purch_hdr2bank_acct,
        biz_hdr_rec.purch_hdr2other_funds,
        biz_hdr_rec.prog_hdr2x_pymt_src,
        biz_hdr_rec.prog_hdr2web_user,
        l_payment_type,
        SYSDATE,
        'CUSTOMER REFUND',		--CR39912
        biz_hdr_rec.purch_hdr2altpymtsource,
        c_rma_id
        );
      EXCEPTION
        WHEN OTHERS THEN
          Out_Err_Num      := 1;
          Out_Err_Msg := ( 'Cloning of purch_hdr record for Refund failed due to' || SQLERRM || '.');
          raise Input_validation_Failed;
      END;
      --
      Out_Objid          := l_hdrobj_id;
      Out_ICSApplication := l_ics_applications;
      Out_FirstName      := biz_hdr_rec.x_customer_firstname;
      Out_LastName       := biz_hdr_rec.x_customer_lastname;
      Out_Ship_Address1  := biz_hdr_rec.x_ship_address1;
      Out_Ship_Address2  := biz_hdr_rec.x_ship_address2;
      Out_Ship_Zip       := biz_hdr_rec.x_ship_zip;
      Out_Ship_city      := biz_hdr_rec.x_ship_city;
      Out_Ship_Country   := biz_hdr_rec.x_ship_country;
      Out_Ship_State     := biz_hdr_rec.x_ship_state;
      Out_AuthRequestId  := biz_hdr_rec.x_auth_request_id;
      Out_MerchantId     := biz_hdr_rec.X_MERCHANT_ID;
      Out_MerchantRefNumber  := l_merchant_ref_number;
      --
      l_bill_zip := SUBSTR(biz_hdr_rec.x_bill_zip,1,5);
      --
      BEGIN
        SELECT SUM(NVL(l.X_QUANTITY,0))
        INTO l_order_totalqty
        FROM x_biz_purch_dtl l
        WHERE l.BIZ_PURCH_DTL2BIZ_PURCH_HDR in (  select objid
                                                  from  x_biz_purch_hdr
                                                  where c_orderid   = In_Order_id
                                                  and   order_type  = 'ORDER'
                                                  and   x_payment_type in ('SETTLEMENT','REAUTH')
                                                  and   x_status = 'SUCCESS');
      EXCEPTION
         WHEN OTHERS THEN
          Out_Err_Num      := 1;
          Out_Err_Msg      := 'Error in fetching Total Order Quantity.';
          raise Input_validation_Failed;
      END;
      --
      DBMS_OUTPUT.PUT_LINE ('l_order_totalqty' || l_order_totalqty);
    END IF;
    -- PREPARING TO INSERT THE REFUND INITIATE DETAIL RECORDS:
    l_e911_surcharge  := 0;
    --
    FOR i IN In_RefundItem.FIRST .. In_RefundItem.LAST
    LOOP
      BEGIN
        l_sales_rate := 0;
        l_e911_rate := 0;
        l_usf_rate := 0;
        l_rcrf_rate := 0;
        --
        IF  In_RefundItem(i).ESN IS NULL AND
		    In_RefundItem(i).SMP IS NULL AND
			In_RefundItem(i).sim IS NULL AND
			In_RefundItem(i).accessory_serial IS NULL-- CR51737
        THEN
          Out_Err_Num      := 1;
          Out_Err_Msg      := 'ESN, SMP, Accessory and sim cannot be NULL';
          raise Input_validation_Failed;
        ELSIF  In_RefundItem(i).PART_NUMBER  IS NULL THEN
          Out_Err_Num      := 1;
          Out_Err_Msg      := 'Part Number cannot be Blank';
          raise Input_validation_Failed;
        ELSIF NVL(In_RefundItem(i).QUANTITY, 0) = 0 THEN
          Out_Err_Num      := 1;
          Out_Err_Msg      := 'Need Quantity For Each LineItem And It Can Not Be Zero.';
          raise Input_validation_Failed;
        /*
	    ELSIF NVL(In_RefundItem(i).UNIT_PRICE, 0) = 0 AND In_RefundItem(i).sim IS NULL -- Skip Zero validation for SIM
        THEN
          Out_Err_Num      := 1;
          Out_Err_Msg      := 'Need UnitPrice For Each LineItem And It Can Not Be Zero.';
          raise Input_validation_Failed;
		*/
        END IF;
        --
		   IF ( In_RefundItem(i).ESN IS NOT NULL OR
		        In_RefundItem(i).SMP IS NOT NULL OR
		        In_RefundItem(i).sim IS NOT NULL ) AND
          In_RefundItem(i).accessory_serial IS NULL
		   THEN

          -- Duplicate refund check
          OPEN duplicate_refund_cur (In_RefundItem(i).ESN,In_RefundItem(i).SMP, In_RefundItem(i).sim) ;-- CR51737
          FETCH duplicate_refund_cur INTO duplicate_refund_rec;
          --
          IF duplicate_refund_cur%FOUND THEN
            Out_Err_Num      := 1;
            Out_Err_Msg      := 'Refund already ISSUED/PENDING for the Item '||In_RefundItem(i).ESN||' '||In_RefundItem(i).SMP||' '||In_RefundItem(i).sim;
            CLOSE duplicate_refund_cur;
            raise Input_validation_Failed;
          END IF;
          CLOSE duplicate_refund_cur;
		    ELSIF In_RefundItem(i).accessory_serial IS NOT NULL
		    THEN
          accessory_validation_check ( in_order_id      =>  in_order_id,
                                       in_part_number   =>  In_RefundItem(i).part_number,
									                     in_quantity      =>  In_RefundItem(i).quantity,
                                       out_err_num      =>  out_err_num,
                                       out_err_msg      =>  out_err_msg
		                                  );
		      IF out_err_num <> 0
		      THEN
		        raise Input_validation_Failed;
          END IF;
		    END IF;
        --
        --Fetching tax rates from the Original order
        BEGIN
          SELECT  distinct domain, sales_rate, e911_rate, usf_rate, rcrf_rate
          INTO    l_domain, l_sales_rate, l_e911_rate, l_usf_rate, l_rcrf_rate
          FROM    x_biz_purch_dtl d
          WHERE   biz_purch_dtl2biz_purch_hdr = biz_hdr_rec.objid
          AND     part_number = In_RefundItem(i).PART_NUMBER;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
              Out_Err_Num      := 1;
              Out_Err_Msg      := 'PartNumber '||In_RefundItem(i).PART_NUMBER|| ' not found in the Original Order. Refund cannot be processed.';
              raise Input_validation_Failed;
          WHEN OTHERS THEN
              Out_Err_Num      := 1;
              Out_Err_Msg      := 'Error in fetching Orignal Order details.';
              raise Input_validation_Failed;
        END;
        --
        sp_checkorder(In_Order_Id,
                      'ALTSOURCE_PURCH' ,
                      'APPLICATION_KEY' ,
                      l_Smartpay_flag ,
                      Out_Err_Num,
                      Out_Err_Msg );
        --
        IF  In_RefundItem(i).ESN IS NULL AND  In_RefundItem(i).SMP IS NOT NULL THEN
          IF nvl(l_Smartpay_flag,'N') <> 'Y' THEN
             l_e911_surcharge  := sa.sp_taxes.computee911surcharge2(l_bill_zip);        -- as calculated as sp_taxes.calculate_taxes pkg.
             DBMS_OUTPUT.PUT_LINE ('Calculating e911_surcharge');
          END IF;
        END IF;

        --Calculating different taxes
        --CR39912  - for negative amounts
        l_salestax_amount := -1 * (ROUND(NVL(In_RefundItem(i).UNIT_PRICE * In_RefundItem(i).QUANTITY * l_sales_rate,0), 2))  ;
        l_e911_tax_amount := -1 * (ROUND(NVL(In_RefundItem(i).UNIT_PRICE * In_RefundItem(i).QUANTITY * l_e911_rate,0), 2))  ;
        l_usf_taxamount   := -1 * (ROUND(NVL(In_RefundItem(i).UNIT_PRICE * In_RefundItem(i).QUANTITY * l_usf_rate,0), 2))  ;
        l_rcrf_tax_amount := -1 * (ROUND(NVL(In_RefundItem(i).UNIT_PRICE * In_RefundItem(i).QUANTITY * l_rcrf_rate,0), 2))  ;
        --
        DBMS_OUTPUT.PUT_LINE ('l_order_totalqty' || l_order_totalqty|| 'i' ||i);
        --
        IF l_order_totalqty = i THEN
          l_full_refund := 'Y';
        ELSE
          l_full_refund := 'N';
        END IF;
        --
        IF l_full_refund = 'Y' AND i = l_order_totalqty THEN
          l_e911_tax_amount  := l_e911_tax_amount + (-1 *l_e911_surcharge) ;
        END IF;
        --
        l_total_tax_amount := l_salestax_amount + l_e911_tax_amount + l_usf_taxamount + l_rcrf_tax_amount ;
        l_amount          :=  -1 * (ROUND(NVL((In_RefundItem(i).UNIT_PRICE * In_RefundItem(i).QUANTITY),0),2));
        l_total_amount     :=  l_amount + l_total_tax_amount;
        --Cumulative tax total
        l_stax_tot      := l_stax_tot     + l_salestax_amount ;
        l_e911_tot      := l_e911_tot     + l_e911_tax_amount ;
        l_usf_tot       := l_usf_tot      + l_usf_taxamount ;
        l_rcrf_tot      := l_rcrf_tot     + l_rcrf_tax_amount ;
        l_tax_tot       := l_tax_tot      + l_total_tax_amount;
        l_amount_tot    := l_amount_tot   + l_amount;
        l_total_refund  := l_total_refund + l_total_amount;
        --
        out_stax_tot      := -1*l_stax_tot;
        out_e911_tot      := -1*l_e911_tot;
        out_usf_tot       := -1*l_usf_tot;
        out_rcrf_tot      := -1*l_rcrf_tot;
        out_tax_tot       := -1*l_tax_tot;
        out_total_refund  := -1*l_total_refund;
        --
        INSERT
        INTO x_biz_purch_dtl
          (
            objid,
            x_esn,
            smp,
            x_amount,
            line_number,
            part_number,
            biz_purch_dtl2biz_purch_hdr,
            x_quantity,
            domain,
            sales_rate,
            salestax_amount,
            e911_rate,
            x_e911_tax_amount,
            usf_rate,
            x_usf_taxamount,
            rcrf_rate,
            x_rcrf_tax_amount,
            total_tax_amount,
            total_amount,
            sim, -- CR51737
			      accessory_serial -- CR54805
          )
          VALUES
          (
            sequ_biz_purch_dtl.NEXTVAL,
            In_RefundItem(i).ESN,
            In_RefundItem(i).SMP,
            In_RefundItem(i).UNIT_PRICE * -1,		--CR39912
            In_RefundItem(i).LINE_NUMBER,
            In_RefundItem(i).PART_NUMBER,
            l_hdrobj_id,
            In_RefundItem(i).QUANTITY,
            l_domain,
            l_sales_rate,
            l_salestax_amount,
            l_e911_rate,
            l_e911_tax_amount,
            l_usf_rate,
            l_usf_taxamount,
            l_rcrf_rate,
            l_rcrf_tax_amount,
            l_total_tax_amount,
            l_total_amount,
            In_RefundItem(i).SIM, -- CR51737
            In_RefundItem(i).accessory_serial -- CR54805
          );
       EXCEPTION
         WHEN Input_validation_Failed THEN
            UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => 'Input validation Failed', IP_KEY => 'OrderId:'||In_Order_id || ', RMA Id:'||c_rma_id , IP_PROGRAM_NAME => 'RETURN_SERVICE_PKG.process_refund', ip_error_text => OUT_Err_MSg);
            ROLLBACK;
            RETURN;
        WHEN OTHERS THEN
            Out_Err_Num    := 1;
            Out_Err_Msg    := ( 'Insert Refund details into x_biz_purch_dtl failed due to' || SQLERRM);
            UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => 'Exception', IP_KEY => 'OrderId:'||In_Order_id || ', RMA Id:'||c_rma_id , IP_PROGRAM_NAME => 'RETURN_SERVICE_PKG.process_refund', ip_error_text => OUT_Err_MSg);
            ROLLBACK;
            RETURN;
      END;
      --
      DBMS_OUTPUT.PUT_LINE ('In_Order_id '|| In_Order_id|| 'l_hdrobj_id ' ||l_hdrobj_id ||' ESN '||In_RefundItem(i).ESN ||'SMP '||In_RefundItem(i).SMP);
      --
      UPDATE sa.X_BIZ_ORDER_DTL
      SET     BIZ_ORDER_DTL2BIZ_PURCH_HDR_CR = l_hdrobj_id
      WHERE   X_ECOM_ORDER_NUMBER  = In_Order_id
      AND     X_ITEM_VALUE in (In_RefundItem(i).ESN,In_RefundItem(i).SMP, In_RefundItem(i).sim,In_RefundItem(i).accessory_serial)
      AND     X_ITEM_PART = In_RefundItem(i).PART_NUMBER;
      --
      IF SQL%ROWCOUNT = 0 THEN
        OUT_Err_MSg  := 'Update to X_BIZ_ORDER_DTL failed';
        UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => NULL, IP_KEY => 'OrderId:'||In_Order_id || ', RMA Id:'||c_rma_id , IP_PROGRAM_NAME => 'RETURN_SERVICE_PKG.process_refund', ip_error_text => OUT_Err_MSg);
      END IF;
    END LOOP;
    --
    l_max_refund_allowed := biz_hdr_rec.x_auth_amount - biz_hdr_rec.freight_amount ;
    --
    IF l_max_refund_allowed + TRUNC(l_Total_Refund,1) < 0 THEN
      Out_Err_Num      := 1;
      Out_Err_Msg      := 'Refund Amount cannot be greater than Order Amount.';
      raise Input_validation_Failed;
    END IF;
    --
    --Updating the Cumulative Total in the Header.
    UPDATE  x_biz_purch_hdr hdr
    SET     x_amount            = l_amount_TOT,
            x_tax_amount        = l_tax_TOT,
            x_sales_tax_amount  = l_STAX_TOT,
            x_e911_tax_amount   = l_E911_TOT,
            x_usf_taxamount     = l_USF_TOT,
            x_rcrf_tax_amount   = l_RCRF_TOT,
            x_auth_amount       = l_Total_Refund,
            x_bill_amount       = NULL,
            hdr.freight_amount  = NULL
    WHERE   hdr.C_OrderId = In_Order_id
    AND     hdr.RMA_Id    = c_rma_id
    AND     UPPER (x_payment_type) IN ('REFUND');
    --
    BEGIN
      SELECT SUM(NVL(X_AUTH_AMOUNT,0)) * -1
      INTO  l_refund_issued
      FROM  x_biz_purch_hdr
      WHERE c_orderid   = In_Order_id
      AND   order_type = 'RETURN'
	  AND   x_status != 'FAILED';

    EXCEPTION
      WHEN OTHERS THEN
        Out_Err_Num      := 1;
        Out_Err_Msg      := 'Error in fetching Orignal Order details.';
        raise Input_validation_Failed;
    END;
    --
    DBMS_OUTPUT.PUT_LINE ('l_refund_issued' || l_refund_issued);
    DBMS_OUTPUT.PUT_LINE ('TRUNC(l_refund_issued,1)' || TRUNC(l_refund_issued,1));
    --
    IF TRUNC(l_refund_issued,1) > l_max_refund_allowed  THEN
      Out_Err_Num      := 1;
      Out_Err_Msg      := 'Total REFUND for an Order is more than SALE amount. Refund cannot be Processed.';
      raise Input_validation_Failed;
    END IF;
    --
    --Resulted Array to OUT param
    SELECT sa.refund_type( dtl.x_esn,
                           dtl.smp,
                           dtl.sim,  -- CR51737
                           NULL,     -- CR54805 accessory_serial
                           dtl.LINE_NUMBER,
                           dtl.PART_NUMBER,
                           -1*dtl.X_AMOUNT,
                           dtl.X_QUANTITY,
                           -1*dtl.SALESTAX_AMOUNT,
                           -1*dtl.X_E911_TAX_AMOUNT,
                           -1*dtl.X_USF_TAXAMOUNT,
                           -1*dtl.X_RCRF_TAX_AMOUNT,
                           -1*dtl.TOTAL_TAX_AMOUNT,
                           -1*dtl.TOTAL_AMOUNT,
						               NULL -- Status
                          )
    BULK COLLECT INTO Out_refundItem
    FROM  x_biz_purch_hdr hdr,
          x_biz_purch_dtl dtl
    WHERE hdr.objid     = dtl.biz_purch_dtl2biz_purch_hdr
    AND   hdr.C_OrderId = In_Order_id
    AND   hdr.RMA_Id    = c_rma_id
    AND   UPPER (x_payment_type) IN ('REFUND')
    ORDER BY dtl.line_number ASC;
    --
    CLOSE biz_hdr_cur;
  --REFUND SETTLEMENT
  ELSIF In_refundsettlement_flag = 'S'
  THEN
    OPEN valid_cur ;     -->  Checking if refund already processed.
    FETCH valid_cur INTO valid_rec;
    IF valid_cur%FOUND THEN
	  CLOSE valid_cur;
      IF valid_rec.x_status = 'SUCCESS' THEN
        Out_Err_Num      := 1;
        Out_Err_Msg      := 'Refund already processed';
		raise Input_validation_Failed;
      END IF;
    ELSE
	  CLOSE valid_cur;
	END IF;

	BEGIN
		SELECT rma_id
		INTO   c_rma_id
		FROM   x_biz_purch_hdr
		WHERE  c_orderid = In_Order_id
		AND    rma_id LIKE In_RMA_Id||'%'
		AND    UPPER (x_payment_type) IN ('REFUND')   --CR39912
		AND    x_status = 'PENDING';
	EXCEPTION
	WHEN OTHERS THEN
		c_rma_id := In_RMA_Id;
	END;

    OPEN refundpost_cur(NVL(c_rma_id,in_rma_id));
    FETCH refundpost_cur INTO refundpost_rec;
    --
    --> Validation rule 1 - Checking if the Refund was initiated:
    IF refundpost_cur%NOTFOUND THEN
      Out_Err_Num    := 1;
      Out_Err_Msg    := 'Refund was not initiated yet, please initiate';
      CLOSE refundpost_cur;
      raise Input_validation_Failed;
    ELSE
	  CLOSE refundpost_cur;
    END IF;
    -- PREPARING TO SETTLE THE REFUND RECORD:
    --Refund Settlement status.
    IF in_ics_rcode IN ('1', '100') THEN
      l_status := 'SUCCESS';
    ELSE
      l_status := 'FAILED';
    END IF;
    --CR39912  -- Changes to have Only one return record
    --Updating the settlement response .
    UPDATE  x_biz_purch_hdr hdr
    SET     x_request_id        = IN_Auth_Request_Id ,
            x_ics_rcode         = IN_ICS_RCODE,
            x_ics_rflag         = IN_ICS_RFLAG,
            x_ics_rmsg          = IN_ICS_RMSG,
            x_bill_rcode        = IN_BILL_RCODE,
            x_bill_rflag        = IN_BILL_RFLAG,
            x_bill_rmsg         = IN_BILL_RMSG,
            x_process_date      = SYSDATE,
            x_bill_trans_ref_no = in_bill_trans_ref_no,
            x_status            = l_status,
            x_bill_amount       = decode (l_status, 'SUCCESS',refundpost_rec.x_auth_amount,NULL)
    WHERE hdr.c_orderid = In_Order_id
    AND   hdr.RMA_Id    = c_rma_id
    AND   UPPER (x_payment_type) IN ('REFUND');
  END IF;
  --
  Out_Err_Num := 0;
  Out_Err_Msg := 'SUCCESS';
 EXCEPTION
  WHEN Input_validation_Failed THEN
    UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => 'Input validation Failed', IP_KEY => 'OrderId:'||In_Order_id || ', RMA Id:'||c_rma_id , IP_PROGRAM_NAME => 'RETURN_SERVICE_PKG.process_refund', ip_error_text => OUT_Err_MSg);
    ROLLBACK;
  WHEN OTHERS THEN
    Out_Err_Num      := 1;
    Out_Err_Msg := ( 'Process Refund failed due to' || SQLERRM || '.');
    UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => NULL, IP_KEY => 'OrderId:'||In_Order_id || ', RMA Id:'||c_rma_id , IP_PROGRAM_NAME => 'RETURN_SERVICE_PKG.process_refund', ip_error_text => OUT_Err_MSg);
    ROLLBACK;
END process_refund;
--
--Process_refund for Ebay Integration Starts
--This procedure will be called by SOA to calculate and the amount to be refunded to the customer.
PROCEDURE process_refund(
    In_Order_id         IN VARCHAR2,
    In_RMA_Id           IN VARCHAR2,
    In_Rqst_Source      IN VARCHAR2,   --TAS/OFS
    In_Partner_id       IN VARCHAR2,   --EBAY
    In_RefundItem       IN REFUND_TBL,
    IN_ICS_RCODE        IN x_biz_purch_hdr.X_ICS_RCODE%TYPE,
    IN_ICS_RFLAG        IN x_biz_purch_hdr.X_ICS_RFLAG%TYPE,
    IN_ICS_RMSG         IN x_biz_purch_hdr.X_ICS_RMSG%TYPE,
    IN_BILL_RCODE       IN x_biz_purch_hdr.X_BILL_RCODE%TYPE,
    IN_BILL_RFLAG       IN x_biz_purch_hdr.X_BILL_RFLAG%TYPE,
    IN_BILL_RMSG        IN x_biz_purch_hdr.X_BILL_RMSG%TYPE,
    In_Request_id       IN x_biz_purch_hdr.X_REQUEST_ID%TYPE, --Ebay Return id will be passed here.
    IN_AUTH_REQUEST_ID  IN x_biz_purch_hdr.X_AUTH_REQUEST_ID%TYPE,
    In_refundsettlement_flag IN VARCHAR2,
    Out_Objid           OUT  NUMBER,
    Out_ICSApplication  OUT VARCHAR2,
    Out_FirstName       OUT VARCHAR2,
    Out_LastName        OUT VARCHAR2,
    Out_Ship_Address1   OUT VARCHAR2,
    Out_Ship_Address2   OUT VARCHAR2,
    Out_Ship_Zip        OUT VARCHAR2,
    Out_Ship_city       OUT VARCHAR2,
    Out_Ship_Country    OUT VARCHAR2,
    Out_Ship_State      OUT VARCHAR2,
    Out_AuthRequestId   OUT VARCHAR2,
    Out_MerchantId      OUT VARCHAR2,
    Out_MerchantRefNumber  OUT  VARCHAR2,
    Out_refundItem      OUT REFUND_TBL,
    Out_Stax_Tot        OUT NUMBER,
    Out_E911_Tot        OUT NUMBER,
    Out_RCRF_Tot        OUT NUMBER,
    Out_USF_Tot         OUT NUMBER,
    Out_Tax_Tot         OUT NUMBER,
    Out_Total_Refund    OUT NUMBER,
    Out_Err_Num         OUT NUMBER,
    Out_Err_Msg         OUT VARCHAR2,
    Out_Warn_Msg        OUT VARCHAR2)
IS
CURSOR biz_hdr_cur
  IS
    SELECT *
    FROM x_biz_purch_hdr
    WHERE c_orderid = In_Order_id
    AND UPPER (x_payment_type) = 'SETTLEMENT'
    AND x_status = 'SUCCESS';

  biz_hdr_rec biz_hdr_cur%ROWTYPE;

  CURSOR valid_cur
  IS
    SELECT *
    FROM x_biz_purch_hdr
    WHERE c_orderid        = In_Order_id
      AND rma_id           = In_RMA_Id
      AND UPPER (x_payment_type) IN ('REFUND')
	  AND x_status in ('SUCCESS','FAILED');

  valid_rec valid_cur%ROWTYPE;

  CURSOR refundpost_cur
  IS
    SELECT *
    FROM x_biz_purch_hdr
    WHERE c_orderid        = In_Order_id
      AND rma_id           = In_RMA_Id
      AND UPPER (x_payment_type) IN ('REFUND')
	  AND x_status = 'PENDING';

   refundpost_rec refundpost_cur%ROWTYPE;

   CURSOR duplicate_refund_cur (p_esn varchar2,p_smp varchar2)
    IS
      SELECT c_orderid,rma_id,d.*
      FROM x_biz_purch_hdr h, x_biz_purch_dtl d
      WHERE h.objid = d.BIZ_PURCH_DTL2BIZ_PURCH_HDR
        AND h.c_orderid        = In_Order_id
        AND ( d.X_ESN          = p_esn
             OR d.SMP         = p_smp
              )
      AND UPPER (h.x_payment_type) IN ('REFUND')
      AND h.x_status in ('SUCCESS','PENDING');
   duplicate_refund_rec  duplicate_refund_cur%ROWTYPE;

   dtls_result_set  Biz_refund_dtl_tbl;

   l_order_type          VARCHAR2(25);
   l_authrequest_id     x_biz_purch_hdr.x_auth_request_id%type;
   l_ics_applications   x_biz_purch_hdr.x_ics_applications%type;
   l_payment_type       x_biz_purch_hdr.x_payment_type%type;
   l_hdrobj_id          x_biz_purch_hdr.objid%type;

  l_domain        x_biz_purch_dtl.domain%type;
  l_sales_rate    x_biz_purch_dtl.sales_rate%type;
  l_e911_rate     x_biz_purch_dtl.e911_rate%type;
  l_usf_rate      x_biz_purch_dtl.usf_rate%type;
  l_rcrf_rate     x_biz_purch_dtl.rcrf_rate%type;
  l_dtlobj_id     x_biz_purch_dtl.objid%type ;
  l_unitsalestax_amount  x_biz_purch_dtl.salestax_amount%type;
  l_salestax_amount  x_biz_purch_dtl.salestax_amount%type;
  l_e911_tax_amount  x_biz_purch_dtl.x_e911_tax_amount%type;
  l_usf_taxamount    x_biz_purch_dtl.x_usf_taxamount%type;
  l_rcrf_tax_amount  x_biz_purch_dtl.x_rcrf_tax_amount%type;
  l_total_tax_amount x_biz_purch_dtl.total_tax_amount%type;
  l_amount           x_biz_purch_dtl.x_amount%type;
  l_amount_TOT       x_biz_purch_dtl.x_amount%type;
  l_total_amount        x_biz_purch_dtl.total_amount%type;
  l_merchant_ref_number  x_biz_purch_hdr.x_merchant_ref_number%type;
  l_status              x_biz_purch_hdr.x_status%type;
  l_bill_zip            x_biz_purch_hdr.x_bill_zip%type;
  l_e911_surcharge      x_biz_purch_dtl.x_e911_tax_amount%type;
  l_rqst_type           x_biz_purch_hdr.x_rqst_type%type;

  l_refund_issued  x_biz_purch_hdr.x_auth_amount%type;
   l_max_refund_allowed  x_biz_purch_dtl.total_amount%type;

  l_duplicate_refund   VARCHAR2(1);
  Input_validation_Failed     EXCEPTION;

BEGIN
 --Initialization
  OUT_STAX_TOT   := 0;
  OUT_E911_TOT   := 0;
  OUT_USF_TOT    := 0;
  OUT_RCRF_TOT   := 0;
  Out_Tax_Tot    := 0;
  Out_Total_Refund    := 0;
  l_amount_TOT     := 0;
  l_e911_surcharge := 0;

  Out_refundItem  :=  sa.REFUND_TBL(); -- CR51737

  /*SELECT SA.REFUND_OUT_REC(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
  BULK COLLECT INTO Out_refundItem
  FROM DUAL;*/

 -- NULL Check
 IF In_Order_id IS NULL or In_RMA_Id IS NULL THEN
    Out_Err_Num    := 1;
    Out_Err_Msg    := 'Order id/RMA id cannot be NULL';
    raise Input_validation_Failed;
 ELSIF IN_REFUNDSETTLEMENT_FLAG IS NULL THEN
    Out_Err_Num    := 1;
    Out_Err_Msg    := 'Settlement Flag cannot be NULL';
    raise Input_validation_Failed;
 END IF;

 --Refund Initiate
 IF In_refundsettlement_flag = 'I' THEN

  OPEN biz_hdr_cur;
  FETCH biz_hdr_cur INTO biz_hdr_rec;

  --> Validation rule 1 - Checking if Original order exists:
  IF biz_hdr_cur%NOTFOUND THEN
      CLOSE biz_hdr_cur;
    Out_Err_Num    := 1;
    Out_Err_Msg    := 'Order is not Eligible for RETURN/REFUND';
    raise Input_validation_Failed;
  ELSE
      CLOSE biz_hdr_cur;
     -->  Checking if refund already processed.
     OPEN valid_cur ;
     FETCH valid_cur INTO valid_rec;

     OPEN refundpost_cur ;
     FETCH refundpost_cur INTO refundpost_rec;

      IF valid_cur%FOUND
      THEN
        CLOSE valid_cur;
        CLOSE refundpost_cur;
        IF valid_rec.x_status = 'SUCCESS'
        THEN
          Out_Err_Num      := 1;
          Out_Err_Msg      := 'Refund already processed';
        ELSE
          Out_Err_Num      := 1;
          Out_Err_Msg      := 'Refund already processed, and it is failed';
        END IF;

        raise Input_validation_Failed;

     ELSIF refundpost_cur%FOUND THEN
        CLOSE valid_cur;
        CLOSE refundpost_cur;
        Out_Err_Num      := 1;
        Out_Err_Msg      := 'Refund already Initiated';

        raise Input_validation_Failed;

     ELSE
        CLOSE valid_cur;
        CLOSE refundpost_cur;
        --CR45294  - Validate In_RefundItem array is not empty - to process further
        IF In_RefundItem.count = 0 THEN
          Out_Err_Num    := 1;
          Out_Err_Msg    := 'In_RefundItem list cannot be empty ';
          raise Input_validation_Failed;
        END IF;

      -- PREPARING TO INSERT THE "REFUND INITIATE" RECORD:
       l_order_type      := 'RETURN';
       l_authrequest_id  := In_Request_id;
	     l_ics_applications  := 'eBayPayPal_refund';
       l_merchant_ref_number := biz_hdr_rec.X_MERCHANT_REF_NUMBER||'_CR_'||In_RMA_Id ;
       l_rqst_type           := SUBSTR(biz_hdr_rec.X_RQST_TYPE, 1, instr(biz_hdr_rec.X_RQST_TYPE,'_',1))||'REFUND';


       l_payment_type    := 'REFUND';
	     l_status          := 'PENDING';
       l_hdrobj_id       := sequ_biz_purch_hdr.NEXTVAL;

      BEGIN
       INSERT
        INTO x_biz_purch_hdr
          (
            objid,
            x_rqst_source,
            channel,
            ecom_org_id,
            order_type,
            c_orderid,
            account_id,
            x_auth_request_id,
            groupidentifier,
            x_rqst_type,
            x_rqst_date,
            x_ics_applications,
            x_merchant_id,
            x_merchant_ref_number,
            x_auth_code,
            x_ics_rcode,
            x_ics_rflag,
            x_ics_rmsg,
            x_request_id,
            x_auth_request_token,
            x_bill_rcode,
            x_bill_rflag,
            x_bill_rmsg,
            x_bill_trans_ref_no,
            x_customer_firstname,
            x_customer_lastname,
            x_customer_phone,
            x_customer_email,
            x_status,
            x_bill_address1,
            x_bill_address2,
            x_bill_city,
            x_bill_state,
            x_bill_zip,
            x_bill_country,
            x_ship_address1,
            x_ship_address2,
            x_ship_city,
            x_ship_state,
            x_ship_zip,
            x_ship_country,
            purch_hdr2creditcard,
            purch_hdr2bank_acct,
            purch_hdr2other_funds,
            prog_hdr2x_pymt_src,
            prog_hdr2web_user,
            x_payment_type,
            x_process_date,
		      	x_credit_reason,
			      purch_hdr2altpymtsource,
            RMA_Id
          )
       VALUES
       (
        l_hdrobj_id,
        In_RQST_SOURCE,
        biz_hdr_rec.CHANNEL,
        biz_hdr_rec.ECOM_ORG_ID,
        l_order_type,
        biz_hdr_rec.C_ORDERID,
        biz_hdr_rec.ACCOUNT_ID,
        l_authrequest_id,
        biz_hdr_rec.GROUPIDENTIFIER,
        l_rqst_type,
        sysdate,
        l_ics_applications,
        biz_hdr_rec.X_MERCHANT_ID,
        l_merchant_ref_number,
        NULL,
        in_ics_rcode,
        in_ics_rflag,
        in_ics_rmsg,
        In_Request_id,
        biz_hdr_rec.X_AUTH_REQUEST_TOKEN,
        in_bill_rcode,
        in_bill_rflag,
        in_bill_rmsg,
        biz_hdr_rec.x_bill_trans_ref_no,
        biz_hdr_rec.x_customer_firstname,
        biz_hdr_rec.x_customer_lastname,
        biz_hdr_rec.x_customer_phone,
        biz_hdr_rec.x_customer_email,
        l_status,
        biz_hdr_rec.x_bill_address1,
        biz_hdr_rec.x_bill_address2,
        biz_hdr_rec.x_bill_city,
        biz_hdr_rec.x_bill_state,
        biz_hdr_rec.x_bill_zip,
        biz_hdr_rec.x_bill_country,
        biz_hdr_rec.x_ship_address1,
        biz_hdr_rec.x_ship_address2,
        biz_hdr_rec.x_ship_city,
        biz_hdr_rec.x_ship_state,
        biz_hdr_rec.x_ship_zip,
        biz_hdr_rec.x_ship_country,
        biz_hdr_rec.purch_hdr2creditcard,
        biz_hdr_rec.purch_hdr2bank_acct,
        biz_hdr_rec.purch_hdr2other_funds,
        biz_hdr_rec.prog_hdr2x_pymt_src,
        biz_hdr_rec.prog_hdr2web_user,
        l_payment_type,
        SYSDATE,
	    	'CUSTOMER REFUND',
        biz_hdr_rec.purch_hdr2altpymtsource,
        In_RMA_Id
        );
       EXCEPTION
        WHEN OTHERS
		THEN
           Out_Err_Num      := 1;
           Out_Err_Msg := ( 'Cloning of purch_hdr record for Refund failed due to' || SQLERRM || '.');
		   raise Input_validation_Failed;
       END;

          Out_Objid          := l_hdrobj_id;
          Out_ICSApplication := l_ics_applications;
          Out_FirstName      := biz_hdr_rec.x_customer_firstname;
          Out_LastName       := biz_hdr_rec.x_customer_lastname;
          Out_Ship_Address1  := biz_hdr_rec.x_ship_address1;
          Out_Ship_Address2  := biz_hdr_rec.x_ship_address2;
          Out_Ship_Zip       := biz_hdr_rec.x_ship_zip;
          Out_Ship_city      := biz_hdr_rec.x_ship_city;
          Out_Ship_Country   := biz_hdr_rec.x_ship_country;
          Out_Ship_State     := biz_hdr_rec.x_ship_state;
          Out_AuthRequestId  := biz_hdr_rec.x_auth_request_id;
          Out_MerchantId     := biz_hdr_rec.X_MERCHANT_ID;
          Out_MerchantRefNumber  := l_merchant_ref_number;

         l_bill_zip := SUBSTR(biz_hdr_rec.x_bill_zip,1,5);

     END IF;
  END IF;

   -- PREPARING TO INSERT THE REFUND INITIATE DETAIL RECORDS:
    FOR i IN In_RefundItem.FIRST .. In_RefundItem.LAST
    LOOP

      l_unitsalestax_amount := 0;
      l_sales_rate := 0;
      l_e911_rate := 0;
      l_usf_rate := 0;
      l_rcrf_rate := 0;
      l_e911_surcharge  := 0;

         IF  In_RefundItem(i).ESN IS NULL AND  In_RefundItem(i).SMP IS NULL THEN
           Out_Err_Num      := 1;
           Out_Err_Msg      := 'ESN and SMP both cannot be NULL';
           raise Input_validation_Failed;
         ELSIF In_RefundItem(i).PART_NUMBER  IS NULL THEN
           Out_Err_Num      := 1;
           Out_Err_Msg      := 'Part Number cannot be Blank';
           raise Input_validation_Failed;
         ELSIF NVL(In_RefundItem(i).QUANTITY, 0) = 0 THEN
           Out_Err_Num      := 1;
           Out_Err_Msg      := 'Need Quantity For Each LineItem And It Can Not Be Zero.';
           raise Input_validation_Failed;
         ELSIF NVL(In_RefundItem(i).UNIT_PRICE, 0) = 0 THEN
           Out_Err_Num      := 1;
           Out_Err_Msg      := 'Need UnitPrice For Each LineItem And It Can Not Be Zero.';
           raise Input_validation_Failed;
         END IF;

        DBMS_OUTPUT.PUT_LINE ('In_RefundItem(i).ESN' || In_RefundItem(i).ESN);
        DBMS_OUTPUT.PUT_LINE ('In_RefundItem(i).SMP' || In_RefundItem(i).SMP);

       -- Duplicate refund check
         OPEN duplicate_refund_cur (In_RefundItem(i).ESN,In_RefundItem(i).SMP) ;
         FETCH duplicate_refund_cur INTO duplicate_refund_rec;

        IF duplicate_refund_cur%FOUND THEN
         CLOSE duplicate_refund_cur;
           Out_Err_Num      := 1;
           Out_Err_Msg      := 'Refund already ISSUED/PENDING for the Item '||In_RefundItem(i).ESN||' '||In_RefundItem(i).SMP;
           raise Input_validation_Failed;
        END IF;
           CLOSE duplicate_refund_cur;

      --Fetching tax rates from the Original order
	   --Note:-SalesTaxAmount may contain e911,and other taxes included in salestax itself and comes from eBay directly,
	   --ie. sales_rate column may not be used to derive tax calculation for refunds,
	   --hence the refund tax is calculated based on what was charged during the order.

        BEGIN
          SELECT  distinct sales_rate,salestax_amount/x_quantity
            INTO  l_sales_rate,l_unitsalestax_amount
            FROM  x_biz_purch_dtl d
           WHERE  biz_purch_dtl2biz_purch_hdr = biz_hdr_rec.objid
		     AND  part_number  = In_RefundItem(i).PART_NUMBER;
       EXCEPTION
        WHEN NO_DATA_FOUND THEN
            Out_Err_Num      := 1;
            Out_Err_Msg      := 'Original Order detail not found. Refund cannot be processed.';
            raise Input_validation_Failed;
        WHEN OTHERS THEN
            Out_Err_Num      := 1;
            Out_Err_Msg      := 'Error in fetching Orignal Order details.';
            raise Input_validation_Failed;
       END;

        --Calculating different taxes
       -- l_salestax_amount := -1 * ROUND(NVL(In_RefundItem(i).UNIT_PRICE * In_RefundItem(i).QUANTITY * l_sales_rate,0), 2)  ;
	    l_salestax_amount := -1 * ROUND(NVL(In_RefundItem(i).QUANTITY * l_unitsalestax_amount,0), 2)  ;
        l_total_tax_amount := l_salestax_amount  ;
        l_amount          := -1 * ROUND(NVL((In_RefundItem(i).UNIT_PRICE * In_RefundItem(i).QUANTITY),0),2);
        l_total_amount     :=  l_amount + l_total_tax_amount;

        DBMS_OUTPUT.PUT_LINE ('l_salestax_amount' || l_salestax_amount);
        DBMS_OUTPUT.PUT_LINE ('l_total_tax_amount' || l_total_tax_amount);
        DBMS_OUTPUT.PUT_LINE ('l_amount' || l_amount);
        DBMS_OUTPUT.PUT_LINE ('l_total_amount' || l_total_amount);

        --Cumulative tax total
        OUT_STAX_TOT := OUT_STAX_TOT + l_salestax_amount ;
        OUT_tax_TOT  := OUT_tax_TOT  + l_total_tax_amount;
        l_amount_TOT :=  l_amount_TOT +  l_amount;
        Out_Total_Refund  := OUT_Total_Refund  + l_total_amount;

        DBMS_OUTPUT.PUT_LINE ('OUT_STAX_TOT' || OUT_STAX_TOT);
        DBMS_OUTPUT.PUT_LINE ('OUT_tax_TOT' || OUT_tax_TOT);
        DBMS_OUTPUT.PUT_LINE ('l_amount_TOT' || l_amount_TOT);
        DBMS_OUTPUT.PUT_LINE ('Out_Total_Refund' || Out_Total_Refund);


       BEGIN
        INSERT
        INTO x_biz_purch_dtl
          (
            objid,
            x_esn,
            smp,
            x_amount,
            line_number,
            part_number,
            biz_purch_dtl2biz_purch_hdr,
            x_quantity,
            domain,
            sales_rate,
            salestax_amount,
            total_tax_amount,
            total_amount
          )
          VALUES
          (
            sequ_biz_purch_dtl.NEXTVAL,
            In_RefundItem(i).ESN,
            In_RefundItem(i).SMP,
            In_RefundItem(i).UNIT_PRICE * -1,
            In_RefundItem(i).LINE_NUMBER,
            In_RefundItem(i).PART_NUMBER,
            l_hdrobj_id,
            In_RefundItem(i).QUANTITY,
            l_domain,
            l_sales_rate,
            l_salestax_amount,
            l_total_tax_amount,
            l_total_amount
          );
       EXCEPTION
         WHEN Input_validation_Failed THEN
            UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => 'Input validation Failed', IP_KEY => 'OrderId:'||In_Order_id || ', RMA Id:'||In_RMA_Id , IP_PROGRAM_NAME => 'RETURN_SERVICE_PKG.process_refund', ip_error_text => OUT_Err_MSg);
            ROLLBACK;
            RETURN;
      WHEN OTHERS THEN
        Out_Err_Num    := 1;
        Out_Err_Msg    := ( 'Insert Refund details into x_biz_purch_dtl failed due to' || SQLERRM);
        UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => 'Exception', IP_KEY => 'OrderId:'||In_Order_id || ', RMA Id:'||In_RMA_Id , IP_PROGRAM_NAME => 'RETURN_SERVICE_PKG.process_refund', ip_error_text => OUT_Err_MSg);
        ROLLBACK;
        RETURN;
      END;

      DBMS_OUTPUT.PUT_LINE ('In_Order_id '|| In_Order_id|| 'l_hdrobj_id ' ||l_hdrobj_id ||' ESN '||In_RefundItem(i).ESN ||'SMP '||In_RefundItem(i).SMP);

       UPDATE sa.X_BIZ_ORDER_DTL
          SET BIZ_ORDER_DTL2BIZ_PURCH_HDR_CR = l_hdrobj_id
        WHERE X_ECOM_ORDER_NUMBER  = In_Order_id
          AND X_ITEM_VALUE in (In_RefundItem(i).ESN,In_RefundItem(i).SMP);

       IF SQL%ROWCOUNT = 0 THEN
         OUT_Err_MSg  := 'Update to X_BIZ_ORDER_DTL failed';
         UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => NULL, IP_KEY => 'OrderId:'||In_Order_id || ', RMA Id:'||In_RMA_Id , IP_PROGRAM_NAME => 'RETURN_SERVICE_PKG.process_refund', ip_error_text => OUT_Err_MSg);
      END IF;
    END LOOP;

      l_max_refund_allowed := nvl(biz_hdr_rec.x_auth_amount,0) - nvl(biz_hdr_rec.freight_amount,0) ;

      DBMS_OUTPUT.PUT_LINE ('biz_hdr_rec.x_auth_amount' || nvl(biz_hdr_rec.x_auth_amount,0));
      DBMS_OUTPUT.PUT_LINE ('biz_hdr_rec.freight_amount' || nvl(biz_hdr_rec.freight_amount,0));
      DBMS_OUTPUT.PUT_LINE ('l_max_refund_allowed' || l_max_refund_allowed);


  --  DBMS_OUTPUT.PUT_LINE ('biz_hdr_rec.x_bill_amount + Out_Total_Refund' || biz_hdr_rec.x_bill_amount + Out_Total_Refund);
    -- IF biz_hdr_rec.x_bill_amount + Out_Total_Refund < 0 THEN

      DBMS_OUTPUT.PUT_LINE ('TRUNC(Out_Total_Refund,1)' || TRUNC(Out_Total_Refund,1));

    IF l_max_refund_allowed + TRUNC(Out_Total_Refund,1) < 0 THEN
       Out_Err_Num      := 1;
       Out_Err_Msg      := 'Refund Amount cannot be greater than Order Amount.';
       raise Input_validation_Failed;
    END IF;

   --CLOSE biz_hdr_cur;

 --Updating the Cumulative Total in the Header.
     UPDATE x_biz_purch_hdr hdr
        SET x_amount = l_amount_TOT,
            x_tax_amount = OUT_tax_TOT,
            x_sales_tax_amount = OUT_STAX_TOT,
            x_auth_amount  =  Out_Total_Refund,
            x_bill_amount = NULL,
            hdr.freight_amount = NULL
     WHERE hdr.C_OrderId = In_Order_id
      AND hdr.RMA_Id    = In_RMA_id
      AND UPPER (x_payment_type) IN ('REFUND');


       BEGIN
          SELECT SUM(NVL(X_AUTH_AMOUNT,0)) * -1
            INTO l_refund_issued
           FROM x_biz_purch_hdr
          WHERE c_orderid   = In_Order_id
            AND order_type = 'RETURN';
       EXCEPTION
         WHEN OTHERS THEN
          Out_Err_Num      := 1;
          Out_Err_Msg      := 'Error in fetching Orignal Order details.';
          raise Input_validation_Failed;
       END;

      DBMS_OUTPUT.PUT_LINE ('l_refund_issued' || l_refund_issued);
      DBMS_OUTPUT.PUT_LINE ('TRUNC(l_refund_issued,1)' || TRUNC(l_refund_issued,1));

      IF TRUNC(l_refund_issued,1) > l_max_refund_allowed  THEN
         Out_Err_Num      := 1;
         Out_Err_Msg      := 'Total REFUND for an Order is more than SALE amount. Refund cannot be Processed.';
         raise Input_validation_Failed;
      END IF;

  --Resulted Array to OUT param
     SELECT sa.refund_type( dtl.x_esn,
                            dtl.smp,
                            dtl.sim,  -- CR51737
                            NULL,     -- CR54805 accessory_serial
                            dtl.LINE_NUMBER,
                            dtl.PART_NUMBER,
                            dtl.X_AMOUNT,
                            dtl.X_QUANTITY,
                            dtl.SALESTAX_AMOUNT,
                            dtl.X_E911_TAX_AMOUNT,
                            dtl.X_USF_TAXAMOUNT,
                            dtl.X_RCRF_TAX_AMOUNT,
                            dtl.TOTAL_TAX_AMOUNT,
                            dtl.TOTAL_AMOUNT,
							              NULL -- status
                           )
        BULK COLLECT INTO Out_refundItem
        FROM X_BIZ_PURCH_HDR hdr,
             X_BIZ_PURCH_DTL dtl
        WHERE hdr.objid     = dtl.biz_purch_dtl2biz_purch_hdr
          AND hdr.C_OrderId = In_Order_id
          AND hdr.RMA_Id    = In_RMA_id
          AND UPPER (x_payment_type) IN ('REFUND')
        ORDER BY dtl.line_number ASC;
 --REFUND SETTLEMENT
 ELSIF In_refundsettlement_flag = 'S' THEN
   OPEN valid_cur ;     -->  Checking if refund already processed.
   FETCH valid_cur INTO valid_rec;

   IF valid_cur%FOUND THEN
      CLOSE valid_cur;
	IF valid_rec.x_status = 'SUCCESS' THEN
		Out_Err_Num      := 1;
		Out_Err_Msg      := 'Refund already processed';
	ELSE
		Out_Err_Num      := 1;
		Out_Err_Msg      := 'Refund already processed, and it is failed';
	END IF;

      raise Input_validation_Failed;

   ELSE
      CLOSE valid_cur;
	  OPEN refundpost_cur;
	  FETCH refundpost_cur INTO refundpost_rec;

	  --> Validation rule 1 - Checking if the Refund was initiated:
	  IF refundpost_cur%NOTFOUND THEN
        CLOSE refundpost_cur;
		 Out_Err_Num    := 1;
		 Out_Err_Msg    := 'Refund was not initiated yet, please initiate';

		 raise Input_validation_Failed;
      ELSE
        CLOSE refundpost_cur;
      -- PREPARING TO SETTLE THE REFUND RECORD:
       --Refund Settlement status.
       IF in_ics_rcode IN ('1', '100') THEN
          l_status := 'SUCCESS';
       ELSE
          l_status := 'FAILED';
       END IF;

	    --Updating the settlement response .
		 UPDATE x_biz_purch_hdr hdr
			SET --x_request_id = IN_Auth_Request_Id ,
				x_ics_rcode  = IN_ICS_RCODE,
				x_ics_rflag  = IN_ICS_RFLAG,
				x_ics_rmsg   = IN_ICS_RMSG,
				x_bill_rcode = IN_BILL_RCODE,
				x_bill_rflag = IN_BILL_RFLAG,
				x_bill_rmsg  = IN_BILL_RMSG,
				x_process_date = SYSDATE,
				--x_bill_trans_ref_no = in_bill_trans_ref_no,
				x_status       = l_status,
		    x_bill_amount  = decode (l_status, 'SUCCESS',refundpost_rec.x_auth_amount,NULL)
		 WHERE hdr.c_orderid = In_Order_id
		  AND hdr.RMA_Id    = In_RMA_id
		  AND UPPER (x_payment_type) IN ('REFUND');

     END IF;
   END IF;

 END IF;
  Out_Err_Num := 0;
  Out_Err_Msg := 'SUCCESS';

 EXCEPTION
  WHEN Input_validation_Failed THEN
 	UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => 'Input validation Failed', IP_KEY => 'OrderId:'||In_Order_id || ', RMA Id:'||In_RMA_Id , IP_PROGRAM_NAME => 'RETURN_SERVICE_PKG.process_refund', ip_error_text => OUT_Err_MSg);
   ROLLBACK;
  WHEN OTHERS THEN
    Out_Err_Num      := 1;
    Out_Err_Msg := ( 'Process Refund failed due to' || SQLERRM || '.');
    UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => NULL, IP_KEY => 'OrderId:'||In_Order_id || ', RMA Id:'||In_RMA_Id , IP_PROGRAM_NAME => 'RETURN_SERVICE_PKG.process_refund', ip_error_text => OUT_Err_MSg);
    ROLLBACK;
END process_refund;
--Process_refund for Ebay Integration ends

--This procedure will be called by SOA to VOID the pin which was returned by the Customer.
PROCEDURE void_pin(
    in_order_id          IN VARCHAR2,
    in_rma_id            IN VARCHAR2,
    in_order_type        IN VARCHAR2,
    in_voiditem          IN refund_tbl,
    in_voidstatus_code   IN VARCHAR2  default '44',
    out_voiditem         OUT refund_tbl,
    out_err_num          OUT NUMBER,
    out_err_msg          OUT VARCHAR2,
    out_warn_msg         OUT VARCHAR2)
IS
  temp_Arry  refund_tbl := refund_tbl ();
  --
  CURSOR void_cur (p_smp  VARCHAR2)
  IS
  SELECT pi.part_serial_no as SMP
         ,pi.x_red_code as PIN
   FROM  table_part_inst pi
  WHERE  pi.part_serial_no = p_smp
    AND  pi.x_domain = 'REDEMPTION CARDS';
  --
  void_rec   void_cur%ROWTYPE;
  l_status     NUMBER;
  p_err_num    NUMBER;
  p_err_msg    VARCHAR2 (500);
  --
  Input_validation_Failed  EXCEPTION;

BEGIN
      /*SELECT SA.refund_type(NULL, NULL)
      BULK COLLECT INTO Out_VoidItem
      FROM DUAL;*/
   out_voiditem  :=   sa.refund_tbl ();
  --NULL Check
  IF in_order_id IS NULL or in_rma_id IS NULL THEN
    out_err_num    := 1;
    out_err_msg    := 'Order id/RMA id cannot be NULL';
    RETURN;
  ELSIF in_order_type IS NULL THEN
    out_err_num    := 1;
    out_err_msg    := 'Order Type cannot be NULL';
    RETURN;
  END IF;
  --
  --Validations
  IF in_voiditem.count = 0 THEN
    out_err_num :=  1;
    out_err_msg  := 'List cannot be empty';
    RETURN;
  ELSE
    --Looping VOID item list
    FOR i_count IN in_voiditem.FIRST .. in_voiditem.LAST
    LOOP
      BEGIN
        IF in_voiditem(i_count).smp IS NULL THEN
          out_err_num := 1;
          out_err_msg :=  'SMP cannot be NULL';
          RETURN;
        ELSE
          BEGIN
            IF void_cur%ISOPEN THEN
               CLOSE void_cur;
            END IF;
            --
            OPEN void_cur (in_voiditem(i_count).smp);
            FETCH void_cur INTO void_rec;
            --
            IF void_cur%FOUND THEN
              -- Removing the ESN - PIN association
              UPDATE table_part_inst
              SET   part_to_esn2part_inst = NULL,
                    last_mod_time = sysdate
              WHERE 1 = 1
              AND   x_part_inst_status||'' = '400'
              AND   part_serial_no = void_rec.SMP  --SMP
              AND   x_domain = 'REDEMPTION CARDS'
              AND   part_to_esn2part_inst IS NOT NULL;
              --
              --VOIDing the PIN
              UPDATE table_part_inst pi
              SET    pi.x_part_inst_status = In_VoidStatus_code,  ---default code '44' (INVALID)
                     pi.STATUS2X_CODE_TABLE = (select objid from table_x_code_table where X_CODE_NUMBER = 44),
                     pi.last_mod_time = sysdate
              WHERE  pi.part_serial_no  = void_rec.SMP
              AND    x_domain = 'REDEMPTION CARDS';
              --
              SELECT refund_type ( NULL, --esn
                                   void_rec.smp, --smp
                                   NULL, --sim
                                   NULL, -- accessory number
                                   in_voiditem(i_count).line_number, --line_number
                                   NULL, --part_number
                                   NULL, --unit_price
                                   NULL, --quantity
                                   NULL, --sales_taxamount
                                   NULL, --e911_taxamount
                                   NULL, --usf_taxamount
                                   NULL, --rcrf_taxamount
                                   NULL, --total_taxamount
                                   NULL, --total_amount
                                   'Y' --status
                                  )
              BULK COLLECT INTO Out_VoidItem
              FROM DUAL;
              --
              IF temp_arry.count = 0 THEN
                temp_arry.extend (in_voiditem.count);
              END IF;
              --
              temp_arry (i_count)  := out_voiditem (1);
              --
              --Logging the status when RETURN
              IF in_order_type = 'RETURN'
              THEN
                BEGIN
                  UPDATE x_return_log_dtl ld
                  SET    ld.void_pin_flag = 'Y',
                         ld.modified_date = SYSDATE
                  WHERE  ld.return_log_hdr_objid IN
                                              (SELECT lh.objid
                                               FROM   x_return_log_hdr lh
                                               WHERE  lh.order_id  = in_order_id
                                               AND    lh.rma_id    = in_rma_id)
                  AND ld.smp  = void_rec.smp;
                  --
                  IF SQL%ROWCOUNT = 0 THEN
                    out_warn_msg := 'Unable to update the Void Pin status - X_Return_Log_dtl'; -- Just a warning message wont stop the flow
                  END IF;
                END;
              END IF;
              CLOSE void_cur;
            ELSIF void_cur%NOTFOUND THEN
              out_err_num := 1;
              out_err_msg  := 'PIN cannot be found ';
              RETURN;
            END IF;
          EXCEPTION
            /*WHEN Input_validation_Failed THEN
              UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => 'Input_validation_Failed', IP_KEY => 'OrderId:'||In_Order_id || ', RMA Id:'||In_RMA_Id , IP_PROGRAM_NAME => 'RETURN_SERVICE_PKG.Void_PIN', ip_error_text => OUT_Err_MSg);
              RETURN;*/
            WHEN  OTHERS THEN
              out_err_num := 1;
              out_err_msg  := 'Error in Void_PIN'|| (SUBSTR (SQLERRM, 1, 300));
              --UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => NULL, IP_KEY => 'OrderId:'||In_Order_id || ', RMA Id:'||In_RMA_Id , IP_PROGRAM_NAME => 'RETURN_SERVICE_PKG.Void_PIN', ip_error_text => OUT_Err_MSg);
              RETURN;
          END;
        END IF;
      END;
    END LOOP;
    --
    IF  NVL(out_err_num,0) = 0 THEN
      l_status := 0;
    ELSE
      l_status := 1;
    END IF;
    --
    IF in_order_type = 'RETURN' THEN
      log_returntransaction (
                    in_order_id             => in_order_id,
                    in_rma_id               => in_rma_id,
                    in_request_payload      => NULL,
                    in_return_stage_code    => NULL,
                    in_return_status_code   => NULL,
                    in_response_payload     => NULL,
                    in_retrigger_stage      => NULL,
                    in_comments             => NULL,
                    in_refund_payload       => NULL,
                    in_refund_stage_code    => 'VOID',
                    in_refund_status_code   => l_status,  -- Status is NOT NULL denotes this updates just STATUS for the stage.
                    in_refund_resp_payload  => NULL,
                    in_returns_dtl          => NULL,
                    out_err_num             => p_err_num,
                    out_err_msg             => p_err_msg
                    );
      --
      IF  p_err_num  <> 0 THEN
        out_warn_msg  := 'Error in Logging X_Return_Log_Hdr - '|| p_err_msg;
      END IF;
    END IF;
    out_voiditem :=  temp_Arry;
  END IF;
  --
  out_err_num := 0;
  out_err_msg  := 'SUCCESS';
  --
EXCEPTION
  /*WHEN Input_validation_Failed THEN
  	  UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => 'Input validation Failed', IP_KEY => 'OrderId:'||In_Order_id || ', RMA Id:'||In_RMA_Id , IP_PROGRAM_NAME => 'RETURN_SERVICE_PKG.Void_PIN', ip_error_text => OUT_Err_MSg);
      ROLLBACK;*/
  WHEN OTHERS THEN
    out_err_num  := 1  ;
    out_err_msg  :=  'Exception in Void_PIN '||SUBSTR (SQLERRM, 1, 300);
    --UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => NULL, IP_KEY => 'OrderId:'||In_Order_id || ', RMA Id:'||In_RMA_Id , IP_PROGRAM_NAME => 'RETURN_SERVICE_PKG.Void_PIN', ip_error_text => OUT_Err_MSg);
    --ROLLBACK;
END void_pin;
--
-- CR51737 Changes starts..
PROCEDURE get_smp_details ( i_order_id        IN      VARCHAR2,
                            io_sim            IN OUT  VARCHAR2,
                            io_esn            IN OUT  VARCHAR2,
                            o_smp             OUT     VARCHAR2,
                            o_smp_partnum     OUT     VARCHAR2,
                            o_smp_unitprice   OUT     NUMBER,
                            o_err_code        OUT     VARCHAR2,
                            o_err_msg         OUT     VARCHAR2)
IS
BEGIN
--
  SELECT  sim,  esn,  smp, app_part_number
  INTO    io_sim, io_esn, o_smp, o_smp_partnum
  FROM    x_biz_order_fulfill_dtl bfd
  WHERE   bfd.order_id    = i_order_id
  AND     (bfd.sim        = NVL(io_sim,0) OR
           bfd.esn        = NVL(io_esn,0));
  --
  SELECT  bpd.x_amount / NVL(bpd.x_quantity,1)
  INTO    o_smp_unitprice
  FROM    x_biz_purch_hdr         bph,
          x_biz_purch_dtl         bpd
  WHERE   1= 1
  AND     bpd.part_number                 = o_smp_partnum
  AND     bpd.biz_purch_dtl2biz_purch_hdr = bph.objid
  AND     bph.x_status                    = 'SUCCESS'
  AND     UPPER (bph.x_payment_type) in ('SETTLEMENT','REAUTH')
  AND     bph.c_orderid                   = i_order_id
  AND     ROWNUM = 1;
  --
  o_err_code  :=  0;
  o_err_msg   :=  'SUCCESS';
--
EXCEPTION
  WHEN OTHERS THEN
    o_smp           :=  NULL;
    o_smp_partnum   :=  NULL;
    o_err_code      :=  99;
    o_err_msg       :=  SUBSTR(SQLERRM,1,400);
END get_smp_details;
-- CR51737 Changes ends.

-- CR54805 This procedure will be called by SOA to get the sim_status before processsing the return.
PROCEDURE  get_sim_status( in_order_id         IN  VARCHAR2,
                           in_rma_id           IN  VARCHAR2,
                           in_order_type       IN  VARCHAR2,
                           in_sim_status       IN  refund_tbl,
                           out_sim_status      OUT refund_tbl,
                           out_err_num         OUT NUMBER,
                           out_err_msg         OUT VARCHAR2,
                           out_warn_msg        OUT VARCHAR2 )
IS
--
  temp_arry  refund_tbl := refund_tbl ();
  --
  CURSOR sim_status_cur  (p_sim IN VARCHAR2)
  IS
    SELECT si.x_sim_serial_no  sim, x_code_name sim_status
    FROM   sa.table_x_sim_inv si,
           sa.table_mod_level ml,
           sa.table_part_num pn,
           table_x_code_table xct
    WHERE  si.x_sim_serial_no = p_sim
    AND    xct.objid = si.X_SIM_STATUS2X_CODE_TABLE
    AND    xct.x_code_type='SIM'
    AND    si.X_sim_INV2PART_MOD  = ml.objid
    AND    ml.part_info2part_num  = pn.objid;
  --
  sim_status_rec            sim_status_cur%ROWTYPE;
  --
BEGIN
  --
  out_sim_status  :=   sa.refund_tbl ();
  --NULL Check
  IF in_order_id IS NULL or in_rma_id IS NULL  THEN
    out_err_num    := 1;
    out_err_msg    := 'Order id/RMA id cannot be NULL';
    RETURN;
  ELSIF in_order_type IS NULL THEN
    out_err_num    := 1;
    out_err_msg    := 'Order Type cannot be NULL';
    RETURN;
  END IF;
  --Validations
  IF in_sim_status.count = 0 THEN
    out_err_num :=  1;
    out_err_msg  := 'List cannot be empty';
    RETURN;
  ELSE
    FOR i_count IN in_sim_status.FIRST .. in_sim_status.LAST
    LOOP
      BEGIN
        IF in_sim_status(i_count).sim IS NULL THEN
          out_err_num := 1;
          out_err_msg :=  'SIM cannot be NULL';
          RETURN;
        ELSE
          BEGIN
            IF sim_status_cur%ISOPEN THEN
               CLOSE sim_status_cur;
            END IF;
            --Get the Status of the PIN
            OPEN sim_status_cur (in_sim_status(i_count).sim);
            FETCH sim_status_cur INTO sim_status_rec;
            --
            IF sim_status_cur%FOUND
            THEN
              SELECT sa.refund_type( NULL, --esn
                                     NULL, --smp
                                     sim_status_rec.sim, --sim
									 NULL, -- accessory number
                                     in_sim_status(i_count).line_number, --line_number
                                     NULL, --part_number
                                     NULL, --unit_price
                                     NULL, --quantity
                                     NULL, --sales_taxamount
                                     NULL, --e911_taxamount
                                     NULL, --usf_taxamount
                                     NULL, --rcrf_taxamount
                                     NULL, --total_taxamount
                                     NULL, --total_amount
                                     sim_status_rec.sim_status --status
                                    )
              BULK COLLECT INTO out_sim_status
              FROM DUAL;
              --
              IF temp_arry.count = 0 THEN
                temp_arry.extend (in_sim_status.count);
              END IF;
              --Collecting SIM status in an array
              temp_Arry (i_count)  := out_sim_status (1);
              --
              --Capturing the status in Log table
              IF in_order_type = 'RETURN' THEN
                BEGIN
                  UPDATE x_return_log_dtl ld
                  SET    ld.sim_status = sim_status_rec.sim_status,
                         ld.modified_date = SYSDATE
                  WHERE  ld.return_log_hdr_objid IN
                                                ( SELECT lh.objid
                                                  FROM   x_return_log_hdr lh
                                                  WHERE  lh.order_id  = in_order_id
                                                  AND    lh.rma_id    = in_rma_id
                                                )
                  AND ld.sim  = sim_status_rec.sim;
                  --
                  IF SQL%ROWCOUNT = 0 THEN
                    out_warn_msg := 'Unable to update the SIM status - X_Return_Log_dtl'; -- Just a warning message wont stop the flow
                  END IF;
                  --
                END;
              END IF;
              CLOSE sim_status_cur;
            ELSIF sim_status_cur%NOTFOUND THEN
              out_err_num := 1;
              out_err_msg  := 'SIM Status not found';
              RETURN;
            END IF;
          EXCEPTION
           WHEN  OTHERS THEN
              out_err_num := 1;
              out_err_msg  := 'Error in get_sim_status'|| (SUBSTR (SQLERRM, 1, 300));
              RETURN;
          END;
        END IF;
      END;
    END LOOP;
    --
    out_sim_status := temp_arry;
  END IF;
  --
  out_err_num := 0;
  out_err_msg  := 'SUCCESS';
  --
EXCEPTION
  WHEN OTHERS THEN
    out_err_num  := 1  ;
    out_err_msg  :=  'Exception in get_sim_status '||SUBSTR (SQLERRM, 1, 300);
END get_sim_status;
-- CR54805 This procedure will check the accessory validation .
PROCEDURE  accessory_validation_check ( in_order_id         IN  VARCHAR2,
                                        in_part_number      IN  VARCHAR2,
                                        in_quantity         IN  NUMBER,
                                        out_err_num         OUT NUMBER,
                                        out_err_msg         OUT VARCHAR2)
IS
--
  n_order_totalqty 		NUMBER ;
  n_return_totalqty 	NUMBER ;
  n_balance_qty       NUMBER ;
BEGIN

  BEGIN
    SELECT NVL(SUM(NVL(l.X_QUANTITY,0)),0)
	  INTO n_order_totalqty
	  FROM x_biz_purch_dtl l
	  WHERE l.BIZ_PURCH_DTL2BIZ_PURCH_HDR in ( Select objid
						   FROM   x_biz_purch_hdr
						   WHERE  c_orderid   = In_Order_id
                                                   AND    order_type  = 'ORDER'
						   AND    x_payment_type in ('SETTLEMENT','REAUTH')
						   AND    x_status = 'SUCCESS'
						   AND    part_number = in_part_number );

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    n_order_totalqty := 0;
  WHEN OTHERS THEN
    Out_Err_Num      := 1;
    Out_Err_Msg      := 'Error in fetching Accessory Order quantity.';
    RETURN;
  END;
  BEGIN
	  SELECT NVL(SUM(NVL(l.X_QUANTITY,0)),0)
	  INTO n_return_totalqty
	  FROM x_biz_purch_dtl l
	  WHERE l.BIZ_PURCH_DTL2BIZ_PURCH_HDR in ( Select objid
						   FROM   x_biz_purch_hdr
						   WHERE  c_orderid   = In_Order_id
						   AND    order_type  = 'RETURN'
						   AND    x_payment_type in ('REFUND')
						   AND    x_status = 'SUCCESS'
                                                   AND    part_number = in_part_number );
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    n_return_totalqty := 0;
  WHEN OTHERS THEN
    Out_Err_Num      := 1;
    Out_Err_Msg      := 'Error in fetching Accessory Return quantity.';
    RETURN;
  END;
  IF n_order_totalqty = 0
  THEN
    out_err_num    := 1;
    out_err_msg    := 'Processing Accessory is not part of this Order.';
    RETURN;
  END IF;
  n_balance_qty := n_order_totalqty - n_return_totalqty ;

  IF	in_quantity <= n_balance_qty
  THEN
    out_err_num    := 0;
    out_err_msg    := 'SUCCESS';
    RETURN;
  ELSE
    out_err_num    := 1;
    out_err_msg    := 'Accessory already refunded.';
    RETURN;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    out_err_num  := 1  ;
    out_err_msg  :=  'Exception in accessory_validation_check '||SUBSTR (SQLERRM, 1, 300);
END accessory_validation_check;

END RETURN_SERVICE_PKG;
/