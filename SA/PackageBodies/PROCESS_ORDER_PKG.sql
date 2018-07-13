CREATE OR REPLACE PACKAGE BODY sa.process_order_pkg AS
/*************************************************************************************************************************************
  * $Revision: 1.12 $
  * $Author: sinturi $
  * $Date: 2018/03/28 21:43:39 $
  * $Log: process_order_pkb.sql,v $
  * Revision 1.12  2018/03/28 21:43:39  sinturi
  * Modified
  *
  * Revision 1.11  2018/03/28 17:01:28  sinturi
  * updated
  *
  * Revision 1.10  2017/06/14 15:27:30  sraman
  * Added new columns to process_order_detail_table
  *
*************************************************************************************************************************************/
PROCEDURE process_order_insert ( op_process_order_type IN OUT process_order_type,
                                 o_err_code            OUT    VARCHAR2,
                                 o_err_msg             OUT    VARCHAR2 ) IS
BEGIN

  IF op_process_order_type IS NULL THEN
    o_err_code := '101';
    o_err_msg  := 'Process Order Type has no input value';
    RETURN;
  END IF;

  IF op_process_order_type.order_detail IS NOT NULL THEN
    -- validate the invalid status passed in the process_order_type
    FOR i IN ( SELECT pd.order_status
               FROM   TABLE(CAST(op_process_order_type.order_detail AS process_order_detail_tab)) pd
               WHERE NOT EXISTS ( SELECT 1
                                  FROM   sa.x_process_order_status
                                  WHERE  process_order_status = pd.order_Status
                                )
             )
    LOOP
      IF i.order_status IS NOT NULL THEN
        o_err_code := '101';
        o_err_msg  := 'PROCESS ORDER STATUS NOT VALID : '|| i.order_status;
        RETURN;
      END IF;
    END LOOP;
  END IF;

  -- call insert method
  op_process_order_type := op_process_order_type.ins;

  IF op_process_order_type.response NOT LIKE '%SUCCESS%' THEN
    o_err_code := '102';
    o_err_msg  := op_process_order_type.response;
    RETURN;
  END IF;

  o_err_code := '0';
  o_err_msg  := 'SUCCESS';

 EXCEPTION
   WHEN OTHERS THEN
     o_err_code := '103';
     o_err_msg := SUBSTR(SQLERRM ,1 ,100);
END process_order_insert;

--
PROCEDURE process_order_update ( op_process_order_type IN OUT process_order_type ,
                                 o_err_code            OUT    VARCHAR2           ,
                                 o_err_msg             OUT    VARCHAR2           ) IS
  po  process_order_type := process_order_type ();

