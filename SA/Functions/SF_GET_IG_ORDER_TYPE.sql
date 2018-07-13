CREATE OR REPLACE FUNCTION sa."SF_GET_IG_ORDER_TYPE" (  P_PROGRAMME_NAME        in  varchar2,
                                                  P_ACTION_ITEM_OBJID     in  number,
                                                  P_ORDER_TYPE            in  varchar2  default null) return VARCHAR2
IS
/************************************************************************************/
/*    Copyright   2010 Tracfone  Wireless Inc. All rights reserved                       */
/*                                                                                       */
/* NAME:         SF_GET_IG_ORDER_TYPE                                                 */
/* PURPOSE:      To get Order type which will be used to populate IG Transaction's Order Type   */
/* FREQUENCY:                                                                            */
/*                                                                                       */
/* REVISIONS:                                                                            */
/* VERSION  DATE        WHO             PURPOSE                                     */
/* -------  ----------  --------        --------------------------------------------*/
/*  1.0     01/31/11    PMistry         Initial  Revision                           */
/************************************************************************************/

  L_IG_ORDER_TYPE   VARCHAR2(30);
  l_cnt             number;

  cursor CUR_ESN_DETAILS is
            select  tsp.x_min, c.objid carrier_objid, PN.X_TECHNOLOGY, pi.part_serial_no esn, OT.X_ORDER_TYPE
            from    TABLE_TASK T, TABLE_X_CALL_TRANS CT, TABLE_SITE_PART TSP, TABLE_X_CARRIER C,
                    table_part_inst pi, table_mod_level ml, table_part_num pn, table_x_order_type ot
            where   1  = 1
            and     CT.OBJID          = T.X_TASK2X_CALL_TRANS
            and     ot.objid          = T.X_TASK2X_ORDER_TYPE
            and     TSP.OBJID         = CT.CALL_TRANS2SITE_PART
            and     C.OBJID           = CT.X_CALL_TRANS2CARRIER
            and     PI.PART_SERIAL_NO = TSP.X_SERVICE_ID
            and     ML.OBJID          = PI.N_PART_INST2PART_MOD
            and     PN.OBJID          = ML.PART_INFO2PART_NUM
            and     T.OBJID           = P_ACTION_ITEM_OBJID ;

  rec_esn_details   CUR_ESN_DETAILS%rowtype;

  L_ORDER_TYPE_OBJID      number;
begin
      if P_ACTION_ITEM_OBJID is null then
        L_IG_ORDER_TYPE := null;
        return L_IG_ORDER_TYPE;
      end if;

      open CUR_ESN_DETAILS;
      FETCH CUR_ESN_DETAILS into REC_ESN_DETAILS;
      close CUR_ESN_DETAILS;

      IGATE.SP_GET_ORDERTYPE (REC_ESN_DETAILS.X_MIN,
                              nvl(P_ORDER_TYPE, REC_ESN_DETAILS.X_ORDER_TYPE),
                              REC_ESN_DETAILS.carrier_objid,
                              REC_ESN_DETAILS.x_technology,
                              L_ORDER_TYPE_OBJID
                             );
      for I in  ( select OT.X_ORDER_TYPE, OT.X_ORDER_TYPE2X_CARRIER, IGOT.*
                  from   TABLE_X_ORDER_TYPE OT, (select *
                                                 from X_IG_ORDER_TYPE IGOT
                                                 where X_PROGRAMME_NAME        = P_PROGRAMME_NAME) IGOt
                  where  1 = 1
                  and    ot.objid                     = l_order_type_objid
                  and    IGOT.X_ACTUAL_ORDER_TYPE(+)  = OT.X_ORDER_TYPE
                  ORDER BY IGOT.x_priority )
      loop
        if i.x_actual_order_type is not null then
           if i.x_sql_text is not null then
              execute immediate I.X_SQL_TEXT into L_CNT using P_ACTION_ITEM_OBJID;
              if l_cnt > 0 then
                L_IG_ORDER_TYPE := I.X_IG_ORDER_TYPE;
                exit;
              end if;
           else
              L_IG_ORDER_TYPE := I.X_IG_ORDER_TYPE;
           end if;
        ELSE
          L_IG_ORDER_TYPE := SUBSTR(I.x_order_type,1,1);
          exit;
        end if;
      END LOOP;
      return L_IG_ORDER_TYPE;
END SF_GET_IG_ORDER_TYPE;
/