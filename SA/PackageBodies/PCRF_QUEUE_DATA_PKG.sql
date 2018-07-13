CREATE OR REPLACE PACKAGE body sa.pcrf_queue_data_pkg is

/*************************************************************************************************************************************
  * $Revision: 1.7 $
  * $Author: skota $
  * $Date: 2017/10/09 20:54:04 $
  * $Log: PCRF_QUEUE_DATA_PKB.sql,v $
  * Revision 1.7  2017/10/09 20:54:04  skota
  * Added RCF enable flag
  *
  * Revision 1.6  2017/02/09 15:28:39  skota
  * modified
  *
  * Revision 1.5  2017/02/09 15:18:25  skota
  * modified for the addons
  *
  * Revision 1.4  2017/01/25 20:05:17  skota
  * modified for the PCRF db2pcrf
  *
  * Revision 1.3  2016/11/01 13:27:31  skota
  * added exception for the duplicates
  *
  * Revision 1.2  2016/10/21 21:29:16  skota
  * CR45527 db2pcrf Low Priority Performance Improvement
  *
  * Revision 1.1  2016/10/21 21:27:20  skota
  * CR45527 db2pcrf Low Priority Performance Improvement
  *
  * Revision 1.1  2016/10/21 14:58:30  skota
  * CR45527 db2pcrf Low Priority Performance Improvement
  *
  *************************************************************************************************************************************/


 --pcrf low  priority
 PROCEDURE sp_low_priority_pcrf_data (i_rownum           IN  NUMBER DEFAULT 100       ,
                                      i_pcrf_status_code IN  VARCHAR2 DEFAULT 'Q'     ,
                                      o_pcrf_data        OUT pcrf_trans_low_prty_tab  ,
                                      o_data_count       OUT NUMBER                   ) is
  CURSOR c_get_pcrf_data IS
    SELECT pcrf_trans_low_prty_type ( pcrf_transaction_id               ,
                                      min                               ,
                                      mdn                               ,
                                      esn                               ,
                                      subscriber_id                     ,
                                      group_id                          ,
                                      order_type                        ,
                                      phone_manufacturer                ,
                                      action_type                       ,
                                      sim                               ,
                                      zipcode                           ,
                                      service_plan_id                   ,
                                      case_id                           ,
                                      pcrf_status_code                  ,
                                      status_message                    ,
                                      web_objid                         ,
                                      bus_org_id                        ,
                                      sourcesystem                      ,
                                      template                          ,
                                      rate_plan                         ,
                                      blackout_wait_date                ,
                                      retry_count                       ,
                                      data_usage                        ,
                                      total_addon_data_usage            ,
                                      total_data_usage                  ,
                                      hi_speed_data_usage               ,
                                      addon_data_balance                ,
                                      hi_speed_total_data_balance       ,
                                      hi_speed_data_balance             ,
                                      conversion_factor                 ,
                                      dealer_id                         ,
                                      denomination                      ,
                                      pcrf_parent_name                  ,
                                      propagate_flag                    ,
                                      service_plan_type                 ,
                                      part_inst_status                  ,
                                      phone_model                       ,
                                      content_delivery_format           ,
                                      language                          ,
                                      wf_mac_id                         ,
                                      pcrf_cos                          ,
                                      ttl                               ,
                                      future_ttl                        ,
                                      redemption_date                   ,
                                      contact_objid                     ,
                                      insert_timestamp                  ,
                                      update_timestamp                  ,
                                      status                            ,
                                      addons                            ,
                                      imsi                              ,
                                      lifeline_id                       ,
                                      install_date                      ,
                                      program_parameter_id              ,
                                      vmbc_certification_flag           ,
                                      char_field_1                      ,
                                      char_field_2                      ,
                                      char_field_3                      ,
                                      date_field_1                      ,
                                      rcs_enable_flag
                                    )
    FROM   ( SELECT objid pcrf_transaction_id        ,  -- pcrf_transaction_id
                    min                              ,  -- min
                    mdn                              ,  -- mdn
                    esn                              ,  -- esn
                    subscriber_id                    ,  -- subscriber_id
                    group_id                         ,  -- group_id
                    order_type                       ,  -- order_type
                    phone_manufacturer               ,  -- phone_manufacturer
                    action_type                      ,  -- action_type
                    sim                              ,  -- sim
                    zipcode                          ,  -- zipcode
                    service_plan_id                  ,  -- service_plan_id
                    case_id                          ,  -- case_id
                    ptl.pcrf_status_code             ,  -- pcrf_status_code
                    status_message                   ,  -- status_message
                    web_objid                        ,  -- web_objid
                    brand bus_org_id                 ,  -- bus_org_id
                    sourcesystem                     ,  -- sourcesystem
                    template                         ,  -- template
                    rate_plan                        ,  -- rate_plan
                    blackout_wait_date               ,  -- blackout_wait_date
                    retry_count                      ,  -- retry_count
                    data_usage                       ,  -- data_usage
                    NULL total_addon_data_usage      ,  -- total_addon_data_usage
                    NULL total_data_usage            ,  -- total_data_usage
                    hi_speed_data_usage              ,  -- hi_speed_data_usage
                    NULL addon_data_balance          ,  -- addon_data_balance
                    NULL hi_speed_total_data_balance ,  -- hi_speed_total_data_balance
                    NULL hi_speed_data_balance       ,  -- hi_speed_data_balance
                    conversion_factor                ,  -- conversion_factor
                    dealer_id                        ,  -- dealer_id
                    denomination                     ,  -- denomination
                    pcrf_parent_name                 ,  -- pcrf_parent_name
                    propagate_flag                   ,  -- propagate_flag
                    service_plan_type                ,  -- service_plan_type
                    part_inst_status                 ,  -- part_inst_status
                    phone_model                      ,  -- phone_model
                    content_delivery_format          ,  -- content_delivery_format
                    language                         ,  -- language
                    wf_mac_id                        ,  -- wf_mac_id
                    pcrf_cos                         ,  -- pcrf_cos
                    ttl                              ,  -- ttl
                    future_ttl                       ,  -- future_ttl
                    redemption_date                  ,  -- redemption_date
                    contact_objid                    ,  -- contact_objid
                    insert_timestamp                 ,  -- insert_timestamp
                    update_timestamp                 ,  -- update_timestamp
                    NULL                status       ,  -- status
                    NULL                addons       ,  -- addons
                    imsi                             ,  -- imsi
                    lifeline_id                      ,  -- lifeline_id
                    install_date                     ,  -- install_date
                    program_parameter_id             ,  -- program_parameter_id
                    vmbc_certification_flag          ,  -- vmbc_certification_flag
                    char_field_1                     ,  -- char_field_1
                    char_field_2                     ,  -- char_field_2
                    char_field_3                     ,  -- char_field_3
                    date_field_1                     ,   -- date_field_1
                    rcs_enable_flag
             FROM   sa.x_pcrf_trans_low_prty ptl
             WHERE  pcrf_status_code = i_pcrf_status_code
             --ORDER BY NVL(( CASE WHEN ptl.pcrf_status_code = 'QP' THEN 1 ELSE 2 END), 2 )
           )
  WHERE  ROWNUM < i_rownum + 1
  FOR UPDATE OF pcrf_status_code;

 BEGIN

  --
  o_pcrf_data := pcrf_trans_low_prty_tab();

  --
  OPEN c_get_pcrf_data;
  FETCH c_get_pcrf_data BULK COLLECT INTO o_pcrf_data;
  CLOSE c_get_pcrf_data;


  o_data_count := o_pcrf_data.COUNT;

  --
  IF o_pcrf_data IS NULL THEN
    o_data_count := 0;
    RETURN;
  END IF;

  IF o_data_count = 0 THEN
    RETURN;
  END IF;

  --
  FOR i IN 1 .. o_pcrf_data.COUNT LOOP

    BEGIN
      UPDATE sa.x_pcrf_trans_low_prty
      SET    pcrf_status_code = 'L'
      WHERE  objid = o_pcrf_data(i).pcrf_transaction_id;
     EXCEPTION
       WHEN others THEN
         BEGIN
           UPDATE x_pcrf_trans_low_prty
           SET    insert_timestamp = SYSDATE + INTERVAL '1' SECOND
           WHERE  objid = o_pcrf_data(i).pcrf_transaction_id;
           --
           UPDATE sa.x_pcrf_trans_low_prty
           SET    pcrf_status_code = 'L'
           WHERE  objid = o_pcrf_data(i).pcrf_transaction_id;
          EXCEPTION
            WHEN others THEN
              NULL;
         END;
    END;
  --
  END LOOP;

  --
 EXCEPTION
   WHEN others THEN
     DBMS_OUTPUT.PUT_LINE('ERROR : ' || SQLERRM );
     o_data_count := -1;
 END sp_low_priority_pcrf_data;

 --pcrf
 PROCEDURE sp_pcrf_data (i_rownum            IN  NUMBER DEFAULT 100     ,
                         i_pcrf_status_code  IN  VARCHAR2 DEFAULT 'Q'   ,
                         i_pcrf_order_type   IN  VARCHAR2               ,
                         o_pcrf_data         OUT pcrf_transaction_tab   ,
                         o_data_count        OUT NUMBER                 ) is

   CURSOR c_get_pcrf_data IS
    SELECT pcrf_transaction_type ( pcrf_transaction_id               ,
                                   min                               ,
                                   mdn                               ,
                                   esn                               ,
                                   subscriber_id                     ,
                                   group_id                          ,
                                   order_type                        ,
                                   phone_manufacturer                ,
                                   action_type                       ,
                                   sim                               ,
                                   zipcode                           ,
                                   service_plan_id                   ,
                                   case_id                           ,
                                   pcrf_status_code                  ,
                                   status_message                    ,
                                   web_objid                         ,
                                   bus_org_id                        ,
                                   sourcesystem                      ,
                                   template                          ,
                                   rate_plan                         ,
                                   blackout_wait_date                ,
                                   retry_count                       ,
                                   data_usage                        ,
                                   total_addon_data_usage            ,
                                   total_data_usage                  ,
                                   hi_speed_data_usage               ,
                                   addon_data_balance                ,
                                   hi_speed_total_data_balance       ,
                                   hi_speed_data_balance             ,
                                   conversion_factor                 ,
                                   dealer_id                         ,
                                   denomination                      ,
                                   pcrf_parent_name                  ,
                                   propagate_flag                    ,
                                   service_plan_type                 ,
                                   part_inst_status                  ,
                                   phone_model                       ,
                                   content_delivery_format           ,
                                   language                          ,
                                   wf_mac_id                         ,
                                   pcrf_cos                          ,
                                   ttl                               ,
                                   future_ttl                        ,
                                   redemption_date                   ,
                                   contact_objid                     ,
                                   insert_timestamp                  ,
                                   update_timestamp                  ,
                                   status                            ,
                                   low_priority_flag                 ,
                                   addons                            ,
                                   imsi                              ,
                                   lifeline_id                       ,
                                   install_date                      ,
                                   program_parameter_id              ,
                                   vmbc_certification_flag           ,
                                   char_field_1                      ,
                                   char_field_2                      ,
                                   char_field_3                      ,
                                   date_field_1                      ,
								                   addons_flag                       ,
                                   rcs_enable_flag
                                 )
    FROM   ( SELECT objid pcrf_transaction_id        ,  -- pcrf_transaction_id
                    min                              ,  -- min
                    mdn                              ,  -- mdn
                    esn                              ,  -- esn
                    subscriber_id                    ,  -- subscriber_id
                    group_id                         ,  -- group_id
                    order_type                       ,  -- order_type
                    phone_manufacturer               ,  -- phone_manufacturer
                    action_type                      ,  -- action_type
                    sim                              ,  -- sim
                    zipcode                          ,  -- zipcode
                    service_plan_id                  ,  -- service_plan_id
                    case_id                          ,  -- case_id
                    ptl.pcrf_status_code             ,  -- pcrf_status_code
                    status_message                   ,  -- status_message
                    web_objid                        ,  -- web_objid
                    brand bus_org_id                 ,  -- bus_org_id
                    sourcesystem                     ,  -- sourcesystem
                    template                         ,  -- template
                    rate_plan                        ,  -- rate_plan
                    blackout_wait_date               ,  -- blackout_wait_date
                    retry_count                      ,  -- retry_count
                    data_usage                       ,  -- data_usage
                    NULL total_addon_data_usage      ,  -- total_addon_data_usage
                    NULL total_data_usage            ,  -- total_data_usage
                    hi_speed_data_usage              ,  -- hi_speed_data_usage
                    NULL addon_data_balance          ,  -- addon_data_balance
                    NULL hi_speed_total_data_balance ,  -- hi_speed_total_data_balance
                    NULL hi_speed_data_balance       ,  -- hi_speed_data_balance
                    conversion_factor                ,  -- conversion_factor
                    dealer_id                        ,  -- dealer_id
                    denomination                     ,  -- denomination
                    pcrf_parent_name                 ,  -- pcrf_parent_name
                    propagate_flag                   ,  -- propagate_flag
                    service_plan_type                ,  -- service_plan_type
                    part_inst_status                 ,  -- part_inst_status
                    phone_model                      ,  -- phone_model
                    content_delivery_format          ,  -- content_delivery_format
                    language                         ,  -- language
                    wf_mac_id                        ,  -- wf_mac_id
                    pcrf_cos                         ,  -- pcrf_cos
                    ttl                              ,  -- ttl
                    future_ttl                       ,  -- future_ttl
                    redemption_date                  ,  -- redemption_date
                    contact_objid                    ,  -- contact_objid
                    insert_timestamp                 ,  -- insert_timestamp
                    update_timestamp                 ,  -- update_timestamp
                    NULL                status       ,  -- status
					          'N' low_priority_flag            ,
                    NULL                addons       ,  -- addons
                    imsi                             ,  -- imsi
                    lifeline_id                      ,  -- lifeline_id
                    install_date                     ,  -- install_date
                    program_parameter_id             ,  -- program_parameter_id
                    vmbc_certification_flag          ,  -- vmbc_certification_flag
                    char_field_1                     ,  -- char_field_1
                    char_field_2                     ,  -- char_field_2
                    char_field_3                     ,  -- char_field_3
                    date_field_1                     ,  -- date_field_1
					          addons_flag                      ,  -- addons_flag
                    rcs_enable_flag
             FROM   sa.x_pcrf_transaction ptl
             WHERE  pcrf_status_code = i_pcrf_status_code
             AND    order_type IN (SELECT regexp_substr (i_pcrf_order_type, '[^,]+', 1, ROWNUM)
                                     FROM dual
                                  CONNECT BY LEVEL <= LENGTH (regexp_replace (i_pcrf_order_type, '[^,]+'))  + 1)
        )
  WHERE  ROWNUM < i_rownum + 1
  FOR UPDATE OF pcrf_status_code;

 BEGIN
    /*
      Note: The input values for i_pcrf_order_type are multiple order types like 'BI,UP,AD,DL' and these are splitting into
      one by one in the above query(cursor).
    */
  --
  o_pcrf_data := pcrf_transaction_tab();

  --
  OPEN c_get_pcrf_data;
  FETCH c_get_pcrf_data BULK COLLECT INTO o_pcrf_data;
  CLOSE c_get_pcrf_data;

  o_data_count := o_pcrf_data.COUNT;

  --
  IF o_pcrf_data IS NULL THEN
    o_data_count := 0;
    RETURN;
  END IF;

  IF o_data_count = 0 THEN
    RETURN;
  END IF;

  --
  FOR i IN 1 .. o_pcrf_data.COUNT loop

     -- getting addons data information
     SELECT pcrf_transaction_detail_type ( objid               ,
                                           pcrf_transaction_id ,
                                           offer_id            ,
                                           ttl                 ,
                                           future_ttl          ,
                                           redemption_date     ,
                                           offer_name          ,
                                           data_usage          ,
                                           NULL                )
      BULK COLLECT  INTO   o_pcrf_data(i).addons
      FROM   x_pcrf_transaction_detail
      WHERE  pcrf_transaction_id = o_pcrf_data(i).pcrf_transaction_id;

      --
      UPDATE sa.x_pcrf_transaction
      SET    pcrf_status_code = 'L'
      WHERE  objid = o_pcrf_data(i).pcrf_transaction_id;
    --
    end loop;
 EXCEPTION
   WHEN others THEN
     DBMS_OUTPUT.PUT_LINE('ERROR : ' || SQLERRM );
     o_data_count := -1;
 END sp_pcrf_data;

end pcrf_queue_data_pkg;
/