BEGIN

  IF op_process_order_type IS NULL THEN
    o_err_code := '104';
    o_err_msg  := 'Process Order Type has no input value';
    RETURN;
  END IF;

  IF op_process_order_type.order_detail IS NOT NULL THEN
    -- validate the invalid status passed in the process_order_type
    FOR i IN ( SELECT pd.order_status
               FROM   TABLE(CAST(op_process_order_type.order_detail AS process_order_detail_tab)) pd
               WHERE NOT EXISTS ( SELECT 1
                                  FROM   sa.x_process_order_status
                                  WHERE  process_order_status = pd.order_Status
                                )
             )
    LOOP
      IF i.order_status IS NOT NULL THEN
        o_err_code := '105';
        o_err_msg  := 'PROCESS ORDER STATUS NOT VALID : '|| i.order_status;
        RETURN;
      END IF;
    END LOOP;
  END IF;
  op_process_order_type := op_process_order_type.upd ( i_process_order_type => op_process_order_type );

  --
  IF op_process_order_type.response NOT LIKE '%SUCCESS%' THEN
    o_err_code := '105';
    o_err_msg  := op_process_order_type.response;
    RETURN;
  END IF;

  IF op_process_order_type.order_detail IS NOT NULL THEN
    BEGIN
      -- Enrich the process order details
      SELECT process_order_detail_type(  pd.process_order_detail_objid ,
                                         pd.process_order_objid        ,
                                         pd.case_objid                 ,
                                         pd.call_trans_objid           ,
                                         pd.order_status               ,
                                         NVL(pd.min,ct.x_min)          ,
                                         customer_info.convert_smp_to_pin ( i_smp => NVL(ext.smp,rc.x_smp ) ),  --PIN
                                         CASE WHEN pi.x_part_inst_status IS NOT NULL THEN pi.x_part_inst_status --PIN_STATUS
                                              WHEN UPPER(rc.x_result) = 'COMPLETED' then '41'
                                         END,
                                         ge.s_title                    ,                                        --CASE_STATUS
                                         DECODE (pi.x_part_inst_status,'44','INVALID',ct.x_action_text),        --ACTION_TEXT
                                         ct.x_result                   ,                                        --CALLTRANS_STATUS
                                         pd.Order_Type                 ,
                                         pd.BAN                        ,
                                         pd.ESN                        ,
                                         NVL(ext.smp,rc.x_smp )        ,
                                         pd.insert_timestamp           ,
                                         pd.update_timestamp           ,
                                         NULL                                                                   -- Response
                                       )
      BULK COLLECT
      INTO  po.order_detail
      FROM  TABLE(CAST(op_process_order_type.order_detail AS process_order_detail_tab)) pd
            LEFT OUTER JOIN table_x_call_trans ct      ON (ct.objid            = pd.call_trans_objid)
            LEFT OUTER JOIN table_x_call_trans_ext ext ON (ct.objid            = ext.call_trans_ext2call_trans)
            LEFT OUTER JOIN table_part_inst pi         ON (pi.x_red_code       = customer_info.convert_smp_to_pin ( i_smp => ext.SMP  ) )
            LEFT OUTER JOIN table_x_red_card rc        ON (rc.red_card2call_trans = ct.objid )
            LEFT OUTER JOIN table_case tc              ON (tc.objid            = pd.case_objid)
            LEFT OUTER JOIN table_gbst_elm ge          ON (tc.casests2gbst_elm = ge.objid)
      WHERE process_order_objid = op_process_order_type.process_order_objid;
    EXCEPTION
      WHEN others THEN
        NULL;
    END;

    -- set values from bulk collect
    op_process_order_type.order_detail := po.order_detail;

  END IF;

  o_err_code := '0';
  o_err_msg  := 'SUCCESS';

 EXCEPTION
   WHEN OTHERS THEN
     o_err_code := '106';
     o_err_msg := SUBSTR(SQLERRM ,1 ,100);
END process_order_update;


PROCEDURE process_order_retrieve ( op_process_order_type IN OUT process_order_type ,
                                   o_err_code            OUT    VARCHAR2           ,
                                   o_err_msg             OUT    VARCHAR2           ) IS

