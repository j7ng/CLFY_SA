CREATE OR REPLACE PROCEDURE sa."SP_INS_UPD_SLA_MGMT_PRC" (i_sla_mgmt_typ                                       IN  sla_mgmt_tab_type,
                                                    o_errnum                                             OUT VARCHAR2         ,
                                                    o_errstr                                             OUT VARCHAR2
                                                    )
AS
--Local variable declaration
sla_obj_typ         sla_mgmt_type;

BEGIN

  FOR i IN i_sla_mgmt_typ.FIRST .. i_sla_mgmt_typ.LAST
  LOOP

  sla_obj_typ := i_sla_mgmt_typ(i);

  IF (sla_obj_typ.action = 'SETTLE' OR sla_obj_typ.action = 'OFS_ORDER') THEN

      INSERT INTO sa.x_ivr_sla_mgmt sla
             (OBJID             ,
              ACTION            ,
              STATUS            ,
              LOG_TIME          ,
              ORDER_NUMBER      ,
              STATUS_MESSAGE    ,
              FULFILLMENT_TYPE  ,
              PIN               ,
              ESN               ,
              MIN               ,
              SERVICE_ID        ,
              CALL_TRANS_OBJID  ,
              KEY               ,
              VALUE             ,
              ORDER_LINE_NUMBER ,
              TITLE_OF_TICKET   ,
              ISSUE             ,
              SOURCE_SYSTEM     ,
              BRAND_NAME        ,
              TYPE_OF_ISSUE     ,
              PAYMENT_SOURCE_ID ,
              FULFILLING_PART   ,
              TICKET_NOTE
              )
      VALUES (sequ_x_ivr_sla_mgmt.NEXTVAL   ,
              sla_obj_typ.action            ,
              sla_obj_typ.status            ,
              SYSTIMESTAMP                  ,
              sla_obj_typ.order_number      ,
              sla_obj_typ.status_message    ,
              sla_obj_typ.fulfillment_type  ,
              sla_obj_typ.pin               ,
              sla_obj_typ.esn               ,
              sla_obj_typ.min               ,
              sla_obj_typ.service_id        ,
              sla_obj_typ.call_trans_objid  ,
              sla_obj_typ.key               ,
              sla_obj_typ.value             ,
              sla_obj_typ.order_line_number ,
              sla_obj_typ.title_of_ticket   ,
              sla_obj_typ.issue             ,
              sla_obj_typ.source_system     ,
              sla_obj_typ.brand_name        ,
              sla_obj_typ.type_of_issue     ,
              sla_obj_typ.payment_source_id ,
              sla_obj_typ.fulfilling_part   ,
              sla_obj_typ.ticket_note
              );

  ELSE
      UPDATE sa.x_ivr_sla_mgmt sla
        SET action            = sla_obj_typ.action            ,
            status            = sla_obj_typ.status            ,
            log_time          = SYSTIMESTAMP                  ,
            status_message    = sla_obj_typ.status_message    ,
            fulfillment_type  = sla_obj_typ.fulfillment_type  ,
            pin               = sla_obj_typ.pin               ,
            esn               = sla_obj_typ.esn               ,
            min               = sla_obj_typ.min               ,
            service_id        = sla_obj_typ.service_id        ,
            call_trans_objid  = sla_obj_typ.call_trans_objid  ,
            key               = sla_obj_typ.key               ,
            value             = sla_obj_typ.value             ,
            title_of_ticket   = sla_obj_typ.title_of_ticket   ,
            issue             = sla_obj_typ.issue             ,
            source_system     = sla_obj_typ.source_system     ,
            brand_name        = sla_obj_typ.brand_name        ,
            type_of_issue     = sla_obj_typ.type_of_issue     ,
            payment_source_id = sla_obj_typ.payment_source_id ,
            fulfilling_part   = sla_obj_typ.fulfilling_part   ,
            ticket_note       = sla_obj_typ.ticket_note
  WHERE sla.order_number      = sla_obj_typ.order_number
  AND   sla.order_line_number = sla_obj_typ.order_line_number;

  END IF;

       o_errnum := 0;
       o_errstr := 'SUCCESS';

  END LOOP;

   EXCEPTION
       WHEN OTHERS THEN
       o_errnum := -1;
       o_errstr := 'sp_ins_upd_sla_mgmt_prc:  '||substr(sqlerrm,1,100);
       util_pkg.insert_error_tab ( i_action       => 'SLA MANAGEMENT',
                                   i_key          => sla_obj_typ.esn,
                                   i_program_name => 'sp_ins_upd_sla_mgmt_prc',
                                   i_error_text   => o_errstr );

END sp_ins_upd_sla_mgmt_prc;
/