BEGIN

  IF op_process_order_type IS NULL OR ( op_process_order_type.Order_Id IS NULL AND
	                                      op_process_order_type.BRM_Trans_ID IS NULL AND
                                        op_process_order_type.external_order_id IS NULL
										                  )
  THEN
    o_err_code := '107';
    o_err_msg  := 'Process Order Type has no input value';
    RETURN;
  END IF;

  --
  op_process_order_type := process_order_type ( i_order_id          => op_process_order_type.order_id          ,
	                                            i_brm_trans_id      => op_process_order_type.brm_trans_id      ,
                                                i_external_order_id => op_process_order_type.external_order_id ,
                                                i_detail_flag       => 'Y'											               );

  --
  IF op_process_order_type.response NOT LIKE '%SUCCESS%' THEN
    o_err_code := '108';
    o_err_msg  := op_process_order_type.response;
    RETURN;
  END IF;

  -- Fecthing the details
	SELECT process_order_detail_type(pd.objid                ,
								     pd.process_order_objid  ,
									 pd.case_objid           ,
                                     pd.call_trans_objid     ,
                                     pd.order_status         ,
                                     NVL(pd.min,ct.x_min)    ,
                                     customer_info.convert_smp_to_pin ( i_smp => NVL(ext.smp,rc.x_smp ) ),  --PIN
                                     CASE WHEN pi.x_part_inst_status IS NOT NULL THEN pi.x_part_inst_status --PIN_STATUS
                                          WHEN UPPER(rc.x_result) = 'COMPLETED' THEN '41'
                                     END,
                                     ge.s_title              ,                                              --CASE_STATUS
                                     DECODE (pi.x_part_inst_status,'44','INVALID',ct.x_action_text),        --ACTION_TEXT
                                     ct.x_result             ,                                              --CALLTRANS_STATUS
                                     pd.Order_Type           ,
                                     pd.BAN                  ,
                                     pd.ESN                  ,
                                     NVL(ext.smp,rc.x_smp )  ,
                                     pd.insert_timestamp     ,
                                     pd.update_timestamp     ,
                                     NULL                                                                   -- Response
										               )
  BULK COLLECT
  INTO   op_process_order_type.order_detail
  FROM   x_process_order_detail pd
         LEFT OUTER JOIN table_x_call_trans ct      ON (ct.objid            = pd.call_trans_objid)
         LEFT OUTER JOIN table_x_call_trans_ext ext ON (ct.objid            = ext.call_trans_ext2call_trans)
         LEFT OUTER JOIN table_part_inst pi         ON (pi.x_red_code       = customer_info.convert_smp_to_pin(i_smp => ext.SMP  ))
         LEFT OUTER JOIN table_x_red_card rc        ON (rc.red_card2call_trans = ct.objid )
         LEFT OUTER JOIN table_case tc              ON (tc.objid            = pd.case_objid)
         LEFT OUTER JOIN table_gbst_elm ge          ON (tc.casests2gbst_elm = ge.objid)
  WHERE  process_order_objid = op_process_order_type.process_order_objid;

  o_err_code := '0';
  o_err_msg  := 'SUCCESS';

 EXCEPTION
   WHEN OTHERS THEN
     o_err_code := '109';
     o_err_msg := SUBSTR(SQLERRM ,1 ,100);
END process_order_retrieve;

PROCEDURE process_order_retrieve ( op_process_order_type_tab IN OUT process_order_type_tab ,
                                   o_err_code                OUT    VARCHAR2               ,
                                   o_err_msg                 OUT    VARCHAR2               ) IS
BEGIN

  o_err_code := '0';
  o_err_msg  := 'SUCCESS';

  IF op_process_order_type_tab IS NULL THEN
    o_err_code := '110';
    o_err_msg  := 'PROCESS ORDER TYPE TAB HAS NO INPUT VALUE';
    RETURN;
  END IF;

  IF op_process_order_type_tab.COUNT = 0 THEN
    o_err_code := '110';
    o_err_msg  := 'PROCESS ORDER TYPE TAB HAS NO RECORDS';
    RETURN;
  END IF;

  --
	FOR i IN 1..op_process_order_type_tab.COUNT
	LOOP
    op_process_order_type_tab(i) := process_order_type ( i_order_id          => op_process_order_type_tab(i).order_id          ,
                                                         i_brm_trans_id      => op_process_order_type_tab(i).brm_trans_id      ,
                                                         i_external_order_id => op_process_order_type_tab(i).external_order_id ,
														 i_detail_flag       => 'N'                                            );

	  IF op_process_order_type_tab(i).response NOT LIKE '%SUCCESS%' THEN
	    o_err_code := '111';
	    o_err_msg  := op_process_order_type_tab(i).response;
    END IF;
	END LOOP;

 EXCEPTION
   WHEN OTHERS THEN
     o_err_code := '112';
     o_err_msg := SUBSTR(SQLERRM ,1 ,100);
END process_order_retrieve;

END process_order_pkg;
/