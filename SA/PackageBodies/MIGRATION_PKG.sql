CREATE OR REPLACE PACKAGE BODY sa.migration_pkg AS
  ------------------------------------------------------------------------
  --$RCSfile: migration_pkb.sql,v $
  --$Revision: 1.111 $
  --$Author: vnainar $
  --$Date: 2017/05/09 17:53:45 $
  --$ $Log: migration_pkb.sql,v $
  --$ Revision 1.111  2017/05/09 17:53:45  vnainar
  --$ CR49721 credit card cursor updated
  --$
  --$ Revision 1.110  2017/05/09 15:34:24  vnainar
  --$ CR49721 credit card cursor updated
  --$
  --$ Revision 1.109  2017/05/08 14:10:51  vnainar
  --$ CR49721  update web account security pin
  --$
  --$ Revision 1.108  2017/04/27 18:44:41  vnainar
  --$ CR49882 contact fix to create new contact for WFM
  --$
  --$ Revision 1.107  2017/04/27 16:43:25  sraman
  --$ Fix the issue with reusing the existing contact.
  --$
  --$ Revision 1.105  2017/04/14 18:57:17  vnainar
  --$ CR49087 email id update  changes
  --$
  --$ Revision 1.104  2017/04/14 14:25:05  vnainar
  --$ CR49087 web user update changes
  --$
  --$ Revision 1.103  2017/04/12 21:17:50  vnainar
  --$ CR49087 Interaction procedure added for bill extract
  --$
  --$ Revision 1.102  2017/04/11 22:40:53  vnainar
  --$ CR49087 firstname and lastname changes for credit card ach
  --$
  --$ Revision 1.101  2017/04/11 22:21:06  vnainar
  --$ CR49807 interaction Load changes
  --$
  --$ Revision 1.100  2017/04/11 13:14:14  vnainar
  --$ premigration and async error enhancements
  --$
  --$ Revision 1.99  2017/04/07 21:50:27  vnainar
  --$ CR48944 index hint added and remainder and divisor added in more rows exist
  --$
  --$ Revision 1.98  2017/04/07 18:52:35  smeganathan
  --$ Added divisor and remainder for load_wfm_interaction
  --$
  --$ Revision 1.97  2017/04/06 22:42:22  vnainar
  --$ CR48944 sysdate changes and  async response changes
  --$
  --$ Revision 1.96  2017/04/06 16:15:59  vnainar
  --$ CR47564  fixed sequence for async_request_log
  --$
  --$ Revision 1.95  2017/04/04 22:15:15  sgangineni
  --$ CR47564 - modified load_wfm_cc_data and load_wfm_ach_data to pick the city and state
  --$  from table_x_zip_code
  --$
  --$ Revision 1.94  2017/04/04 21:57:59  vnainar
  --$ CR47564 added enhancements in credit card and ach procedure
  --$
  --$ Revision 1.93  2017/04/03 22:47:10  vnainar
  --$ CR47564 updated premigration and final migration for updatecontact prc changes
  --$
  --$ Revision 1.92  2017/04/03 16:24:22  sgangineni
  --$ CR47564 - changes in CC and ACH loading procedures
  --$
  --$ Revision 1.91  2017/03/31 23:22:40  vnainar
  --$ CR47564 added web contact changes
  --$
  --$ Revision 1.90  2017/03/31 14:43:40  smeganathan
  --$ CR47564 WFM added BAN contact creation without associating the contact to PHONE and MIN
  --$
  --$ Revision 1.89  2017/03/30 21:15:05  vnainar
  --$ CR47564 commit removed from load_wfm_final_migration and sim status parameter updated to 180
  --$
  --$ Revision 1.88  2017/03/30 16:25:47  vnainar
  --$ CR47564 igtb_wfm_async_type moved to wfmmig schema
  --$
  --$ Revision 1.87  2017/03/28 20:48:15  vnainar
  --$ CR47564 fixed ig creation issue by passing correct task id in async
  --$
  --$ Revision 1.86  2017/03/24 21:21:14  nsurapaneni
  --$ load_wfm_interaction Proc changes
  --$
  --$ Revision 1.84  2017/03/22 22:29:41  nsurapaneni
  --$ Added load_wfm_interaction Proc
  --$
  --$ Revision 1.83  2017/03/22 21:18:54  vnainar
  --$ CR47564 assigned user objid directly in load_wfm_final_migration
  --$
  --$ Revision 1.82  2017/03/20 23:04:56  vnainar
  --$ CR47564 performance enhancements added
  --$
  --$ Revision 1.81  2017/03/20 19:11:24  smeganathan
  --$ added procedures to load payment source details
  --$
  --$ Revision 1.80  2017/03/17 20:24:29  vnainar
  --$ CR47564 expiration date added
  --$
  --$ Revision 1.79  2017/03/14 23:01:04  vnainar
  --$ CR47564 process_wfm_async enhancements
  --$
  --$ Revision 1.78  2017/03/13 20:39:33  vnainar
  --$ CR47564 updated delta processing logic in wfm final migration and added new procedure to update sim status
  --$
  --$ Revision 1.77  2017/03/13 18:18:33  vnainar
  --$ CR47564 updated process_wfm_async
  --$
  --$ Revision 1.76  2017/03/11 00:46:50  vnainar
  --$ CR47564 language logic updated in wfm premigration
  --$
  --$ Revision 1.75  2017/03/10 20:35:08  smeganathan
  --$ added get_sim_legacy_flag function
  --$
  --$ Revision 1.74  2017/03/10 16:26:48  smeganathan
  --$ CR47564 WFM added created wrapper procedure process_wfm_async to call process_wfm_async_full and changed wfm_customer_status field to wfm_bill_customer_status in x_wfm_customer_status_mapping table
  --$
  --$ Revision 1.73  2017/03/08 16:37:19  vnainar
  --$ CR47564 enqueue call added in process_wfm_async
  --$
  --$ Revision 1.72  2017/03/03 23:58:29  vnainar
  --$ CR47564 sysdate enhancements added
  --$
  --$ Revision 1.71  2017/03/03 00:05:34  vnainar
  --$ CR47564  service_plan_hist insert ,update added for WFM
  --$
  --$ Revision 1.70  2017/03/02 21:20:59  vnainar
  --$ CR47564 cc and ach code commented
  --$
  --$ Revision 1.69  2017/03/02 21:19:04  vnainar
  --$ CR47564 sph code commented
  --$
  --$ Revision 1.68  2017/03/02 21:15:09  vnainar
  --$ CR47564 new function get_legacy_flag added
  --$
  --$ Revision 1.67  2017/03/01 22:54:46  vnainar
  --$ CR47564 interactions added in process_wfm_async
  --$
  --$ Revision 1.66  2017/02/28 22:06:13  vnainar
  --$ process_wfm_async updated oresponse assigned oracle errmsg in case of unhandled exception
  --$
  --$ Revision 1.65  2017/02/28 21:59:52  vnainar
  --$ CR47564 process_wfm_async procedure signature updated
  --$
  --$ Revision 1.64  2017/02/24 19:24:10  vnainar
  --$ CR47564 overloaded  load_wfm_final_migration converted to wrapper
  --$
  --$ Revision 1.63  2017/02/23 21:35:12  vnainar
  --$ CR47564 process_wfm_async enhancements added
  --$
  --$ Revision 1.62  2017/02/22 23:15:15  vnainar
  --$ CR47564 process_wfm_async enhancements added
  --$
  --$ Revision 1.61  2017/02/21 23:04:36  vnainar
  --$ CR47564 process_wfm_async enhancements added
  --$
  --$ Revision 1.60  2017/02/20 23:09:24  vnainar
  --$ CR47564 async procedure and wfm final migration updated
  --$
  --$ Revision 1.59  2017/02/16 23:03:04  vnainar
  --$ CR47564 WFM  enhancements added and  status mapping procedure added
  --$
  --$ Revision 1.58  2017/02/15 23:14:41  vnainar
  --$ CR47564 new wfm premigration and async procedures added
  --$
  --$ Revision 1.57  2017/02/07 18:25:52  vnainar
  --$ cleanup procedure added
  --$
  --$ Revision 1.56  2017/02/02 22:53:37  vlaad
  --$ Updated for PINs
  --$
  --$ Revision 1.54  2017/01/26 22:23:48  vlaad
  --$ Merged with PROD
  --$
  --$ Revision 1.52  2017/01/26 16:52:42  vlaad
  --$ Updated to exclude call_trans_type
  --$
  --$ Revision 1.39  2017/01/17 23:16:34  vlaad
  --$ Updated create_cash_balance_tran and Process_cash_balance signatures
  --$
  --$ Revision 1.37  2017/01/13 23:23:53  vnainar
  --$ CR46581 cash balance procedure updated
  --$
  --$ Revision 1.36  2017/01/13 17:02:33  vnainar
  --$ CR46581 new procedure added forcash balance
  --$
  --$ Revision 1.35  2017/01/12 16:41:02  vnainar
  --$ CR46581 code updated as suggested by Juda
  --$
  --$ Revision 1.34  2017/01/12 14:23:56  vlaad
  --$ Added Juda's comment
  --$
  --$ Revision 1.33  2017/01/10 22:01:57  vlaad
  --$ Updated final migration for throttling
  --$
  --$ Revision 1.32  2017/01/04 16:12:57  vnainar
  --$ CR46581 queued cards code commented in final migration
  --$
  --$ Revision 1.31  2017/01/03 17:07:22  vnainar
  --$ CR46581 new parameter skip_premigration added in final migration
  --$
  --$ Revision 1.30  2016/12/30 21:58:44  vnainar
  --$ CR46581 new columns and call trans existence check added for rerun
  --$
  --$ Revision 1.29  2016/12/28 18:16:54  vnainar
  --$ CR44729  city and state mapping updated for updatecontactprc
  --$
  --$ Revision 1.28  2016/12/27 23:12:06  vnainar
  --$ CR44729 table_contact_role exception updated
  --$
  --$ Revision 1.27  2016/12/23 20:28:09  pamistry
  --$ CR44729 Fixing l_flag initialing to avoid multiple site part insert for same esn
  --$
  --$ Revision 1.26  2016/12/23 20:12:13  pamistry
  --$ CR44729 Fix the type initialization for Site_Part_Type
  --$
  --$ Revision 1.25  2016/12/23 16:14:21  sraman
  --$ CR 44729 - Defect Fix
  --$
  --$ Revision 1.22  2016/12/21 22:43:48  sraman
  --$ CR44729- not to fail the network migration if the PCRF transaction is not generated
  --$
  --$ Revision 1.21  2016/12/20 20:02:25  sraman
  --$ CR44729 - Modify the final migration procedure to fix repeating call trans ID in STG table
  --$
  --$ Revision 1.20  2016/12/16 22:30:13  pamistry
  --$ CR44729 - Modify the interaction input value and Sim status
  --$
  --$ Revision 1.19  2016/12/16 20:07:29  vnainar
  --$ CR44729 interactions added in final migration
  --$
  --$ Revision 1.18  2016/12/16 18:57:39  pamistry
  --$ CR44729 Modify final migration procedure to correct the next due date value for call trans
  --$
  --$ Revision 1.17  2016/12/16 16:21:40  pamistry
  --$ CR44729 Added Failure count
  --$
  --$ Revision 1.16  2016/12/15 21:13:54  vnainar
  --$ CR44729 removed pph and ppd inserts
  --$
  --$ Revision 1.15  2016/12/15 18:42:02  pamistry
  --$ CR44729 - Modify the final migration procedure to handle failure in updates, modify the procedure name based on review comment
  --$
  --$ Revision 1.14  2016/12/14 23:27:08  vnainar
  --$ CR44729 new overloaded procedure added
  --$
  --$ Revision 1.13  2016/12/14 16:32:27  pamistry
  --$ CR44729 Added exception handler inside the loop.
  --$
  --$ Revision 1.12  2016/12/13 19:12:07  pamistry
  --$ CR44729 Modify final migration script to update the phone, min and sim status based on customer_status. Added commit.
  --$
  --$ Revision 1.9  2016/12/08 16:42:12  vnainar
  --$ CR44729 dealer_inv_bin mapping updated
  --$
  --$ Revision 1.8  2016/12/06 20:08:18  vnainar
  --$ CR44729 Temporay dealer updated
  --$
  --$ Revision 1.7  2016/12/02 18:46:54  vnainar
  --$ CR44729 response error fixed
  --$
  --$ Revision 1.6  2016/12/02 18:00:51  vnainar
  --$ CR44729 Error codes fine tuned
  --$
  --$ Revision 1.5  2016/12/01 18:31:32  vnainar
  --$ CR44729 language updated
  --$
  --$ Revision 1.4  2016/11/30 22:54:13  vnainar
  --$ CR44729 errors fixed
  --$
  --$ Revision 1.3  2016/11/30 22:43:03  vnainar
  --$ CR44729 enrollment and credit tables removed
  --$
  --$ Revision 1.2  2016/11/30 22:41:27  vnainar
  --$ CR44279 dependent tables commented
  --$
  --$ Revision 1.1  2016/11/30 22:11:03  vnainar
  --$ CR44729 Migration pkg added
  --$
  --$
  -------------------------------------------------------------------------

-- Function to get customer type attributes using the modular customer type functions instead of retrieve function
FUNCTION get_customer_type_attributes ( i_esn IN VARCHAR2 ) RETURN customer_type IS

  --
  c         customer_type   :=  customer_type ();
  cst       customer_type   :=  customer_type ();
  --
BEGIN
  --
  c.esn   :=  i_esn;
  --
  c                        := c.get_web_user_attributes;
  cst.contact_objid        := c.contact_objid;
  cst.web_user_objid       := c.web_user_objid;
  --
  c                        := customer_type ();
  c                        := c.get_part_class_attributes ( i_esn => i_esn );
  cst.phone_manufacturer   := c.phone_manufacturer;
  cst.technology           := c.technology;
  --
  c                        := c.get_service_plan_attributes;
  cst.site_part_status     := c.site_part_status;
  cst.zipcode              := c.zipcode;
  cst.iccid                := c.iccid;
  --
  c                        := customer_type ();
  c                        := c.get_cos_attributes  ( i_esn => i_esn );
  cst.esn                  := c.esn                 ;
  cst.esn_part_inst_objid  := c.esn_part_inst_objid ;
  cst.min_part_inst_objid  := c.min_part_inst_objid ;
  cst.carrier_objid        := c.carrier_objid       ;
  cst.wf_mac_id            := c.wf_mac_id           ;
  cst.parent_name          := c.parent_name         ;
  cst.site_part_objid      := c.site_part_objid     ;
  cst.min                  := c.min                 ;
  cst.install_date         := c.install_date        ;
  cst.esn_part_inst_status := c.esn_part_inst_status;
  cst.service_plan_objid   := c.service_plan_objid  ;
  cst.cos                  := c.cos                 ;
  cst.bus_org_id           := c.bus_org_id          ;
  cst.bus_org_objid        := c.bus_org_objid       ;
  cst.part_class_name      := c.part_class_name     ;
  cst.part_class_objid     := c.part_class_objid    ;
  cst.inv_bin_objid        := c.inv_bin_objid       ;
  cst.dealer_id            := c.dealer_id           ;
  cst.site_id              := c.site_id             ;
  --
  cst.expiration_date      := c.get_expiration_date ( i_esn => i_esn );
  -- get the rate plan
  cst.rate_plan            := c.get_rate_plan ( i_esn => i_esn );
  --
  cst.response := 'SUCCESS';
  --
  RETURN cst;
  --
EXCEPTION
  WHEN OTHERS THEN
    cst.response := 'FAILED GET_CUSTOMER_TYPE_ATTRIBUTES '|| SUBSTR (SQLERRM, 1,500);
    RETURN cst;
END get_customer_type_attributes;

FUNCTION get_gosmart_service_plan ( i_source            IN VARCHAR2,
                                     i_service_plan      IN VARCHAR2,
                                     i_auto_refill_flag  IN VARCHAR2 DEFAULT 'N',
                                     i_ild_service       IN VARCHAR2 DEFAULT 'N') RETURN VARCHAR2 DETERMINISTIC IS
BEGIN
  IF i_source = 'GOSMART' THEN
    IF i_ild_service = 'N'
       AND i_auto_refill_flag = 'N' THEN
      RETURN (CASE
                WHEN i_service_plan = '2' THEN '449'
                WHEN i_service_plan = '3' THEN '451'
                WHEN i_service_plan = '4' THEN '453'
                WHEN i_service_plan = '5' THEN '455'
                WHEN i_service_plan = '69' THEN '455'
                ELSE NULL
              END);
    ELSIF i_ild_service = 'Y'
          AND i_auto_refill_flag = 'N' THEN
      RETURN (CASE
                WHEN i_service_plan = '3' THEN '472'
                WHEN i_service_plan = '4' THEN '474'
                WHEN i_service_plan = '5' THEN '476'
                WHEN i_service_plan = '69' THEN '478'
                ELSE NULL
              END);
    ELSIF i_ild_service = 'Y'
          AND i_auto_refill_flag = 'Y' THEN
      RETURN (CASE
                WHEN i_service_plan = '3' THEN '473'
                WHEN i_service_plan = '4' THEN '475'
                WHEN i_service_plan = '5' THEN '477'
                WHEN i_service_plan = '69' THEN '479'
                ELSE NULL
              END);
    ELSIF i_ild_service = 'N'
          AND i_auto_refill_flag = 'Y' THEN
      RETURN (CASE
                WHEN i_service_plan = '3' THEN '450'
                WHEN i_service_plan = '4' THEN '452'
                WHEN i_service_plan = '5' THEN '454'
                WHEN i_service_plan = '69' THEN '456'
                ELSE NULL
              END);
    ELSE
      RETURN NULL;
    END IF;
  ELSE
    RETURN NULL;
  END IF;
 EXCEPTION
   WHEN OTHERS THEN
     RETURN NULL;
END get_gosmart_service_plan;

FUNCTION get_program_id (i_source IN VARCHAR2, i_service_plan IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC IS
BEGIN
  IF i_source = 'GOSMART' THEN
    RETURN (CASE
              WHEN i_service_plan = '454' THEN '5803336'
              --     WHEN i_service_plan ='458' THEN '5803341'
              WHEN i_service_plan = '473' THEN '5803342'
              WHEN i_service_plan = '475' THEN '5803344'
              WHEN i_service_plan = '477' THEN '5803346'
              WHEN i_service_plan = '479' THEN '5803348'
              WHEN i_service_plan = '456' THEN '5803338'
              --  WHEN i_service_plan ='457' THEN '5803340'
              WHEN i_service_plan = '450' THEN '5803332'
              WHEN i_service_plan = '452' THEN '5803334'
              ELSE NULL
            END);
  ELSE
    RETURN NULL;
  END IF;
 EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_program_id;

FUNCTION get_price (i_program_param_objid IN NUMBER) RETURN NUMBER IS
  n_enroll_fee  NUMBER (8, 2) := '0.0';
BEGIN
  SELECT (price1.x_retail_price + price2.x_retail_price) enroll_fee
  INTO   n_enroll_fee
  FROM   x_program_parameters param,
         table_part_num pn,
         table_x_pricing price1,
         table_x_pricing price2
  WHERE  1 = 1
  AND    param.objid = i_program_param_objid
  AND    param.prog_param2prtnum_monfee = price1.x_pricing2part_num
  AND    param.prog_param2prtnum_enrlfee = pn.objid
  AND    param.prog_param2prtnum_enrlfee = price2.x_pricing2part_num
  AND    SYSDATE BETWEEN price1.x_start_date AND price1.x_end_date
  AND    SYSDATE BETWEEN price2.x_start_date AND price2.x_end_date;


  RETURN n_enroll_fee;
EXCEPTION
  WHEN OTHERS THEN
    RETURN '0.0';
END get_price;

PROCEDURE get_gosmart_status_mappings ( i_status              IN  VARCHAR2,
                                        o_phone_status_objid  OUT NUMBER,
                                        o_phone_status_code   OUT VARCHAR2,
                                        o_line_status_objid   OUT NUMBER,
                                        o_line_status_code    OUT VARCHAR2,
                                        o_sim_status_objid    OUT NUMBER,
                                        o_sim_status_code     OUT VARCHAR2,
                                        o_site_part_status    OUT VARCHAR2) IS
BEGIN
  o_phone_status_objid := CASE i_status
                            WHEN 'PAID' THEN 988
                            WHEN 'PAY PER DAY' THEN 990
                            WHEN 'CANCELLED' THEN 990
                            WHEN 'SUSPEND' THEN 990
                            WHEN 'NOT PAID' THEN 990
                            WHEN 'PREACTIVE' THEN 986
                          END;
  o_phone_status_code := CASE i_status
                           WHEN 'PAID' THEN '52'
                           WHEN 'PAY PER DAY' THEN '54'
                           WHEN 'CANCELLED' THEN '54'
                           WHEN 'SUSPEND' THEN '54'
                           WHEN 'NOT PAID' THEN '54'
                           WHEN 'PREACTIVE' THEN '50'
                         END;
  o_line_status_objid := CASE i_status
                           WHEN 'PAID' THEN 960
                           WHEN 'PAY PER DAY' THEN 1040
                           WHEN 'CANCELLED' THEN 963
                           WHEN 'SUSPEND' THEN 1040
                           WHEN 'NOT PAID' THEN 1040
                           WHEN 'PREACTIVE' THEN 958
                         END;
  o_line_status_code := CASE i_status
                          WHEN 'PAID' THEN '13'
                          WHEN 'PAY PER DAY' THEN '39'
                          WHEN 'CANCELLED' THEN '17'
                          WHEN 'SUSPEND' THEN '39'
                          WHEN 'NOT PAID' THEN '39'
                          WHEN 'PREACTIVE' THEN '11'
                        END;
  o_sim_status_objid := CASE i_status
                          WHEN 'PAID' THEN 268438607
                          WHEN 'PAY PER DAY' THEN 268438604
                          WHEN 'CANCELLED' THEN 268438609
                          WHEN 'SUSPEND' THEN 268438604
                          WHEN 'NOT PAID' THEN 268438604
                          WHEN 'PREACTIVE' THEN 268438606
                        END;
  o_sim_status_code := CASE i_status
                         WHEN 'PAID' THEN '254'
                         WHEN 'PAY PER DAY' THEN '251' --251  Reserved  268438604
                         WHEN 'CANCELLED' THEN '250'
                         WHEN 'SUSPEND' THEN '251'
                         WHEN 'NOT PAID' THEN '251'
                         WHEN 'PREACTIVE' THEN '253'
                       END;
  o_site_part_status := CASE i_status
                          WHEN 'PAID' THEN 'Active'
                          WHEN 'PAY PER DAY' THEN 'Inactive'
                          WHEN 'CANCELLED' THEN 'Inactive'
                          WHEN 'SUSPEND' THEN 'Inactive'
                          WHEN 'NOT PAID' THEN 'Inactive'
                          WHEN 'PREACTIVE' THEN 'Inactive'
                        END;
END get_gosmart_status_mappings;

PROCEDURE get_wfm_status_mappings ( i_status              IN  VARCHAR2,
                                    o_phone_status_objid  OUT NUMBER,
                                    o_phone_status_code   OUT VARCHAR2,
                                    o_line_status_objid   OUT NUMBER,
                                    o_line_status_code    OUT VARCHAR2,
                                    o_sim_status_objid    OUT NUMBER,
                                    o_sim_status_code     OUT VARCHAR2,
                                    o_site_part_status    OUT VARCHAR2,
                                    o_response            OUT VARCHAR2) IS
BEGIN


  SELECT   tf_phone_status_objid  ,
           tf_phone_status_code   ,
           tf_line_status_objid   ,
           tf_line_status_code    ,
           tf_sim_status_objid    ,
           tf_sim_status_code     ,
           tf_site_part_status
  INTO     o_phone_status_objid  ,
           o_phone_status_code   ,
           o_line_status_objid   ,
           o_line_status_code    ,
           o_sim_status_objid    ,
           o_sim_status_code     ,
           o_site_part_status
  FROM x_wfm_customer_status_mapping
  WHERE wfm_async_customer_status = UPPER(i_status);


  --
  o_response := 'SUCCESS';
  --
/*
  o_phone_status_objid := CASE i_status
                            WHEN 'A' THEN 988
                            WHEN 'C' THEN 990
                            WHEN 'S' THEN 990
                          END;
  o_phone_status_code := CASE i_status
                           WHEN 'A' THEN '52'
                           WHEN 'C' THEN '54'
                           WHEN 'S' THEN '54'
                         END;
  o_line_status_objid := CASE i_status
                           WHEN 'A' THEN 960
                           WHEN 'C' THEN 963
                           WHEN 'S' THEN 1040
                         END;
  o_line_status_code := CASE i_status
                          WHEN 'A' THEN '13'
                          WHEN 'C' THEN '17'
                          WHEN 'S' THEN '39'
                        END;
  o_sim_status_objid := CASE i_status
                          WHEN 'A' THEN 268438607
                          WHEN 'C' THEN 268438609
                          WHEN 'S' THEN 268438604
                        END;
  o_sim_status_code := CASE i_status
                         WHEN 'A' THEN '254'
                         WHEN 'C' THEN '250'
                         WHEN 'S' THEN '251'
                       END;
  o_site_part_status := CASE i_status
                          WHEN 'A' THEN 'Active'
                          WHEN 'C' THEN 'Inactive'
                          WHEN 'S' THEN 'Inactive'
                        END;*/
EXCEPTION
  WHEN NO_DATA_FOUND THEN
   o_response := 'INVALID CUSTOMER STATUS';
  WHEN OTHERS THEN
   o_response := substr(sqlerrm,1,100);
END get_wfm_status_mappings;
--
PROCEDURE ins_part_inst ( i_part_inst_type  IN OUT part_inst_type,
                          o_response           OUT VARCHAR2) IS
  pi  part_inst_type := part_inst_type ();
BEGIN
  NULL;
END ins_part_inst;

PROCEDURE ins_pi_hist ( i_pi_hist_type  IN OUT pi_hist_type,
                        o_response      OUT    VARCHAR2) IS
  ph  pi_hist_type := pi_hist_type ();
BEGIN
  ph := i_pi_hist_type;
  ph := ph.ins;
  i_pi_hist_type := ph;
  o_response := ph.response;
END ins_pi_hist;

--
PROCEDURE ins_site_part ( i_site_part_type IN OUT site_part_type,
                          o_response       OUT    VARCHAR2) IS
--sp   site_part_type := site_part_type();
--l_sp site_part_type := site_part_type();
BEGIN

    IF NOT i_site_part_type.exist ( i_site_part_type => i_site_part_type ) THEN -- Site part record is not found
      i_site_part_type := i_site_part_type.ins;
    ELSE
      i_site_part_type := i_site_part_type.upd ( i_site_part_type => i_site_part_type );
    END IF;

   o_response := i_site_part_type.response;

END ins_site_part;

PROCEDURE ins_web_user ( i_web_user_type  IN OUT web_user_type,
                         o_response          OUT VARCHAR2) IS
--wu  web_user_type := web_user_type();
BEGIN

    IF NOT i_web_user_type.exist (i_web_user_type => i_web_user_type) THEN -- Web_user is not found
      i_web_user_type := i_web_user_type.ins;
    ELSE
      i_web_user_type := i_web_user_type.upd (i_web_user_type => i_web_user_type);
    END IF;

  o_response := i_web_user_type.response;
END ins_web_user;

PROCEDURE ins_contact_part_inst ( i_contact_part_inst_type  IN OUT contact_part_inst_type,
                                  o_response                   OUT VARCHAR2) IS
--cpi  contact_part_inst_type := contact_part_inst_type();
BEGIN

    IF NOT i_contact_part_inst_type.exist ( i_contact_part_inst_type => i_contact_part_inst_type ) THEN
      i_contact_part_inst_type := i_contact_part_inst_type.ins;
    ELSE
      i_contact_part_inst_type := i_contact_part_inst_type.upd ( i_contact_part_inst_type => i_contact_part_inst_type );
    END IF;

  o_response := i_contact_part_inst_type.response;
END ins_contact_part_inst;

PROCEDURE ins_service_plan_site_part ( i_service_plan_site_part_type  IN OUT service_plan_site_part_type,
                                       o_response                        OUT VARCHAR2) IS

BEGIN

    IF NOT i_service_plan_site_part_type.exist ( i_service_plan_site_part_type => i_service_plan_site_part_type) THEN -- Site part record is not found
      i_service_plan_site_part_type := i_service_plan_site_part_type.ins;
    ELSE
      i_service_plan_site_part_type := i_service_plan_site_part_type.upd ( i_service_plan_site_part_type => i_service_plan_site_part_type);
    END IF;

END ins_service_plan_site_part;

PROCEDURE ins_service_plan_hist ( i_service_plan_hist_type  IN OUT service_plan_hist_type,
                                  o_response                OUT    VARCHAR2) IS
  --sph  service_plan_hist_type := service_plan_hist_type ();
BEGIN

    IF NOT i_service_plan_hist_type.exist ( i_service_plan_hist_type => i_service_plan_hist_type) THEN -- Site part record is not found
      i_service_plan_hist_type := i_service_plan_hist_type.ins;
    ELSE
      i_service_plan_hist_type := i_service_plan_hist_type.upd ( i_service_plan_hist_type => i_service_plan_hist_type);
    END IF;
END ins_service_plan_hist;

PROCEDURE ins_program_enrolled ( i_program_enrolled_type  IN OUT program_enrolled_type,
                                 o_response               OUT    VARCHAR2) IS
BEGIN
  IF l_flag = 'Insert' THEN
    i_program_enrolled_type := i_program_enrolled_type.ins;
  ELSE
    IF NOT i_program_enrolled_type.exist (i_program_enrolled_type => i_program_enrolled_type) THEN -- PGM Enrolled record is not found
      i_program_enrolled_type := i_program_enrolled_type.ins;
    ELSE
      i_program_enrolled_type := i_program_enrolled_type.upd ( i_program_enrolled_type => i_program_enrolled_type );
    END IF;
  END IF;

  o_response := i_program_enrolled_type.response;

END ins_program_enrolled;


PROCEDURE ins_program_purch_hdr ( i_program_purch_hdr_type  IN OUT program_purch_hdr_type,
                                  i_esn                     IN     VARCHAR2,
                                  o_response                OUT    VARCHAR2) IS
  --pph  program_purch_hdr_type := program_purch_hdr_type();
  l_program_purch_hdr_objid  NUMBER;
BEGIN
  IF l_flag = 'Insert' THEN
    i_program_purch_hdr_type := i_program_purch_hdr_type.ins;
  ELSE
    IF NOT i_program_purch_hdr_type.exist ( i_esn                      => i_esn,
                                            o_program_purch_hdr_objid  => l_program_purch_hdr_objid) THEN --  not found
      i_program_purch_hdr_type := i_program_purch_hdr_type.ins;
    ELSE
      i_program_purch_hdr_type.program_purch_hdr_objid := l_program_purch_hdr_objid;
      i_program_purch_hdr_type := i_program_purch_hdr_type.upd ( i_program_purch_hdr_type => i_program_purch_hdr_type );
    END IF;
  END IF;

  --pph := i_program_purch_hdr_type;
  --pph := pph.ins;
  --i_program_purch_hdr_type := pph;
  o_response := i_program_purch_hdr_type.response;
END ins_program_purch_hdr;

--
PROCEDURE ins_program_purch_dtl ( i_program_purch_dtl_type  IN OUT program_purch_dtl_type,
                                  o_response                OUT    VARCHAR2) IS
--ppd  program_purch_dtl_type := program_purch_dtl_type();
BEGIN
  IF l_flag = 'Insert' THEN
    i_program_purch_dtl_type := i_program_purch_dtl_type.ins;
  ELSE
    IF NOT i_program_purch_dtl_type.exist ( i_program_purch_dtl_type => i_program_purch_dtl_type ) THEN -- PGM Enrolled record is not found
      i_program_purch_dtl_type := i_program_purch_dtl_type.ins;
    ELSE
      i_program_purch_dtl_type := i_program_purch_dtl_type.upd ( i_program_purch_dtl_type => i_program_purch_dtl_type );
    END IF;
  END IF;

  o_response := i_program_purch_dtl_type.response;
--ppd := i_program_purch_dtl_type;
--ppd := ppd.ins;
--i_program_purch_dtl_type := ppd;
--o_response               := ppd.response;
END ins_program_purch_dtl;


PROCEDURE ins_program_trans ( i_program_trans_type  IN OUT program_trans_type,
                              o_response               OUT VARCHAR2) IS
  pt  program_trans_type := program_trans_type ();
BEGIN
  pt := i_program_trans_type;

  IF NOT pt.exist (i_program_trans_type => i_program_trans_type) THEN
    pt := pt.ins;
  END IF;

  i_program_trans_type := pt;
  o_response := pt.response;
END ins_program_trans;


PROCEDURE ins_call_trans ( i_call_trans_type  IN OUT call_trans_type,
                           o_response            OUT VARCHAR2) IS
  ct  call_trans_type := call_trans_type ();
BEGIN
  ct := i_call_trans_type;
  ct := ct.ins;
  i_call_trans_type := ct;
  o_response := ct.response;
END ins_call_trans;

--
PROCEDURE ins_subscriber_spr ( i_subscriber_type  IN OUT subscriber_type,
                               o_response            OUT VARCHAR2) IS
  sub  sa.subscriber_type := sa.subscriber_type (i_esn => i_subscriber_type.pcrf_esn);
BEGIN
  sub := sub.ins;
  i_subscriber_type := sub;
  o_response := sub.status;
END ins_subscriber_spr;

--
PROCEDURE ins_pcrf_transaction ( i_pcrf_transaction_type  IN OUT pcrf_transaction_type,
                                 o_response                  OUT VARCHAR2) IS
  pcrf  sa.pcrf_transaction_type := sa.pcrf_transaction_type ();
BEGIN
  pcrf := i_pcrf_transaction_type;
  pcrf := pcrf.ins;
  i_pcrf_transaction_type := pcrf;
END ins_pcrf_transaction;

/*
PROCEDURE ins_subscriber_enrollments ( i_part_inst_type IN OUT part_inst_type,
                                       o_response       OUT VARCHAR2) IS
BEGIN
  NULL;
END ins_subscriber_enrollments;

PROCEDURE upd_migration_stg(i_gsm_migration_stg_objid  IN NUMBER,
                            i_response                 IN VARCHAR2,
                            o_response                 OUT VARCHAR2) IS
BEGIN
 IF i_gsm_migration_stg_objid IS NULL OR i_response IS NULL THEN
  o_response :='RESP IS NULL OR MIGRATION OBJID IS NULL';
  RETURN;
 END IF;

     UPDATE x_gsm_account_migration_stg_t SET migration_response = i_response
     WHERE objid = i_gsm_migration_stg_objid;

     IF sql%rowcount =1 THEN
        o_response := 'SUCCESS';
     END IF;

END upd_migration_stg;*/

FUNCTION npanxx_exist ( i_min         IN VARCHAR2 ,
                        i_npa         IN VARCHAR2 ,
                        i_nxx         IN VARCHAR2 ,
                        i_carrier_id  IN VARCHAR2 ,
                        i_zip         IN VARCHAR2 ) RETURN BOOLEAN IS
  n_count  NUMBER := 0;
BEGIN

  SELECT COUNT (1)
  INTO   n_count
  FROM   carrierzones a,
         npanxx2carrierzones b
  WHERE  b.nxx = i_nxx
  AND    b.npa = i_npa
  AND    a.st = b.state
  AND    a.zone = b.zone
  AND    a.zip = i_zip
  AND    b.carrier_id = i_carrier_id;

  --
  RETURN (CASE WHEN n_count > 0 THEN TRUE ELSE FALSE END);
--
EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END npanxx_exist;


PROCEDURE ins_interaction ( i_contact_objid  IN     NUMBER,
                            i_reason_1       IN     VARCHAR2,
                            i_reason_2       IN     VARCHAR2,
                            i_notes         IN  VARCHAR2     ,
                            i_rslt          IN  VARCHAR2     ,
                            i_user          IN  VARCHAR2     ,
                            i_esn           IN  VARCHAR2     ,
                            i_create_date   IN  DATE DEFAULT SYSDATE ,
                            i_start_date    IN  DATE         ,
                            i_end_date      IN  DATE         ,
			    o_interact_objid OUT  NUMBER,
                            o_response       OUT VARCHAR2) AS

  /*v_reason_1                table_hgbst_elm.title%TYPE;
  v_reason_2                table_hgbst_elm.title%TYPE;
  v_call_rslt               table_hgbst_elm.title%TYPE;*/
  v_c_f_name                VARCHAR2 (30);
  v_c_l_name                VARCHAR2 (30);
  v_c_phone                 VARCHAR2 (20);
  v_c_email                 VARCHAR2 (80);
  v_c_zip                   VARCHAR2 (20);
  n_user_objid              NUMBER;
  v_user_name               VARCHAR2 (30);
  n_tab_phone_log_objid     NUMBER;                 -- table_phone_log objid
  n_tab_interact_objid      NUMBER;                  -- table_interact objid
  n_interaction_id          NUMBER;                        -- interaction id
  n_tab_interact_txt_objid  NUMBER;              -- table_interact_txt objid
  v_datadump                VARCHAR2 (4000);           -- info we don't need
BEGIN
  -- INITIALIZE VARIABLES
  /*v_reason_1 := i_reason_1;
  v_reason_2 := i_reason_2;
  v_call_rslt := p_rslt;*/

  -- GET CONTACT and AGENT INFORMATION
  BEGIN
    SELECT first_name,
           last_name,
           phone,
           e_mail,
           zipcode
    INTO   v_c_f_name,
           v_c_l_name,
           v_c_phone,
           v_c_email,
           v_c_zip
    FROM   table_contact
    WHERE  1 = 1
    AND    objid = i_contact_objid;

    SELECT objid, login_name
    INTO   n_user_objid, v_user_name
    FROM   table_user
    WHERE  s_login_name = UPPER (i_user);
  EXCEPTION
    WHEN OTHERS THEN
      o_response := 'ERROR - Unable to obtain the contact or agent information';
      RETURN;
  END;

  -- CREATE (TABLE_PHONE_LOG and TABLE_INTERACT OBJIDS) AND INTERACTION ID
  BEGIN
    SELECT obj_num
    INTO   n_tab_phone_log_objid
    FROM   adp_tbl_oid
    WHERE  type_id = 28;

    SELECT obj_num
    INTO   n_tab_interact_objid
    FROM   adp_tbl_oid
    WHERE  type_id = 5225;

    sa.next_id ('Interaction ID', n_interaction_id, v_datadump);

    SELECT obj_num
    INTO   n_tab_interact_txt_objid
    FROM   adp_tbl_oid
    WHERE  type_id = 5226;
  EXCEPTION
    WHEN OTHERS THEN
      o_response := 'ERROR - Unable to create the required objid or the interaction_id';
      RETURN;
  END;

  -- CREATE PHONE LOG
  BEGIN
    INSERT
    INTO table_phone_log
         ( objid,
           creation_time,
           stop_time,
           notes,
           site_time,
           internal,
           commitment,
           due_date,
           action_type,
           phone_custmr2contact,
           phone_owner2user,
           old_phone_stat2gbst_elm,
           new_phone_stat2gbst_elm)
    VALUES
    ( n_tab_phone_log_objid,
      i_start_date,                                         --d_start_time,
      i_end_date,                                           --d_end_time,
      i_notes,
      TO_DATE ('01-JAN-53 00:00:00', 'DD-MON-YYYY HH24:MI:SS'),
      '',
      '',
      TO_DATE ('01-JAN-53 00:00:00', 'DD-MON-YYYY HH24:MI:SS'),
      'Inbound' || ':' || 'Letter',
      i_contact_objid,
      n_user_objid,
      268435478, -- 268435478 (NO IDEA WHERE THIS VALUE COMES FROM BUT, IT SEEMS LIKE A STATIC VALUE)
      268435478 ); -- 268435478 (NO IDEA WHERE THIS VALUE COMES FROM BUT, IT SEEMS LIKE A STATIC VALUE)
  EXCEPTION
    WHEN OTHERS THEN
      o_response := 'ERROR - While inserting phone log - ' || SQLERRM;
      RETURN;
  END;

  -- CREATE INTERACTION
  BEGIN
    INSERT
    INTO table_interact
    ( objid,
      interact_id,
      create_date,
      inserted_by,
      external_id,
      direction,
      TYPE,
      s_type,
      origin,
      product,
      s_product,
      reason_1,
      s_reason_1,
      reason_2,
      s_reason_2,
      reason_3,
      s_reason_3,
      result,
      done_in_one,
      fee_based,
      wait_time,
      system_time,
      entered_time,
      pay_option,
      title,
      s_title,
      start_date,
      end_date,
      last_name,
      s_last_name,
      first_name,
      s_first_name,
      phone,
      fax_number,
      email,
      s_email,
      zipcode,
      arch_ind,
      agent,
      s_agent,
      serial_no,
      mobile_phone,
      x_service_type,
      interact2contact,
      interact2user)
    VALUES
    ( n_tab_interact_objid,
      n_interaction_id,
      i_create_date,
      v_user_name,
      '',
      'Inbound',
      'Letter',
      'LETTER',
      'Customer',
      'None',
      'NONE',
      SUBSTR (i_reason_1, 1, 20),
      SUBSTR (UPPER (i_reason_1), 1, 20),
      i_reason_2,
      UPPER (i_reason_2),
      '',
      '',
      i_rslt,
      0,
      0,
      0,
      0,
      0,
      SUBSTR (i_reason_1, 1, 20),
      '',
      '',
      i_start_date,  -- start_date
      i_end_date,    -- end_date
      v_c_l_name,
      UPPER (v_c_l_name),
      v_c_f_name,
      UPPER (v_c_f_name),
      v_c_phone,
      '',
      v_c_email,
      UPPER (v_c_email),
      v_c_zip,
      0,
      v_user_name,
      UPPER (V_USER_NAME),
      NVL (i_esn, ''),
      '',
      'Wireless',
      i_contact_objid,
      n_user_objid);

    INSERT
    INTO   table_interact_txt
           ( objid,
             notes,
             interact_txt2interact)
    VALUES
    ( n_tab_interact_txt_objid,
      i_notes,
      n_tab_interact_objid );
  EXCEPTION
    WHEN OTHERS THEN
      o_response := 'ERROR - Unable to create interaction ' || SQLERRM;
      RETURN;
  END;

  o_response       := 'SUCCESS';
  o_interact_objid := n_tab_interact_objid; --interact objid added for WFM
EXCEPTION
  WHEN OTHERS THEN
    o_response := 'ERROR - Unable to complete create interaction call ' || SQLERRM;
END ins_interaction;

PROCEDURE insert_npanxx ( i_min         IN VARCHAR2,
                          i_carrier_id  IN VARCHAR2,
                          i_zip         IN VARCHAR2) AS
  CURSOR c_npanxx IS
    SELECT DISTINCT
           SUBSTR (i_min, 1, 3) npa,
           SUBSTR (i_min, 4, 3) nxx,
           N.CARRIER_ID,
           MIN (n.carrier_name) carrier_name,
           '0' lead_time,
           '0' target_level,
           MIN (n.ratecenter) ratecenter,
           N.STATE,
           'PORT CALL_CENTER' carrier_id_description,
           N.ZONE,
           MIN (n.county) county,
           MIN (n.marketid) marketid,
           MIN (n.mrkt_area) mrkt_area,
           MIN (n.sid) sid,
           CASE
             WHEN n.gsm_tech = 'GSM' THEN 'GSM'
             WHEN n.cdma_tech = 'CDMA' THEN 'CDMA'
             ELSE NULL
           END
             technology,
           MIN (n.frequency1) frequency1,
           MIN (n.frequency2) frequency2,
           MIN (n.bta_mkt_number) bta_mkt_number,
           MIN (n.bta_mkt_name) bta_mkt_name,
           NULL tdma_tech,
           CASE
             WHEN n.gsm_tech = 'GSM' THEN 'GSM'
             WHEN n.cdma_tech = 'CDMA' THEN 'NULL'
             ELSE NULL
           END
             gsm_tech,
           CASE WHEN n.cdma_tech = 'CDMA' THEN 'CDMA' ELSE NULL END
             cdma_tech,
           CASE
             WHEN ( N.CARRIER_NAME LIKE 'AT%T%' OR N.CARRIER_NAME LIKE 'CING%') THEN 'G0410'
             WHEN N.CARRIER_NAME LIKE 'T-MO%' THEN 'G0260'
             ELSE ''
           END MNC_V
    FROM   npanxx2carrierzones N,
           carrierzones C
    WHERE  1 = 1
    AND    n.zone = c.zone
    AND    n.state = c.st
    AND    EXISTS
             (SELECT 1
              FROM   table_x_carrier cr, table_x_carrier_group cg
              WHERE  cg.objid = cr.carrier2carrier_group
              AND    cr.x_status = 'ACTIVE'
              AND    cr.x_carrier_id = i_carrier_id
              AND    n.carrier_id = cr.x_carrier_id)
    AND    c.zip = i_zip
    AND    ROWNUM < 2
    GROUP BY n.npa,
             n.nxx,
             n.carrier_id,
             n.carrier_name,
             n.state,
             n.zone,
             CASE
               WHEN n.gsm_tech = 'GSM' THEN 'GSM'
               WHEN n.cdma_tech = 'CDMA' THEN 'CDMA'
               ELSE NULL
             END,
             CASE
               WHEN n.gsm_tech = 'GSM' THEN 'GSM'
               WHEN n.cdma_tech = 'CDMA' THEN 'NULL'
               ELSE NULL
             END,
             CASE WHEN n.cdma_tech = 'CDMA' THEN 'CDMA' ELSE NULL END,
             CASE
               WHEN (n.carrier_name LIKE 'AT%T%' AND n.carrier_name LIKE 'CING%') THEN 'G0410'
               WHEN (n.carrier_name LIKE 'T-MO%') THEN 'G0260'
               ELSE ''
             END;

  c_npx  c_npanxx%ROWTYPE;
BEGIN
  IF c_npanxx%ISOPEN THEN
    CLOSE c_npanxx;
  END IF;

  OPEN c_npanxx;
  FETCH c_npanxx INTO C_NPX;
  IF c_npanxx%FOUND THEN
    INSERT
    INTO npanxx2carrierzones
    VALUES
    ( c_npx.npa,
      c_npx.nxx,
      c_npx.carrier_id,
      c_npx.carrier_name,
      c_npx.lead_time,
      c_npx.target_level,
      c_npx.ratecenter,
      c_npx.state,
      c_npx.carrier_id_description,
      c_npx.zone,
      c_npx.county,
      c_npx.marketid,
      c_npx.mrkt_area,
      c_npx.sid,
      c_npx.technology,
      c_npx.frequency1,
      c_npx.frequency2,
      c_npx.bta_mkt_number,
      c_npx.bta_mkt_name,
      c_npx.tdma_tech,
      c_npx.gsm_tech,
      c_npx.cdma_tech,
      c_npx.mnc_v);
  END IF;

  CLOSE c_npanxx;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_line ('Error in NPANXX creation ' || SQLCODE || '-' || SQLERRM);
    --log error here
    --sp_insert_error(i_esn => LINE_IN, i_sim => LINE_IN, i_zipcode => NULL, i_process_step => NULL, i_error_code => SQLCODE, i_error_string => 'Oracle Error: '||sqlerrm);
END insert_npanxx;

-- procedure to load all subscribers from staging table
PROCEDURE load_gosmart_premigration ( o_response                OUT VARCHAR2,
                                      i_max_rows_limit          IN  NUMBER DEFAULT 50000,
                                      i_commit_every_rows       IN  NUMBER DEFAULT 5000,
                                      i_bulk_collection_limit   IN  NUMBER DEFAULT 200,
                                      i_carrier_id              IN  VARCHAR2 DEFAULT '1113385',
                                      i_brand                   IN  VARCHAR2 DEFAULT 'SIMPLE_MOBILE',
                                      i_phone_part_inst_status  IN  VARCHAR2 DEFAULT '160',
                                      i_line_part_inst_status   IN  VARCHAR2 DEFAULT '120',
                                      i_sim_status              IN  VARCHAR2 DEFAULT '253',
                                      i_site_part_status        IN  VARCHAR2 DEFAULT 'NotMigrated',
                                      i_source_system           IN  VARCHAR2 DEFAULT 'BATCH',
                                      i_enrollment_status       IN  VARCHAR2 DEFAULT 'READYTOREENROLL',
                                      i_pph_request_type        IN  VARCHAR2 DEFAULT 'GOSMART_PURCH',
                                      i_pph_request_source      IN  VARCHAR2 DEFAULT 'GOSMART',
                                      i_user                    IN  VARCHAR2 DEFAULT 'OPERATIONS',
                                      i_pph_payment_type        IN  VARCHAR2 DEFAULT 'GOSMART_ENROLLMENT' ) AS
  -- get transactions (limit the rows to be retrieved)
  CURSOR c_get_data IS
    SELECT *
    FROM   (SELECT *
            FROM   x_gsm_acct_migration_stg
            WHERE  migration_status IN ('PENDING'))
    WHERE  ROWNUM <= i_max_rows_limit;

  CURSOR cur_part_inst_detail (
    c_part_serial_no VARCHAR2) IS
    SELECT *
    FROM   table_part_inst
    WHERE  part_serial_no = c_part_serial_no
    AND    x_part_inst_status IN
             (i_phone_part_inst_status, i_line_part_inst_status);

  rec_part_inst_detail_ph   cur_part_inst_detail%ROWTYPE;
  rec_part_inst_detail_min  cur_part_inst_detail%ROWTYPE;

  --
  CURSOR cur_min_esn ( c_domain           VARCHAR2,
                       c_part_serial_no   VARCHAR2) IS
    SELECT pi_phone.part_serial_no x_ESN,
           pi_min.part_serial_no x_MIN,
           pi_phone.x_part_inst2contact
    FROM   table_part_inst pi_phone, table_part_inst pi_min
    WHERE  pi_min.part_to_esn2part_inst = pi_phone.objid
    AND    pi_min.x_domain = 'LINES'
    AND    pi_phone.x_domain = 'PHONES'
    AND    ( (c_domain = 'LINES'
    AND       pi_min.part_serial_no = c_part_serial_no)
    OR       (c_domain = 'PHONES'
    AND       pi_phone.part_serial_no = c_part_serial_no));

  rec_min_esn               cur_min_esn%ROWTYPE;

  -- temporary record to hold required attributes
  TYPE dataList IS TABLE OF c_get_data%ROWTYPE;

  -- based on record above
  --  TYPE dataList IS TABLE OF data_record;

  -- table to hold array of data
  data                      dataList;

  --
  pi                        part_inst_type := part_inst_type ();
  sp                        site_part_type := site_part_type ();
  ph                        pi_hist_type := pi_hist_type ();
  wu                        web_user_type := web_user_type ();
  cpi                       contact_part_inst_type := contact_part_inst_type ();
  spsp                      service_plan_site_part_type := service_plan_site_part_type ();
  sph                       service_plan_hist_type := service_plan_hist_type ();
  pe                        program_enrolled_type := program_enrolled_type ();
  pph                       program_purch_hdr_type := program_purch_hdr_type ();
  ppd                       program_purch_dtl_type := program_purch_dtl_type ();
  pphh                      program_purch_hdr_type := program_purch_hdr_type ();
  ppdh                      program_purch_dtl_type := program_purch_dtl_type ();
  pt                        program_trans_type := program_trans_type ();
  ctt                       code_table_type := code_table_type ();
  ct                        sa.call_trans_type := call_trans_type ();
  c                         sa.call_trans_type;

  --
  n_count_rows              NUMBER := 0;
  n_failed_rows             NUMBER := 0;
  d_due_date                DATE := TRUNC (SYSDATE) + 30;

  --c_carrier_id          VARCHAR2(50) := '1113385';--need to update
  c_line_i_carrier_id       VARCHAR2 (50) := '';            --need to update
  c_line_o_carrier_id       VARCHAR2 (50);
  c_line_o_carrier_name     VARCHAR2 (50);
  c_line_o_result           NUMBER;
  c_line_o_msg              VARCHAR2 (500);

  c_contact_o_err_code      VARCHAR2 (100);
  c_contact_o_err_msg       VARCHAR2 (500);
  c_contact_o_objid         NUMBER;
  n_bus_org_objid           NUMBER;
  c_brand                   VARCHAR2 (30) := 'SIMPLE_MOBILE';
  c_response                VARCHAR2 (1000);
  c_sim_status              VARCHAR2 (100);
  n_inv_bin_objid           NUMBER;
  c_autorefill_flag         VARCHAR2 (1);
  c_old_esn                 VARCHAR2 (30);
  c_city                    VARCHAR2 (30);
  c_state                   VARCHAR2 (10);

  -- cc_rec              x_gsm_cc_payment_stg%ROWTYPE;
  -- ach_rec             x_gsm_ach_payment_stg%ROWTYPE;
  -- en_rec              x_gsm_enrollment_stg%ROWTYPE;
  pymnt_src_rec             x_payment_source%ROWTYPE;

  c_cc_objid                NUMBER;
  c_cc_errno                VARCHAR2 (100);
  c_cc_errstr               VARCHAR2 (500);
  l_service_plan_id         NUMBER;
  l_account_group_uid       VARCHAR2 (200);
  l_account_group_id        NUMBER;
  l_subscriber_uid          VARCHAR2 (200);
  l_group_err_code          NUMBER;
  l_group_err_msg           VARCHAR2 (200);
  l_group_return            NUMBER;

  --

  -- used to determine if a pcrf transaction exists that needs to be archived
  FUNCTION more_rows_exist
    RETURN BOOLEAN IS
    n_count  NUMBER := 0;
  BEGIN
    SELECT COUNT (1)
    INTO   n_count
    FROM   DUAL
    WHERE  EXISTS
             (SELECT 1
              FROM   x_gsm_acct_migration_stg
              WHERE  migration_status IN ('PENDING'));

    --
    RETURN (CASE WHEN n_count > 0 THEN TRUE ELSE FALSE END);
  --
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END more_rows_exist;
BEGIN
  -- set global variable to avoid unwanted trigger executions
  sa.globals_pkg.g_run_my_trigger := FALSE;

  --
  BEGIN
    SELECT objid
    INTO   n_bus_org_objid
    FROM   table_bus_org
    WHERE  org_id = i_brand;
  EXCEPTION
    WHEN OTHERS THEN
      n_bus_org_objid := NULL;                   --need to update value here
  END;

  --below block added temporarily for dealer set up
  /* BEGIN
    SELECT objid INTO n_inv_bin_objid
    FROM table_inv_bin WHERE bin_name ='9621';
   EXCEPTION
     WHEN OTHERS THEN
       n_inv_bin_objid := NULL;
   END ;    */

  -- perform a loop while applicable pcrf record exists
  WHILE (more_rows_exist) LOOP
    -- open cursor to retrieve data records
    OPEN c_get_data;

    -- start loop
    LOOP
      -- fetch cursor data into pcrf collection (limit collection to i_bulk_collection_limit rows at a time)
      FETCH c_get_data
      BULK COLLECT INTO data LIMIT i_bulk_collection_limit;

      -- loop through migration  collection
      FOR i IN 1 .. data.COUNT LOOP
        -- reset response as null for reuse
        o_response := NULL;
        c_response := NULL;
        c_line_i_carrier_id := NULL;
        c_line_o_carrier_name := NULL;
        c_line_o_result := NULL;
        c_line_o_msg := NULL;
        c_contact_o_objid := 0;
        c_sim_status := NULL;
        pymnt_src_rec := NULL;
        -- n_inv_bin_objid         := NULL;
        c_autorefill_flag := NULL;
        c_old_esn := NULL;
        c_city := NULL;
        c_state := NULL;

        -- initialize type attributes to null
        pi := part_inst_type ();
        sp := site_part_type ();
        ph := pi_hist_type ();
        wu := web_user_type ();
        cpi := contact_part_inst_type ();
        spsp := service_plan_site_part_type ();
        sph := service_plan_hist_type ();
        pe := program_enrolled_type ();
        pph := program_purch_hdr_type ();
        ppd := program_purch_dtl_type ();
        pphh := program_purch_hdr_type ();
        ppdh := program_purch_dtl_type ();
        pt := program_trans_type ();
        ctt := code_table_type ();
        ct := call_trans_type ();

        l_flag := NULL;

        rec_part_inst_detail_ph := NULL;
        rec_part_inst_detail_min := NULL;
        rec_min_esn := NULL;

        -- ps_rec := typ_pymt_src_dtls_rec();

        BEGIN -- Loop Exception
          pi := part_inst_type (i_esn => data (i).esn);

          IF pi.response NOT LIKE '%SUCCESS%' THEN
            c_response := c_response || '|' || 'Part Inst Err :' || pi.response;

            UPDATE x_gsm_acct_migration_stg
            SET    migration_status = 'PREMIGRATION_FAILED',
                   migration_response = c_response
            WHERE  objid = data (i).objid;

            CONTINUE;                              --continue next iteration
          END IF;

          DBMS_OUTPUT.put_line ('part inst response ' || pi.response);

          OPEN cur_part_inst_detail (data(i).esn);
          FETCH cur_part_inst_detail INTO rec_part_inst_detail_ph;
          CLOSE cur_part_inst_detail;

          OPEN cur_part_inst_detail (data(i).MIN);
          FETCH cur_part_inst_detail INTO rec_part_inst_detail_min;
          CLOSE cur_part_inst_detail;

          IF rec_part_inst_detail_ph.part_serial_no IS NULL
             AND rec_part_inst_detail_min.part_serial_no IS NULL THEN
            l_flag := 'Insert'; -- ???  who is going to populate the phone and line record in part inst and with which status initially before migration.
          ELSE
            IF rec_part_inst_detail_min.part_to_esn2part_inst =
                 rec_part_inst_detail_ph.objid THEN
              l_flag := 'Update';
              c_contact_o_objid := rec_part_inst_detail_ph.x_part_inst2contact;
            ELSE
              --rec_part_inst_detail_ph.part_serial_no <> data(i).esn
              -- ESN Change or upgrade
              OPEN cur_min_esn ('LINES', data (i).MIN);
              FETCH cur_min_esn INTO rec_min_esn;
              CLOSE cur_min_esn;

              IF data (i).esn <> rec_min_esn.x_ESN THEN
                l_flag := 'ESN Change';
                c_old_esn := rec_min_esn.x_ESN;
                c_contact_o_objid := rec_min_esn.x_part_inst2contact;
              ELSE
                -- MIN Change
                OPEN cur_min_esn ('PHONES', data (i).esn);
                FETCH cur_min_esn INTO rec_min_esn;
                CLOSE cur_min_esn;

                IF data (i).MIN <> rec_min_esn.x_min THEN
                  l_flag := 'MIN Change';
                  c_contact_o_objid := rec_min_esn.x_part_inst2contact;
                ELSE
                  l_flag := 'Insert';
                END IF;
              END IF;
            END IF;
          END IF;

          DBMS_OUTPUT.put_line ('test 00: ' || l_flag || ' - ' || c_contact_o_objid);

          --
          BEGIN
            SELECT x_city,
                   x_state
            INTO   c_city,
                   c_state
            FROM   table_x_zip_code
            WHERE  x_zip = data (i).zipcode;
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;


          IF c_contact_o_objid = 0
             AND l_flag = 'Insert'
          THEN
            -- create contact related information
            sa.contact_pkg.createcontact_prc ( p_esn                => data (i).esn,
                                               p_first_name         => data (i).first_name,
                                               p_last_name          => data (i).last_name,
                                               p_middle_name        => NULL,
                                               p_phone              => data (i).MIN,
                                               p_add1               => data (i).address_1,
                                               p_add2               => data (i).address_2,
                                               p_fax                => NULL,
                                               p_city               => NVL (data (i).city, c_city),
                                               p_st                 => NVL (data (i).state, c_state),
                                               p_zip                => data (i).zipcode,
                                               p_email              => data (i).email,
                                               p_email_status       => NULL,
                                               p_roadside_status    => NULL,
                                               p_no_name_flag       => NULL,
                                               p_no_phone_flag      => NULL,
                                               p_no_address_flag    => NULL,
                                               p_sourcesystem       => i_source_system,
                                               p_brand_name         => data (i).bus_org_id,
                                               p_do_not_email       => data (i).do_not_mail_flag,
                                               p_do_not_phone       => data (i).do_not_phone_flag,
                                               p_do_not_mail        => data (i).do_not_mail_flag,
                                               p_do_not_sms         => data (i).do_not_sms_flag,
                                               p_ssn                => NULL,
                                               p_dob                => data (i).date_of_birth,
                                               p_do_not_mobile_ads  => NULL,
                                               p_contact_objid      => c_contact_o_objid,
                                               p_err_code           => c_contact_o_err_code,
                                               p_err_msg            => c_contact_o_err_msg);

            IF c_contact_o_err_code <> '0'
               AND c_contact_o_err_msg <> 'Contact Created Successfully' THEN
              c_response := c_response || '|' || 'Contact Err :' || c_contact_o_err_msg;
            END IF;
          ELSE
            sa.contact_pkg.updatecontact_prc ( i_esn                => data (i).esn,
                                               i_first_name         => data (i).first_name,
                                               i_last_name          => data (i).last_name,
                                               i_middle_name        => NULL,
                                               i_phone              => data (i).MIN,
                                               i_add1               => data (i).address_1,
                                               i_add2               => data (i).address_2,
                                               i_fax                => NULL,
                                               i_city               => data (i).city,
                                               i_st                 => data (i).state,
                                               i_zip                => data (i).zipcode,
                                               i_email              => data (i).email,
                                               i_email_status       => NULL,
                                               i_roadside_status    => NULL,
                                               i_no_name_flag       => NULL,
                                               i_no_phone_flag      => NULL,
                                               i_no_address_flag    => NULL,
                                               i_sourcesystem       => i_source_system,
                                               i_brand_name         => data (i).bus_org_id,
                                               i_do_not_email       => data (i).do_not_mail_flag,
                                               i_do_not_phone       => data (i).do_not_phone_flag,
                                               i_do_not_mail        => data (i).do_not_mail_flag,
                                               i_do_not_sms         => data (i).do_not_sms_flag,
                                               i_ssn                => NULL,
                                               i_dob                => data (i).date_of_birth,
                                               i_do_not_mobile_ads  => NULL,
                                               i_contact_objid      => c_contact_o_objid,
                                               o_err_code           => c_contact_o_err_code,
                                               o_err_msg            => c_contact_o_err_msg);

            -- ??? based on update procedure output.
            IF c_contact_o_err_code <> '0'
               AND c_contact_o_err_msg <> 'Success' THEN
              c_response := c_response || '|' || 'Contact Err :' || c_contact_o_err_msg;
            END IF;
          END IF;

          DBMS_OUTPUT.put_line ( 'contact ' || c_contact_o_err_code || '-' || c_contact_o_err_msg);
          DBMS_OUTPUT.put_line ('contact objid ' || c_contact_o_objid);

          --
          IF c_contact_o_objid IS NOT NULL THEN -- update language pref
            UPDATE table_x_contact_add_info
            SET    x_lang_pref = CASE
                                   WHEN data (i).language = 'ENGLISH' THEN 'EN'
                                   WHEN data (i).language = 'SPANISH' THEN 'ES'
                                   ELSE NULL
                                 END
            WHERE  add_info2contact = c_contact_o_objid;
          END IF;

          BEGIN
            SELECT contact_role2site
            INTO   sp.site_objid
            FROM   table_contact_role
            WHERE  1 = 1
            AND    contact_role2contact = c_contact_o_objid;
          EXCEPTION
            WHEN OTHERS  THEN
              sp.site_objid := NULL;
          END;

          /* ins_part_inst ( i_part_inst_type => pi         ,
                           o_response       => o_response );   */

          --site part attribute assignment

          ctt := code_table_type ( i_code_number => data(i).customer_status );

          sp.instance_name := 'Wireless';
          sp.serial_no := data (i).esn;
          sp.service_id := data (i).esn;
          sp.iccid := data (i).sim;
          sp.install_date := SYSDATE;
          sp.warranty_date := NULL;
          sp.expire_dt := NULL;
          sp.actual_expire_dt := NULL;
          sp.state_code := 0;
          sp.state_value := 'GSM';
          sp.part_status := NVL (ctt.code_name, i_site_part_status);
          --sp.site_objid         := null ;-- need to derive
          sp.dir_site_objid := sp.site_objid;               --need to derive
          sp.all_site_part2site := sp.site_objid;
          sp.site_part2site := sp.site_objid;
          sp.service_end_dt := NULL;                        --need to derive
          sp.MIN := data (i).MIN;
          sp.msid := data (i).MIN;
          sp.update_stamp := SYSDATE;
          sp.site_part2part_info := pi.n_part_inst2part_mod; --need to derive
          sp.zipcode := data (i).zipcode;
          --site_part end

          ins_site_part ( i_site_part_type => sp,
                          o_response       => o_response);

          IF sp.response NOT LIKE '%SUCCESS%' THEN
            c_response := c_response || '|' || 'Site Part Err :' || sp.response;
          END IF;

          DBMS_OUTPUT.put_line ('site part response ' || sp.response);


          ctt := code_table_type ();

          ctt := code_table_type (i_code_number => i_phone_part_inst_status);

          /* BEGIN
             SELECT x_tf_dealer
             INTO n_inv_bin_objid
             FROM x_gsm_dealer_mapping
             WHERE x_source ='GOSMART'
             AND   x_source_dealer = data(i).dealer_id ;
           EXCEPTION
             WHEN OTHERS THEN
               n_inv_bin_objid := NULL;
           END ;        */

          -- update ESN status
          UPDATE table_part_inst
          SET    x_part_inst_status = i_phone_part_inst_status, --DECODE (data(i).customer_status, 'Active', '52', 'Suspend', '54', 'Inactive', '54', 'New', '50', x_part_inst_status),
                 status2x_code_table = ctt.code_table_objid, --DECODE (data(i).customer_status, 'Active', '988', 'Suspend', '990', 'Inactive', '2044', 'New', '986', status2x_code_table),
                 x_part_inst2site_part = sp.site_part_objid,
                 x_part_inst2contact = c_contact_o_objid,
                 part_inst2inv_bin = data (i).dealer_inv_objid --need to update this to data(i).dealer_id
          WHERE  part_serial_no = data (i).esn;

          -- c_sim_status:='253' ;

          ctt := code_table_type (); -- reinitialize for sim

          ctt := code_table_type ( i_code_number => i_sim_status );

          -- need to check this
          -- update sim status
          /* UPDATE table_x_sim_inv
             SET x_sim_inv_status          = i_sim_status ,
                 x_sim_status2x_code_table = ctt.code_table_objid
             WHERE x_sim_serial_no = data(i).sim;    */

          -- need to delete line if it already exists
          DELETE FROM table_part_inst
          WHERE  part_serial_no = data (i).MIN
          AND    x_domain = 'LINES';

          --create line
          IF NOT npanxx_exist (i_min         => data (i).MIN,
                               i_npa         => SUBSTR (data (i).MIN, 1, 3),
                               i_nxx         => SUBSTR (data (i).MIN, 4, 3),
                               i_carrier_id  => i_carrier_id,
                               i_zip         => data (i).zipcode)
          THEN
            insert_npanxx (i_min         => data(i).MIN,
                           i_carrier_id  => i_carrier_id,
                           i_zip         => data (i).zipcode);
          END IF;

          toppapp.line_insert_pkg.line_validation ( ip_msid          => data(i).MIN,
                                                    ip_min           => data(i).MIN,
                                                    ip_carrier_id    => i_carrier_id,
                                                    ip_file_name     => 'GSM MOBILE',
                                                    ip_file_type     => '1',
                                                    ip_expire_date   => 'NA',
                                                    op_carrier_id    => c_line_o_carrier_id,
                                                    op_carrier_name  => c_line_o_carrier_name,
                                                    op_result        => c_line_o_result,
                                                    op_msg           => c_line_o_msg);

          DBMS_OUTPUT.put_line ('Line creation  result  ' || c_line_o_result);
          DBMS_OUTPUT.put_line ('Line creation  message ' || c_line_o_msg);

          IF c_line_o_result <> 1 THEN
            c_response := c_response || '|' || 'Line Insert Err :' || c_line_o_msg;
          END IF;

          ctt := code_table_type (); -- again reinitialize for line
          --
          ctt := code_table_type ( i_code_number => i_line_part_inst_status );

          --link the line to ESN
          UPDATE table_part_inst
          SET    part_to_esn2part_inst = pi.part_inst_objid,
                 x_part_inst_status = i_line_part_inst_status,
                 status2x_code_table = ctt.code_table_objid
          WHERE  part_serial_no = data (i).MIN
          AND    x_domain = 'LINES';

          -- x_service_plan_site_part
          spsp.service_plan_site_part_objid := sp.site_part_objid;
          spsp.service_plan_id := data(i).service_plan;
          /* get_gosmart_service_plan(i_source           => 'GOSMART',
                              i_service_plan     => data(i).service_plan,
                              i_auto_refill_flag => NVL(c_autorefill_flag,'N'),
                              i_ild_service      => NVL(data(i).ild_service,'N')); */
          spsp.switch_base_rate := 0; -- need to check this value for simple mobile
          spsp.new_service_plan_id := NULL;
          spsp.last_modified_date := SYSDATE;

          IF spsp.service_plan_id IS NOT NULL THEN
            ins_service_plan_site_part ( i_service_plan_site_part_type  => spsp,
                                         o_response                     => o_response);
            DBMS_OUTPUT.put_line ( 'service plan site part response   ' || spsp.response);

            IF spsp.response NOT LIKE '%SUCCESS%' THEN
              c_response := c_response || '|' || 'Service Plan SP Err :' || spsp.response;
            ELSIF spsp.response IN ('SUCCESS-UPDATED', 'SUCCESS-INSERTED') THEN
              --insert x_xervice_plan_hist
              sph.plan_hist2site_part_objid := sp.site_part_objid;
              sph.start_date := SYSDATE;
              sph.plan_hist2service_plan := spsp.service_plan_id;
              sph.insert_date := SYSDATE;
              sph.last_modified_date := SYSDATE;
              ins_service_plan_hist ( i_service_plan_hist_type  => sph,
                                      o_response                => o_response);
              DBMS_OUTPUT.put_line ('service plan hist   ' || sph.response);

              --insert x_xervice_plan_hist
              IF sph.response NOT LIKE '%SUCCESS%' THEN
                c_response := c_response || '|' || 'Service Plan H Err :' || sph.response;
              END IF;
            END IF;
          ELSE
            c_response := c_response || '|' || 'Service Plan Not Found';
          END IF;



          --commented not needed during pre migration
          /*  -- insert table_x_pi_hist entry only for active devices
                ph.status_hist2code_table         := 988; --Active
                ph.change_date                    := SYSDATE;
                ph.change_reason                  := 'ACTIVATE';
                ph.creation_date                  := pi.creation_date;
                ph.domain                         := 'PHONES';
                ph.insert_date                    := pi.insert_date;
                ph.part_inst_status               := '52';
                ph.part_serial_no                 := data(i).esn;
                ph.part_status                    := 'Active';
    --          ph.pi_hist2carrier_mkt            :=
                ph.pi_hist2inv_bin                := '';--need to updated TBD
    --          ph.pi_hist2part_inst              :=
                ph.pi_hist2part_mod               := pi.n_part_inst2part_mod;
                ph.pi_hist2user                   := 268435556;
    --          ph.pi_hist2new_pers               := 0;
    --          ph.pi_hist2pers                   := 0;
    --          ph.po_num                         :=
                ph.reactivation_flag              := 0;
    --          ph.red_code                       :=
                ph.sequence                       := 0;
                ph.warr_end_date                  := pi.warr_end_date;
    --          ph.dev                            :=
    --          ph.fulfill_hist2demand_dtl        :=
    --          ph.part_to_esn_hist2part_inst     :=
    --          ph.bad_res_qty                    :=
    --          ph.date_in_serv                   :=
    --          ph.good_res_qty                   :=
    --          ph.last_cycle_ct                  :=
    --          ph.last_mod_time                  :=
    --          ph.last_pi_date                   :=
                ph.last_trans_time                := SYSDATE;
    --          ph.next_cycle_ct                  :=
                ph.order_number                   := pi.order_number;
    --          ph.part_bad_qty                   :=
    --          ph.part_good_qty                  :=
    --          ph.pi_tag_no                      :=
    --          ph.pick_request                   :=
    --          ph.repair_date                    :=
    --          ph.transaction_id                 :=
                ph.pi_hist2site_part              := sp.site_part_objid;
    --          ph.msid                           :=
                ph.pi_hist2contact                := c_contact_o_objid;
                ph.iccid                          := data(i).sim;


                ins_pi_hist ( i_pi_hist_type   => ph         ,
                              o_response       => o_response );

                   IF ph.response NOT LIKE '%SUCCESS%' THEN
                  c_response := c_response||'|'||ph.response;
                END IF;      */

          --dbms_output.put_line('pi hist response   '||ph.response)    ;

          --implement logic for below tables here
          --set the type attributes(refer budget scripts to set the type attributes and also refer other tables implementation in migration package )
          --call insert procedure if procedure is not then create procedure
          --set the c_response variable if it is not success
          --if you are not sure about attribute value then leave it as null and mention that as a comment  in the same line

          /*
                  Table_web_user
                  Table_x_contact_part_inst
                  X_program_enrolled
                  X_program_purch_hdr
                  X_program_purch_dtl
                  X_program_trans*/

          -- insert table_web_user
          -- wu.web_user_objid    := data(i).web_user_objid;

          -- IF  REGEXP_LIKE (data(i).login_name ,'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$') THEN

          wu.login_name := data(i).login_name;
          wu.s_login_name := UPPER (data(i).login_name);
          wu.password := data(i).login_password;
          wu.user_key := NULL;
          wu.status := 1;                                  --need to confirm
          wu.passwd_chg := NULL;
          wu.dev := NULL;
          wu.ship_via := NULL;
          --  wu.secret_questn     := data(i).secret_question;
          --  wu.s_secret_questn   := UPPER(data(i).secret_question);
          --  wu.secret_ans        := data(i).secret_answer;
          --  wu.s_secret_ans      := UPPER(data(i).secret_answer);
          wu.web_user2user := NULL;
          wu.web_user2contact := c_contact_o_objid;
          wu.web_user2lead := NULL;
          wu.web_user2bus_org := n_bus_org_objid;
          wu.last_update_date := SYSDATE;
          wu.validated := NULL;                      --need to confirm value
          wu.validated_counter := NULL;              --need to confirm value
          wu.named_userid := NULL;
          wu.insert_timestamp := SYSDATE;


          ins_web_user ( i_web_user_type => wu,
                         o_response      => o_response);

          IF wu.response NOT LIKE '%SUCCESS%' THEN
            c_response := c_response || '|' || 'Web User Err :' || wu.response;
          END IF;

          -- ELSE
          --    c_response := c_response||'|'||'LOGIN NAME NOT VALID';
          -- END IF;

          DBMS_OUTPUT.put_line ('web user response   ' || wu.response);


          --   Table_x_contact_part_inst

          cpi.contact_part_inst2contact := c_contact_o_objid;
          cpi.contact_part_inst2part_inst := pi.part_inst_objid;
          cpi.esn_nick_name := NULL;                 --need to confirm value
          cpi.is_default := 1;                       --need to confirm value
          cpi.transfer_flag := 0;                    --need to confirm value
          cpi.verified := 'Y';                       --need to confirm value
          cpi.response := NULL;

          --
          ins_contact_part_inst ( i_contact_part_inst_type => cpi,
                                  o_response               => o_response);

          IF cpi.response NOT LIKE '%SUCCESS%' THEN
            c_response := c_response || '|' || 'Contact PI Err :' || cpi.response;
          END IF;

          DBMS_OUTPUT.put_line ('contact part inst response   ' || cpi.response);

          -- IF data(i).auto_refill_flag = 'Y' THEN

          IF data(i).auto_refill_flag = 'Y' AND data(i).SERVICE_PLAN NOT IN (457,458) THEN
            pe.pgm_enroll2pgm_parameter := get_program_id (
                                             i_source        => 'GOSMART',
                                             i_service_plan  => spsp
                                                               .service_plan_id);

            pe.esn := data (i).esn;
            pe.amount := get_price (pe.pgm_enroll2pgm_parameter); --need to update
            pe.TYPE := 'INDIVIDUAL';
            pe.zipcode := data (i).zipcode;
            pe.sourcesystem := i_source_system;          ----need to confirm
            pe.insert_date := SYSDATE;
            pe.charge_date := NULL;
            pe.pec_customer := NULL;
            pe.charge_type := NULL;
            pe.enrolled_date := data (i).activation_date;
            pe.start_date := data (i).activation_date;
            pe.reason := NULL;
            pe.exp_date := NULL;
            pe.delivery_cycle_number := NULL;
            pe.enroll_amount := 0;
            pe.language := data (i).language; /*CASE WHEN data(i).language ='1' THEN 'English'
                              WHEN data(i).language ='255' THEN 'Spanish'
      ELSE NULL
         END;    */
            --NULL;--data(i).language;--need to update
            pe.payment_type := NULL;                         --need to confirm
            pe.grace_period := NULL;
            pe.cooling_period := NULL;
            pe.service_days := NULL;
            pe.cooling_exp_date := NULL;
            pe.enrollment_status := i_enrollment_status;   --need to confirm
            pe.is_grp_primary := NULL;
            pe.tot_grace_period_given := NULL;
            pe.next_charge_date := NULL; --not updating during pre migration
            pe.next_delivery_date := NULL;
            pe.update_stamp := SYSDATE;
            pe.update_user := NULL;
            pe.pgm_enroll2pgm_group := NULL;
            pe.pgm_enroll2site_part := sp.site_part_objid;
            pe.pgm_enroll2part_inst := pi.part_inst_objid;
            pe.pgm_enroll2contact := c_contact_o_objid;
            pe.pgm_enroll2web_user := wu.web_user_objid;
            pe.pgm_enroll2x_pymt_src := pph.prog_hdr2pymt_src;
            pe.wait_exp_date := NULL;
            pe.pgm_enroll2x_promotion := NULL;
            pe.pgm_enroll2prog_hdr := NULL;
            pe.termscond_accepted := NULL;
            pe.service_delivery_date := NULL;
            pe.default_denomination := NULL;
            pe.auto_refill_max_limit := NULL;
            pe.auto_refill_counter := NULL;
            pe.response := NULL;
            pe.varchar2_value := c_old_esn;                 --assign old esn

            IF pe.pgm_enroll2pgm_parameter IS NOT NULL THEN
              ins_program_enrolled ( i_program_enrolled_type  => pe,
                                     o_response               => o_response);

              IF pe.response NOT LIKE '%SUCCESS%' THEN
                c_response := c_response || '|' || 'Program En Err :' || pe.response;
              ELSE -- insert X_PROGRAM_PURCH_HDR,X_PROGRAM_PURCH_DTL,X_PROGRAM_TRANS only when x_program_enrolled is SUCCESS

                --dbms_output.put_line ('payment source to credit card'||pymnt_src_rec.pymt_src2x_credit_card);

                -- insert table X_PROGRAM_TRANS
                pt.trans_date := SYSDATE;
                pt.enrollment_status := pe.enrollment_status;
                pt.enroll_status_reason := 'FIRST TIME ENROLLMENT';
                pt.action_text := 'ENROLLMENT ATTEMPT';    --need to confirm
                pt.action_type := 'ENROLLMENT';            --need to confirm
                pt.reason := 'GoSmart Migration Enrollment'; --need to confirm
                pt.sourcesystem := i_source_system;        --need to confirm
                pt.esn := data (i).esn;
                pt.exp_date := NULL;
                pt.cooling_exp_date := NULL;
                pt.update_status := NULL;
                pt.update_user := 'OPERATIONS';            --need to confirm
                pt.pgm_tran2pgm_entrolled := pe.program_enrolled_objid;
                pt.pgm_trans2web_user := wu.web_user_objid;
                pt.pgm_trans2site_part := sp.site_part_objid;

                ins_program_trans ( i_program_trans_type  => pt,
                                    o_response            => o_response);

                IF pt.response NOT LIKE '%SUCCESS%' THEN
                  c_response := c_response || '|' || 'Program Trans Err :' || pt.response;
                END IF;

                DBMS_OUTPUT.put_line ('Program trans  response' || pt.response);
              -- END IF; -- ESN_flag
              END IF; -- pe.response IS NOT NULL
            ELSE
              c_response := c_response || '|' || 'PROGRAM ID NOT FOUND';
            END IF;                --pe.pgm_enroll2pgm_parameter IS NOT NULL
          END IF;                                   --en_rec.min IS NOT NULL



          IF UPPER (c_response) NOT LIKE '%SUCCESS%'
             AND c_response IS NOT NULL
          THEN
            -- increase row count
            n_failed_rows := n_failed_rows + 1;
            -- maybe update the staging table with the failed response message

            -- maybe continue to next iteration row
            -- CONTINUE

          END IF;


          --code to update migration status
          UPDATE x_gsm_acct_migration_stg
          SET    migration_status = CASE
                                      WHEN c_response IS NULL THEN 'PREMIGRATION_COMPLETED'
                                      ELSE 'PREMIGRATION_FAILED'
                                    END,
                 migration_response = CASE
                                        WHEN c_response IS NULL THEN 'SUCCESS'
                                        ELSE c_response
                                      END,
                 part_inst_objid = pi.part_inst_objid,
                 site_part_objid = sp.site_part_objid,
                 call_trans_objid = ct.call_trans_objid,
                 contact_objid = c_contact_o_objid,
                 program_enrolled_objid = pe.program_enrolled_objid,
                 web_user_objid = wu.web_user_objid,
                 update_timestamp = SYSDATE
          WHERE  objid = data (i).objid;

          -- reset response as null for reuse
          --o_response := NULL;


          -- increase row count
          n_count_rows := n_count_rows + 1;

          IF (MOD (n_count_rows, i_commit_every_rows) = 0) THEN
            -- Save changes
            COMMIT;
          END IF;
        --


        EXCEPTION                                           --loop exception
          WHEN OTHERS THEN
            c_response := c_response || 'sqlcode-sqlerrm' || SQLCODE || ' - ' || SUBSTR (SQLERRM, 1, 500);

            UPDATE x_gsm_acct_migration_stg
            SET    migration_status = 'PREMIGRATION_FAILED',
                   migration_response = c_response,
                   part_inst_objid = pi.part_inst_objid,
                   site_part_objid = sp.site_part_objid,
                   call_trans_objid = ct.call_trans_objid,
                   contact_objid = c_contact_o_objid,
                   program_enrolled_objid = pe.program_enrolled_objid,
                   web_user_objid = wu.web_user_objid,
                   update_timestamp = SYSDATE
            WHERE  objid = data (i).objid;
        END;
      END LOOP;                                                    -- c_data

      --
      EXIT WHEN c_get_data%NOTFOUND;
    --
    END LOOP;

    CLOSE c_get_data;

    -- exit when there are no more records to archive
    EXIT WHEN NOT (more_rows_exist);
  END LOOP;                                       -- WHILE (more_rows_exist)

  --
  DBMS_OUTPUT.PUT_LINE (n_count_rows || ' rows processed');
  --
  DBMS_OUTPUT.PUT_LINE (n_failed_rows || ' rows failed');


  -- Save changes
  COMMIT;


  o_response := 'SUCCESS';
--
EXCEPTION
  WHEN OTHERS THEN
    --
    o_response := 'ERROR IN LOAD_GOSMART: ' || SQLERRM;

    -- possibly log in the error table
    -- sa.util_pkg.log_error
    --
    RAISE;
END load_gosmart_premigration;


-- new overloaded procedure to process by min
PROCEDURE load_gosmart_premigration ( o_response                OUT VARCHAR2,
                                      i_max_rows_limit          IN  NUMBER DEFAULT 50000,
                                      i_commit_every_rows       IN  NUMBER DEFAULT 5000,
                                      i_bulk_collection_limit   IN  NUMBER DEFAULT 200,
                                      i_carrier_id              IN  VARCHAR2 DEFAULT '1113385',
                                      i_brand                   IN  VARCHAR2 DEFAULT 'SIMPLE_MOBILE',
                                      i_min                     IN  VARCHAR2,
                                      i_phone_part_inst_status  IN  VARCHAR2 DEFAULT '160',
                                      i_line_part_inst_status   IN  VARCHAR2 DEFAULT '120',
                                      i_sim_status              IN  VARCHAR2 DEFAULT '253',
                                      i_site_part_status        IN  VARCHAR2 DEFAULT 'NotMigrated',
                                      i_source_system           IN  VARCHAR2 DEFAULT 'BATCH',
                                      i_enrollment_status       IN  VARCHAR2 DEFAULT 'READYTOREENROLL',
                                      i_pph_request_type        IN  VARCHAR2 DEFAULT 'GOSMART_PURCH',
                                      i_pph_request_source      IN  VARCHAR2 DEFAULT 'GOSMART',
                                      i_user                    IN  VARCHAR2 DEFAULT 'OPERATIONS',
                                      i_pph_payment_type        IN  VARCHAR2 DEFAULT 'GOSMART_ENROLLMENT' ) AS -- Need to confirm

  -- get pcrf transactions (limit the rows to be retrieved)
  CURSOR c_get_data IS
    SELECT *
    FROM   ( SELECT *
             FROM   x_gsm_acct_migration_stg
             WHERE  migration_status IN ('READYTOMIGRATE')
             AND    min = i_min
           )
    WHERE  ROWNUM <= i_max_rows_limit;


  CURSOR cur_part_inst_detail (
    c_part_serial_no VARCHAR2) IS
    SELECT *
    FROM   table_part_inst
    WHERE  part_serial_no = c_part_serial_no
    AND    x_part_inst_status IN
             (i_phone_part_inst_status, i_line_part_inst_status);

  rec_part_inst_detail_ph   cur_part_inst_detail%ROWTYPE;
  rec_part_inst_detail_min  cur_part_inst_detail%ROWTYPE;


  CURSOR cur_min_esn (
    c_domain           VARCHAR2,
    c_part_serial_no   VARCHAR2) IS
    SELECT pi_phone.part_serial_no x_ESN,
           pi_min.part_serial_no x_MIN,
           pi_phone.x_part_inst2contact
    FROM   table_part_inst pi_phone, table_part_inst pi_min
    WHERE  pi_min.part_to_esn2part_inst = pi_phone.objid
    AND    pi_min.x_domain = 'LINES'
    AND    pi_phone.x_domain = 'PHONES'
    AND    ( (c_domain = 'LINES'
    AND       pi_min.part_serial_no = c_part_serial_no)
    OR       (c_domain = 'PHONES'
    AND       pi_phone.part_serial_no = c_part_serial_no));

  rec_min_esn               cur_min_esn%ROWTYPE;

  -- temporary record to hold required attributes
  TYPE dataList IS TABLE OF c_get_data%ROWTYPE;

  -- based on record above
  --  TYPE dataList IS TABLE OF data_record;

  -- table to hold array of data
  data                      dataList;

  --
  pi                        part_inst_type := part_inst_type ();
  sp                        site_part_type := site_part_type ();
  ph                        pi_hist_type := pi_hist_type ();
  wu                        web_user_type := web_user_type ();
  cpi                       contact_part_inst_type := contact_part_inst_type ();
  spsp                      service_plan_site_part_type := service_plan_site_part_type ();
  sph                       service_plan_hist_type := service_plan_hist_type ();
  pe                        program_enrolled_type  := program_enrolled_type ();
  pph                       program_purch_hdr_type := program_purch_hdr_type ();
  ppd                       program_purch_dtl_type := program_purch_dtl_type ();
  pphh                      program_purch_hdr_type := program_purch_hdr_type ();
  ppdh                      program_purch_dtl_type := program_purch_dtl_type ();
  pt                        program_trans_type     := program_trans_type ();
  ctt                       code_table_type        := code_table_type ();
  ct                        sa.call_trans_type := call_trans_type ();
  c                         sa.call_trans_type;

  --
  n_count_rows              NUMBER := 0;
  n_failed_rows             NUMBER := 0;
  d_due_date                DATE := TRUNC (SYSDATE) + 30;

  --c_carrier_id          VARCHAR2(50) := '1113385';--need to update
  c_line_i_carrier_id       VARCHAR2 (50) := '';            --need to update
  c_line_o_carrier_id       VARCHAR2 (50);
  c_line_o_carrier_name     VARCHAR2 (50);
  c_line_o_result           NUMBER;
  c_line_o_msg              VARCHAR2 (500);

  c_contact_o_err_code      VARCHAR2 (100);
  c_contact_o_err_msg       VARCHAR2 (500);
  c_contact_o_objid         NUMBER;
  n_bus_org_objid           NUMBER;
  c_brand                   VARCHAR2 (30) := 'SIMPLE_MOBILE';
  c_response                VARCHAR2 (1000);
  c_sim_status              VARCHAR2 (100);
  n_inv_bin_objid           NUMBER;
  c_autorefill_flag         VARCHAR2 (1);
  c_old_esn                 VARCHAR2 (30);
  c_city                    VARCHAR2 (30);
  c_state                   VARCHAR2 (10);

  -- cc_rec              x_gsm_cc_payment_stg%ROWTYPE;
  -- ach_rec             x_gsm_ach_payment_stg%ROWTYPE;
  -- en_rec              x_gsm_enrollment_stg%ROWTYPE;
  pymnt_src_rec             x_payment_source%ROWTYPE;

  c_cc_objid                NUMBER;
  c_cc_errno                VARCHAR2 (100);
  c_cc_errstr               VARCHAR2 (500);
  l_service_plan_id         NUMBER;
  l_account_group_uid       VARCHAR2 (200);
  l_account_group_id        NUMBER;
  l_subscriber_uid          VARCHAR2 (200);
  l_group_err_code          NUMBER;
  l_group_err_msg           VARCHAR2 (200);
  l_group_return            NUMBER;
--

BEGIN
  -- set global variable to avoid unwanted trigger executions
  sa.globals_pkg.g_run_my_trigger := FALSE;


  BEGIN
    SELECT objid
    INTO   n_bus_org_objid
    FROM   table_bus_org
    WHERE  org_id = i_brand;
  EXCEPTION
    WHEN OTHERS THEN
      n_bus_org_objid := NULL;                   --need to update value here
  END;

  --below block added temporarily for dealer set up
  /* BEGIN
    SELECT objid INTO n_inv_bin_objid
    FROM table_inv_bin WHERE bin_name ='9621';
   EXCEPTION
     WHEN OTHERS THEN
       n_inv_bin_objid := NULL;
   END ;    */

  -- perform a loop while applicable pcrf record exists
  -- WHILE ( more_rows_exist )
  -- LOOP

  -- open cursor to retrieve data records
  OPEN c_get_data;

  -- start loop
  LOOP
    -- fetch cursor data into pcrf collection (limit collection to i_bulk_collection_limit rows at a time)
    FETCH c_get_data
    BULK   COLLECT INTO data
    LIMIT i_bulk_collection_limit;

    -- loop through migration  collection
    FOR i IN 1 .. data.COUNT LOOP

      -- reset response as null for reuse
      o_response            := NULL;
      c_response            := NULL;
      c_line_i_carrier_id   := NULL;
      c_line_o_carrier_name := NULL;
      c_line_o_result       := NULL;
      c_line_o_msg          := NULL;
      c_contact_o_objid     := 0;
      c_sim_status          := NULL;
      pymnt_src_rec         := NULL;
      -- n_inv_bin_objid    := NULL;
      c_autorefill_flag     := NULL;
      c_old_esn             := NULL;
      c_city                := NULL;
      c_state               := NULL;


      -- initialize type attributes to null
      pi := part_inst_type ();
      sp := site_part_type ();
      ph := pi_hist_type ();
      wu := web_user_type ();
      cpi := contact_part_inst_type ();
      spsp := service_plan_site_part_type ();
      sph := service_plan_hist_type ();
      pe := program_enrolled_type ();
      pph := program_purch_hdr_type ();
      ppd := program_purch_dtl_type ();
      pphh := program_purch_hdr_type ();
      ppdh := program_purch_dtl_type ();
      pt := program_trans_type ();
      ctt := code_table_type ();

      ct := call_trans_type ();

      l_flag := NULL;

      rec_part_inst_detail_ph := NULL;
      rec_part_inst_detail_min := NULL;
      rec_min_esn := NULL;

      -- ps_rec := typ_pymt_src_dtls_rec();
      -- ps_rech := typ_pymt_src_dtls_rec();

      BEGIN -- Loop Exception
        pi := part_inst_type (i_esn => data (i).esn);

        IF pi.response NOT LIKE '%SUCCESS%' THEN
          c_response := c_response || '|' || 'Part Inst Err :' || pi.response;

          UPDATE x_gsm_acct_migration_stg
          SET    migration_status = 'PREMIGRATION_FAILED',
                 migration_response = c_response
          WHERE  objid = data (i).objid;

          CONTINUE; -- continue next iteration
        END IF;

        DBMS_OUTPUT.put_line('part inst response ' || pi.response);

        OPEN cur_part_inst_detail (data (i).esn);
        FETCH cur_part_inst_detail INTO rec_part_inst_detail_ph;
        CLOSE cur_part_inst_detail;

        OPEN cur_part_inst_detail (data (i).MIN);
        FETCH cur_part_inst_detail INTO rec_part_inst_detail_min;
        CLOSE cur_part_inst_detail;

        IF rec_part_inst_detail_ph.part_serial_no IS NULL
           AND rec_part_inst_detail_min.part_serial_no IS NULL THEN
          l_flag := 'Insert'; -- ???  who is going to populate the phone and line record in part inst and with which status initially before migration.
        ELSE
          IF rec_part_inst_detail_min.part_to_esn2part_inst =
               rec_part_inst_detail_ph.objid THEN
            l_flag := 'Update';
            c_contact_o_objid := rec_part_inst_detail_ph.x_part_inst2contact;
          ELSE
            --rec_part_inst_detail_ph.part_serial_no <> data(i).esn
            -- ESN Change or upgrade
            OPEN cur_min_esn ('LINES', data (i).MIN);
            FETCH cur_min_esn INTO rec_min_esn;
            CLOSE cur_min_esn;

            IF data (i).esn <> rec_min_esn.x_ESN THEN
              l_flag := 'ESN Change';
              c_old_esn := rec_min_esn.x_ESN;
              c_contact_o_objid := rec_min_esn.x_part_inst2contact;
            ELSE
              -- MIN Change
              OPEN cur_min_esn ('PHONES', data (i).esn);
              FETCH cur_min_esn INTO rec_min_esn;
              CLOSE cur_min_esn;

              IF data (i).MIN <> rec_min_esn.x_min THEN
                l_flag := 'MIN Change';
                c_contact_o_objid := rec_min_esn.x_part_inst2contact;
              ELSE
                l_flag := 'Insert';
              END IF;
            END IF;
          END IF;
        END IF;

        DBMS_OUTPUT.put_line ('test 00: ' || l_flag || ' - ' || c_contact_o_objid);

        BEGIN
          SELECT x_city, x_state
          INTO   c_city, c_state
          FROM   table_x_zip_code
          WHERE  x_zip = data (i).zipcode;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;

        --
        IF c_contact_o_objid = 0
           AND l_flag = 'Insert' THEN
          -- create contact related information
          sa.contact_pkg.createcontact_prc ( p_esn                => data (i).esn,
                                             p_first_name         => data (i).first_name,
                                             p_last_name          => data (i).last_name,
                                             p_middle_name        => NULL,
                                             p_phone              => data (i).MIN,
                                             p_add1               => data (i).address_1,
                                             p_add2               => data (i).address_2,
                                             p_fax                => NULL,
                                             p_city               => NVL (data (i).city, c_city),
                                             p_st                 => NVL (data (i).state, c_state),
                                             p_zip                => data (i).zipcode,
                                             p_email              => data (i).email,
                                             p_email_status       => NULL,
                                             p_roadside_status    => NULL,
                                             p_no_name_flag       => NULL,
                                             p_no_phone_flag      => NULL,
                                             p_no_address_flag    => NULL,
                                             p_sourcesystem       => i_source_system,
                                             p_brand_name         => data (i).bus_org_id,
                                             p_do_not_email       => data (i).do_not_mail_flag,
                                             p_do_not_phone       => data (i).do_not_phone_flag,
                                             p_do_not_mail        => data (i).do_not_mail_flag,
                                             p_do_not_sms         => data (i).do_not_sms_flag,
                                             p_ssn                => NULL,
                                             p_dob                => data (i).date_of_birth,
                                             p_do_not_mobile_ads  => NULL,
                                             p_contact_objid      => c_contact_o_objid,
                                             p_err_code           => c_contact_o_err_code,
                                             p_err_msg            => c_contact_o_err_msg);

          IF c_contact_o_err_code <> '0'
             AND c_contact_o_err_msg <> 'Contact Created Successfully' THEN
            c_response := c_response || '|' || 'Contact Err :' || c_contact_o_err_msg;
          END IF;
        ELSE
          sa.contact_pkg.updatecontact_prc ( i_esn                => data (i).esn,
                                             i_first_name         => data (i).first_name,
                                             i_last_name          => data (i).last_name,
                                             i_middle_name        => NULL,
                                             i_phone              => data (i).MIN,
                                             i_add1               => data (i).address_1,
                                             i_add2               => data (i).address_2,
                                             i_fax                => NULL,
                                             i_city               => NVL (data (i).city, c_city),
                                             i_st                 => NVL (data (i).state, c_state),
                                             i_zip                => data (i).zipcode,
                                             i_email              => data (i).email,
                                             i_email_status       => NULL,
                                             i_roadside_status    => NULL,
                                             i_no_name_flag       => NULL,
                                             i_no_phone_flag      => NULL,
                                             i_no_address_flag    => NULL,
                                             i_sourcesystem       => i_source_system,
                                             i_brand_name         => data (i).bus_org_id,
                                             i_do_not_email       => data (i).do_not_mail_flag,
                                             i_do_not_phone       => data (i).do_not_phone_flag,
                                             i_do_not_mail        => data (i).do_not_mail_flag,
                                             i_do_not_sms         => data (i).do_not_sms_flag,
                                             i_ssn                => NULL,
                                             i_dob                => data (i).date_of_birth,
                                             i_do_not_mobile_ads  => NULL,
                                             i_contact_objid      => c_contact_o_objid,
                                             o_err_code           => c_contact_o_err_code,
                                             o_err_msg            => c_contact_o_err_msg);

          -- ??? based on update procedure output.
          IF c_contact_o_err_code <> '0'
             AND c_contact_o_err_msg <> 'Success' THEN
            c_response := c_response || '|' || 'Contact Err :' || c_contact_o_err_msg;
          END IF;
        END IF;

        DBMS_OUTPUT.put_line ('contact ' || c_contact_o_err_code || '-' || c_contact_o_err_msg);
        DBMS_OUTPUT.put_line ('contact objid ' || c_contact_o_objid);

        --
        IF c_contact_o_objid IS NOT NULL THEN         --update language pref
          UPDATE table_x_contact_add_info
          SET    x_lang_pref = CASE
                                 WHEN data (i).language = 'ENGLISH' THEN
                                   'EN'
                                 WHEN data (i).language = 'SPANISH' THEN
                                   'ES'
                                 ELSE
                                   NULL
                               END
          WHERE  add_info2contact = c_contact_o_objid;
        END IF;

        BEGIN
          SELECT contact_role2site
          INTO   sp.site_objid
          FROM   table_contact_role
          WHERE  1 = 1
          AND    contact_role2contact = c_contact_o_objid;
        EXCEPTION
          WHEN OTHERS  THEN
            sp.site_objid := NULL;
        END;

        /* ins_part_inst ( i_part_inst_type => pi         ,
                         o_response       => o_response );   */

        --site part attribute assignment

        ctt := code_table_type (i_code_number => data (i).customer_status);

        sp.instance_name := 'Wireless';
        sp.serial_no := data (i).esn;
        sp.service_id := data (i).esn;
        sp.iccid := data (i).sim;
        sp.install_date := SYSDATE;
        sp.warranty_date := NULL;
        sp.expire_dt := NULL;
        sp.actual_expire_dt := NULL;
        sp.state_code := 0;
        sp.state_value := 'GSM';
        sp.part_status := NVL (ctt.code_name, i_site_part_status);
        --sp.site_objid         := null ;-- need to derive
        sp.dir_site_objid := sp.site_objid;                 --need to derive
        sp.all_site_part2site := sp.site_objid;
        sp.site_part2site := sp.site_objid;
        sp.service_end_dt := NULL;                          --need to derive
        sp.MIN := data (i).MIN;
        sp.msid := data (i).MIN;
        sp.update_stamp := SYSDATE;
        sp.site_part2part_info := pi.n_part_inst2part_mod;  --need to derive
        sp.zipcode := data (i).zipcode;
        --site_part end

        ins_site_part ( i_site_part_type => sp,
                        o_response => o_response);

        IF sp.response NOT LIKE '%SUCCESS%' THEN
          c_response := c_response || '|' || 'Site Part Err :' || sp.response;
        END IF;

        DBMS_OUTPUT.put_line ('site part response ' || sp.response);


        ctt := code_table_type ();

        ctt := code_table_type ( i_code_number => i_phone_part_inst_status );

        /* BEGIN
           SELECT x_tf_dealer
           INTO n_inv_bin_objid
           FROM x_gsm_dealer_mapping
           WHERE x_source ='GOSMART'
           AND   x_source_dealer = data(i).dealer_id ;
         EXCEPTION
           WHEN OTHERS THEN
             n_inv_bin_objid := NULL;
         END ;        */



        --update ESN status
        UPDATE table_part_inst
        SET    x_part_inst_status = i_phone_part_inst_status, --DECODE (data(i).customer_status, 'Active', '52', 'Suspend', '54', 'Inactive', '54', 'New', '50', x_part_inst_status),
               status2x_code_table = ctt.code_table_objid, --DECODE (data(i).customer_status, 'Active', '988', 'Suspend', '990', 'Inactive', '2044', 'New', '986', status2x_code_table),
               x_part_inst2site_part = sp.site_part_objid,
               x_part_inst2contact = c_contact_o_objid,
               part_inst2inv_bin = data (i).dealer_inv_objid --need to update this to data(i).dealer_id
        WHERE  part_serial_no = data (i).esn;

        -- c_sim_status:='253' ;

        ctt := code_table_type ();                    --reinitialize for sim

        ctt := code_table_type (i_code_number => i_sim_status);

        -- need to check this
        --update sim status
        /* UPDATE table_x_sim_inv
           SET x_sim_inv_status          = i_sim_status ,
               x_sim_status2x_code_table = ctt.code_table_objid
           WHERE x_sim_serial_no = data(i).sim;    */



        -- need to delete line if it already exists
        DELETE FROM table_part_inst
        WHERE  part_serial_no = data(i).min
        AND    x_domain = 'LINES';

        -- create line
        IF NOT npanxx_exist (i_min         => data (i).MIN,
                             i_npa         => SUBSTR (data (i).MIN, 1, 3),
                             i_nxx         => SUBSTR (data (i).MIN, 4, 3),
                             i_carrier_id  => i_carrier_id,
                             i_zip         => data (i).zipcode)
        THEN
          insert_npanxx (i_min         => data (i).MIN,
                         i_carrier_id  => i_carrier_id,
                         i_zip         => data (i).zipcode);
        END IF;

        toppapp.line_insert_pkg.line_validation ( ip_msid          => data (i).MIN,
                                                  ip_min           => data (i).MIN,
                                                  ip_carrier_id    => i_carrier_id,
                                                  ip_file_name     => 'GSM MOBILE',
                                                  ip_file_type     => '1',
                                                  ip_expire_date   => 'NA',
                                                  op_carrier_id    => c_line_o_carrier_id,
                                                  op_carrier_name  => c_line_o_carrier_name,
                                                  op_result        => c_line_o_result,
                                                  op_msg           => c_line_o_msg);

        DBMS_OUTPUT.put_line ('Line creation  result  ' || c_line_o_result);
        DBMS_OUTPUT.put_line ('Line creation  message ' || c_line_o_msg);

        IF c_line_o_result <> 1 THEN
          c_response := c_response || '|' || 'Line Insert Err :' || c_line_o_msg;
        END IF;

        ctt := code_table_type ();             --again reinitialize for line
        --
        ctt := code_table_type ( i_code_number => i_line_part_inst_status );

        --link the line to ESN
        UPDATE table_part_inst
        SET    part_to_esn2part_inst = pi.part_inst_objid,
               x_part_inst_status = i_line_part_inst_status,
               status2x_code_table = ctt.code_table_objid
        WHERE  part_serial_no = data (i).MIN
        AND    x_domain = 'LINES';

        --x_service_plan_site_part
        spsp.service_plan_site_part_objid := sp.site_part_objid;
        spsp.service_plan_id := data (i).service_plan;
        /*get_gosmart_service_plan(i_source           => 'GOSMART',
                                   i_service_plan     => data(i).service_plan,
                                   i_auto_refill_flag => NVL(c_autorefill_flag,'N'),
                                   i_ild_service      => NVL(data(i).ild_service,'N')); */
        spsp.switch_base_rate := 0; -- need to check this value for simple mobile
        spsp.new_service_plan_id := NULL;
        spsp.last_modified_date := SYSDATE;

        IF spsp.service_plan_id IS NOT NULL THEN
          ins_service_plan_site_part ( i_service_plan_site_part_type  => spsp,
                                       o_response                     => o_response);
          DBMS_OUTPUT.put_line ('service plan site part response   ' || spsp.response);

          IF spsp.response NOT LIKE '%SUCCESS%' THEN
            c_response := c_response || '|' || 'Service Plan SP Err :' || spsp.response;
          ELSIF spsp.response IN ('SUCCESS-UPDATED', 'SUCCESS-INSERTED') THEN
            --insert x_xervice_plan_hist
            sph.plan_hist2site_part_objid := sp.site_part_objid;
            sph.start_date := SYSDATE;
            sph.plan_hist2service_plan := spsp.service_plan_id;
            sph.insert_date := SYSDATE;
            sph.last_modified_date := SYSDATE;
            ins_service_plan_hist (i_service_plan_hist_type  => sph,
                                   o_response                => o_response);
            DBMS_OUTPUT.put_line ('service plan hist   ' || sph.response);

            --insert x_xervice_plan_hist
            IF sph.response NOT LIKE '%SUCCESS%' THEN
              c_response := c_response || '|' || 'Service Plan H Err :' || sph.response;
            END IF;
          END IF;
        ELSE
          c_response := c_response || '|' || 'Service Plan Not Found';
        END IF;

        -- commented not needed during pre migration
        /*  -- insert table_x_pi_hist entry only for active devices
              ph.status_hist2code_table         := 988; --Active
              ph.change_date                    := SYSDATE;
              ph.change_reason                  := 'ACTIVATE';
              ph.creation_date                  := pi.creation_date;
              ph.domain                         := 'PHONES';
              ph.insert_date                    := pi.insert_date;
              ph.part_inst_status               := '52';
              ph.part_serial_no                 := data(i).esn;
              ph.part_status                    := 'Active';
  --          ph.pi_hist2carrier_mkt            :=
              ph.pi_hist2inv_bin                := '';--need to updated TBD
  --          ph.pi_hist2part_inst              :=
              ph.pi_hist2part_mod               := pi.n_part_inst2part_mod;
              ph.pi_hist2user                   := 268435556;
  --          ph.pi_hist2new_pers               := 0;
  --          ph.pi_hist2pers                   := 0;
  --          ph.po_num                         :=
              ph.reactivation_flag              := 0;
  --          ph.red_code                       :=
              ph.sequence                       := 0;
              ph.warr_end_date                  := pi.warr_end_date;
  --          ph.dev                            :=
  --          ph.fulfill_hist2demand_dtl        :=
  --          ph.part_to_esn_hist2part_inst     :=
  --          ph.bad_res_qty                    :=
  --          ph.date_in_serv                   :=
  --          ph.good_res_qty                   :=
  --          ph.last_cycle_ct                  :=
  --          ph.last_mod_time                  :=
  --          ph.last_pi_date                   :=
              ph.last_trans_time                := SYSDATE;
  --          ph.next_cycle_ct                  :=
              ph.order_number                   := pi.order_number;
  --          ph.part_bad_qty                   :=
  --          ph.part_good_qty                  :=
  --          ph.pi_tag_no                      :=
  --          ph.pick_request                   :=
  --          ph.repair_date                    :=
  --          ph.transaction_id                 :=
              ph.pi_hist2site_part              := sp.site_part_objid;
  --          ph.msid                           :=
              ph.pi_hist2contact                := c_contact_o_objid;
              ph.iccid                          := data(i).sim;


              ins_pi_hist ( i_pi_hist_type   => ph         ,
                            o_response       => o_response );

                 IF ph.response NOT LIKE '%SUCCESS%' THEN
                c_response := c_response||'|'||ph.response;
              END IF;      */

        --dbms_output.put_line('pi hist response   '||ph.response)    ;

        --implement logic for below tables here
        --set the type attributes(refer budget scripts to set the type attributes and also refer other tables implementation in migration package )
        --call insert procedure if procedure is not then create procedure
        --set the c_response variable if it is not success
        --if you are not sure about attribute value then leave it as null and mention that as a comment  in the same line

        /*
                Table_web_user
                Table_x_contact_part_inst
                X_program_enrolled
                X_program_purch_hdr
                X_program_purch_dtl
                X_program_trans*/

        -- insert table_web_user
        -- wu.web_user_objid    := data(i).web_user_objid;

        -- IF  REGEXP_LIKE (data(i).login_name ,'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$') THEN

        wu.login_name := data (i).login_name;
        wu.s_login_name := UPPER (data (i).login_name);
        wu.password := data(i).login_password;
        wu.user_key := NULL;
        wu.status := 1;                                    --need to confirm
        wu.passwd_chg := NULL;
        wu.dev := NULL;
        wu.ship_via := NULL;
        --  wu.secret_questn     := data(i).secret_question;
        --  wu.s_secret_questn   := UPPER(data(i).secret_question);
        --  wu.secret_ans        := data(i).secret_answer;
        --  wu.s_secret_ans      := UPPER(data(i).secret_answer);
        wu.web_user2user := NULL;
        wu.web_user2contact := c_contact_o_objid;
        wu.web_user2lead := NULL;
        wu.web_user2bus_org := n_bus_org_objid;
        wu.last_update_date := SYSDATE;
        wu.validated := NULL;                        --need to confirm value
        wu.validated_counter := NULL;                --need to confirm value
        wu.named_userid := NULL;
        wu.insert_timestamp := SYSDATE;


        ins_web_user ( i_web_user_type => wu,
                       o_response      => o_response);

        IF wu.response NOT LIKE '%SUCCESS%' THEN
          c_response := c_response || '|' || 'Web User Err :' || wu.response;
        END IF;

        --
        DBMS_OUTPUT.put_line ('web user response   ' || wu.response);


        --   Table_x_contact_part_inst
        cpi.contact_part_inst2contact := c_contact_o_objid;
        cpi.contact_part_inst2part_inst := pi.part_inst_objid;
        cpi.esn_nick_name := NULL;                   --need to confirm value
        cpi.is_default := 1;                         --need to confirm value
        cpi.transfer_flag := 0;                      --need to confirm value
        cpi.verified := 'Y';                         --need to confirm value
        cpi.response := NULL;


        ins_contact_part_inst ( i_contact_part_inst_type  => cpi,
                                o_response                => o_response);

        IF cpi.response NOT LIKE '%SUCCESS%' THEN
          c_response := c_response || '|'|| 'Contact PI Err :' || cpi.response;
        END IF;

        DBMS_OUTPUT.put_line ('contact part inst response   ' || cpi.response);

        -- IF data(i).auto_refill_flag = 'Y' THEN
        IF data(i).auto_refill_flag = 'Y' AND data(i).SERVICE_PLAN NOT IN (457,458) THEN
          pe.pgm_enroll2pgm_parameter := get_program_id (
                                           i_source        => 'GOSMART',
                                           i_service_plan  => spsp
                                                             .service_plan_id);

          pe.esn := data (i).esn;
          pe.amount := get_price (pe.pgm_enroll2pgm_parameter); --need to update
          pe.TYPE := 'INDIVIDUAL';
          pe.zipcode := data (i).zipcode;
          pe.sourcesystem := i_source_system;            ----need to confirm
          pe.insert_date := SYSDATE;
          pe.charge_date := NULL;
          pe.pec_customer := NULL;
          pe.charge_type := NULL;
          pe.enrolled_date := data (i).activation_date;
          pe.start_date := data (i).activation_date;
          pe.reason := NULL;
          pe.exp_date := NULL;
          pe.delivery_cycle_number := NULL;
          pe.enroll_amount := 0;
          pe.language := data(i).language;
          --NULL;--data(i).language;--need to update
          pe.payment_type := NULL;                           --need to confirm
          pe.grace_period := NULL;
          pe.cooling_period := NULL;
          pe.service_days := NULL;
          pe.cooling_exp_date := NULL;
          pe.enrollment_status := i_enrollment_status;     --need to confirm
          pe.is_grp_primary := NULL;
          pe.tot_grace_period_given := NULL;
          pe.next_charge_date := NULL;   --not updating during pre migration
          pe.next_delivery_date := NULL;
          pe.update_stamp := SYSDATE;
          pe.update_user := NULL;
          pe.pgm_enroll2pgm_group := NULL;
          pe.pgm_enroll2site_part := sp.site_part_objid;
          pe.pgm_enroll2part_inst := pi.part_inst_objid;
          pe.pgm_enroll2contact := c_contact_o_objid;
          pe.pgm_enroll2web_user := wu.web_user_objid;
          pe.pgm_enroll2x_pymt_src := pph.prog_hdr2pymt_src;
          pe.wait_exp_date := NULL;
          pe.pgm_enroll2x_promotion := NULL;
          pe.pgm_enroll2prog_hdr := NULL;
          pe.termscond_accepted := NULL;
          pe.service_delivery_date := NULL;
          pe.default_denomination := NULL;
          pe.auto_refill_max_limit := NULL;
          pe.auto_refill_counter := NULL;
          pe.response := NULL;
          pe.varchar2_value := c_old_esn;                   --assign old esn

          IF pe.pgm_enroll2pgm_parameter IS NOT NULL THEN
            ins_program_enrolled ( i_program_enrolled_type  => pe,
                                   o_response               => o_response);

            IF pe.response NOT LIKE '%SUCCESS%' THEN
              c_response := c_response || '|' || 'Program En Err :' || pe.response;
            ELSE -- insert X_PROGRAM_TRANS
              --insert X_PROGRAM_PURCH_HDR,X_PROGRAM_PURCH_DTL,X_PROGRAM_TRANS only when x_program_enrolled is SUCCESS

              -- insert table X_PROGRAM_PURCH_HDR
              /* UPDATE x_gsm_enrollment_stg
               SET record_status    ='COMPLETED',
                   record_response  = 'SUCCESS',
                   update_timestamp = SYSDATE
               WHERE objid = en_rec.objid;        */

              --dbms_output.put_line ('payment source to credit card'||pymnt_src_rec.pymt_src2x_credit_card);

              /*  IF l_flag <> 'ESN Change' THEN

                    pph.rqst_source             :=i_pph_request_source;  --need to confirm value
                    pph.rqst_type               := i_pph_request_type ;/*CASE WHEN ps_rec.payment_type = 'CREDITCARD' THEN 'CREDITCARD_PURCH'
                                                  WHEN ps_rec.payment_type = 'ACH' THEN 'ACH_PURCH'
                                                  ELSE NULL
                                                  END ; */
              --need to confirm value
              /*    pph.rqst_date               :=SYSDATE;
                  pph.ics_applications        :=NULL;
                  pph.merchant_id             :=NULL; --need to confirm value
                  pph.merchant_ref_NUMBER     :=sa.merchant_ref_number;
                  pph.offer_num               :=NULL;
                  pph.quantity                :='1'; --need to confirm value
                  pph.merchant_product_sku    :=NULL;
                  pph.payment_line2program    :=NULL;
                  pph.product_code            :=NULL;
                  pph.ignore_avs              :='YES';
                  pph.user_po                 :=NULL;
                  pph.avs                     :=NULL;
                  pph.disable_avs             :=NULL;
                  pph.customer_hostname       :=NULL;
                  pph.customer_ipaddress      :=NULL;
                  pph.auth_request_id         :=NULL;
                  pph.auth_code               :=NULL;
                  pph.auth_type               :=NULL;
                  pph.ics_rcode               :='1';  --need to confirm value
                  pph.ics_rflag               :='SOK';  --need to confirm value
                  pph.ics_rmsg                :='Request was processed successfully.';  --need to confirm value
                  pph.request_id              :=NULL;
                  pph.auth_avs                :=NULL;
                  pph.auth_response           :=NULL;
                  pph.auth_time               :=NULL;
                  pph.auth_rcode              :='1'; --need to confirm value
                  pph.auth_rflag              :='SOK'; --need to confirm value
                  pph.auth_rmsg               :='Request was processed successfully.'; --need to confirm value
                  pph.bill_request_time       :=NULL;
                  pph.bill_rcode              :='1'; --need to confirm value
                  pph.bill_rflag              :='SOK'; --need to confirm value
                  pph.bill_rmsg               :='Request was processed successfully.'; --need to confirm value
                  pph.bill_trans_ref_no       :=NULL;
                  pph.customer_firstname      :=data(i).first_name;--NVL(cc_rec.customer_first_name,ach_rec.ach_customer_firstname);
                  pph.customer_lastname       :=data(i).last_name;--NVL(cc_rec.customer_last_name,ach_rec.ach_customer_lastname);
                  pph.customer_phone          :=data(i).min;
                  pph.customer_email          :=data(i).email;--NVL(cc_rec.customer_email,ach_rec.ach_customer_email); --need to confirm value
                  pph.status                  :='SUCCESS';  --need to confirm value
                  pph.bill_address1           :=data(i).address_1;--NVL(cc_rec.address_1 ,ach_rec.ach_address_1);
                  pph.bill_address2           :=data(i).address_2;--NVL(cc_rec.address_2 ,ach_rec.ach_address_2);
                  pph.bill_city               := NVL(data(i).city,c_city);--NVL(cc_rec.city      ,ach_rec.ach_city);
                  pph.bill_state              := NVL(data(i).state,c_state);--NVL(cc_rec.state     ,ach_rec.ach_state);
                  pph.bill_zip                :=data(i).zipcode;--NVL(cc_rec.zipcode   ,ach_rec.ach_zipcode);
                  pph.bill_country            :=NULL;--NVL(cc_rec.country ,ach_rec.ach_country);
                  pph.esn                     :=NULL;
                  pph.amount                  :=pe.amount;--need to confirm
                  pph.tax_amount              :=NULL;
                  pph.auth_amount             :=NULL;
                  pph.bill_amount             :=NULL;
                  pph.userid                  :='OPERATIONS'; --need to confirm
                  pph.credit_code             :=NULL;
                  pph.purch_hdr2creditcard    :=NULL;--CASE WHEN ps_rec.payment_type = 'CREDITCARD' THEN pymnt_src_rec.pymt_src2x_credit_card ELSENULLEND;
                  pph.purch_hdr2bank_acct     :=NULL;--CASE WHEN ps_rec.payment_type ='ACH' THEN pymnt_src_rec.pymt_src2x_bank_account ELSE NULL END ;
                  pph.purch_hdr2user          :=NULL;
                  pph.purch_hdr2esn           :=NULL;
                  pph.purch_hdr2rmsg_codes    :=NULL;
                  pph.purch_hdr2cr_purch      :=NULL;
                  --pph.prog_hdr2pymt_src       :=NULL;
                  pph.prog_hdr2web_user       :=wu.web_user_objid;
                  pph.prog_hdr2prog_batch     :=NULL;
                  pph.payment_type            :=i_pph_payment_type; --need to confirm
                  pph.e911_taamount           :=NULL;
                  pph.usf_taxamount           :=NULL;
                  pph.rcrf_tax_amount          :=NULL;
                  pph.process_date            :=NULL;
                  pph.discount_amount         :=NULL;
                  pph.priority                :=NULL;

                  ins_program_purch_hdr ( i_program_purch_hdr_type => pph,
                                          i_esn                    => data(i).esn,
                                          o_response               => o_response );

                  IF pph.response NOT LIKE '%SUCCESS%' THEN
                    c_response := c_response||'|'||'PPH Err :'||pph.response;
                  END IF;

                  dbms_output.put_line('Program purch hdr response'||pph.response);

                  --X_program_purch_dtl
                  ppd.program_purch_dtl_objid              := NULL;
                  ppd.esn                                  := data(i).esn;
                  ppd.amount                               := pe.amount;
                  ppd.charge_desc                          := 'GoSmart Enrollment Migration';
                  ppd.cycle_start_date                     := data(i).activation_date; --need to confirm
                  ppd.cycle_end_date                       := NULL;                    --need to confirm
                  ppd.pgm_purch_dtl2pgm_enrolled           := pe.program_enrolled_objid;
                  ppd.pgm_purch_dtl2prog_hdr               := pph.program_purch_hdr_objid;
                  ppd.pgm_purch_dtl2penal_pend             := NULL;
                  ppd.tax_amount                           := NULL;
                  ppd.e911_tax_amount                      := NULL;
                  ppd.usf_taxamount                        := NULL;
                  ppd.rcrf_tax_amount                      := NULL;
                  ppd.priority                             := NULL;

                  ins_program_purch_dtl ( i_program_purch_dtl_type   => ppd         ,
                                          o_response                 => o_response );

                  IF ppd.response NOT LIKE '%SUCCESS%' THEN
                    c_response := c_response||'|'||'PPD Err :'||ppd.response;
                  END IF;

                  dbms_output.put_line('Program purch dtl response'||ppd.response);    */

              -- insert table X_PROGRAM_TRANS
              pt.trans_date := SYSDATE;
              pt.enrollment_status := pe.enrollment_status;
              pt.enroll_status_reason := 'FIRST TIME ENROLLMENT';
              pt.action_text := 'ENROLLMENT ATTEMPT';      --need to confirm
              pt.action_type := 'ENROLLMENT';              --need to confirm
              pt.reason := 'GoSmart Migration Enrollment'; --need to confirm
              pt.sourcesystem := i_source_system;          --need to confirm
              pt.esn := data (i).esn;
              pt.exp_date := NULL;
              pt.cooling_exp_date := NULL;
              pt.update_status := NULL;
              pt.update_user := 'OPERATIONS';              --need to confirm
              pt.pgm_tran2pgm_entrolled := pe.program_enrolled_objid;
              pt.pgm_trans2web_user := wu.web_user_objid;
              pt.pgm_trans2site_part := sp.site_part_objid;

              ins_program_trans (i_program_trans_type  => pt,
                                 o_response            => o_response);

              IF pt.response NOT LIKE '%SUCCESS%' THEN
                c_response := c_response  || '|' || 'Program Trans Err :' || pt.response;
              END IF;

              DBMS_OUTPUT.put_line ('Program trans  response' || pt.response);
            END IF; --pe.response IS NOT NULL
          ELSE
            c_response := c_response || '|' || 'PROGRAM ID NOT FOUND';
          END IF; -- pe.pgm_enroll2pgm_parameter IS NOT NULL
        END IF; -- auto_refill_flag IS NOT NULL


        IF UPPER (c_response) NOT LIKE '%SUCCESS%'
           AND c_response IS NOT NULL
        THEN
          -- increase row count
          n_failed_rows := n_failed_rows + 1;
          -- maybe update the staging table with the failed response message

          -- maybe continue to next iteration row
          -- CONTINUE

        END IF;

        --code to update migration status
        UPDATE x_gsm_acct_migration_stg
        SET    migration_status = CASE
                                    WHEN c_response IS NULL THEN
                                      'PREMIGRATION_COMPLETED'
                                    ELSE
                                      'PREMIGRATION_FAILED'
                                  END,
               migration_response = CASE
                                      WHEN c_response IS NULL THEN 'SUCCESS'
                                      ELSE c_response
                                    END,
               part_inst_objid = pi.part_inst_objid,
               site_part_objid = sp.site_part_objid,
               call_trans_objid = ct.call_trans_objid,
               contact_objid = c_contact_o_objid,
               program_enrolled_objid = pe.program_enrolled_objid,
               web_user_objid = wu.web_user_objid,
               update_timestamp = SYSDATE
        WHERE  objid = data (i).objid;

        -- reset response as null for reuse
        --o_response := NULL;

        -- increase row count
        n_count_rows := n_count_rows + 1;

        IF (MOD (n_count_rows, i_commit_every_rows) = 0) THEN
          -- Save changes
          COMMIT;
        END IF;
        --


      EXCEPTION -- loop exception
        WHEN OTHERS THEN
          c_response := c_response || 'sqlcode-sqlerrm' || SQLCODE || ' - ' || SUBSTR (SQLERRM, 1, 500);

          UPDATE x_gsm_acct_migration_stg
          SET    migration_status = 'PREMIGRATION_FAILED',
                 migration_response = c_response,
                 part_inst_objid = pi.part_inst_objid,
                 site_part_objid = sp.site_part_objid,
                 call_trans_objid = ct.call_trans_objid,
                 contact_objid = c_contact_o_objid,
                 program_enrolled_objid = pe.program_enrolled_objid,
                 web_user_objid = wu.web_user_objid,
                 update_timestamp = SYSDATE
          WHERE  objid = data (i).objid;
      END;
    END LOOP;                                                      -- c_data

    --
    EXIT WHEN c_get_data%NOTFOUND;
  --
  END LOOP;

  CLOSE c_get_data;

  -- exit when there are no more records to archive
  -- EXIT WHEN NOT ( more_rows_exist );

  -- END LOOP; -- WHILE (more_rows_exist)

  --
  DBMS_OUTPUT.PUT_LINE (n_count_rows || ' rows processed');
  --
  DBMS_OUTPUT.PUT_LINE (n_failed_rows || ' rows failed');


  -- Save changes
  COMMIT;

  -- Set response
  o_response := CASE
                  WHEN c_response IS NULL THEN 'SUCCESS'
                  ELSE c_response
                END;
--
EXCEPTION
  WHEN OTHERS THEN
    --
    o_response := 'ERROR IN LOAD_GOSMART: ' || SQLERRM;

    -- possibly log in the error table
    -- sa.util_pkg.log_error
    --
    RAISE;
END load_gosmart_premigration;

PROCEDURE load_gosmart_final_migration ( o_response                OUT    VARCHAR2,
                                         i_max_rows_limit          IN     NUMBER DEFAULT 50000,
                                         i_commit_every_rows       IN     NUMBER DEFAULT 5000,
                                         i_bulk_collection_limit   IN     NUMBER DEFAULT 300,
                                         i_skip_premigration       IN     VARCHAR2 DEFAULT 'N',
                                         i_carrier_id              IN     VARCHAR2 DEFAULT '1113385',
                                         i_brand                   IN     VARCHAR2 DEFAULT 'SIMPLE_MOBILE',
                                         i_phone_part_inst_status  IN     VARCHAR2 DEFAULT '160',
                                         i_line_part_inst_status   IN     VARCHAR2 DEFAULT '120',
                                         i_sim_status              IN     VARCHAR2 DEFAULT '253',
                                         i_site_part_status        IN     VARCHAR2 DEFAULT 'NotMigrated',
                                         i_source_system           IN     VARCHAR2 DEFAULT 'BATCH',
                                         i_enrollment_status       IN     VARCHAR2 DEFAULT 'READYTOREENROLL',
                                         i_pph_request_type        IN     VARCHAR2 DEFAULT 'GOSMART_PURCH',
                                         i_pph_request_source      IN     VARCHAR2 DEFAULT 'GOSMART',
                                         i_user                    IN     VARCHAR2 DEFAULT 'OPERATIONS',
                                         i_pph_payment_type        IN     VARCHAR2 DEFAULT 'GOSMART_ENROLLMENT',
                                         i_policy_name             IN     VARCHAR2 DEFAULT 'policy54') AS
  --
  pi_phone                  part_inst_type := part_inst_type ();
  pi_line                   part_inst_type := part_inst_type ();
  sp                        site_part_type := site_part_type ();
  ph                        pi_hist_type := pi_hist_type ();
  rc                        sa.red_card_type := red_card_type ();
  ct                        sa.call_trans_type := call_trans_type ();
  c                         sa.call_trans_type;
  sub                       sa.subscriber_type := subscriber_type ();
  pcrf                      sa.pcrf_transaction_type := pcrf_transaction_type ();
  --

  n_count_rows              NUMBER := 0;
  n_success_final_mig_cnt   NUMBER := 0;
  n_failed_final_mig_cnt    NUMBER := 0;
  n_failed_data_update_cnt  NUMBER := 0;
  c_err_code                VARCHAR2 (50);
  c_err_msg                 VARCHAR2 (1000);
  n_bus_org_objid           NUMBER;
  n_user_objid              NUMBER;
  n_call_trans_objid        NUMBER;
  n_carrier_objid           NUMBER;
  n_interact_objid          NUMBER; --CR47564 added for WFM
  c_response                VARCHAR2 (4000);
  l_pcrf_response           VARCHAR2 (4000);
  l_sourcesystem            VARCHAR2 (100) := 'BATCH';
  l_pintoesn                NUMBER;
  l_return                  NUMBER;
  l_group_return            NUMBER;
  l_account_group_uid       VARCHAR2 (50);
  l_account_group_id        VARCHAR2 (50);
  l_subscriber_uid          VARCHAR2 (50);
  l_group_err_code          VARCHAR2 (50);
  l_group_err_msg           VARCHAR2 (1000);
  l_phone_status_objid      NUMBER;
  l_phone_status_code       VARCHAR2 (50);
  l_line_status_objid       NUMBER;
  l_line_status_code        VARCHAR2 (50);
  l_sim_status_objid        NUMBER;
  l_sim_status_code         VARCHAR2 (50);
  l_site_part_status        VARCHAR2 (50);
  l_step                    VARCHAR2 (150);
  c_cos                     VARCHAR2 (50);
  l_throttle_err_code       NUMBER;
  l_throttle_err_msg        VARCHAR2 (1000);
  l_throttle_response       VARCHAR2 (1000);
  l_cash_bal_err_code       NUMBER;
  l_cash_bal_err_msg        VARCHAR2 (1000);

  -- get pending staging records
  CURSOR c_get_data IS
    SELECT *
    FROM   (SELECT *
            FROM   x_gsm_acct_migration_stg
            WHERE  migration_status IN ('READYTOMIGRATE')
            ORDER BY objid--AND    insert_timestamp < TRUNC(SYSDATE)
           )
    WHERE  ROWNUM <= i_max_rows_limit;

  CURSOR c_get_interactions (i_min IN VARCHAR2) IS
    SELECT /*+ INDEX(stg idx1_gsm_interactions_stg) */*
    FROM   x_gsm_interactions_stg stg
    WHERE  MIN = i_min
    AND    record_status = 'PENDING';

  rec_interactions          c_get_interactions%ROWTYPE;

  --
  CURSOR cur_wu_contact_objid ( c_pi_objid NUMBER ) IS
    SELECT web.objid web_user_objid,
           WEB.web_user2contact contact_objid,
           conpi.objid contact_part_inst_objid
    FROM   table_web_user web, table_x_contact_part_inst CONPI
    WHERE  CONPI.x_contact_part_inst2contact = WEB.web_user2contact
    AND    CONPI.x_contact_part_inst2part_inst = c_pi_objid;

  CURSOR cur_site_part_record ( c_esn VARCHAR2 ) IS
    SELECT objid site_part_objid
    FROM   table_site_part
    WHERE  x_service_id = c_esn;

  rec_wu_contact_objid      cur_wu_contact_objid%ROWTYPE;

  -- temporary record to hold required attributes
  TYPE dataList IS TABLE OF c_get_data%ROWTYPE;

  -- table to hold array of data
  data                      dataList;

  -- This function used to determine whether any staging data exist to process for migration.
  FUNCTION f_more_rows_exist
    RETURN BOOLEAN IS
    n_count  NUMBER := 0;
  BEGIN
    SELECT COUNT (1)
    INTO   n_count
    FROM   DUAL
    WHERE  EXISTS
             (SELECT 1
              FROM   x_gsm_acct_migration_stg
              WHERE  migration_status IN ('READYTOMIGRATE'));

    --
    RETURN (CASE WHEN n_count > 0 THEN TRUE ELSE FALSE END);
  --
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END f_more_rows_exist;
BEGIN
  -- set global variable to avoid unwanted trigger executions
  sa.globals_pkg.g_run_my_trigger := FALSE;

  -- Get bus org objid.
  l_step := 'Get bus org objid.';

  BEGIN
    SELECT objid
    INTO   n_bus_org_objid
    FROM   table_bus_org
    WHERE  org_id = i_brand;
  EXCEPTION
    WHEN OTHERS THEN
      n_bus_org_objid := NULL;                   --need to update value here
  END;

  -- Get Carrier objid
  BEGIN
    SELECT objid
    INTO   n_carrier_objid
    FROM   table_x_carrier
    WHERE  x_carrier_id = i_carrier_id;
  EXCEPTION
    WHEN OTHERS THEN
      n_carrier_objid := NULL;                   --need to update value here
  END;

  -- Get user objid.
  l_step := 'Get user objid.';

  BEGIN
    SELECT objid
    INTO   n_user_objid
    FROM   table_user
    WHERE  UPPER (login_name) = 'SA';
  EXCEPTION
    WHEN OTHERS THEN
      n_user_objid := NULL;                      --need to update value here
  END;

  -- perform a loop while applicable staging record exists
  WHILE (f_more_rows_exist) LOOP
    -- open cursor to retrieve data records
    OPEN c_get_data;

    -- start loop
    LOOP
      -- fetch cursor data into collection (limit collection to i_bulk_collection_limit rows at a time)
      FETCH c_get_data BULK COLLECT INTO data LIMIT i_bulk_collection_limit;

      -- loop through staging data collection
      FOR i IN 1 .. data.COUNT LOOP
        BEGIN
          l_phone_status_objid  := NULL;
          l_phone_status_code   := NULL;
          l_line_status_objid   := NULL;
          l_line_status_code    := NULL;
          l_sim_status_objid    := NULL;
          l_sim_status_code     := NULL;
          l_site_part_status    := NULL;
          n_call_trans_objid    := NULL;
          l_group_return        := null;
          l_flag                := null;

          l_account_group_uid   := NULL;
          l_account_group_id    := NULL;
          l_subscriber_uid      := NULL;
          l_group_err_code      := NULL;
          l_group_err_msg       := NULL;


          rec_wu_contact_objid := NULL;
          o_response := NULL;
          c_response := NULL;
          l_pcrf_response := NULL;
	  l_throttle_response  := NULL;
	  l_throttle_err_code  := NULL;
          l_throttle_err_msg   := NULL;

	  l_cash_bal_err_code  := NULL;
          l_cash_bal_err_msg   := NULL;

          -- derive go smart status in clarify
          get_gosmart_status_mappings ( i_status              => data (i).customer_status,
                                        o_phone_status_objid  => l_phone_status_objid,
                                        o_phone_status_code   => l_phone_status_code,
                                        o_line_status_objid   => l_line_status_objid,
                                        o_line_status_code    => l_line_status_code,
                                        o_sim_status_objid    => l_sim_status_objid,
                                        o_sim_status_code     => l_sim_status_code,
                                        o_site_part_status    => l_site_part_status);

          --***********************************************
          -- Call Pre migration script to update the data
          --***********************************************
          l_step := 'Call Pre migration script to update the data.';
          DBMS_OUTPUT.put_line ( TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss') || ' test 00a before premigration call for update : ' || DATA (i).esn || ' - ' || DATA (i).MIN);
          --
          IF  NVL(i_skip_premigration,'X')  <> 'Y' THEN
            migration_pkg.load_gosmart_premigration ( o_response                => o_response,
                                                      i_max_rows_limit          => i_max_rows_limit,
                                                      i_commit_every_rows       => i_commit_every_rows,
                                                      i_bulk_collection_limit   => i_bulk_collection_limit,
                                                      i_carrier_id              => i_carrier_id,
                                                      i_brand                   => i_brand,
                                                      i_min                     => data(i).min,
                                                      i_phone_part_inst_status  => i_phone_part_inst_status,
                                                      i_line_part_inst_status   => i_line_part_inst_status,
                                                      i_sim_status              => i_sim_status,
                                                      i_site_part_status        => i_site_part_status,
                                                      i_source_system           => i_source_system,
                                                      i_enrollment_status       => i_enrollment_status,
                                                      i_pph_request_type        => i_pph_request_type,
                                                      i_pph_request_source      => i_pph_request_source,
                                                      i_user                    => i_user,
                                                      i_pph_payment_type        => i_pph_payment_type);
          END IF;

          l_flag := null;	-- to nullify flag set during pre migration

          DBMS_OUTPUT.put_line ( TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss') || ' test 00b after premigration call for update : ' || O_RESPONSE);

          IF NVL (o_response, 'x') LIKE '%SUCCESS%' OR  i_skip_premigration ='Y' THEN
            BEGIN
              -- reset response as null for reuse
              o_response := NULL;
              c_response := NULL;
              l_return := NULL;
              l_pintoesn := NULL;

              --initialize type attributes to null
              DBMS_OUTPUT.put_line ( TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss') || ' test 01: ' || data (i).esn || ' - ' || data (i).MIN);
              pi_phone := part_inst_type (i_esn => data (i).esn);
              pi_line := part_inst_type (i_esn => data (i).MIN); -- ??? may need to change the parameter name
              rc := red_card_type ();
              -- Get Web user and Contact objid
              l_step := 'Get Web user and Contact objid.';

              OPEN cur_wu_contact_objid (pi_phone.part_inst_objid);
              FETCH cur_wu_contact_objid INTO rec_wu_contact_objid;
              CLOSE cur_wu_contact_objid;

              ct := call_trans_type ();

              --*********************************************
              -- Update Site part status (TABLE_SITE_PART).
              --*********************************************
              l_step := 'Update Site part status (TABLE_SITE_PART).';
              sp   := site_part_type ();
              sp.service_id := data (i).esn;
              sp.MIN := data (i).MIN;
              sp.iccid := data (i).sim;
              sp.install_date := TRUNC (
                                   NVL (data (i).activation_date, SYSDATE));
              sp.warranty_date := CASE
                                    WHEN l_site_part_status = 'Active' THEN
                                      TRUNC(GREATEST(data(i).renewal_date,SYSDATE))
                                    ELSE
                                      TRUNC(data(i).renewal_date)
                                  END;
              sp.expire_dt :=  CASE
                                    WHEN l_site_part_status = 'Active' THEN
                                      TRUNC(GREATEST(data(i).renewal_date,SYSDATE))
                                    ELSE
                                      TRUNC(data(i).renewal_date)
                                  END;

              sp.part_status := l_site_part_status;

              -- insert site part record
              ins_site_part (i_site_part_type  => sp,
                             o_response        => o_response);

              DBMS_OUTPUT.put_line ( TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss') || ' test 02 site part insert: ' || o_response);

              IF sp.response NOT LIKE '%SUCCESS%' THEN
                c_response := c_response || '|' || 'Site Part Err :' || sp.response;
                n_failed_final_mig_cnt := n_failed_final_mig_cnt + 1;

                UPDATE x_gsm_acct_migration_stg
                SET    migration_status = 'FAILED_FINAL_MIGRATION',
                       migration_response = c_response
                WHERE  objid = data (i).objid;

                CONTINUE;                          --continue next iteration
              END IF;

              --*****************************************
              -- Update PHONE status in TABLE_PART_INST.
              --*****************************************
              /*
                  Active      -> ACTIVE   (52-988)
                  Suspend     -> PASTDUE  (54-990)
                  Inactive    -> PASTDUE  (54-990)
                  New         -> NEW      (50-986)
              */
              l_step := 'Update PHONE status in TABLE_PART_INST.';

              -- update status of the esn
              UPDATE table_part_inst
              SET    x_part_inst_status = NVL (l_phone_status_code, x_part_inst_status),
                     status2x_code_table = NVL (l_phone_status_objid, status2x_code_table),
                     x_part_inst2site_part = NVL (x_part_inst2site_part, sp.site_part_objid),
                     warr_end_date = CASE
                                       WHEN l_site_part_status = 'Active' THEN TRUNC(GREATEST(data(i).renewal_date,SYSDATE))
                                       ELSE TRUNC(data(i).renewal_date)
                                     END
              WHERE  part_serial_no = data(i).esn
              AND    x_domain = 'PHONES';

              DBMS_OUTPUT.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss') || ' test 03 phone status update for ESN: ' || data (i).esn || ' - update record count ' || SQL%ROWCOUNT);
              --****************************************
              -- Update MIN status in TABLE_PART_INST.
              --****************************************
              /*
                  Active      -> ACTIVE         (13-960)
                  Suspend     -> RESERVED USED  (39-1040)
                  Inactive    -> RESERVED USED  (39-1040)
                  New         -> NEW            (11-958)
              */
              l_step := 'Update MIN status in TABLE_PART_INST.';

              -- update status of the line
              UPDATE table_part_inst
              SET    x_part_inst_status = NVL (l_line_status_code, x_part_inst_status),
                     status2x_code_table = NVL (l_line_status_objid, status2x_code_table),
                     x_part_inst2site_part = NVL (x_part_inst2site_part, sp.site_part_objid),
                     warr_end_date = CASE
                                       WHEN l_site_part_status = 'Active' THEN GREATEST(data(i).renewal_date,SYSDATE)
                                       ELSE data(i).renewal_date
                                     END
              WHERE  part_serial_no = data(i).min
              AND    x_domain = 'LINES';

              DBMS_OUTPUT.put_line ( TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss') || ' test 04 line status update for ESN: ' || data (i).MIN || ' - update record count ' || SQL%ROWCOUNT);
              --**********************************************************************
              -- Update SIM status to Active in X_SIM_INV_STATUS (254 - SIM ACTIVE).
              --**********************************************************************
              l_step := 'Update SIM status to Active in X_SIM_INV_STATUS (254 - SIM ACTIVE).';

              UPDATE table_x_sim_inv
              SET    x_sim_inv_status = NVL(l_sim_status_code,x_sim_inv_status),
                     x_sim_status2x_code_table = NVL(l_sim_status_objid,x_sim_status2x_code_table)
              WHERE  x_sim_serial_no = data(i).sim;

              DBMS_OUTPUT.put_line ( TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss') || ' test 05 SIM status update for ESN: ' || data (i).sim || ' - update record count ' || SQL%ROWCOUNT);
              --**********************************************************************
              -- LOAD Interactions
              --**********************************************************************
              l_step := 'LOAD Interactions';

              FOR rec_interactions IN c_get_interactions (data (i).MIN)
              LOOP
                n_interact_objid := NULL;
                ins_interaction ( i_contact_objid  => rec_wu_contact_objid.contact_objid,
                                  i_reason_1       => rec_interactions.action,
                                  i_reason_2       => rec_interactions.subaction,
                                  i_notes          => rec_interactions.moreinformation,
                                  i_rslt           => 'Successful',
                                  i_user           => 'SA',
                                  i_esn            => data(i).esn,
                                  i_create_date    => NVL(rec_interactions.cmdr_datetime,rec_interactions.datetime),
                                  i_start_date     => NVL(rec_interactions.cmdr_datetime,rec_interactions.datetime),
                                  i_end_date       => NVL(rec_interactions.cmdr_datetime,rec_interactions.datetime),
                                  o_interact_objid => n_interact_objid ,
                                  o_response       => o_response);

                IF o_response NOT LIKE '%SUCCESS%' THEN
                  UPDATE x_gsm_interactions_stg
                  SET    record_status = 'FAILED',
                         record_response = o_response,
                         update_timestamp = SYSDATE
                  WHERE  objid = rec_interactions.objid;
                ELSE
                  UPDATE x_gsm_interactions_stg
                  SET    record_status = 'COMPLETED',
                         record_response = 'SUCCESS',
                         update_timestamp = SYSDATE
                  WHERE  objid = rec_interactions.objid;
                END IF;
              END LOOP;

             /* l_step := 'LOAD cash balance interactions';

              IF  TO_NUMBER(data(i).wallet_balance) > 0  THEN

                IF data(i).additional_service_days IS NOT NULL  THEN
                 ins_interaction (  i_contact_objid  => rec_wu_contact_objid.contact_objid,
                                    i_reason_1       => 'Service days extended',
                                    i_reason_2       => 'Service days extended',
                                    p_notes          => 'Service days extended by '||data(i).additional_service_days||' days from cash balance ',
                                    p_rslt           => 'Successful',
                                    p_user           => 'SA',
                                    p_esn            => data(i).esn,
                                    o_response       => o_response);
                END IF;

                IF data(i).additional_data IS NOT NULL THEN
                 ins_interaction (  i_contact_objid  => rec_wu_contact_objid.contact_objid,
                                    i_reason_1       => 'Additonal data given',
                                    i_reason_2       => 'Additonal data given',
                                    p_notes          => 'Additonal data '||data(i).additional_data||' MB given from cash balance ',
                                    p_rslt           => 'Successful',
                                    p_user           => 'SA',
                                    p_esn            => data(i).esn,
                                    o_response       => o_response);
                END IF;


              END IF;*/



              --*******************************************
              --Group creation in X_ACCOUNT_GROUP_MEMBER.
              --*******************************************

              l_group_return := sa.create_member( i_esn               => data(i).esn,
                                                  i_web_user_objid    => rec_wu_contact_objid.web_user_objid,
                                                  i_service_plan_id   => data(i).service_plan,
                                                  i_bus_org_objid     => n_bus_org_objid,
                                                  i_group_status      => 'ACTIVE',
                                                  i_member_status     => 'ACTIVE',
                                                  i_force_create_flag => 'N',
                                                  i_retrieve_only_flag=> 'N',
                                                  o_account_group_uid => l_account_group_uid,
                                                  o_account_group_id  => l_account_group_id,
                                                  o_subscriber_uid    => l_subscriber_uid,
                                                  o_err_code          => l_group_err_code,
                                                  o_err_msg           => l_group_err_msg);

              if l_group_err_code <> '0' then
                  c_response := c_response || '|' || 'Group creation Err :' || l_group_err_msg;
                  n_failed_final_mig_cnt := n_failed_final_mig_cnt + 1;

                  UPDATE x_gsm_acct_migration_stg
                  SET    migration_status = 'FAILED_FINAL_MIGRATION',
                         migration_response = c_response
                  WHERE  objid = data(i).objid;

                  CONTINUE; -- continue next iteration
              END IF;

              UPDATE sa.x_account_group_member
              SET SITE_PART_ID       = sp.site_part_objid
              WHERE ACCOUNT_GROUP_ID = l_account_group_id;

              -- load interactions
              IF l_site_part_status = 'Active' THEN
                --*******************************************
                --call trans creation (TABLE_X_CALL_TRANS).
                --*******************************************
                l_step := 'call trans creation (TABLE_X_CALL_TRANS).';
                ct := call_trans_type ( i_call_trans2site_part        => sp.site_part_objid,
                                        i_action_type                 => '1',
                                        i_call_trans2carrier          => n_carrier_objid, -- Objid of T-MOBILE SIMPLE
                                        i_call_trans2dealer           => data (i).dealer_inv_objid,
                                        i_call_trans2user             => n_user_objid, -- 'sa'
                                        i_line_status                 => NULL,
                                        i_min                         => data (i).MIN,
                                        i_esn                         => data (i).esn,
                                        i_sourcesystem                => l_sourcesystem,
                                        i_transact_date               => SYSDATE - 6 / 24, --insert with some lag so that missing task job doesnt pick the record
                                        i_total_units                 => 0,
                                        i_action_text                 => 'ACTIVATION',
                                        i_reason                      => 'Activation',
                                        i_result                      => 'Completed',
                                        i_sub_sourcesystem            => i_brand,
                                        i_iccid                       => data (i).sim,
                                        i_ota_req_type                => NULL,
                                        i_ota_type                    => NULL,
                                        i_call_trans2x_ota_code_hist  => NULL,
                                        i_new_due_date                => GREATEST(data(i).renewal_date,SYSDATE));

                -- check existence of call_trans in case of rerun
                BEGIN
                  SELECT  objid
                  INTO    ct.call_trans_objid
                  FROM    table_x_call_trans
                  WHERE   x_service_id     = data(i).esn
                  AND     x_min              = data(i).min
                  AND     x_iccid            = data(i).sim
                  AND     x_action_type      = '1'
                  AND     x_action_text      = 'ACTIVATION'
                  AND     x_sub_sourcesystem = i_brand;
                 EXCEPTION
                   WHEN OTHERS THEN
                     ct.call_trans_objid := NULL;
                END;

                --
                IF ct.call_trans_objid IS NULL THEN
                  ins_call_trans ( i_call_trans_type  => ct,
                                   o_response         => o_response);


                  IF ct.response NOT LIKE '%SUCCESS%' THEN
                    c_response := c_response || '|' || 'Call Trans Err :' || ct.response;
                    n_failed_final_mig_cnt := n_failed_final_mig_cnt + 1;

                    UPDATE x_gsm_acct_migration_stg
                    SET    migration_status = 'FAILED_FINAL_MIGRATION',
                           migration_response = c_response
                    WHERE  objid = data(i).objid;

                    CONTINUE; -- continue next iteration
                  END IF;

                END IF;

                n_call_trans_objid := ct.call_trans_objid;

                DBMS_OUTPUT.put_line ( TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss') || ' test 06 call trans insert: ' || o_response || ' - ' || ct.response);

                --*****************************************************
                -- queue cards for ESNs with future dated service plans
                --*****************************************************

                -- l_step := 'queue cards for ESN.';
                --
                /*  IF data(i).future_dated_service_plan IS NOT NULL THEN
                  BEGIN
                    SELECT plan_purchase_part_number
                    INTO   rc.pin_part_number
                    FROM   service_plan_feat_pivot_mv
                    WHERE  service_plan_objid = data(i).future_dated_service_plan;
                  EXCEPTION
                    WHEN OTHERS THEN
                      NULL;
                  END;

                  l_step := 'Get the Pin to put it into queue.';

                  BEGIN
                        SELECT  objid INTO
                        ct.call_trans_objid
                        FROM table_x_call_trans
                        WHERE x_service_id     = data(i).esn
                        AND x_min              = data(i).min
                        AND x_iccid            = data(i).sim
                        AND x_action_type      = '401'
                        AND x_action_text      = 'QUEUED'
                        AND x_sub_sourcesystem = i_brand;
                  EXCEPTION
                     WHEN OTHERS THEN
                       ct.call_trans_objid := NULL;
                  END;

                  IF rc.pin_part_number IS NOT NULL AND ct.call_trans_objid IS NULL THEN  --do not queue in case of rerun
                    -- generate a soft pin
                    l_return := getsoftpin ( ip_pin_part_num   => rc.pin_part_number,
                                             ip_inv_bin_objid  => data(i).dealer_inv_objid, -- we need to check this
                                             op_soft_pin       => rc.pin,
                                             op_smp_number     => rc.smp,
                                             op_err_msg        => c_err_msg);

                    DBMS_OUTPUT.put_line ('test 07d: ' || l_return);

                    IF l_return = 0 THEN
                      l_pintoesn := rc.qpintoesn ( i_esn       => data(i).esn,
                                                   i_pin       => rc.pin,
                                                   o_err_code  => c_err_code,
                                                   o_err_msg   => c_err_msg);
                      DBMS_OUTPUT.put_line ('test 07e: ' || l_pintoesn);

                      IF l_pintoesn = 0 THEN
                        l_step := 'Put the card in queue.';
                        ct := call_trans_type (); -- reinitialize for queue
                        ct := call_trans_type ( i_call_trans2site_part        => sp.site_part_objid,
                                                i_action_type                 => '401',
                                                i_call_trans2carrier          => n_carrier_objid, --Objid of T-MOBILE SIMPLE
                                                i_call_trans2dealer           => data(i).dealer_inv_objid,
                                                i_call_trans2user             => n_user_objid, --'sa'
                                                i_line_status                 => NULL,
                                                i_min                         => data(i).min,
                                                i_esn                         => data(i).esn,
                                                i_sourcesystem                => l_sourcesystem,
                                                i_transact_date               => (SYSDATE - 6 / 24) + 1 / 86400, --insert with some lag so that missing task job doesnt pick the record
                                                i_total_units                 => 0,
                                                i_action_text                 => 'QUEUED',
                                                i_reason                      => rc.pin,
                                                i_result                      => 'Completed',
                                                i_sub_sourcesystem            => i_brand,
                                                i_iccid                       => data(i).sim,
                                                i_ota_req_type                => NULL,
                                                i_ota_type                    => '402',
                                                i_call_trans2x_ota_code_hist  => NULL ,
                                                i_new_due_date                => NULL );




                           ins_call_trans ( i_call_trans_type  => ct,
                                            o_response         => o_response);

                           DBMS_OUTPUT.put_line ( TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss') || ' test 07a queue card insert: ' || o_response || ' - ' || ct.response);

                           IF ct.response NOT LIKE '%SUCCESS%' THEN
                             c_response := c_response || '|' || 'Queued Call Trans Err :' || ct.response;
                             n_failed_final_mig_cnt := n_failed_final_mig_cnt + 1;

                             UPDATE x_gsm_acct_migration_stg
                             SET    migration_status = 'FAILED_FINAL_MIGRATION',
                                    migration_response = c_response
                             WHERE  objid = data (i).objid;

                             CONTINUE; -- continue next iteration
                           END IF;



                        -- juda: if the card was queued successfully can you please log the call trans objid in the staging table

                      ELSE                                   --_pintoesn = 0
                        c_response := c_response || '|' || 'Pin to ESN Err :';
                        n_failed_final_mig_cnt := n_failed_final_mig_cnt + 1;

                        UPDATE x_gsm_acct_migration_stg
                        SET    migration_status = 'FAILED_FINAL_MIGRATION',
                               migration_response = l_step || c_response
                        WHERE  objid = data (i).objid;

                        CONTINUE;                  --continue next iteration
                      END IF;                                --_pintoesn = 0
                    ELSE                                      --l_return = 0
                      c_response := c_response || '|' || 'softpin generation Err :';
                      n_failed_final_mig_cnt := n_failed_final_mig_cnt + 1;

                      UPDATE x_gsm_acct_migration_stg
                      SET    migration_status = 'FAILED_FINAL_MIGRATION',
                             migration_response = l_step || c_response
                      WHERE  objid = data (i).objid;

                      CONTINUE; -- continue next iteration
                    END IF; -- l_return = 0
                  ELSE --  rc.pin_part_number IS NOT NULL
                    c_response := c_response || '|' || 'PIN part number not found Err :';
                    n_failed_final_mig_cnt := n_failed_final_mig_cnt + 1;

                    UPDATE x_gsm_acct_migration_stg
                    SET    migration_status = 'FAILED_FINAL_MIGRATION',
                           migration_response = l_step || c_response
                    WHERE  objid = data (i).objid;

                    CONTINUE; -- continue next iteration
                  END IF; --  rc.pin_part_number IS NOT NULL
                END IF; -- data(i).future_dated_plan IS NOT NULL

                DBMS_OUTPUT.put_line ( TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss') || ' test 07b queue card insert: ' || o_response || ' - ' || ct.response);
                */
                --*******************************************
                -- Create PI Hist record (TABLE_X_PI_HIST).
                --*******************************************
                -- For PHONE entry.

                --
                l_step := 'Create PI Hist record (TABLE_X_PI_HIST) - For PHONE entry.';

                -- insert esn pi hist
                ph := pi_hist_type();
                -- wrap code to avoid errors and continue process
                BEGIN
                pi_phone := part_inst_type ( i_esn => data(i).esn );

                ph.pi_hist_objid := NULL;
                ph.status_hist2code_table := pi_phone.status2x_code_table; --Active
                ph.change_date := SYSDATE;
                ph.change_reason := 'ACTIVATE';
                ph.creation_date := pi_phone.creation_date;
                ph.domain := pi_phone.domain;
                ph.insert_date := pi_phone.insert_date;
                ph.part_inst_status := pi_phone.part_inst_status;
                ph.part_serial_no := pi_phone.part_serial_no;
                ph.part_status := 'Active';
                ph.pi_hist2carrier_mkt := pi_phone.part_inst2carrier_mkt;
                ph.pi_hist2inv_bin := pi_phone.part_inst2inv_bin;
                ph.pi_hist2part_mod := pi_phone.n_part_inst2part_mod;
                ph.pi_hist2user := n_user_objid;                      --'sa'
                ph.warr_end_date := pi_phone.warr_end_date;
                ph.last_trans_time := SYSDATE;
                ph.order_number := pi_phone.order_number;
                ph.pi_hist2site_part := sp.site_part_objid;
                ph.msid := pi_phone.msid;
                ph.pi_hist2contact := rec_wu_contact_objid.contact_objid;
                ph.iccid := pi_phone.iccid;

                -- insert part inst history of the esn (phone)
                ins_pi_hist ( i_pi_hist_type => ph,
                              o_response     => o_response );

                IF ph.response NOT LIKE '%SUCCESS%' THEN
                  c_response := c_response || '|' || 'Create PI Hist (ESN) Err :' || ph.response;
                  n_failed_final_mig_cnt := n_failed_final_mig_cnt + 1;

                  UPDATE x_gsm_acct_migration_stg
                  SET    migration_status = 'FAILED_FINAL_MIGRATION',
                         migration_response = c_response
                  WHERE  objid = data (i).objid;

                  CONTINUE; -- continue next iteration
                END IF;
                 EXCEPTION
                   WHEN others THEN
                     NULL;
                END;
                DBMS_OUTPUT.put_line ( TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss') || ' test 08 PI History PHONE insert : ' || o_response);

                -- For LINE entry calling constructor to retrive updated data.
                l_step := 'Create PI Hist record (TABLE_X_PI_HIST) - For LINE entry.';
                -- insert line pi hist
                ph := pi_hist_type();
                BEGIN
                pi_line := part_inst_type (i_esn => data(i).MIN);

                ph.pi_hist_objid := NULL;
                ph.status_hist2code_table := pi_line.status2x_code_table; --Active
                ph.change_date := SYSDATE;
                ph.change_reason := 'ACTIVATE';
                ph.creation_date := pi_line.creation_date;
                ph.domain := pi_line.domain;
                ph.insert_date := pi_line.insert_date;
                ph.part_inst_status := pi_line.part_inst_status;
                ph.part_serial_no := pi_line.part_serial_no;
                ph.part_status := 'Active';
                ph.pi_hist2carrier_mkt := pi_line.part_inst2carrier_mkt;
                ph.pi_hist2inv_bin := pi_line.part_inst2inv_bin;
                ph.pi_hist2part_mod := pi_line.n_part_inst2part_mod;
                ph.pi_hist2user := n_user_objid; --'sa'
                ph.warr_end_date := pi_line.warr_end_date;
                ph.last_trans_time := SYSDATE;
                ph.order_number := pi_line.order_number;
                ph.pi_hist2site_part := sp.site_part_objid;
                ph.msid := pi_line.msid;
                ph.pi_hist2contact := rec_wu_contact_objid.contact_objid;
                ph.iccid := pi_line.iccid;

                -- insert part inst history of the line (min)
                ins_pi_hist ( i_pi_hist_type => ph,
                              o_response     => o_response);

                --
                IF ph.response NOT LIKE '%SUCCESS%' THEN
                  c_response :=  c_response || '|' || 'Create PI Hist (MIN) Err :' || ph.response;
                  n_failed_final_mig_cnt := n_failed_final_mig_cnt + 1;

                  UPDATE x_gsm_acct_migration_stg
                  SET    migration_status = 'FAILED_FINAL_MIGRATION',
                         migration_response = c_response
                  WHERE  objid = data (i).objid;

                  CONTINUE; --continue next iteration
                END IF;

                 EXCEPTION
                   WHEN others THEN
                     NULL;
                END;
                DBMS_OUTPUT.put_line ( TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss') || ' test 09 PI History LINE insert : ' || o_response);


                --********************
                -- Create Subscriber_SPR
                --********************
                l_step := 'Create Subscriber_SPR.';
                sub := subscriber_type ();

                sub.pcrf_esn := data(i).esn;

                -- insert subscriber spr
                ins_subscriber_spr ( i_subscriber_type  => sub,
                                     o_response         => o_response);

                IF sub.status NOT LIKE '%SUCCESS%' THEN
                  c_response := c_response || 'SPR Err: |' || sub.status;
                END IF;

                DBMS_OUTPUT.put_line ( TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss') || ' test 10 SPR call response : ' || o_response || ' - status: ' || sub.status);

                --*************************
                -- Create PCRF_Subscriber
                --*************************
                l_step := 'Create PCRF_Subscriber.';
                pcrf := pcrf_transaction_type ( i_esn               => sub.pcrf_esn,
                                                i_min               => sub.pcrf_min,
                                                i_order_type        => 'UP',
                                                i_zipcode           => sub.zipcode,
                                                i_sourcesystem      => l_sourcesystem,
                                                i_pcrf_status_code  => 'Q');

                --
                ins_pcrf_transaction ( i_pcrf_transaction_type  => pcrf,
                                       o_response               => o_response);

                -- juda: i would like to log the response in a column (on staging table) from the pcrf transaction creation
                --
                IF pcrf.status NOT LIKE '%SUCCESS%' THEN
                  l_pcrf_response := ' PCRF transaction WARNING :' || pcrf.status;
                END IF;

                DBMS_OUTPUT.put_line ( TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss') || ' test 11 PCRF call response : ' || o_response || ' - status: ' || pcrf.status);
              END IF; -- customer_status = 'Active'

              --
              l_step := 'Calling throttling procedure';

              -- CALL THROTTLE PROCEDURE BASED ON THROTTLE FLAG AND MEMO DATE
              IF data(i).throttle_flag = 'Y' THEN
                -- THROTTLE ONLY IF MEMO DATE AND RENEWAL DATES ARE PRESENT AND RENEWAL DATE IS TODAY OR FUTURE
                IF data(i).memo_date IS NOT NULL AND data(i).renewal_date IS NOT NULL AND data(i).renewal_date >= TRUNC(SYSDATE) THEN
                  -- AND MEMO WAS SENT WITHIN 30 DAYS FROM RENEWAL DATE
                  IF data(i).renewal_date - data(i).memo_date < 30 THEN
                    -- IF SITE PART STATUS IS NOT ACTIVE, THROTTLING WILL NOT WORK
                    -- IN THAT CASE, JUST LOG THE ERROR AND SKIP_UNUSABLE_INDEXESMALLINT
                    IF l_site_part_status = 'Active' THEN
                      -- GET COS VALUE
                      c_cos := sa.get_cos(i_esn => data(i).esn);
                      -- PROCEED ONLY IF COS IS RETURNED
                      IF c_cos IS NOT NULL THEN
                        -- CALL THROTTLING PROCEDURE
                        sa.service_profile_pkg.throttle_subscriber ( i_source         => 'TMO'              ,
                                                                     i_min            => data(i).min        ,
                                                                     i_parent_name    => 'TMO'              ,
                                                                     i_usage_tier_id  => 2                  ,
                                                                     i_cos            => c_cos              ,
                                                                     i_policy_name    => i_policy_name      ,
                                                                     o_err_code       => l_throttle_err_code,
                                                                     o_err_msg        => l_throttle_err_msg  );

                        IF l_throttle_err_msg NOT LIKE '%SUCCESS%' THEN
                             l_throttle_response := ' Throttling WARNING : '||l_throttle_err_msg;
                        END IF; -- IF l_throttle_err_msg IS NOT LIKE '%SUCCESS%'
                      END IF; -- IF c_cos IS NOT NULL
                    ELSE
                      l_throttle_response := ' Throttling WARNING : Can NOT throttle non active accounts';
                    END IF; --IF l_site_part_status = 'Active'
                  ELSE
                    l_throttle_response := ' Throttling WARNING : Memo sent more than 30 days prior to renewal date';
                  END IF; --IF data(i).renewal_date - data(i).memo_date < 30
                ELSE
                  l_throttle_response := ' Throttling WARNING : Memo or renewal date is null/invalid';
                END IF; --IF data(i).memo_date IS NOT NULL AND data(i).renewal_date IS NOT NULL AND data(i).renewal_date
              END IF; --IF data(i).throttle_flag = 'Y'

	     /* --Create cash balance transaction
	      IF data(i).additional_service_days  IS NOT NULL AND data(i).additional_data IS NOT NULL  THEN
	        IF l_site_part_status ='Active' THEN

		    create_cash_balance_trans(  i_esn                          => data(i).esn ,
                                                i_min                          => NULL,
                                               --i_action_type                 => NULL,
                                               --i_action_text                 => NULL,
                                                i_source_system                => 'BATCH',
                                               --i_order_type                  => NULL,
                                               --i_ig_order_type               => NULL,
                                               --i_intl_bucket_id              => NULL,
                                                i_intl_bucket_value            => NULL, --TBD
                                                i_intl_bucket_expiration_date  => NULL,
                                                --i_data_bucket_id              => NULL,
                                                i_data_bucket_value            => data(i).additional_data,
                                                i_data_bucket_expiration_date  => data(i).renewal_date,
                                                o_err_num                      => l_cash_bal_err_code,
                                                o_err_msg                      => l_cash_bal_err_msg );



                END IF;
	      END IF;	*/



              l_step := 'Update staging table with success.';

              UPDATE x_gsm_acct_migration_stg
              SET    migration_status = CASE
                                          WHEN c_response IS NULL THEN 'COMPLETE_FINAL_MIGRATION'
                                          ELSE 'FAILED_FINAL_MIGRATION'
                                        END,
                     migration_response = CASE
                                            WHEN c_response IS NULL THEN 'SUCCESS'||l_pcrf_response||l_throttle_response
                                            ELSE c_response
                                          END,
                     call_trans_objid = n_call_trans_objid
              WHERE  objid = data (i).objid;

              DBMS_OUTPUT.put_line ( TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss') || ' test 12 staging table update : ');

              n_success_final_mig_cnt := n_success_final_mig_cnt + 1;
            EXCEPTION
              WHEN OTHERS THEN
                DBMS_OUTPUT.put_line ( TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss') || ' test 13 exception : ' || SQLERRM);
                l_step := l_step || ' - ' || SQLERRM;

                UPDATE x_gsm_acct_migration_stg
                SET    migration_status = 'FAILED_FINAL_MIGRATION',
                       migration_response = l_step
                WHERE  objid = data (i).objid;

                n_failed_final_mig_cnt := n_failed_final_mig_cnt + 1;
            END;
          ELSE
            l_step := 'Update staging table with Fail.';

            UPDATE x_gsm_acct_migration_stg
            SET    migration_status = 'FAILED_FINAL_MIG_DATA_UPDATE',
                   migration_response = o_response
            WHERE  objid = data (i).objid;

            n_failed_data_update_cnt := n_failed_data_update_cnt + 1;
          END IF; -- LOAD_GOSMART_PREMIGRATION Response

          n_count_rows := n_count_rows + 1;

          IF (MOD (n_count_rows, i_commit_every_rows) = 0) THEN
            -- Save changes
            COMMIT;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            l_step := l_step || ' - ' || SQLERRM;

            UPDATE x_gsm_acct_migration_stg
            SET    migration_status = 'FAILED_FINAL_MIGRATION',
                   migration_response = l_step
            WHERE  objid = data (i).objid;

            n_failed_final_mig_cnt := n_failed_final_mig_cnt + 1;
        END;
      END LOOP; -- c_data

      --
      EXIT WHEN c_get_data%NOTFOUND;
    --
    END LOOP;

    CLOSE c_get_data;

    -- exit when there are no more records to archive
    EXIT WHEN NOT (f_more_rows_exist);

  END LOOP; -- WHILE (f_more_rows_exist)

  -- Save changes
  COMMIT;

  DBMS_OUTPUT.put_line ('*********************Final Migration Results*********************');
  DBMS_OUTPUT.put_line ('Total records successfully processed: ' || n_success_final_mig_cnt);
  DBMS_OUTPUT.put_line ('Total reocrds failed in final migration: ' || n_failed_final_mig_cnt);
  DBMS_OUTPUT.put_line ('Total records failed in pre migration: ' || n_failed_data_update_cnt);

 EXCEPTION
   WHEN OTHERS THEN
     DBMS_OUTPUT.put_line ('Exception : ' || l_step || ' - ' || SQLERRM);
END load_gosmart_final_migration;

PROCEDURE create_cash_balance_trans ( i_esn                         IN  VARCHAR2, --
                                      i_min                         IN  VARCHAR2, -- ATLEAST ONE OF THESE (ESN/MIN) SHOULD ALWAYS BE PASSED
                                      i_action_type                 IN  VARCHAR2 DEFAULT '401', -- CALL_TRANS ACTION TYPE  FOR THIS TRANSACTION
                                      i_action_text                 IN  VARCHAR2 DEFAULT 'QUEUED', --CALL_TRANS  ACTION TEXT
                                      i_source_system               IN  VARCHAR2, -- SOURCE SYSTEM  FOR THIS TRANSACTION, MANDATORY PARAMETER,
                                      i_extend_service_days         IN  VARCHAR2 DEFAULT 'N',
                                      i_order_type                  IN  VARCHAR2 DEFAULT 'Cash Balance',-- ORDER TYPEFORTHIS TRANSACTION, MANDATORY PARAMETER
                                      i_ig_order_type               IN  VARCHAR2 DEFAULT 'DBT', -- IG ORDER TYPE FOR THIS TRANSACTION, MANDATORY PARAMETER
                                      i_intl_bucket_id              IN  VARCHAR2 DEFAULT 'WALLETPB',
                                      i_intl_bucket_value           IN  VARCHAR2, -- INTL BUCKET VALUE
                                      i_intl_bucket_expiration_date IN  DATE,     -- MANDATORY IF ILD_BUCKET VLAUE IS PASSED
                                      i_data_bucket_id              IN  VARCHAR2 DEFAULT 'WADADJTH4',
                                      i_data_bucket_value           IN  VARCHAR2, -- DATA BUCKET VALUE. ONE OF ILD OR DATA BUCKET MUST BE PASSED
                                      i_data_bucket_expiration_date IN  DATE,     -- MANDATORY IF DATA_BUCKET VLAUE IS PASSED
                                      o_err_num                     OUT NUMBER,   -- ERROR NUMBER. WILL BE SENT AS "0" FOR SUCCESS
                                      o_err_msg                     OUT VARCHAR2, -- ERROR MESSGAE. WILL BE SENT AS "SUCCESS" FOR SUCCESSFUL PROCESSING
                                      i_update_expiration_date_flag IN VARCHAR2 DEFAULT 'Y'
                                     )
IS

  n_user_objid  NUMBER;
    -- customer type
  cst  sa.customer_type := customer_type();

  -- call trans type
  ct  sa.call_trans_type := call_trans_type ();

  -- task type
  tt  sa.task_type := task_type ();

  --
  ig sa.ig_transaction_type := ig_transaction_type();

  rc  sa.red_card_type := red_card_type ();

  n_already_queued     NUMBER;
  n_queued_cards_count NUMBER;
  c_queue_card_pn      VARCHAR2(500);
  n_soft_pin_return    NUMBER;
  n_pin_to_esn_return  NUMBER;
  c_err_msg            VARCHAR2(4000);
  c_err_code           VARCHAR2(4000);
  c_queue_card_rowid   ROWID;
  c_queue_card_err     VARCHAR2(4000);
  c_rowid              ROWID;
  c_pin                VARCHAR2(50);

BEGIN

    -- Get the user objid
    BEGIN
      SELECT objid
      INTO   n_user_objid
      FROM   table_user
      WHERE  s_login_name = (SELECT UPPER(USER) FROM DUAL);
     EXCEPTION
       WHEN OTHERS THEN
  	   -- default to SA objid
         n_user_objid := 268435556;
    END;

  IF i_esn IS NULL AND i_min IS NULL THEN
    o_err_num := -90;
    o_err_msg := 'ESN AND MIN ARE NOT PASSED';
    RETURN;
  END IF;

  IF i_esn IS NOT NULL  THEN
    cst  := cst.retrieve ( i_esn => i_esn );
  END IF;

  IF i_esn IS NULL AND i_min IS NOT NULL THEN
    cst  := cst.retrieve_min ( i_min => i_min );
  END IF;

  dbms_output.put_line('cst  response ;'||cst.response);

  BEGIN
  -- CHECK IN GSM_MIG_BUCKET TABLE IF THE MIN EXISTS
  -- IF NOT, DISCARD TRANSACTION

    SELECT cards,
           new_card_pn,
           rowid,
           pin
    INTO   n_queued_cards_count,
           c_queue_card_pn,
           c_rowid,
           c_pin
    FROM   x_gsm_mig_buckets
    WHERE  min = cst.min
    AND    transaction_status is null;
    -- HERE PUT THE CONDITION TO CHECK IN THE CHILD TABLE
    -- IF EACH OF THE TRANSACTION HAS SUCCESSFULLY COMPLETED


  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('cst  MIN ;'||cst.min);

     o_err_num := -91;
     o_err_msg := 'NOTHING TO QUEUE/MIN NOT FOUND';

     RETURN;
    WHEN OTHERS THEN
     o_err_num := -92;
     o_err_msg := 'ERROR getting queue card info '||sqlerrm;
     RETURN;
  END;

  -- Create call trans for IG
  -- This will be for the redemption of card
  ct := call_trans_type();

  ct := call_trans_type ( i_call_trans2site_part       => cst.site_part_objid,
                         i_action_type                 => '6',
                         i_call_trans2carrier          => cst.carrier_objid, -- Objid of T-MOBILE SIMPLE
                         i_call_trans2dealer           => cst.inv_bin_objid,
                         i_call_trans2user             => n_user_objid, -- 'sa'
                         i_line_status                 => NULL,
                         i_min                         => cst.min,
                         i_esn                         => cst.esn,
                         i_sourcesystem                => i_source_system, --need to pass as input
                         i_transact_date               => SYSDATE ,
                         i_total_units                 => 0,
                         i_action_text                 => 'Cash Balance',
                         i_reason                      => INITCAP(i_action_text),
                         i_result                      => 'Completed',
                         i_sub_sourcesystem            => cst.bus_org_id,
                         i_iccid                       => cst.iccid,
                         i_ota_req_type                => NULL,
                         i_ota_type                    => NULL,
                         i_call_trans2x_ota_code_hist  => NULL,
                         i_new_due_date                => nvl(i_intl_bucket_expiration_date,i_data_bucket_expiration_date) ); --need to update

  ct := ct.save;

   IF ct.response NOT LIKE '%SUCCESS%' THEN
    o_err_num := -100;
    o_err_msg := 'Error creating call trans for IG :'||ct.response;
    RETURN;
  END IF;

  dbms_output.put_line('call trans  response ;'||ct.response);

   -- set the values for the task to be created
  tt := task_type ( i_call_trans_objid  => ct.call_trans_objid ,
                    i_contact_objid     => cst.contact_objid ,
                    i_order_type        => i_order_type , -- New order type TBD
                    i_bypass_order_type => 0 ,
                    i_case_code         => 0 );

   -- call the insert method to create a new task
  tt := tt.ins;

  dbms_output.put_line('task response ;'||tt.response);

  IF tt.response NOT LIKE '%SUCCESS%' THEN
    o_err_num := -100;
    o_err_msg := 'Error creating Task for IG :'||tt.response;
    RETURN;
  END IF;

  -- Update site part and part inst expire_dt
  IF NVL(i_update_expiration_date_flag,'Y') = 'Y' THEN
    UPDATE table_site_part
    SET    x_expire_dt = NVL(i_intl_bucket_expiration_date,i_data_bucket_expiration_date),
           warranty_date = NVL(i_intl_bucket_expiration_date,i_data_bucket_expiration_date)
    WHERE  objid = cst.site_part_objid;
    dbms_output.put_line('site part expiry date update :'||sql%rowcount);
    UPDATE table_part_inst
    SET    warr_end_date  = NVL(i_intl_bucket_expiration_date,i_data_bucket_expiration_date)
    WHERE  objid = cst.esn_part_inst_objid ;
    dbms_output.put_line('part inst expiry date update :'||sql%rowcount);
  END IF;


  dbms_output.put_line('carrier objid  ;'||cst.carrier_objid);
     -- Get the template value
  ig := ig_transaction_type();
   IF cst.carrier_objid IS NOT NULL THEN
   BEGIN
      SELECT x_carrier_id
      INTO   ig.carrier_id
      FROM   table_x_carrier
      WHERE objid = cst.carrier_objid;
     EXCEPTION
       WHEN OTHERS THEN
         NULL;
	  dbms_output.put_line('sql'||sqlcode);
    END;
  END IF;

  dbms_output.put_line('carrier id  ;'||ig.carrier_id);

  ig.template := ig.get_template ( i_technology          => tt.technology,
                                   i_trans_profile_objid => tt.trans_profile_objid );
  dbms_output.put_line('IG Template :'||ig.template );

    ig.esn                 := cst.esn;
    ig.status_message      := NULL;
    ig.creation_date       := SYSDATE;
    ig.update_date         := SYSDATE;
    ig.blackout_wait       := SYSDATE;
    ig.min                 := cst.min;
    ig.msid                := cst.min;
    ig.new_msid_flag       := NULL;
    ig.action_item_id      := tt.task_id;
    ig.order_type          := i_ig_order_type;
    ig.network_login       := CASE WHEN ig.template IN ('TMOBILE','TMOSM','TMOUN') THEN 'tracfone' ELSE NULL END;
    ig.network_password    := CASE WHEN ig.template IN ('TMOBILE','TMOSM','TMOUN') THEN 'Tr@cfon3' ELSE NULL END;
    ig.status              := 'Q';
    ig.transaction_id      := gw1.trans_id_seq.NEXTVAL + ( POWER(2,28));
    ig.technology_flag     := substr(cst.technology,1,1);
    ig.phone_manf          := cst.phone_manufacturer;
    ig.rate_plan           := cst.rate_plan;
    ig.zip_code            := cst.zipcode;
    ig.iccid               := cst.iccid;
    ig.application_system  := 'IG';
    ig.transmission_method := 'AOL';

    ig := ig_transaction_type (i_action_item_id          => ig.action_item_id        ,
                               i_carrier_id              => ig.carrier_id            ,
                               i_order_type              => ig.order_type            ,
                               i_min                     => ig.min                   ,
                               i_esn                     => ig.esn                   ,
                               i_esn_hex                 => ig.esn_hex               ,
                               i_old_esn                 => ig.old_esn               ,
                               i_old_esn_hex             => ig.old_esn_hex           ,
                               i_pin                     => ig.pin                   ,
                               i_phone_manf              => ig.phone_manf            ,
                               i_end_user                => ig.end_user              ,
                               i_account_num             => ig.account_num           ,
                               i_market_code             => ig.market_code           ,
                               i_rate_plan               => ig.rate_plan             ,
                               i_ld_provider             => ig.ld_provider           ,
                               i_sequence_num            => ig.sequence_num          ,
                               i_dealer_code             => ig.dealer_code           ,
                               i_transmission_method     => ig.transmission_method   ,
                               i_fax_num                 => ig.fax_num               ,
                               i_online_num              => ig.online_num            ,
                               i_email                   => ig.email                 ,
                               i_network_login           => ig.network_login         ,
                               i_network_password        => ig.network_password      ,
                               i_system_login            => ig.system_login          ,
                               i_system_password         => ig.system_password       ,
                               i_template                => ig.template              ,
                               i_exe_name                => ig.exe_name              ,
                               i_com_port                => ig.com_port              ,
                               i_status                  => ig.status                ,
                               i_status_message          => ig.status_message        ,
                               i_fax_batch_size          => ig.fax_batch_size        ,
                               i_fax_batch_q_time        => ig.fax_batch_q_time      ,
                               i_expidite                => ig.expidite              ,
                               i_trans_prof_key          => ig.trans_prof_key        ,
                               i_q_transaction           => ig.q_transaction         ,
                               i_online_num2             => ig.online_num2           ,
                               i_fax_num2                => ig.fax_num2              ,
                               i_creation_date           => ig.creation_date         ,
                               i_update_date             => ig.update_date           ,
                               i_blackout_wait           => ig.blackout_wait         ,
                               i_tux_iti_server          => ig.tux_iti_server        ,
                               i_transaction_id          => ig.transaction_id        ,
                               i_technology_flag         => ig.technology_flag       ,
                               i_voice_mail              => ig.voice_mail            ,
                               i_voice_mail_package      => ig.voice_mail_package    ,
                               i_caller_id               => ig.caller_id             ,
                               i_caller_id_package       => ig.caller_id_package     ,
                               i_call_waiting            => ig.call_waiting          ,
                               i_call_waiting_package    => ig.call_waiting_package  ,
                               i_rtp_server              => ig.rtp_server            ,
                               i_digital_feature_code    => ig.digital_feature_code  ,
                               i_state_field             => ig.state_field           ,
                               i_zip_code                => ig.zip_code              ,
                               i_msid                    => ig.msid                  ,
                               i_new_msid_flag           => ig.new_msid_flag         ,
                               i_sms                     => ig.sms                   ,
                               i_sms_package             => ig.sms_package           ,
                               i_iccid                   => ig.iccid                 ,
                               i_old_min                 => ig.old_min               ,
                               i_digital_feature         => ig.digital_feature       ,
                               i_ota_type                => ig.ota_type              ,
                               i_rate_center_no          => ig.rate_center_no        ,
                               i_application_system      => ig.application_system    ,
                               i_subscriber_update       => ig.subscriber_update     ,
                               i_download_date           => ig.download_date         ,
                               i_prl_number              => ig.prl_number            ,
                               i_amount                  => ig.amount                ,
                               i_balance                 => ig.balance               ,
                               i_language                => ig.language              ,
                               i_exp_date                => ig.exp_date              ,
                               i_x_mpn                   => ig.x_mpn                 ,
                               i_x_mpn_code              => ig.x_mpn_code            ,
                               i_x_pool_name             => ig.x_pool_name           ,
                               i_imsi                    => ig.imsi                  ,
                               i_new_imsi_flag           => ig.new_imsi_flag         );

  -- call the insert method
  ig  := ig.ins;

  dbms_output.put_line('Ig Transaction created '||ig.transaction_id);

  IF tt.response NOT LIKE '%SUCCESS%' THEN
    o_err_num := -100;
    o_err_msg := 'Error creating IG :' ||ig.response;
    RETURN;
  END IF;

  -- DO NOT CREATE WALLETPB IF PIN IS NOT NULL
  IF c_pin IS NULL THEN
    igate.insert_ig_transaction_buckets ( i_ig_transaction_id    => ig.transaction_id    ,
                                          i_bucket_id              => i_intl_bucket_id     ,
                                          i_bucket_value           => NVL(i_intl_bucket_value,0)  ,
                                          i_bucket_balance         => NULL,
                                          i_bucket_expiration_date => i_intl_bucket_expiration_date,
                                          i_benefit_type           => NULL );
  END IF;

  IF i_data_bucket_value > 0 THEN
    igate.insert_ig_transaction_buckets ( i_ig_transaction_id      => ig.transaction_id    ,
                                          i_bucket_id              => i_data_bucket_id     ,
                                          i_bucket_value           => i_data_bucket_value  ,
                                          i_bucket_balance         => NULL,
                                          i_bucket_expiration_date => i_data_bucket_expiration_date,
                                          i_benefit_type           => 'SWEEP_ADD' );
  END IF;

  dbms_output.put_line('Created Buckets');

  c_queue_card_err := 'SUCCESS';


  -- GET THE COUNT OF already queued cards
  BEGIN
    SELECT COUNT(*)
    INTO   n_already_queued
    FROM   x_gsm_mig_queued_cards
    WHERE  min = cst.min
    AND    esn = cst.esn
    AND    status = 'SUCCESS';
  EXCEPTION
    WHEN OTHERS THEN
     o_err_num := -93;
     o_err_msg := 'ERROR checking already queued card info '||sqlerrm;
     RETURN;
  END;

  -- IF NUMBER OF CARDS TO BE QUEUED IS 0, THEN NOTHING ELSE REQUIRED
  IF NVL(n_queued_cards_count,0) = 0 THEN
    o_err_num := 0;
    o_err_msg := 'SUCCESS';
    UPDATE x_gsm_mig_buckets
    SET    transaction_status = 'SUCCESS'
    WHERE  rowid = c_rowid;
    RETURN;
  END IF;

  -- IF ALL CARDS ALREADY QUEUED, THEN LEAVE
  IF n_already_queued >= n_queued_cards_count AND n_queued_cards_count != 0 THEN
    o_err_num := -94;
    o_err_msg := 'ALL CARDS ALREADY QUEUED';
    RETURN;
  END IF;

   --Check if the part number of new card is populated
  -- if not leave
  IF c_queue_card_pn IS NULL AND
     NVL(n_queued_cards_count,0) > 0
  THEN
     o_err_num := -95;
     o_err_msg := 'Missing queue card part number';
     RETURN;
  END IF;



  -- LOOP THROUGH FOR ALL REMAINING CARDS
  FOR i IN 1..n_queued_cards_count - n_already_queued
  LOOP
  dbms_output.put_line('Inside LOOP : ['||i||']');
    n_soft_pin_return   := NULL;
    n_pin_to_esn_return := NULL;
    c_err_msg           := NULL;
    c_err_code          := NULL;
    c_queue_card_rowid  := NULL;
    ct                  := call_trans_type (); -- reinitialize for queue
    rc                  := red_card_type();
    rc.pin_part_number  := c_queue_card_pn;

    --INSERT A RECORD INTO x_gsm_mig_queued_cards WITH DUMMY VALUES TO LOG THAT THE PROCESS WAS STARTED

    INSERT INTO x_gsm_mig_queued_cards
      (
        esn,
        min,
        smp,
        call_trans_objid,
        status,
        status_message,
        insert_timestamp
       )
       VALUES
       (
         cst.esn,
         cst.min,
         NULL,
         NULL,
         NULL,
         NULL,
         SYSDATE
        )
        RETURNING ROWID INTO c_queue_card_rowid;

    -- generate a soft pin
    n_soft_pin_return := sa.getsoftpin ( ip_pin_part_num   => rc.pin_part_number,
                                         ip_inv_bin_objid  => cst.inv_bin_objid, -- ??
                                         op_soft_pin       => rc.pin,
                                         op_smp_number     => rc.smp,
                                         op_err_msg        => c_err_msg);

    IF (n_soft_pin_return != 0 OR NVL(rc.pin,rc.smp) IS NULL) THEN
      UPDATE x_gsm_mig_queued_cards
      SET    smp              = rc.smp,
             status           = 'FAILURE',
             status_message   = 'ERROR GENERATING PIN '||c_err_msg,
             update_timestamp = SYSDATE
      WHERE  rowid = c_queue_card_rowid;

      UPDATE x_gsm_mig_buckets
      SET    transaction_status = 'FAILURE'
      WHERE  min = cst.min;

      c_queue_card_err := 'FAILURE';

      CONTINUE;
     END IF;

    n_pin_to_esn_return := rc.qpintoesn ( i_esn       => cst.esn,
                                          i_pin       => rc.pin,
                                          o_err_code  => c_err_code,
                                          o_err_msg   => c_err_msg);
    IF n_pin_to_esn_return != 0 THEN
      UPDATE x_gsm_mig_queued_cards
      SET    smp            = rc.smp,
             status         = 'FAILURE',
             status_message = 'ERROR ATTACHING PIN TO ESN'||c_err_msg,
             update_timestamp = SYSDATE
      WHERE  ROWID = c_queue_card_rowid;

      UPDATE x_gsm_mig_buckets
      SET    transaction_status = 'FAILURE'
      WHERE  min = cst.min;

      c_queue_card_err := 'FAILURE';

      CONTINUE;

    END IF;

    ct := call_trans_type ( i_call_trans2site_part        => cst.site_part_objid,
                            i_action_type                 => i_action_type,
                            i_call_trans2carrier          => cst.carrier_objid, --Objid of T-MOBILE SIMPLE
                            i_call_trans2dealer           => cst.inv_bin_objid,
                            i_call_trans2user             => n_user_objid, --'sa'
                            i_line_status                 => NULL,
                            i_min                         => cst.min,
                            i_esn                         => cst.esn,
                            i_sourcesystem                => i_source_system,
                            i_transact_date               => SYSDATE+(i/86400),
                            i_total_units                 => 0,
                            i_action_text                 => i_action_text,
                            i_reason                      => rc.pin,
                            i_result                      => 'Completed',
                            i_sub_sourcesystem            => cst.bus_org_id,
                            i_iccid                       => cst.iccid,
                            i_ota_req_type                => NULL,
                            i_ota_type                    => '402', ---???
                            i_call_trans2x_ota_code_hist  => NULL ,
                            i_new_due_date                => NVL(i_intl_bucket_expiration_date,i_data_bucket_expiration_date) --??
                            );
    --CALL INSERT METHOD
    ct := ct.save;

    UPDATE x_gsm_mig_queued_cards
    SET    call_trans_objid = ct.call_trans_objid,
           smp              = rc.smp,
           status           = CASE WHEN ct.response LIKE '%SUCCESS%'
                                THEN 'SUCCESS'
                                ELSE 'FAILURE'
                                END,
           status_message   = CASE WHEN ct.response LIKE '%SUCCESS%'
                                THEN 'CARD QUEUED SUCCESSFULLY'
                                ELSE 'ERROR CREATING CALL TRANS '||ct.response
                              END,
           update_timestamp = SYSDATE
    WHERE ROWID = c_queue_card_rowid;

    UPDATE x_gsm_mig_buckets
    SET    transaction_status = CASE WHEN ct.response LIKE '%SUCCESS%' AND c_queue_card_err LIKE '%SUCCESS%'
                                  THEN 'SUCCESS'
                                  ELSE 'FAILURE'
                                END
    WHERE  min = cst.min;
  END LOOP;

  o_err_num := 0;
  o_err_msg := 'SUCCESS';

EXCEPTION
   WHEN OTHERS THEN
   o_err_num := sqlcode;
   o_err_msg := substr(sqlerrm,1,500);
END create_cash_balance_trans;

PROCEDURE process_cash_balance (i_action_type                   IN  VARCHAR2 DEFAULT '6',
                                i_action_text                   IN  VARCHAR2 DEFAULT 'REDEMPTION',
                                i_source_system                 IN  VARCHAR2 DEFAULT 'BATCH',
                                i_extend_service_days           IN  VARCHAR2 DEFAULT  'N',
                                i_order_type                    IN  VARCHAR2 DEFAULT 'Cash Balance',
                                i_ig_order_type                 IN  VARCHAR2 DEFAULT 'DBT',
                                i_intl_bucket_id                IN  VARCHAR2 DEFAULT 'WALLETPB',
                                i_data_bucket_id                IN  VARCHAR2 DEFAULT 'WADADJTH4',
                                o_response                      OUT VARCHAR2,
                                i_dataset_limit                 IN NUMBER DEFAULT 1000)
IS
CURSOR stg IS
  SELECT stg.*, bu.additional_data bu_additional_data
    FROM x_gsm_acct_migration_stg stg, x_gsm_mig_buckets bu
   WHERE stg.migration_status = 'COMPLETE_FINAL_MIGRATION'
     AND stg.migration_response NOT LIKE '%Cash Card Success%'
     AND stg.migration_response NOT LIKE '%Cash Card Err%'
     AND stg.MIN = bu.MIN
     AND NVL(bu.transaction_status,'FAILURE') != 'SUCCESS'
     AND (NVL (bu.service_days, 0) > 0 OR NVL (bu.additional_data, 0) > 0)
     AND UPPER(bu.new_plan) = 'OK'
     AND ROWNUM <= NVL(i_dataset_limit,1000);

l_cash_bal_err_code NUMBER ;
l_cash_bal_err_msg  VARCHAR2(1000);
c_response VARCHAR2(1000);
n_interact_objid  NUMBER;


BEGIN

  FOR stg_rec IN stg
  LOOP
    l_cash_bal_err_code := NULL;
    l_cash_bal_err_msg  := NULL;
    c_response          := NULL;

    BEGIN
      create_cash_balance_trans( i_esn                         => stg_rec.esn ,
                                 i_min                         => NULL,
                                 i_action_type                 => i_action_type,
                                 i_action_text                 => i_action_text,
                                 i_source_system               => i_source_system,
                                 i_extend_service_days         => i_extend_service_days,
                                 i_order_type                  => i_order_type,
                                 i_ig_order_type               => i_ig_order_type,
                                 i_intl_bucket_id              => i_intl_bucket_id,
                                 i_intl_bucket_value           => 0,
                                 i_intl_bucket_expiration_date => stg_rec.renewal_date,
                                 i_data_bucket_id              => i_data_bucket_id,
                                 i_data_bucket_value           => stg_rec.additional_data,
                                 i_data_bucket_expiration_date => stg_rec.renewal_date,
                                 o_err_num                     => l_cash_bal_err_code,
                                 o_err_msg                     => l_cash_bal_err_msg,
                                 i_update_expiration_date_flag => 'N' );

      IF l_cash_bal_err_msg <> 'SUCCESS' THEN
         UPDATE x_gsm_acct_migration_stg
         SET migration_response =  migration_response||'|'||' Cash Card Err :'||l_cash_bal_err_msg
         WHERE objid = stg_rec.objid ;

      ELSE
         UPDATE x_gsm_acct_migration_stg
         SET migration_response =  migration_response||'|'|| 'Cash Card Success'
         WHERE objid = stg_rec.objid ;

         IF stg_rec.additional_service_days IS NOT NULL  THEN

           n_interact_objid := NULL;

           ins_interaction ( i_contact_objid  => stg_rec.contact_objid,
                             i_reason_1       => 'Service days extended',
                             i_reason_2       => 'Service days extended',
                             i_notes          => 'Service days extended by '||stg_rec.additional_service_days||' days from '||stg_rec.wallet_balance||' cash balance ',
                             i_rslt           => 'Successful',
                             i_user           => 'SA',
                             i_esn            => stg_rec.esn,
                             i_create_date    => SYSDATE,
                             i_start_date     => SYSDATE,
                             i_end_date       => SYSDATE,
                             o_interact_objid => n_interact_objid,
                             o_response       => c_response);
         END IF;

         IF stg_rec.additional_data IS NOT NULL THEN

           n_interact_objid := NULL;

           ins_interaction ( i_contact_objid  => stg_rec.contact_objid,
                             i_reason_1       => 'Additonal data given',
                             i_reason_2       => 'Additonal data given',
                             i_notes          => 'Additonal data '||stg_rec.additional_data||' MB given from '||stg_rec.wallet_balance||'  cash balance ',
                             i_rslt           => 'Successful',
                             i_user           => 'SA',
                             i_esn            => stg_rec.esn,
                             i_create_date    => SYSDATE,
                             i_start_date     => SYSDATE,
                             i_end_date       => SYSDATE,
                             o_interact_objid => n_interact_objid,
                             o_response       => c_response);
         END IF;
      END IF;

      COMMIT;

    EXCEPTION
      WHEN OTHERS THEN
        c_response := 'Cash Card Err'||sqlcode||' - '||substr(sqlerrm,1,500);
        UPDATE x_gsm_acct_migration_stg
        SET    migration_response =  migration_response||c_response
        WHERE  objid = stg_rec.objid ;
    END ;

  END LOOP;

  o_response := 'SUCCESS';

EXCEPTION
  WHEN OTHERS THEN
    o_response := sqlcode ||substr(sqlerrm,1,500);
END process_cash_balance;

--CR47564 MOVED FROM CUSTOMER TYPE TO HERE
FUNCTION get_migration_flag ( i_min IN VARCHAR2 ) RETURN VARCHAR2
IS
  c_ret_val VARCHAR2(1);
  cdt       code_table_type := code_table_type ();
BEGIN
-- CHECK IF MIN IS PASSED
  IF i_min IS NULL THEN
    RETURN 'Y';
  ELSE
    BEGIN
      SELECT cdt.get_migration_flag( i_code_number => x_part_inst_status )
      INTO   c_ret_val
      FROM   table_part_inst
      WHERE  part_serial_no = i_min
      AND    x_domain       = 'LINES' ;
    EXCEPTION
     WHEN OTHERS THEN
      RETURN 'Y';
    END;
    RETURN c_ret_val;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
   RETURN 'Y';
END get_migration_flag;

PROCEDURE cleanup_wfm_migration( i_esn               IN VARCHAR2  DEFAULT NULL ,
                                 i_min               IN VARCHAR2               ,
		                 i_sim               IN VARCHAR2  DEFAULT NULL ,
		                 i_stg_objid         IN NUMBER    DEFAULT NULL ,
		                 i_migration_status  IN VARCHAR2,
		                 i_migration_type    IN VARCHAR2,
		                 o_response          OUT VARCHAR2) IS

CURSOR c IS
   SELECT m.*
   FROM   wfmmig.x_wfm_acct_migration_stg m
   WHERE  1 = 1
   AND    m.migration_status = i_migration_status
   AND    m.objid            = i_stg_objid
   UNION
   SELECT m.*
   FROM   wfmmig.x_wfm_acct_migration_stg m
   WHERE  1 = 1
   AND    m.migration_status = i_migration_status
   AND    m.min              = i_min;


CURSOR c_bill IS
   SELECT m.*
   FROM   wfmmig.x_wfm_acct_migration_bill_stg m
   WHERE  1 = 1
   AND    m.migration_status = i_migration_status
   AND    m.objid            = i_stg_objid
   UNION
   SELECT m.*
   FROM   wfmmig.x_wfm_acct_migration_bill_stg m
   WHERE  1 = 1
   AND    m.migration_status = i_migration_status
   AND    m.min              = i_min;


 CURSOR c_contacts ( p_contact_objid NUMBER) IS
   select  /*+ ordered */
              distinct b.objid contact_objid, c.objid contact_add_info_objid, cc.objid contact_add_info_bus_org, ccc.objid contact_user_objid
             , d.objid address_objid, e.objid site_objid, ee.objid site_bus_org
             , g.objid contact_role_objid,
   	       h.objid contact_role_gbst_elm_objid
             , b.last_name contact_last_name, b.first_name contact_first_name, b.address_1 contact_address_1
             , c.add_info2contact,   c.add_info2user, c.add_info2bus_org
             , ccc.s_login_name table_user_login_name
             , h.title gbst_elm_title
             , e.site_id
             , e.site_type
             , b.phone
             , d.objid
             , d.address
            -- , a.*
   FROM wfmmig.x_wfm_acct_migration_stg a  ,
        sa.table_contact              b    ,
        sa.table_x_contact_add_info   c    ,
        sa.table_bus_org              cc   ,
        sa.table_user                 ccc  ,
        sa.table_address              d    ,
        sa.table_site                 e    ,
        sa.table_bus_org              ee   ,
        sa.table_contact_role         g    ,
        sa.table_gbst_elm             h
       --,table_bus_site_role        f
       --,table_bus_org              ff
   WHERE b.objid(+)                = p_contact_objid
   AND   c.add_info2contact(+)     = b.objid
   AND   cc.objid(+)               = c.add_info2bus_org
   AND   ccc.objid(+)              = c.add_info2user
   AND   g.contact_role2contact(+) = b.objid
   AND   h.objid(+)                = g.contact_role2gbst_elm
   AND   e.objid(+)                = g.contact_role2site
   AND   ee.objid(+)               = e.primary2bus_org
   AND   d.objid(+)                = e.cust_primaddr2address
   AND   a.migration_status       = i_migration_status
   AND   a.objid                  = i_stg_objid;


   CURSOR c_contacts_bill ( p_contact_objid NUMBER) IS
   select  /*+ ordered */
              distinct b.objid contact_objid, c.objid contact_add_info_objid, cc.objid contact_add_info_bus_org, ccc.objid contact_user_objid
             , d.objid address_objid, e.objid site_objid, ee.objid site_bus_org
             , g.objid contact_role_objid,
   	       h.objid contact_role_gbst_elm_objid
             , b.last_name contact_last_name, b.first_name contact_first_name, b.address_1 contact_address_1
             , c.add_info2contact,   c.add_info2user, c.add_info2bus_org
             , ccc.s_login_name table_user_login_name
             , h.title gbst_elm_title
             , e.site_id
             , e.site_type
             , b.phone
             , d.objid
             , d.address
            -- , a.*
   FROM wfmmig.x_wfm_acct_migration_bill_stg a  ,
        sa.table_contact              b    ,
        sa.table_x_contact_add_info   c    ,
        sa.table_bus_org              cc   ,
        sa.table_user                 ccc  ,
        sa.table_address              d    ,
        sa.table_site                 e    ,
        sa.table_bus_org              ee   ,
        sa.table_contact_role         g    ,
        sa.table_gbst_elm             h
       --,table_bus_site_role        f
       --,table_bus_org              ff
   WHERE b.objid(+)                = p_contact_objid
   AND   c.add_info2contact(+)     = b.objid
   AND   cc.objid(+)               = c.add_info2bus_org
   AND   ccc.objid(+)              = c.add_info2user
   AND   g.contact_role2contact(+) = b.objid
   AND   h.objid(+)                = g.contact_role2gbst_elm
   AND   e.objid(+)                = g.contact_role2site
   AND   ee.objid(+)               = e.primary2bus_org
   AND   d.objid(+)                = e.cust_primaddr2address
   AND   a.migration_status       = i_migration_status
   AND   a.objid                  = i_stg_objid;

c_delete_flag  VARCHAR2(1) := 'N';

BEGIN

IF i_migration_type NOT IN ('PREMIGRATION','FINAL_MIGRATION_ASYNC' ) THEN

 o_response := 'INVALID MIGRATION TYPE';

 RETURN;

END IF;

IF i_migration_type  = 'PREMIGRATION' THEN

  FOR i IN c LOOP

    c_delete_flag := 'Y';

    IF i.site_part_objid IS NOT NULL THEN
      DELETE FROM x_service_plan_hist WHERE plan_hist2site_part= i.site_part_objid;

      DELETE FROM x_service_plan_site_part WHERE table_site_part_id = i.site_part_objid;
    END IF;


    DELETE FROM table_site_part WHERE objid = i.site_part_objid;

    DELETE FROM table_site_part WHERE x_service_id = i.esn AND x_min = i.min;

    DELETE FROM table_part_inst WHERE part_serial_no = i.min AND x_domain = 'LINES';

   /*	IF i.program_enrolled_objid IS NOT NULL THEN

      DELETE FROM x_program_trans WHERE pgm_tran2pgm_entrolled = i.program_enrolled_objid;

      DELETE FROM x_program_enrolled WHERE objid = i.program_enrolled_objid;
    END IF;    */

    IF i.contact_objid IS NOT NULL THEN
      DELETE FROM table_x_contact_part_inst  WHERE x_contact_part_inst2contact= i.contact_objid;
    END IF;

    IF i.part_inst_objid IS NOT NULL THEN
      DELETE FROM table_x_contact_part_inst where x_contact_part_inst2part_inst = i.part_inst_objid;
    END IF;

    IF i.web_user_objid IS NOT NULL THEN
      DELETE FROM table_web_user WHERE objid = i.web_user_objid;
    END IF;

    IF i.email IS NOT NULL THEN
      DELETE FROM table_web_user WHERE login_name = i.email AND web_user2bus_org =  536884081; --make sure we are deleting only WFM records
    END IF;

    --resetting the ESN to new
    UPDATE table_part_inst
    SET    x_part_inst_status = '50',
    status2x_code_table       = (select objid from table_x_code_table where x_code_number = '50'),
    x_part_inst2site_part     = NULL,
    x_part_inst2contact       = NULL,
    part_inst2inv_bin         = NULL
    WHERE part_serial_no = i.esn
    AND   x_domain       ='PHONES';

    FOR j IN c_contacts ( i.contact_objid )
	LOOP
      -- contact
        IF i.contact_objid IS NOT NULL THEN

        -- contact role
           DELETE
           FROM   table_contact_role
           WHERE  objid = j.contact_role_objid;

           DELETE
           FROM   table_contact
           WHERE  objid = i.contact_objid;

           -- add contact info
           DELETE
           FROM   table_x_contact_add_info
           WHERE  objid = j.contact_add_info_objid;

           -- address
           DELETE
           FROM   table_address
           WHERE  objid = j.address_objid;

           -- site
           DELETE
           FROM   table_site
           WHERE  objid = j.site_objid;

           -- site bus org
           DELETE
           FROM   table_bus_site_role
           WHERE  role_name = 'OWNER'
           AND    bus_site_role2site = j.site_objid;
         END IF;
    END LOOP; -- j

  --  IF  i_migration_status ='PREMIGRATION_FAILED' THEN
      UPDATE wfmmig.x_wfm_acct_migration_stg
      SET     migration_status   = 'PENDING',
             migration_response  = NULL,
	     part_inst_objid     = NULL,
	     site_part_objid     = NULL ,
	     contact_objid       = NULL,
	     web_user_objid      = NULL
      WHERE  objid = i.objid;

      IF i.pah_indicator ='Y' THEN

	--update migration status to pending for other members SUCCESS records in the account so that My account is aligned

      UPDATE wfmmig.x_wfm_acct_migration_stg
      SET     migration_status    = 'PENDING',
              migration_response  = NULL,
	      part_inst_objid     = NULL,
	      site_part_objid     = NULL,
	      contact_objid       = NULL,
	      web_user_objid      = NULL
      WHERE  ban = i.ban
             AND objid <> i.objid
	     AND migration_status = 'PREMIGRATION_COMPLETED';

      END IF;

  --  END IF;

   /* IF  i_migration_status ='FAILED_FINAL_MIG_DATA_UPDATE' THEN

      UPDATE wfmmig.x_wfm_acct_migration_stg
      SET    migration_status = 'READYTOMIGRATE',
             migration_response = NULL
      WHERE  objid = i.objid;

    END IF;*/

  END LOOP;

END IF;

IF i_migration_type  = 'FINAL_MIGRATION_ASYNC' THEN

  FOR i IN c_bill LOOP
    c_delete_flag := 'Y';

    IF i.site_part_objid IS NOT NULL THEN
      DELETE FROM x_service_plan_hist WHERE plan_hist2site_part= i.site_part_objid;

      DELETE FROM x_service_plan_site_part WHERE table_site_part_id = i.site_part_objid;
    END IF;

    DELETE FROM table_site_part WHERE objid = i.site_part_objid;--delete by site_part_objid

  --  DELETE FROM table_site_part WHERE x_service_id = i_esn AND x_min = i.min; --delete by async call esn

      DELETE FROM table_site_part WHERE x_service_id = i.esn AND x_min = i.min; --delete by existing  esn

  -- DELETE FROM table_part_inst WHERE part_serial_no = i.min AND x_domain = 'LINES';

   /*	IF i.program_enrolled_objid IS NOT NULL THEN

      DELETE FROM x_program_trans WHERE pgm_tran2pgm_entrolled = i.program_enrolled_objid;

      DELETE FROM x_program_enrolled WHERE objid = i.program_enrolled_objid;
    END IF;    */

    IF i.contact_objid IS NOT NULL THEN
      DELETE FROM table_x_contact_part_inst  WHERE x_contact_part_inst2contact= i.contact_objid;
    END IF;

    IF i.part_inst_objid IS NOT NULL THEN
      DELETE FROM table_x_contact_part_inst where x_contact_part_inst2part_inst = i.part_inst_objid;
    END IF;

    IF i.web_user_objid IS NOT NULL THEN
      DELETE FROM table_web_user WHERE objid = i.web_user_objid;
    END IF;

    IF i.email IS NOT NULL THEN
      DELETE FROM table_web_user WHERE login_name = i.email AND web_user2bus_org =  536884081; --make sure we are deleting only WFM records ;
    END IF;

    --resetting the ESN to new
  /*  UPDATE table_part_inst
    SET    x_part_inst_status = '50',
    status2x_code_table       = (select objid from table_x_code_table where x_code_number = '50'),
    x_part_inst2site_part     = NULL,
    x_part_inst2contact       = NULL,
    part_inst2inv_bin         = NULL
    WHERE part_serial_no = i.esn
    AND   x_domain       ='PHONES';*/

    UPDATE table_part_inst
    SET    x_part_inst_status = '50',
    status2x_code_table       = (select objid from table_x_code_table where x_code_number = '50'),
    x_part_inst2site_part     = NULL,
    x_part_inst2contact       = NULL,
    part_inst2inv_bin         = NULL
    WHERE part_serial_no = i_esn  --resetting async call esn
    AND   x_domain       ='PHONES';

    --resetting sim
    UPDATE table_x_sim_inv
    SET x_sim_inv_status       = '180',
     x_sim_status2x_code_table = (select objid from table_x_code_table where x_code_number = '180')
    WHERE x_sim_serial_no  = i_sim ; --resetting async call sim

    FOR j IN c_contacts_bill ( i.contact_objid )
	LOOP
      -- contact
        IF i.contact_objid IS NOT NULL THEN

        -- contact role
           DELETE
           FROM   table_contact_role
           WHERE  objid = j.contact_role_objid;

           DELETE
           FROM   table_contact
           WHERE  objid = i.contact_objid;

           -- add contact info
           DELETE
           FROM   table_x_contact_add_info
           WHERE  objid = j.contact_add_info_objid;

           -- address
           DELETE
           FROM   table_address
           WHERE  objid = j.address_objid;

           -- site
           DELETE
           FROM   table_site
           WHERE  objid = j.site_objid;

           -- site bus org
           DELETE
           FROM   table_bus_site_role
           WHERE  role_name = 'OWNER'
           AND    bus_site_role2site = j.site_objid;
         END IF;
    END LOOP; -- j

  --  IF  i_migration_status ='PREMIGRATION_FAILED' THEN
      UPDATE wfmmig.x_wfm_acct_migration_bill_stg
      SET     migration_status = 'READYTOMIGRATE',
             migration_response = NULL,
	     part_inst_objid     = NULL,
	     site_part_objid     = NULL ,
	     contact_objid       = NULL,
	     web_user_objid      = NULL
      WHERE  objid = i.objid;

  --  END IF;

   /* IF  i_migration_status ='FAILED_FINAL_MIG_DATA_UPDATE' THEN

      UPDATE wfmmig.x_wfm_acct_migration_stg
      SET    migration_status = 'READYTOMIGRATE',
             migration_response = NULL
      WHERE  objid = i.objid;

    END IF;*/

  END LOOP;

END IF;


COMMIT;

o_response := CASE WHEN c_delete_flag='Y' THEN 'SUCCESS' ELSE 'NO DATA TO DELETE' END;


END cleanup_wfm_migration;

PROCEDURE update_contact_phone (i_contact_objid IN  NUMBER,
                                i_phone         IN  NUMBER,
                                o_response      OUT VARCHAR2 )
IS

  n_site_objid NUMBER;

BEGIN
    BEGIN
       SELECT ts.objid INTO n_site_objid
       FROM table_site ts ,
            table_bus_org tb ,
            table_contact_role tc
       WHERE 1                    =1
         AND tc.contact_role2contact = i_contact_objid
         AND ts.objid                = tc.contact_role2site
         AND tb.objid                = ts.primary2bus_org
         AND tb.org_id               ='WFM';

    EXCEPTION
        WHEN OTHERS THEN
          n_site_objid := NULL;
    END;

    UPDATE table_contact SET PHONE=i_phone WHERE objid=i_contact_objid;

    UPDATE table_site SET PHONE=i_phone WHERE objid=n_site_objid;

    o_response          := 'SUCCESS';

EXCEPTION
  WHEN OTHERS THEN
   o_response := 'ERROR '||' SQLCODE :'||sqlcode|| ' ERRM :'||substr(sqlerrm,1,500);
END update_contact_phone;

PROCEDURE load_wfm_premigration ( o_response                OUT VARCHAR2,
                                  i_max_rows_limit          IN  NUMBER DEFAULT 10000,
                                  i_commit_every_rows       IN  NUMBER DEFAULT 5000,
                                  i_bulk_collection_limit   IN  NUMBER DEFAULT 1000,
                                  i_divisor                 IN  NUMBER DEFAULT  1,
                                  i_remainder               IN  NUMBER DEFAULT  0,
                                  i_carrier_id              IN  VARCHAR2 DEFAULT '180260',
                                  i_brand                   IN  VARCHAR2 DEFAULT 'WFM',
                                  i_phone_part_inst_status  IN  VARCHAR2 DEFAULT '160',
                                  i_line_part_inst_status   IN  VARCHAR2 DEFAULT '120',
                                  i_sim_status              IN  VARCHAR2 DEFAULT '180',
                                  i_site_part_status        IN  VARCHAR2 DEFAULT 'NotMigrated',
                                  i_source_system           IN  VARCHAR2 DEFAULT 'BATCH',
                                  i_user                    IN  VARCHAR2 DEFAULT 'OPERATIONS' ) AS
  -- get transactions (limit the rows to be retrieved)
  CURSOR c_get_data IS
    SELECT *
    FROM   (SELECT *
            FROM   x_wfm_acct_migration_stg
            WHERE  migration_status IN ('PENDING')
            AND    MOD(ban,i_divisor) = i_remainder
            ORDER BY ban asc,pah_indicator desc)
    WHERE  ROWNUM <= i_max_rows_limit;


  CURSOR c_get_interactions (i_min IN VARCHAR2) IS
    SELECT /*+ index (stg idx1_wfm_interactions_stg) */ *
    FROM   x_wfm_interactions_stg stg
    WHERE  MIN = i_min
    AND    record_status = 'PENDING';

   rec_interactions          c_get_interactions%ROWTYPE;

  -- temporary record to hold required attributes
  TYPE dataList IS TABLE OF c_get_data%ROWTYPE;

  -- based on record above
  --  TYPE dataList IS TABLE OF data_record;

  -- table to hold array of data
  data                      dataList;

  --
  pi                        part_inst_type := part_inst_type ();
  sp                        site_part_type := site_part_type ();
  ph                        pi_hist_type := pi_hist_type ();
  wu                        web_user_type := web_user_type ();
  cpi                       contact_part_inst_type := contact_part_inst_type ();
  spsp                      service_plan_site_part_type := service_plan_site_part_type ();
  sph                       service_plan_hist_type := service_plan_hist_type ();
  ctt                       code_table_type := code_table_type ();


  --
  n_count_rows              NUMBER := 0;
  n_failed_rows             NUMBER := 0;
  n_interact_objid          NUMBER;

  c_line_i_carrier_id       VARCHAR2 (50) := '';            --need to update
  c_line_o_carrier_id       VARCHAR2 (50);
  c_line_o_carrier_name     VARCHAR2 (50);
  c_line_o_result           NUMBER;
  c_line_o_msg              VARCHAR2 (500);

  c_contact_o_err_code      VARCHAR2 (100);
  c_contact_o_err_msg       VARCHAR2 (500);
  c_contact_o_objid         NUMBER;
  n_bus_org_objid           NUMBER;
  c_brand                   VARCHAR2 (30) := 'WFM';
  c_response                VARCHAR2 (1000);
  c_sim_status              VARCHAR2 (100);
  n_inv_bin_objid           NUMBER;
  c_autorefill_flag         VARCHAR2 (1);
  c_old_esn                 VARCHAR2 (30);
  c_city                    VARCHAR2 (30);
  c_state                   VARCHAR2 (10);
  c_web_contact_objid       NUMBER;
  c_sysdate                 DATE ;--DEFAULT SYSDATE;
  c_step                    VARCHAR2(1000);


  c_cc_objid                NUMBER;
  c_cc_errno                VARCHAR2 (100);
  c_cc_errstr               VARCHAR2 (500);
  l_service_plan_id         NUMBER;
  l_account_group_uid       VARCHAR2 (200);
  l_account_group_id        NUMBER;
  l_subscriber_uid          VARCHAR2 (200);
  l_group_err_code          NUMBER;
  l_group_err_msg           VARCHAR2 (200);
  l_group_return            NUMBER;

  --

  -- used to determine if a pcrf transaction exists that needs to be archived
  FUNCTION more_rows_exist
    RETURN BOOLEAN IS
    n_count  NUMBER := 0;
  BEGIN
    SELECT COUNT (1)
    INTO   n_count
    FROM   DUAL
    WHERE  EXISTS
             (SELECT 1
              FROM   x_wfm_acct_migration_stg
              WHERE  migration_status IN ('PENDING')
	      AND    MOD(ban,i_divisor) = i_remainder );

    --
    RETURN (CASE WHEN n_count > 0 THEN TRUE ELSE FALSE END);
  --
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END more_rows_exist;
BEGIN
  -- set global variable to avoid unwanted trigger executions
  sa.globals_pkg.g_run_my_trigger := FALSE;

  --
  BEGIN
    SELECT objid
    INTO   n_bus_org_objid
    FROM   table_bus_org
    WHERE  org_id = i_brand;
  EXCEPTION
    WHEN OTHERS THEN
      n_bus_org_objid := NULL;                   --need to update value here
  END;



  -- perform a loop while applicable pcrf record exists
  WHILE (more_rows_exist) LOOP
    -- open cursor to retrieve data records
    OPEN c_get_data;

    -- start loop
    LOOP
      -- fetch cursor data into pcrf collection (limit collection to i_bulk_collection_limit rows at a time)
      FETCH c_get_data
      BULK COLLECT INTO data LIMIT i_bulk_collection_limit;

      -- loop through migration  collection
      FOR i IN 1 .. data.COUNT LOOP
        -- reset response as null for reuse
        o_response            := NULL;
        c_response            := NULL;
        c_line_i_carrier_id   := NULL;
        c_line_o_carrier_name := NULL;
        c_line_o_result       := NULL;
        c_line_o_msg          := NULL;
        c_contact_o_objid     := 0;
        c_sim_status          := NULL;
     -- n_inv_bin_objid         := NULL;
        c_autorefill_flag     := NULL;
        c_old_esn             := NULL;
        c_city                := NULL;
        c_state               := NULL;
        c_web_contact_objid   := NULL;
	c_step                := NULL;

        -- initialize type attributes to null
        pi   := part_inst_type ();
        sp   := site_part_type ();
        ph   := pi_hist_type ();
        wu   := web_user_type ();
        cpi  := contact_part_inst_type ();
        spsp := service_plan_site_part_type ();
        sph  := service_plan_hist_type ();

	c_sysdate  := SYSDATE;
        --
        BEGIN -- Loop Exception
        --
	  c_step := 'Get Part Inst Record';

          pi := part_inst_type (i_esn => data (i).esn);
          --
           IF pi.response NOT LIKE '%SUCCESS%' THEN
            c_response := c_response || '|' || 'Part Inst Err :' || pi.response;
            --
            UPDATE x_wfm_acct_migration_stg
            SET    migration_status = 'PREMIGRATION_FAILED',
                   migration_response = c_response
            WHERE  objid = data (i).objid;
            --
            CONTINUE;                              --continue next iteration
          END IF;
          --
          IF pi.part_inst2contact IS NOT NULL AND ( NVL(data(i).contact_objid,0) = pi.part_inst2contact) THEN
            c_contact_o_objid := pi.part_inst2contact; --assign contact
          END IF;
          --
          DBMS_OUTPUT.put_line ('part inst response ' || pi.response);
          --
          BEGIN
            SELECT x_city,
                   x_state
            INTO   c_city,
                   c_state
            FROM   table_x_zip_code
            WHERE  x_zip = data (i).zipcode;
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
          --
          --   dbms_output.put_line('Contact Objid before contact creation  '||c_contact_o_objid);

          IF c_contact_o_objid  = 0  THEN
            -- create contact related information
	    c_step := 'Create Contact';

            sa.contact_pkg.createcontact_prc ( p_esn                => data (i).esn,
                                               p_first_name         => data (i).first_name,
                                               p_last_name          => data (i).last_name,
                                               p_middle_name        => NULL,
                                               p_phone              => data (i).MIN ||' ', --added a space to force new contact creation for WFM
                                               p_add1               => data (i).address_1,
                                               p_add2               => data (i).address_2,
                                               p_fax                => NULL,
                                               p_city               => NVL (c_city,data(i).city),
                                               p_st                 => NVL (c_state,data(i).state),
                                               p_zip                => data (i).zipcode,
                                               p_email              => data (i).email,
                                               p_email_status       => NULL,
                                               p_roadside_status    => NULL,
                                               p_no_name_flag       => NULL,
                                               p_no_phone_flag      => NULL,
                                               p_no_address_flag    => NULL,
                                               p_sourcesystem       => i_source_system,
                                               p_brand_name         => data (i).bus_org_id,
                                               p_do_not_email       => data (i).do_not_mail_flag,
                                               p_do_not_phone       => data (i).do_not_phone_flag,
                                               p_do_not_mail        => data (i).do_not_mail_flag,
                                               p_do_not_sms         => data (i).do_not_sms_flag,
                                               p_ssn                => NULL,
                                               p_dob                => data (i).date_of_birth,
                                               p_do_not_mobile_ads  => NULL,
                                               p_contact_objid      => c_contact_o_objid,
                                               p_err_code           => c_contact_o_err_code,
                                               p_err_msg            => c_contact_o_err_msg);

            IF c_contact_o_err_code <> '0' AND c_contact_o_err_msg <> 'Contact Created Successfully' THEN
              c_response := c_response || '|' || 'Create Contact Err :' || c_contact_o_err_msg;
            END IF;

            --Remove space added in phone before
            update_contact_phone (i_contact_objid => c_contact_o_objid,
                                  i_phone         => data (i).MIN,
                                  o_response      => c_contact_o_err_msg );
          ELSE
	    c_step := 'Update Contact';
            sa.contact_pkg.updatecontact_prc ( i_esn                => data (i).esn,
                                               i_first_name         => data (i).first_name,
                                               i_last_name          => data (i).last_name,
                                               i_middle_name        => NULL,
                                               i_phone              => data (i).MIN,
                                               i_add1               => data (i).address_1,
                                               i_add2               => data (i).address_2,
                                               i_fax                => NULL,
                                               i_city               => NVL (c_city,data(i).city),
                                               i_st                 => NVL (c_state,data(i).state),
                                               i_zip                => data (i).zipcode,
                                               i_email              => data (i).email,
                                               i_email_status       => NULL,
                                               i_roadside_status    => NULL,
                                               i_no_name_flag       => NULL,
                                               i_no_phone_flag      => NULL,
                                               i_no_address_flag    => NULL,
                                               i_sourcesystem       => i_source_system,
                                               i_brand_name         => data (i).bus_org_id,
                                               i_do_not_email       => data (i).do_not_mail_flag,
                                               i_do_not_phone       => data (i).do_not_phone_flag,
                                               i_do_not_mail        => data (i).do_not_mail_flag,
                                               i_do_not_sms         => data (i).do_not_sms_flag,
                                               i_ssn                => NULL,
                                               i_dob                => data (i).date_of_birth,
                                               i_do_not_mobile_ads  => NULL,
                                               i_contact_objid      => c_contact_o_objid,
                                               o_err_code           => c_contact_o_err_code,
                                               o_err_msg            => c_contact_o_err_msg);
            --
            -- ??? based on update procedure output.
            IF c_contact_o_err_code <> '0' AND c_contact_o_err_msg <> 'Success' THEN
              c_response := c_response || '|' || 'Update Contact Err :' || c_contact_o_err_msg;
            END IF;
          END IF;
          --
          DBMS_OUTPUT.put_line ( 'contact ' || c_contact_o_err_code || '-' || c_contact_o_err_msg);
          --  DBMS_OUTPUT.put_line ('contact objid ' || c_contact_o_objid);
          --   dbms_output.put_line('Contact Objid after contact creation  '||c_contact_o_objid);
          --
          IF c_contact_o_objid IS NOT NULL THEN -- update language pref
            UPDATE table_x_contact_add_info
            SET    x_lang_pref = CASE
                                   WHEN data (i).language = 'EN' THEN 'EN'
                                   WHEN data (i).language = 'SP' THEN 'ES'
                                   ELSE 'EN'
                                 END,
                   x_pin       = data(i).security_pin
            WHERE  add_info2contact = c_contact_o_objid;
          END IF;
          --
          BEGIN
            SELECT contact_role2site
            INTO   sp.site_objid
            FROM   table_contact_role
            WHERE  1 = 1
            AND    contact_role2contact = c_contact_o_objid;
          EXCEPTION
            WHEN OTHERS  THEN
              sp.site_objid := NULL;
          END;
          --
          --site part attribute assignment
          --
          --ctt := code_table_type ( i_code_number => data(i).customer_status );
          --
	  c_step := 'Create Table Site Part';

          sp.instance_name      := 'Wireless';
          sp.serial_no          := data (i).esn;
          sp.service_id         := data (i).esn;
          sp.iccid              := data (i).sim;
          sp.install_date       := TRUNC(NVL(data(i).activation_date,c_sysdate));
          sp.warranty_date      := NULL;
          sp.expire_dt          := NULL;
          sp.actual_expire_dt   := NULL;
          sp.state_code         := 0;
          sp.state_value        := 'GSM';
          sp.part_status        := i_site_part_status;
          --sp.site_objid         := null ;-- need to derive
          sp.dir_site_objid     := sp.site_objid;               --need to derive
          sp.all_site_part2site := sp.site_objid;
          sp.site_part2site     := sp.site_objid;
          sp.service_end_dt     := NULL;                        --need to derive
          sp.MIN                := data (i).MIN;
          sp.msid               := data (i).MIN;
          sp.update_stamp       := c_sysdate;
          sp.site_part2part_info:= pi.n_part_inst2part_mod; --need to derive
          sp.zipcode            := data (i).zipcode;
          --
          --site_part end
          --
          ins_site_part ( i_site_part_type => sp,
                          o_response       => o_response);
          --
          IF sp.response NOT LIKE '%SUCCESS%' THEN
            c_response := c_response || '|' || 'Site Part Err :' || sp.response;
          END IF;
          --
          DBMS_OUTPUT.put_line ('site part response ' || sp.response);
          --
          ctt := code_table_type ();
          --
          ctt := code_table_type (i_code_number => i_phone_part_inst_status);
          --
          -- update ESN status
          UPDATE table_part_inst
          SET    x_part_inst_status    = i_phone_part_inst_status,
                 status2x_code_table   = ctt.code_table_objid,
                 x_part_inst2site_part = sp.site_part_objid,
                 x_part_inst2contact   = c_contact_o_objid,
                 part_inst2inv_bin     = data (i).dealer_inv_objid ,
                 x_iccid               = data(i).sim
          WHERE  part_serial_no        = data (i).esn;

          -- c_sim_status:='253' ;

          ctt := code_table_type (); -- reinitialize for sim

          ctt := code_table_type ( i_code_number => i_sim_status );

          -- need to check this
          -- update sim status
          /* UPDATE table_x_sim_inv
             SET x_sim_inv_status          = i_sim_status ,
                 x_sim_status2x_code_table = ctt.code_table_objid
             WHERE x_sim_serial_no = data(i).sim;    */

          -- need to delete line if it already exists
          DELETE FROM table_part_inst
          WHERE  part_serial_no = data (i).MIN
          AND    x_domain = 'LINES';

          --create line
          IF NOT npanxx_exist (i_min         => data (i).MIN,
                               i_npa         => SUBSTR (data (i).MIN, 1, 3),
                               i_nxx         => SUBSTR (data (i).MIN, 4, 3),
                               i_carrier_id  => i_carrier_id,
                               i_zip         => data (i).zipcode)
          THEN
            insert_npanxx (i_min         => data(i).MIN,
                           i_carrier_id  => i_carrier_id,
                           i_zip         => data (i).zipcode);
          END IF;
          --
	  c_step := 'Create Line';
          toppapp.line_insert_pkg.line_validation ( ip_msid          => data(i).MIN,
                                                    ip_min           => data(i).MIN,
                                                    ip_carrier_id    => i_carrier_id,
                                                    ip_file_name     => 'WFM MOBILE',
                                                    ip_file_type     => '1',
                                                    ip_expire_date   => 'NA',
                                                    op_carrier_id    => c_line_o_carrier_id,
                                                    op_carrier_name  => c_line_o_carrier_name,
                                                    op_result        => c_line_o_result,
                                                    op_msg           => c_line_o_msg);

          DBMS_OUTPUT.put_line ('Line creation  result  ' || c_line_o_result);
          DBMS_OUTPUT.put_line ('Line creation  message ' || c_line_o_msg);

          IF c_line_o_result <> 1 THEN
            c_response := c_response || '|' || 'Line Insert Err :' || c_line_o_msg;
          END IF;

          ctt := code_table_type (); -- again reinitialize for line
          --
          ctt := code_table_type ( i_code_number => i_line_part_inst_status );
          --
          --link the line to ESN
          UPDATE table_part_inst
          SET    part_to_esn2part_inst = pi.part_inst_objid,
                 x_part_inst_status    = i_line_part_inst_status,
                 status2x_code_table   = ctt.code_table_objid
          WHERE  part_serial_no = data (i).MIN
          AND    x_domain = 'LINES';
          --
          --delink any other existing line
          UPDATE table_part_inst
          SET    part_to_esn2part_inst = NULL,
                 x_part_inst_status    = '17',
                 status2x_code_table   = (select objid from table_x_code_table where x_code_number='17')  --updating to line returned
          WHERE  part_to_esn2part_inst = pi.part_inst_objid
          AND    x_domain = 'LINES'
          AND    part_serial_no <> data (i).MIN;
          --
          -- x_service_plan_site_part
	  c_step := 'Create Service Plan Site Part';

          spsp.service_plan_site_part_objid := sp.site_part_objid;
          spsp.service_plan_id              := data(i).service_plan;
          spsp.switch_base_rate             := 0; -- need to check this value for simple mobile
          spsp.new_service_plan_id          := NULL;
          spsp.last_modified_date           := c_sysdate;
          --
          IF spsp.service_plan_id IS NOT NULL
          THEN
            --
            ins_service_plan_site_part ( i_service_plan_site_part_type  => spsp,
                                         o_response                     => o_response);
            DBMS_OUTPUT.put_line ( 'service plan site part response   ' || spsp.response);
            --
            IF spsp.response NOT LIKE '%SUCCESS%' THEN
              c_response := c_response || '|' || 'Service Plan SP Err :' || spsp.response;
            ELSE
	            --insert x_xervice_plan_hist

              c_step := 'Create Service Plan Site Part hist';

              sph.plan_hist2site_part_objid := sp.site_part_objid;
              sph.start_date                := c_sysdate;
              sph.plan_hist2service_plan    := spsp.service_plan_id;
              sph.insert_date               := c_sysdate;
              sph.last_modified_date        := c_sysdate;
              --
              ins_service_plan_hist (i_service_plan_hist_type  => sph,
                                     o_response                => o_response);
              --
              DBMS_OUTPUT.put_line ('service plan hist   ' || sph.response);
              --
              --insert x_xervice_plan_hist
              IF sph.response NOT LIKE '%SUCCESS%' THEN
                c_response := c_response || '|' || 'Service Plan H Err :' || sph.response;
              END IF;
              --
            END IF;
            --
          ELSE
            c_response := c_response || '|' || 'Service Plan Not Found';
          END IF;
          --
          IF  data(i).pah_indicator ='Y' AND data(i).email IS NOT NULL THEN --create account only  for PAH
            -- Check whether WEB contact is created already
	    c_web_contact_objid  := NULL ; -- resetting to null

            BEGIN
              SELECT  web_user2contact
              INTO    c_web_contact_objid
              FROM    table_web_user
              WHERE   s_login_name         = UPPER (data(i).email)
              AND     web_user2bus_org     = n_bus_org_objid;
            EXCEPTION
              WHEN OTHERS THEN
                c_web_contact_objid :=  0;
            END;
            IF NVL(c_web_contact_objid,0) = 0
            THEN
              -- create contact that doesn not associate to any ESN, specifially to link WEB USER
	      c_step := 'Create Web Contact';
              contact_pkg.createcontact_prc (  p_esn                => NULL,
                                               p_first_name         => data (i).first_name,
                                               p_last_name          => data (i).last_name,
                                               p_middle_name        => NULL,
                                               p_phone              => '',
                                               p_add1               => data (i).address_1,
                                               p_add2               => data (i).address_2,
                                               p_fax                => NULL,
                                               p_city               => NVL (c_city,data(i).city),
                                               p_st                 => NVL (c_state,data(i).state),
                                               p_zip                => data (i).zipcode,
                                               p_email              => data (i).email,
                                               p_email_status       => NULL,
                                               p_roadside_status    => NULL,
                                               p_no_name_flag       => NULL,
                                               p_no_phone_flag      => NULL,
                                               p_no_address_flag    => NULL,
                                               p_sourcesystem       => i_source_system,
                                               p_brand_name         => data (i).bus_org_id,
                                               p_do_not_email       => data (i).do_not_mail_flag,
                                               p_do_not_phone       => data (i).do_not_phone_flag,
                                               p_do_not_mail        => data (i).do_not_mail_flag,
                                               p_do_not_sms         => data (i).do_not_sms_flag,
                                               p_ssn                => NULL,
                                               p_dob                => data (i).date_of_birth,
                                               p_do_not_mobile_ads  => NULL,
                                               p_contact_objid      => c_web_contact_objid,
                                               p_err_code           => c_contact_o_err_code,
                                               p_err_msg            => c_contact_o_err_msg);
            ELSE
	      c_step := 'Update Web Contact';

              contact_pkg.updatecontact_prc (  i_esn                => NULL,
                                               i_first_name         => data (i).first_name,
                                               i_last_name          => data (i).last_name,
                                               i_middle_name        => NULL,
                                               i_phone              => '',
                                               i_add1               => data (i).address_1,
                                               i_add2               => data (i).address_2,
                                               i_fax                => NULL,
                                               i_city               => NVL (c_city,data(i).city),
                                               i_st                 => NVL (c_state,data(i).state),
                                               i_zip                => data (i).zipcode,
                                               i_email              => data (i).email,
                                               i_email_status       => NULL,
                                               i_roadside_status    => NULL,
                                               i_no_name_flag       => NULL,
                                               i_no_phone_flag      => NULL,
                                               i_no_address_flag    => NULL,
                                               i_sourcesystem       => i_source_system,
                                               i_brand_name         => data (i).bus_org_id,
                                               i_do_not_email       => data (i).do_not_mail_flag,
                                               i_do_not_phone       => data (i).do_not_phone_flag,
                                               i_do_not_mail        => data (i).do_not_mail_flag,
                                               i_do_not_sms         => data (i).do_not_sms_flag,
                                               i_ssn                => NULL,
                                               i_dob                => data (i).date_of_birth,
                                               i_do_not_mobile_ads  => NULL,
                                               i_contact_objid      => c_web_contact_objid,
                                               o_err_code           => c_contact_o_err_code,
                                               o_err_msg            => c_contact_o_err_msg);
            END IF;
            --
            IF c_contact_o_err_code <> '0' AND c_contact_o_err_msg <> 'Contact Created Successfully'
            THEN
              c_response := c_response || '|' || 'Create BAN Contact Err :' || c_contact_o_err_msg;
            ELSE
              --
	      c_step := 'Create Web User';

              wu.login_name           := data(i).email;
              wu.s_login_name         := UPPER (data(i).email);
              wu.password             := data(i).login_password;
              wu.user_key             := NULL;
              wu.status               := 1;                                  --need to confirm
              wu.passwd_chg           := NULL;
              wu.dev                  := NULL;
              wu.ship_via             := NULL;
              wu.secret_questn        := data(i).secret_question;
              wu.s_secret_questn      := UPPER(data(i).secret_question);
              wu.secret_ans           := data(i).secret_answer;
              wu.s_secret_ans         := UPPER(data(i).secret_answer);
              wu.web_user2user        := NULL;
              wu.web_user2contact     := c_web_contact_objid;
              wu.web_user2lead        := NULL;
              wu.web_user2bus_org     := n_bus_org_objid;
              wu.last_update_date     := c_sysdate;
              wu.validated            := NULL;           --need to confirm value
              wu.validated_counter    := NULL;           --need to confirm value
              wu.named_userid         := NULL;
              wu.insert_timestamp     := c_sysdate;
              --
              --
              ins_web_user ( i_web_user_type => wu,
                             o_response      => o_response);

              IF wu.response NOT LIKE '%SUCCESS%' THEN
                c_response := c_response || '|' || 'Web User Err :' || wu.response;
              END IF;

              -- ELSE
              --    c_response := c_response||'|'||'LOGIN NAME NOT VALID';
              -- END IF;

              DBMS_OUTPUT.put_line ('web user response   ' || wu.response);
              --
            END IF;
          END IF;
          --   Table_x_contact_part_inst
          --query to get ban contact objid

           BEGIN

             SELECT
             wbu.web_user2contact INTO c_web_contact_objid
             FROM
             x_wfm_acct_migration_stg stg,
             table_web_user wbu
             WHERE stg.ban            = data(i).ban
             AND stg.pah_indicator    = 'Y'
             AND stg.email            = wbu.login_name
             AND wbu.web_user2bus_org = n_bus_org_objid;

           EXCEPTION
            WHEN OTHERS THEN
               c_web_contact_objid := NULL;
           END ;


	  IF c_web_contact_objid IS NOT NULL THEN  --Create My Account only if Web is present

         -- cpi.contact_part_inst2contact   := NVL(c_web_contact_objid,c_contact_o_objid);
	    c_step := 'Create Contact part Inst';

	    cpi.contact_part_inst2contact   := c_web_contact_objid;
            cpi.contact_part_inst2part_inst := pi.part_inst_objid;
            cpi.esn_nick_name               := NULL;                 --need to confirm value
            --
            --	  dbms_output.put_line ('cpi contact objid '|| cpi.contact_part_inst2contact);
            --
            IF  data(i).pah_indicator ='Y' AND data(i).email IS NOT NULL THEN  --assigning is_default for PAH
              cpi.is_default                 := 1;
            ELSE
              cpi.is_default                 := 0;
            END IF;  --need to confirm value
            --
            cpi.transfer_flag               := 0;                    --need to confirm value
            cpi.verified                    := 'Y';                       --need to confirm value
            cpi.response                    := NULL;
            --
            --
            ins_contact_part_inst ( i_contact_part_inst_type => cpi,
                                    o_response               => o_response);
            --
            IF cpi.response NOT LIKE '%SUCCESS%' THEN
              c_response := c_response || '|' || 'Contact PI Err :' || cpi.response;
            END IF;
            --
            DBMS_OUTPUT.put_line ('contact part inst response   ' || cpi.response);
	  ELSE

	   c_response := c_response || '|' || 'Contact PI Err :' || 'Web User Not Found';

	  END IF;
          --
          --insert interactions
        /*  FOR rec_interactions IN c_get_interactions (data (i).MIN)
          LOOP
            n_interact_objid := NULL;
            --
            ins_interaction ( i_contact_objid  => c_contact_o_objid,
                              i_reason_1       => rec_interactions.memo_code_desc,
                              i_reason_2       => rec_interactions.memo_code||' - '||rec_interactions.memo_code_desc,
                              i_notes          => NVL(rec_interactions.memo_system_text,rec_interactions.memo_manual_text),
                              i_rslt           => 'Successful',
                              i_user           => 'SA',
                              i_esn            => data(i).esn,
                              i_create_date    => NVL(rec_interactions.memo_date,c_sysdate),
                              i_start_date     => NVL(rec_interactions.memo_date,c_sysdate),
                              i_end_date       => NVL(rec_interactions.memo_date,c_sysdate),
                              o_interact_objid => n_interact_objid ,
                              o_response       => o_response);
			      --
            --
            IF o_response NOT LIKE '%SUCCESS%' THEN
              UPDATE x_wfm_interactions_stg
              SET    record_status        = 'FAILED',
                     record_response      = o_response,
                     update_timestamp     = c_sysdate
              WHERE  objid = rec_interactions.objid;
            ELSE
              UPDATE x_wfm_interactions_stg
              SET    record_status       = 'COMPLETED',
                     record_response     = 'SUCCESS',
                     update_timestamp    = c_sysdate,
                     table_interact_objid = n_interact_objid
              WHERE  objid = rec_interactions.objid;
            END IF;
            --
          END LOOP;*/
          --
          IF UPPER (c_response) NOT LIKE '%SUCCESS%'
             AND c_response IS NOT NULL
          THEN
            -- increase row count
            n_failed_rows := n_failed_rows + 1;
            -- maybe update the staging table with the failed response message
            -- maybe continue to next iteration row
            -- CONTINUE

          END IF;
          --
          --code to update migration status
          UPDATE x_wfm_acct_migration_stg
          SET    migration_status = CASE
                                      WHEN c_response IS NULL THEN 'PREMIGRATION_COMPLETED'
                                      ELSE 'PREMIGRATION_FAILED'
                                    END,
                 migration_response = CASE
                                        WHEN c_response IS NULL THEN 'SUCCESS'
                                        ELSE c_response
                                      END,
                 part_inst_objid  = pi.part_inst_objid,
                 site_part_objid  = sp.site_part_objid,
                 contact_objid    = c_contact_o_objid,
                 web_user_objid   = wu.web_user_objid,
                 update_timestamp = c_sysdate
          WHERE  objid = data (i).objid;

          -- reset response as null for reuse
          --o_response := NULL;
          -- increase row count
          n_count_rows := n_count_rows + 1;

          IF (MOD (n_count_rows, i_commit_every_rows) = 0) THEN
            -- Save changes
            COMMIT;
          END IF;
          --
        EXCEPTION                                           --loop exception
          WHEN OTHERS THEN
            c_response := c_step||' : '||c_response || ' sqlcode-sqlerrm ' || SQLCODE || ' - ' || SUBSTR (SQLERRM, 1, 500);

            UPDATE x_wfm_acct_migration_stg
            SET    migration_status       = 'PREMIGRATION_FAILED',
                   migration_response     = c_response,
                   part_inst_objid        = pi.part_inst_objid,
                   site_part_objid        = sp.site_part_objid,
                   contact_objid          = c_contact_o_objid,
                   web_user_objid         = wu.web_user_objid,
                   update_timestamp       = c_sysdate
            WHERE  objid = data (i).objid;
        END;
      END LOOP;                                                    -- c_data
      --
      EXIT WHEN c_get_data%NOTFOUND;
    --
    END LOOP;

    CLOSE c_get_data;

    -- exit when there are no more records to archive
    EXIT WHEN NOT (more_rows_exist);
  END LOOP;                                       -- WHILE (more_rows_exist)
  --
  DBMS_OUTPUT.PUT_LINE (n_count_rows || ' rows processed');
  --
  DBMS_OUTPUT.PUT_LINE (n_failed_rows || ' rows failed');
  --
  -- Save changes
  COMMIT;
  --
  o_response := 'SUCCESS';
--
EXCEPTION
  WHEN OTHERS THEN
    --
    o_response := 'ERROR IN LOAD_WFM_PREMIGRATION: ' || SQLERRM;

    -- possibly log in the error table
    -- sa.util_pkg.log_error
    --
    RAISE;
END load_wfm_premigration;


PROCEDURE create_pah_web_user ( i_min               IN VARCHAR2,
                                o_web_user_objid    OUT NUMBER,
                                o_web_contact_objid OUT NUMBER,
                                o_response          OUT VARCHAR2 )
IS
  CURSOR c_bill_stg IS
    SELECT *
    FROM   x_wfm_acct_migration_bill_stg
    WHERE  migration_status = 'READYTOMIGRATE' AND
           min              = i_min;

  c_bill_stg_rec       c_bill_stg%ROWTYPE;

  CURSOR c_pah ( p_ban VARCHAR2) IS
    SELECT *
    FROM   x_wfm_acct_migration_bill_stg
    WHERE  ban              = p_ban AND
           pah_indicator    = 'Y' AND
           migration_status = 'READYTOMIGRATE';

  c_pah_rec            c_pah %ROWTYPE;

  c_web_contact_objid  NUMBER := 0;
  c_contact_o_err_code VARCHAR2 (100);
  c_contact_o_err_msg  VARCHAR2 (500);
  wu                   web_user_type := web_user_type ( );
  n_bus_org_objid      NUMBER;
  c_old_esn            VARCHAR2(100);
  c_old_sim            VARCHAR2(100);
  n_old_web_user_objid NUMBER;

BEGIN
    BEGIN
        SELECT objid
        INTO   n_bus_org_objid
        FROM   table_bus_org
        WHERE  org_id = 'WFM';
    EXCEPTION
        WHEN OTHERS THEN
          n_bus_org_objid := NULL;
    END;

    BEGIN
     SELECT  /*+ index(table_site_part, x_x_min) */
         x_service_id,
         x_iccid
     INTO c_old_esn,
          c_old_sim
     FROM table_site_part
     WHERE x_min      = i_min
     AND  part_status = 'NotMigrated';

    EXCEPTION
     WHEN OTHERS THEN
      c_old_esn := NULL;
      c_old_sim := NULL;
    END;

  --get existing web user objid



    OPEN c_bill_stg;

    FETCH c_bill_stg INTO c_bill_stg_rec;

    IF c_bill_stg%NOTFOUND THEN
      o_response := 'MIN IS NOT FOUND IN x_wfm_acct_migration_bill_stg';
      RETURN;
    END IF;

    OPEN c_pah (c_bill_stg_rec.ban);

    FETCH c_pah INTO c_pah_rec;

    IF c_pah%NOTFOUND THEN
      o_response := 'PAH IS NOT READY FOR MIGRATION';
      RETURN;
    END IF;

    BEGIN
     SELECT
          weu.objid INTO n_old_web_user_objid
     FROM table_web_user weu,
          table_x_contact_part_inst cpi,
          table_part_inst pi
     WHERE pi.part_serial_no                      = c_pah_rec.esn --current esn
         AND cpi.x_contact_part_inst2part_inst    =  pi.objid
         AND cpi.x_contact_part_inst2contact	  = weu.web_user2contact
         AND weu.web_user2bus_org                 = n_bus_org_objid;
    EXCEPTION
      WHEN OTHERS THEN
       n_old_web_user_objid  := NULL;
    END;

    IF c_pah_rec.esn  <> c_old_esn  AND c_old_esn IS NOT NULL THEN  --get the web user objid by old ESN if exists

        -- c_old_esn   := data(i).esn;
        -- data(i).esn := i_esn;
	  BEGIN
	     SELECT
	     weu.objid INTO n_old_web_user_objid
	     FROM table_web_user weu,
	          table_x_contact_part_inst cpi,
		  table_part_inst pi
             WHERE pi.part_serial_no                    = c_old_esn
                  AND cpi.x_contact_part_inst2part_inst =  pi.objid
                  AND cpi.x_contact_part_inst2contact	= weu.web_user2contact
		  AND weu.web_user2bus_org              = n_bus_org_objid;
	  EXCEPTION
           WHEN OTHERS THEN
             n_old_web_user_objid  := NULL;
          END;

    END IF;


    BEGIN

      IF n_old_web_user_objid  IS NOT NULL THEN 	 -- IF old web user exists then go by that web user id

               SELECT  web_user2contact
               INTO    c_web_contact_objid
               FROM    table_web_user
               WHERE   objid                = n_old_web_user_objid
               AND     web_user2bus_org     = n_bus_org_objid;

      ELSE

              SELECT  web_user2contact
              INTO    c_web_contact_objid
              FROM    table_web_user
              WHERE   s_login_name         = UPPER(c_pah_rec.email)
              AND     web_user2bus_org     = n_bus_org_objid;

      END IF;

    EXCEPTION
     WHEN   OTHERS THEN
       c_web_contact_objid :=  0;
    END;

     dbms_output.put_line('web contact before creation '||c_web_contact_objid);
     IF NVL(c_web_contact_objid,0) = 0    THEN

       contact_pkg.createcontact_prc (  p_esn              => NULL,
                                      p_first_name         => c_pah_rec.first_name,
                                      p_last_name          => c_pah_rec.last_name,
                                      p_middle_name        => NULL,
                                      p_phone              => '',
                                      p_add1               => c_pah_rec.address_1,
                                      p_add2               => c_pah_rec.address_2,
                                      p_fax                => NULL,
                                      p_city               => c_pah_rec.city,
                                      p_st                 => c_pah_rec.state,
                                      p_zip                => c_pah_rec.zipcode,
                                      p_email              => c_pah_rec.email,
                                      p_email_status       => NULL,
                                      p_roadside_status    => NULL,
                                      p_no_name_flag       => NULL,
                                      p_no_phone_flag      => NULL,
                                      p_no_address_flag    => NULL,
                                      p_sourcesystem       => 'BATCH',
                                      p_brand_name         => c_pah_rec.bus_org_id,
                                      p_do_not_email       => c_pah_rec.do_not_mail_flag,
                                      p_do_not_phone       => c_pah_rec.do_not_phone_flag,
                                      p_do_not_mail        => c_pah_rec.do_not_mail_flag,
                                      p_do_not_sms         => c_pah_rec.do_not_sms_flag,
                                      p_ssn                => NULL,
                                      p_dob                => c_pah_rec.date_of_birth,
                                      p_do_not_mobile_ads  => NULL,
                                      p_contact_objid      => c_web_contact_objid,
                                      p_err_code           => c_contact_o_err_code,
                                      p_err_msg            => c_contact_o_err_msg);

     ELSE

      	   contact_pkg.updatecontact_prc (   i_esn                => NULL ,
                                             i_first_name         => c_pah_rec.first_name,
                                             i_last_name          => c_pah_rec.last_name,
                                             i_middle_name        => NULL,
                                             i_phone              => '',
                                             i_add1               => c_pah_rec.address_1,
                                             i_add2               => c_pah_rec.address_2,
                                             i_fax                => NULL,
                                             i_city               => c_pah_rec.city,
                                             i_st                 => c_pah_rec.state,
                                             i_zip                => c_pah_rec.zipcode,
                                             i_email              => c_pah_rec.email,
                                             i_email_status       => NULL,
                                             i_roadside_status    => NULL,
                                             i_no_name_flag       => NULL,
                                             i_no_phone_flag      => NULL,
                                             i_no_address_flag    => NULL,
                                             i_sourcesystem       => 'BATCH',
                                             i_brand_name         => c_pah_rec.bus_org_id,
                                             i_do_not_email       => c_pah_rec.do_not_mail_flag,
                                             i_do_not_phone       => c_pah_rec.do_not_phone_flag,
                                             i_do_not_mail        => c_pah_rec.do_not_mail_flag,
                                             i_do_not_sms         => c_pah_rec.do_not_sms_flag,
                                             i_ssn                => NULL,
                                             i_dob                => c_pah_rec.date_of_birth,
                                             i_do_not_mobile_ads  => NULL,
                                             i_contact_objid      => c_web_contact_objid,
                                             o_err_code           => c_contact_o_err_code,
                                             o_err_msg            => c_contact_o_err_msg);

   END IF;
       dbms_output.put_line('web contact after creation '||c_web_contact_objid);

    IF c_contact_o_err_code <> '0' --AND c_contact_o_err_msg <> 'Contact Created Successfully'
    THEN
      o_response := 'Create/Update BAN Contact Err :'|| c_contact_o_err_msg;
      RETURN;
    ELSE

      IF n_old_web_user_objid  IS NOT NULL  THEN  --assigning the old web user so that it updates login information against old web user objid
         wu.web_user_objid := n_old_web_user_objid   ;
      END IF;

      wu.login_name           := c_pah_rec.email;
      wu.s_login_name         := UPPER (c_pah_rec.email);
      wu.password             := c_pah_rec.login_password;
      wu.user_key             := NULL;
      wu.status               := 1;                                  --need to confirm
      wu.passwd_chg           := NULL;
      wu.dev                  := NULL;
      wu.ship_via             := NULL;
      wu.secret_questn        := c_pah_rec.secret_question;
      wu.s_secret_questn      := UPPER(c_pah_rec.secret_question);
      wu.secret_ans           := c_pah_rec.secret_answer;
      wu.s_secret_ans         := UPPER(c_pah_rec.secret_answer);
      wu.web_user2user        := NULL;
      wu.web_user2contact     := c_web_contact_objid;
      wu.web_user2lead        := NULL;
      wu.web_user2bus_org     := n_bus_org_objid;
      wu.last_update_date     := sysdate;
      wu.validated            := NULL;             --need to confirm value
      wu.validated_counter    := NULL;              --need to confirm value
      wu.named_userid         := NULL;
      wu.insert_timestamp     := sysdate;

      migration_pkg.Ins_web_user ( i_web_user_type => wu, o_response => o_response );

      IF wu.response NOT LIKE '%SUCCESS%' THEN
        o_response := 'Web User Err :' || wu.response;
		RETURN;
      END IF;

    END IF;

    dbms_output.put_line('web contact after creation2 '||c_web_contact_objid);

    o_web_user_objid    := wu.web_user_objid;
    o_web_contact_objid := c_web_contact_objid;
    o_response          := 'SUCCESS';

EXCEPTION
  WHEN OTHERS THEN
   o_response := 'ERROR '||' SQLCODE :'||sqlcode|| ' ERRM :'||substr(sqlerrm,1,500);
END create_pah_web_user;
--
--async call procedure
PROCEDURE load_wfm_final_migration ( o_response                OUT VARCHAR2,
                                     i_max_rows_limit          IN  NUMBER DEFAULT 10000,
                                     i_commit_every_rows       IN  NUMBER DEFAULT 5000,
                                     i_bulk_collection_limit   IN  NUMBER DEFAULT 1000,
                                     i_carrier_id              IN  VARCHAR2 DEFAULT '180260',
                                     i_brand                   IN  VARCHAR2 DEFAULT 'WFM',
                                     i_min                     IN  VARCHAR2,
                                     i_sim                     IN  VARCHAR2 DEFAULT NULL,
                                     i_esn                     IN  VARCHAR2 DEFAULT NULL,
                                     i_customer_status         IN  VARCHAR2 DEFAULT NULL,
                                     i_phone_part_inst_status  IN  VARCHAR2 DEFAULT '160',
                                     i_line_part_inst_status   IN  VARCHAR2 DEFAULT '120',
                                     i_sim_status              IN  VARCHAR2 DEFAULT '180',
                                     i_site_part_status        IN  VARCHAR2 DEFAULT 'NotMigrated',
                                     i_source_system           IN  VARCHAR2 DEFAULT 'BATCH',
                                     i_user                    IN  VARCHAR2 DEFAULT 'OPERATIONS' ) AS
  -- get transactions (limit the rows to be retrieved)
  CURSOR c_get_data IS
    SELECT *
    FROM   (SELECT *
            FROM   x_wfm_acct_migration_bill_stg
            WHERE  migration_status = 'READYTOMIGRATE'  --need to verify this
	    AND    min              = i_min )
    WHERE  ROWNUM <= i_max_rows_limit;



  -- temporary record to hold required attributes
 -- TYPE dataList IS TABLE OF x_wfm_acct_migration_bill_stg%ROWTYPE;

  -- based on record above
  --  TYPE dataList IS TABLE OF data_record;

  -- table to hold array of data
  data                      billdateextract_tbl;

  --
  pi                        part_inst_type := part_inst_type ();
  sp                        site_part_type := site_part_type ();
  ph                        pi_hist_type := pi_hist_type ();
  wu                        web_user_type := web_user_type ();
  cpi                       contact_part_inst_type := contact_part_inst_type ();
  spsp                      service_plan_site_part_type := service_plan_site_part_type ();
  sph                       service_plan_hist_type := service_plan_hist_type ();
  ctt                       code_table_type := code_table_type ();
  pi_phone                  part_inst_type := part_inst_type ();
  pi_line                   part_inst_type := part_inst_type ();


  --
  n_count_rows              NUMBER := 0;
  n_failed_rows             NUMBER := 0;
  n_check                   NUMBER := 0;



  c_line_o_carrier_id       VARCHAR2 (50);
  c_line_o_carrier_name     VARCHAR2 (50);
  c_line_o_result           NUMBER;
  c_line_o_msg              VARCHAR2 (500);

  c_contact_o_err_code      VARCHAR2 (100);
  c_contact_o_err_msg       VARCHAR2 (500);
  c_contact_o_objid         NUMBER;
  n_bus_org_objid           NUMBER;
  c_brand                   VARCHAR2 (30) := 'WFM';
  c_response                VARCHAR2 (1000);
  c_sim_status              VARCHAR2 (100);
  n_inv_bin_objid           NUMBER;
  c_autorefill_flag         VARCHAR2 (1);
  c_old_esn                 VARCHAR2 (30);
  c_old_sim                 VARCHAR2 (30);
  c_city                    VARCHAR2 (30);
  c_state                   VARCHAR2 (10);


  c_cc_objid                NUMBER;
  c_cc_errno                VARCHAR2 (100);
  c_cc_errstr               VARCHAR2 (500);
  c_ban                     NUMBER :=0;
  c_web_contact_objid       NUMBER :=0;
  --c_web_user_objid          NUMBER ;

  l_return                  NUMBER;
  l_group_return            NUMBER;
  l_service_plan_id         NUMBER;
  l_account_group_uid       VARCHAR2 (200);
  l_account_group_id        NUMBER;
  l_subscriber_uid          VARCHAR2 (200);
  l_group_err_code          NUMBER;
  l_group_err_msg           VARCHAR2 (200);

  n_user_objid             NUMBER;
  n_web_user_objid         NUMBER;
 c_migration_respone     VARCHAR2 (4000);


BEGIN
  -- set global variable to avoid unwanted trigger executions
  sa.globals_pkg.g_run_my_trigger := FALSE;

  --
  BEGIN
    SELECT objid
    INTO   n_bus_org_objid
    FROM   table_bus_org
    WHERE  org_id = i_brand;
  EXCEPTION
    WHEN OTHERS THEN
      n_bus_org_objid := NULL;                   --need to update value here
  END;


  BEGIN
    SELECT objid
    INTO   n_user_objid
    FROM   table_user
    WHERE  s_login_name = 'SA';
  EXCEPTION
    WHEN OTHERS THEN
      n_user_objid := NULL;                      --need to update value here
  END;


    OPEN c_get_data;

    -- start loop
    LOOP
      -- fetch cursor data into pcrf collection (limit collection to i_bulk_collection_limit rows at a time)
      FETCH c_get_data
      BULK COLLECT INTO data LIMIT i_bulk_collection_limit;
      -- c_data


       migration_pkg.load_wfm_final_migration ( o_response                => o_response,
                                             --i_max_rows_limit          => NUMBER DEFAULT 50000,
                                             --i_commit_every_rows       => NUMBER DEFAULT 5000,
                                             --i_bulk_collection_limit   => NUMBER DEFAULT 200,
                                             --i_carrier_id              => VARCHAR2 DEFAULT '180260',
                                             --i_brand                   => VARCHAR2 DEFAULT 'WFM',
                                              i_min                       => i_min,
                                              i_sim                       => i_sim,
                                              i_esn                       => i_esn,
                                              i_customer_status           => i_customer_status,
                                              i_billdateextract_tbl       => data
					      );
                                             -- i_phone_part_inst_status    => i_phone_part_inst_status,
                                             -- i_phone_part_inst_status    => i_phone_part_inst_status,
                                             -- i_sim_status                => l_sim_status_code,
                                             -- i_site_part_status          => l_site_part_status
                                             --i_source_system           => VARCHAR2 DEFAULT 'BATCH',
                                             --i_user                    => VARCHAR2 DEFAULT 'OPERATIONS'
                                            -- ) ;

      --
      EXIT WHEN c_get_data%NOTFOUND;
    --
    END LOOP;

    CLOSE c_get_data;


  --
--  DBMS_OUTPUT.PUT_LINE (n_count_rows || ' rows processed');
  --
 -- DBMS_OUTPUT.PUT_LINE (n_failed_rows || ' rows failed');


  -- Save changes
  COMMIT;

  -- Set response
  /*o_response :=  CASE
                  WHEN c_response IS NULL THEN 'SUCCESS'
                  ELSE c_response
                END;*/
--
--
EXCEPTION
  WHEN OTHERS THEN
    --
    o_response := 'ERROR IN LOAD_WFM_FINAL_MIGRATION: ' || SQLERRM;

    -- possibly log in the error table
    -- sa.util_pkg.log_error
    --
    RAISE;
END load_wfm_final_migration;

-- Overloaded procedure with typ as input
PROCEDURE load_wfm_final_migration ( o_response                OUT VARCHAR2,
                                     i_max_rows_limit          IN  NUMBER DEFAULT 10000,
                                     i_commit_every_rows       IN  NUMBER DEFAULT 5000,
                                     i_bulk_collection_limit   IN  NUMBER DEFAULT 1000,
                                     i_carrier_id              IN  VARCHAR2 DEFAULT '180260',
                                     i_brand                   IN  VARCHAR2 DEFAULT 'WFM',
                                     i_min                     IN  VARCHAR2,
                                     i_sim                     IN  VARCHAR2 DEFAULT NULL,
                                     i_esn                     IN  VARCHAR2 DEFAULT NULL,
                                     i_customer_status         IN  VARCHAR2 DEFAULT NULL,
                                     i_billdateextract_tbl     IN  billdateextract_tbl	,
                                     i_phone_part_inst_status  IN  VARCHAR2 DEFAULT '160',
                                     i_line_part_inst_status   IN  VARCHAR2 DEFAULT '120',
                                     i_sim_status              IN  VARCHAR2 DEFAULT '180',
                                     i_site_part_status        IN  VARCHAR2 DEFAULT 'NotMigrated',
                                     i_source_system           IN  VARCHAR2 DEFAULT 'BATCH',
                                     i_user                    IN  VARCHAR2 DEFAULT 'OPERATIONS' ) AS
  -- get transactions (limit the rows to be retrieved)
 /* CURSOR c_get_data IS
    SELECT *
    FROM   (SELECT *
            FROM   x_wfm_acct_migration_bill_stg
            WHERE  migration_status = 'READYTOMIGRATE'  --need to verify this
	    AND    min              = i_min )
    WHERE  ROWNUM <= i_max_rows_limit;*/



  -- temporary record to hold required attributes
  --TYPE dataList IS TABLE OF c_get_data%ROWTYPE;

  -- based on record above
  --  TYPE dataList IS TABLE OF data_record;

  -- table to hold array of data
  data                      billdateextract_tbl;

  --
  pi                        part_inst_type := part_inst_type ();
  sp                        site_part_type := site_part_type ();
  ph                        pi_hist_type := pi_hist_type ();
  wu                        web_user_type := web_user_type ();
  cpi                       contact_part_inst_type := contact_part_inst_type ();
  spsp                      service_plan_site_part_type := service_plan_site_part_type ();
  sph                       service_plan_hist_type := service_plan_hist_type ();
  ctt                       code_table_type := code_table_type ();
  pi_phone                  part_inst_type := part_inst_type ();
  pi_line                   part_inst_type := part_inst_type ();


  --
  n_count_rows              NUMBER := 0;
  n_failed_rows             NUMBER := 0;
  n_check                   NUMBER := 0;



  c_line_o_carrier_id       VARCHAR2 (50);
  c_line_o_carrier_name     VARCHAR2 (50);
  c_line_o_result           NUMBER;
  c_line_o_msg              VARCHAR2 (500);

  c_contact_o_err_code      VARCHAR2 (100);
  c_contact_o_err_msg       VARCHAR2 (500);
  c_contact_o_objid         NUMBER;
  n_bus_org_objid           NUMBER;
  c_brand                   VARCHAR2 (30) := 'WFM';
  c_response                VARCHAR2 (1000);
  c_sim_status              VARCHAR2 (100);
  n_inv_bin_objid           NUMBER;
  c_autorefill_flag         VARCHAR2 (1);
  c_old_esn                 VARCHAR2 (30);
  c_old_sim                 VARCHAR2 (30);
  c_city                    VARCHAR2 (30);
  c_state                   VARCHAR2 (10);

  c_sysdate                 DATE; --DEFAULT SYSDATE;
  c_step                    VARCHAR2(1000);

  c_ban                     NUMBER :=0;
  c_web_contact_objid       NUMBER :=0;
  --c_web_user_objid          NUMBER ;

  c_cleanup_respone         VARCHAR2(1000);

  l_return                  NUMBER;
  l_group_return            NUMBER;
  l_service_plan_id         NUMBER;
  l_account_group_uid       VARCHAR2 (200);
  l_account_group_id        NUMBER;
  l_subscriber_uid          VARCHAR2 (200);
  l_group_err_code          NUMBER;
  l_group_err_msg           VARCHAR2 (200);

  n_user_objid             NUMBER;
  n_web_user_objid         NUMBER;
  n_old_web_user_objid     NUMBER;
  n_pah_web_user_objid     NUMBER;



BEGIN
  -- set global variable to avoid unwanted trigger executions
  sa.globals_pkg.g_run_my_trigger := FALSE;

  --
  BEGIN
    SELECT objid
    INTO   n_bus_org_objid
    FROM   table_bus_org
    WHERE  org_id = i_brand;
  EXCEPTION
    WHEN OTHERS THEN
      n_bus_org_objid := NULL;                   --need to update value here
  END;


  /*BEGIN
    SELECT objid
    INTO   n_user_objid
    FROM   table_user
    WHERE  UPPER (login_name) = 'SA';
  EXCEPTION
    WHEN OTHERS THEN
      n_user_objid := NULL;                      --need to update value here
  END;*/

   n_user_objid := 268435556;  --assign directly to avoid unnecessary repeated call to table_user


   --OPEN c_get_data;

    -- start loop
   -- LOOP
      -- fetch cursor data into pcrf collection (limit collection to i_bulk_collection_limit rows at a time)
     -- FETCH c_get_data
     -- BULK COLLECT INTO data LIMIT i_bulk_collection_limit;

      data := i_billdateextract_tbl;

      -- loop through migration  collection
      FOR i IN 1 .. data.COUNT LOOP
        -- reset response as null for reuse
        o_response            := NULL;
        c_response            := NULL;
        c_line_o_carrier_name := NULL;
        c_line_o_result       := NULL;
        c_line_o_msg          := NULL;
        c_contact_o_objid     := 0;
        c_sim_status          := NULL;
          -- n_inv_bin_objid         := NULL;
        c_autorefill_flag     := NULL;
        c_old_esn             := NULL;
	c_old_sim             := NULL;
        c_city                := NULL;
        c_state               := NULL;
	--c_ban               := 0;
	c_web_contact_objid   := NULL;
	c_cleanup_respone     := NULL;
	c_step                := NULL;

        l_account_group_uid   := NULL;
        l_account_group_id    := NULL;
        l_subscriber_uid      := NULL;
        l_group_err_code      := NULL;
        l_group_err_msg       := NULL;


        n_web_user_objid      := NULL;
	n_old_web_user_objid  := NULL;
	n_pah_web_user_objid  := NULL;

	c_sysdate             := SYSDATE;

        -- initialize type attributes to null
        pi   := part_inst_type ();
        sp   := site_part_type ();
        ph   := pi_hist_type ();
        wu   := web_user_type ();
        cpi  := contact_part_inst_type ();
        spsp := service_plan_site_part_type ();
        sph  := service_plan_hist_type ();



        -- ps_rec := typ_pymt_src_dtls_rec();

        BEGIN -- Loop Exception

	--Code block to skip pre migration when there is no change in sim /esn/customer status
	/*IF (i_esn IS NOT NULL AND data(i).esn = i_esn) AND (i_sim IS NOT NULL  AND  data(i).sim = i_sim) THEN --no change in esn and sim


	   IF i_customer_status IS NOT NULL AND data(i).customer_status <> i_customer_status THEN

             UPDATE x_wfm_acct_migration_stg
             SET    migration_response = migration_response||'Customer Status updated',
		    customer_status    = i_customer_status
             WHERE  objid = data (i).objid;


	   END IF;
	  dbms_output.put_line ('Returning '||'STG ESN '||data(i).esn||'STG MIN '||data(i).min||'STG SIM '||data(i).sim);

	   EXIT;  --no need to do anything exit the loop

	END IF;*/

	--query to get existing esn/sim from site part
	  BEGIN
	    SELECT  /*+ index(table_site_part, x_x_min) */
	    x_service_id,
	    x_iccid
	    INTO c_old_esn,
	         c_old_sim
	    FROM table_site_part
	    WHERE x_min      = data(i).min
	    AND  part_status = 'NotMigrated';

	  EXCEPTION
	    WHEN OTHERS THEN
	    c_old_esn := NULL;
	    c_old_sim := NULL;

	  END;

	  --get existing web user objid
	  BEGIN
	   SELECT
	   weu.objid INTO n_old_web_user_objid
	   FROM table_web_user weu,
	        table_x_contact_part_inst cpi,
	        table_part_inst pi
           WHERE pi.part_serial_no                 = data(i).esn --current esn
           AND cpi.x_contact_part_inst2part_inst   =  pi.objid
           AND cpi.x_contact_part_inst2contact	   = weu.web_user2contact
	   AND weu.web_user2bus_org                = n_bus_org_objid;

	  EXCEPTION
           WHEN NO_DATA_FOUND THEN

            BEGIN
               SELECT
	         weu.objid INTO n_old_web_user_objid
	       FROM table_web_user weu
               WHERE s_login_name          = UPPER(data(i).email)
               AND weu.web_user2bus_org    = n_bus_org_objid;
            EXCEPTION
               WHEN OTHERS THEN
                 n_old_web_user_objid  := NULL;
             END;

           WHEN OTHERS THEN
              n_old_web_user_objid  := NULL;
           END;

          IF data(i).esn <> c_old_esn  AND c_old_esn IS NOT NULL THEN  --IF the esn is not matching to billextract ESN  then

           -- c_old_esn   := data(i).esn;
           -- data(i).esn := i_esn;
           IF n_old_web_user_objid IS  NULL THEN
	         BEGIN

	          SELECT
	          weu.objid INTO n_old_web_user_objid
	          FROM table_web_user weu,
	               table_x_contact_part_inst cpi,
	     	       table_part_inst pi
                  WHERE pi.part_serial_no                       = c_old_esn
                       AND cpi.x_contact_part_inst2part_inst    =  pi.objid
                       AND cpi.x_contact_part_inst2contact	= weu.web_user2contact
	     	       AND weu.web_user2bus_org                 = n_bus_org_objid;
	          EXCEPTION
                    WHEN OTHERS THEN
                      n_old_web_user_objid  := NULL;
                  END;

            END IF;

	    --update the old ESN to past due in case if billextract/async sends a different ESN

            UPDATE table_part_inst
            SET    x_part_inst_status = '54',
            status2x_code_table       = (select objid from table_x_code_table where x_code_number = '54'),
            x_part_inst2site_part     = NULL,
            x_part_inst2contact       = NULL,
            part_inst2inv_bin         = NULL ,
	    x_iccid                   = NULL
            WHERE part_serial_no = c_old_esn
            AND   x_domain       ='PHONES';

	    DELETE from table_x_contact_part_inst
	    WHERE x_contact_part_inst2part_inst = (SELECT objid from table_part_inst WHERE part_serial_no = c_old_esn
                                                   AND   x_domain       ='PHONES') ;  --remove the my account association for the old ESN



          END IF;

          IF data(i).sim <> c_old_sim AND c_old_sim IS NOT NULL THEN  --IF the sim is not matching to billextract SIM then
	   -- c_old_sim   := data(i).sim;
	   -- data(i).sim := i_sim;


	   --update the old SIM  to SIM Reserved  in case if billextract/async  sends a different SIM
	    UPDATE table_x_sim_inv
            SET x_sim_inv_status       = '250',
            x_sim_status2x_code_table = (select objid from table_x_code_table where x_code_number = '250')
            WHERE x_sim_serial_no  = c_old_sim  ;



	  END IF;

	  IF data(i).migration_status = 'FINAL_MIGRATION_FAILED' THEN

           cleanup_wfm_migration( i_esn               =>  data(i).esn,
	                          i_min               =>  data(i).min,
                                  i_sim               =>  data(i).sim,
                                  i_migration_status  =>  data(i).migration_status ,
                                  i_migration_type    =>  'FINAL_MIGRATION_ASYNC',
                                  o_response          =>  c_cleanup_respone);

	  dbms_output.put_line ('Cleanup Respone  '||	c_cleanup_respone);

	  END IF;



          c_step := 'Get Part Inst Record';

          pi := part_inst_type (i_esn => data (i).esn);



          IF pi.response NOT LIKE '%SUCCESS%' THEN
            c_response := c_response || '|' || 'Part Inst Err :' || pi.response;

            UPDATE x_wfm_acct_migration_bill_stg
            SET    migration_status = 'FINAL_MIGRATION_FAILED',
                   migration_response = c_response,
		   update_timestamp   = c_sysdate
            WHERE  objid = data (i).objid;

            CONTINUE;                              --continue next iteration
          END IF;

	  IF pi.part_inst2contact IS NOT NULL THEN
           c_contact_o_objid := pi.part_inst2contact; --assign contact
	  END IF;

          DBMS_OUTPUT.put_line ('part inst response ' || pi.response);


          --
          BEGIN
            SELECT x_city,
                   x_state
            INTO   c_city,
                   c_state
            FROM   table_x_zip_code
            WHERE  x_zip = data (i).zipcode;
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;


          IF c_contact_o_objid  = 0  THEN
            -- create contact related information
	    c_step := 'Create Contact';

            sa.contact_pkg.createcontact_prc ( p_esn                => data (i).esn,
                                               p_first_name         => data (i).first_name,
                                               p_last_name          => data (i).last_name,
                                               p_middle_name        => NULL,
                                               p_phone              => data (i).MIN || ' ', --added a space to force new contact creation for WFM
                                               p_add1               => data (i).address_1,
                                               p_add2               => data (i).address_2,
                                               p_fax                => NULL,
                                               p_city               => NVL (c_city,data (i).city),
                                               p_st                 => NVL (c_state,data (i).state),
                                               p_zip                => data (i).zipcode,
                                               p_email              => data (i).email,
                                               p_email_status       => NULL,
                                               p_roadside_status    => NULL,
                                               p_no_name_flag       => NULL,
                                               p_no_phone_flag      => NULL,
                                               p_no_address_flag    => NULL,
                                               p_sourcesystem       => i_source_system,
                                               p_brand_name         => data (i).bus_org_id,
                                               p_do_not_email       => data (i).do_not_mail_flag,
                                               p_do_not_phone       => data (i).do_not_phone_flag,
                                               p_do_not_mail        => data (i).do_not_mail_flag,
                                               p_do_not_sms         => data (i).do_not_sms_flag,
                                               p_ssn                => NULL,
                                               p_dob                => data (i).date_of_birth,
                                               p_do_not_mobile_ads  => NULL,
                                               p_contact_objid      => c_contact_o_objid,
                                               p_err_code           => c_contact_o_err_code,
                                               p_err_msg            => c_contact_o_err_msg);

            IF c_contact_o_err_code <> '0' AND c_contact_o_err_msg <> 'Contact Created Successfully' THEN
              c_response := c_response || '|' || 'Contact Err :' || c_contact_o_err_msg;
            END IF;

           --Remove space added in phone before
            update_contact_phone (i_contact_objid => c_contact_o_objid,
                                  i_phone         => data (i).MIN,
                                  o_response      => c_contact_o_err_msg );
          ELSE

	    c_step := 'Update Contact';

            sa.contact_pkg.updatecontact_prc ( i_esn                => data (i).esn,
                                               i_first_name         => data (i).first_name,
                                               i_last_name          => data (i).last_name,
                                               i_middle_name        => NULL,
                                               i_phone              => data (i).MIN,
                                               i_add1               => data (i).address_1,
                                               i_add2               => data (i).address_2,
                                               i_fax                => NULL,
                                               i_city               => NVL (c_city,data (i).city),
                                               i_st                 => NVL (c_state,data (i).state),
                                               i_zip                => data (i).zipcode,
                                               i_email              => data (i).email,
                                               i_email_status       => NULL,
                                               i_roadside_status    => NULL,
                                               i_no_name_flag       => NULL,
                                               i_no_phone_flag      => NULL,
                                               i_no_address_flag    => NULL,
                                               i_sourcesystem       => i_source_system,
                                               i_brand_name         => data (i).bus_org_id,
                                               i_do_not_email       => data (i).do_not_mail_flag,
                                               i_do_not_phone       => data (i).do_not_phone_flag,
                                               i_do_not_mail        => data (i).do_not_mail_flag,
                                               i_do_not_sms         => data (i).do_not_sms_flag,
                                               i_ssn                => NULL,
                                               i_dob                => data (i).date_of_birth,
                                               i_do_not_mobile_ads  => NULL,
                                               i_contact_objid      => c_contact_o_objid,
                                               o_err_code           => c_contact_o_err_code,
                                               o_err_msg            => c_contact_o_err_msg);

            -- ??? based on update procedure output.
            IF c_contact_o_err_code <> '0' AND c_contact_o_err_msg <> 'Success' THEN
              c_response := c_response || '|' || 'Update Contact Err :' || c_contact_o_err_msg;
            END IF;
          END IF;

          DBMS_OUTPUT.put_line ( 'contact ' || c_contact_o_err_code || '-' || c_contact_o_err_msg);
          DBMS_OUTPUT.put_line ('contact objid ' || c_contact_o_objid);

          --
          IF c_contact_o_objid IS NOT NULL THEN -- update language pref
            UPDATE table_x_contact_add_info
            SET    x_lang_pref = CASE
                                   WHEN data (i).language = 'EN' THEN 'EN'
                                   WHEN data (i).language = 'SP' THEN 'ES'
                                   ELSE 'EN'
                                 END,
                   x_pin       = data(i).security_pin
            WHERE  add_info2contact = c_contact_o_objid;
          END IF;

          BEGIN
            SELECT contact_role2site
            INTO   sp.site_objid
            FROM   table_contact_role
            WHERE  1 = 1
            AND    contact_role2contact = c_contact_o_objid;
          EXCEPTION
            WHEN OTHERS  THEN
              sp.site_objid := NULL;
          END;


          --site part attribute assignment

         -- ctt := code_table_type ( i_code_number => data(i).customer_status );

          c_step := 'Create Table Site Part';

          sp.instance_name      := 'Wireless';
          sp.serial_no          := data (i).esn;
          sp.service_id         := data (i).esn;
          sp.iccid              := data (i).sim;
          sp.install_date       := TRUNC(NVL(data(i).activation_date, c_sysdate));
          sp.warranty_date      := data(i).expiration_date;

          sp.expire_dt          := data(i).expiration_date;
          sp.actual_expire_dt   := NULL;
          sp.state_code         := 0;
          sp.state_value        := 'GSM';
          sp.part_status        := i_site_part_status;
          --sp.site_objid         := null ;-- need to derive
          sp.dir_site_objid     := sp.site_objid;               --need to derive
          sp.all_site_part2site := sp.site_objid;
          sp.site_part2site     := sp.site_objid;
          sp.service_end_dt     := NULL;                        --need to derive
          sp.MIN                := data (i).MIN;
          sp.msid               := data (i).MIN;
          sp.update_stamp       := c_sysdate;
          sp.site_part2part_info:= pi.n_part_inst2part_mod; --need to derive
          sp.zipcode            := data (i).zipcode;
          --site_part end


           DBMS_OUTPUT.put_line ('site part status  ' || i_site_part_status);
          ins_site_part ( i_site_part_type => sp,
                          o_response       => o_response);

          IF sp.response NOT LIKE '%SUCCESS%' THEN
            c_response := c_response || '|' || 'Site Part Err :' || sp.response;
          END IF;

          DBMS_OUTPUT.put_line ('site part response ' || sp.response);


          ctt := code_table_type ();

          ctt := code_table_type (i_code_number => i_phone_part_inst_status);

          /* BEGIN
             SELECT x_tf_dealer
             INTO n_inv_bin_objid
             FROM x_gsm_dealer_mapping
             WHERE x_source ='GOSMART'
             AND   x_source_dealer = data(i).dealer_id ;
           EXCEPTION
             WHEN OTHERS THEN
               n_inv_bin_objid := NULL;
           END ;        */

          -- update ESN status
          UPDATE table_part_inst
          SET    x_part_inst_status    = i_phone_part_inst_status,
                 status2x_code_table   = ctt.code_table_objid,
                 x_part_inst2site_part = sp.site_part_objid,
                 x_part_inst2contact   = c_contact_o_objid,
                 part_inst2inv_bin     = data (i).dealer_inv_objid ,
                 x_iccid               = data (i).sim  , --sim marriage
                 warr_end_date         = data(i).expiration_date
          WHERE  part_serial_no        = data (i).esn;

          -- c_sim_status:='253' ;

          ctt := code_table_type (); -- reinitialize for sim

          ctt := code_table_type ( i_code_number => i_sim_status );

          -- need to check this
          -- update sim status
           UPDATE table_x_sim_inv
             SET  x_sim_inv_status          = i_sim_status ,
                  x_sim_status2x_code_table = ctt.code_table_objid
             WHERE x_sim_serial_no = data(i).sim;


          /* ins_part_inst ( i_part_inst_type => pi         ,
                           o_response       => o_response );   */

          -- need to delete line if it already exists
          DELETE FROM table_part_inst
          WHERE  part_serial_no = data (i).MIN
          AND    x_domain = 'LINES';

          --create line
          IF NOT npanxx_exist (i_min         => data (i).MIN,
                               i_npa         => SUBSTR (data (i).MIN, 1, 3),
                               i_nxx         => SUBSTR (data (i).MIN, 4, 3),
                               i_carrier_id  => i_carrier_id,
                               i_zip         => data (i).zipcode)
          THEN
            insert_npanxx (i_min         => data(i).MIN,
                           i_carrier_id  => i_carrier_id,
                           i_zip         => data (i).zipcode);
          END IF;

          c_step := 'Create Line';

          toppapp.line_insert_pkg.line_validation ( ip_msid          => data(i).MIN,
                                                    ip_min           => data(i).MIN,
                                                    ip_carrier_id    => i_carrier_id,
                                                    ip_file_name     => 'WFM MOBILE',
                                                    ip_file_type     => '1',
                                                    ip_expire_date   => 'NA',
                                                    op_carrier_id    => c_line_o_carrier_id,
                                                    op_carrier_name  => c_line_o_carrier_name,
                                                    op_result        => c_line_o_result,
                                                    op_msg           => c_line_o_msg);

          DBMS_OUTPUT.put_line ('Line creation  result  ' || c_line_o_result);
          DBMS_OUTPUT.put_line ('Line creation  message ' || c_line_o_msg);

          IF c_line_o_result <> 1 THEN
            c_response := c_response || '|' || 'Line Insert Err :' || c_line_o_msg;
          END IF;

          ctt := code_table_type (); -- again reinitialize for line
          --
          ctt := code_table_type ( i_code_number => i_line_part_inst_status );

          --link the line to ESN
          UPDATE table_part_inst
          SET    part_to_esn2part_inst = pi.part_inst_objid,
                 x_part_inst_status    = i_line_part_inst_status,
                 status2x_code_table   = ctt.code_table_objid
          WHERE  part_serial_no = data (i).MIN
          AND    x_domain = 'LINES';


	  --delink any other existing line  and update line status to returned min change scenario
          UPDATE table_part_inst
          SET    part_to_esn2part_inst = NULL,
                 x_part_inst_status    = '17' ,
                 status2x_code_table   = (select objid from table_x_code_table where x_code_number ='17')
          WHERE  part_to_esn2part_inst = pi.part_inst_objid
          AND    x_domain = 'LINES'
          AND    part_serial_no <> data (i).MIN;




          -- x_service_plan_site_part
          c_step := 'Create Service Plan Site Part';

          spsp.service_plan_site_part_objid := sp.site_part_objid;
          spsp.service_plan_id              := data(i).service_plan;
          spsp.switch_base_rate             := 0; -- need to check this value for simple mobile
          spsp.new_service_plan_id          := NULL;
          spsp.last_modified_date           := c_sysdate;

          IF spsp.service_plan_id IS NOT NULL THEN
            ins_service_plan_site_part ( i_service_plan_site_part_type  => spsp,
                                         o_response                     => o_response);
            DBMS_OUTPUT.put_line ( 'service plan site part response   ' || spsp.response);

            IF spsp.response NOT LIKE '%SUCCESS%' THEN
              c_response := c_response || '|' || 'Service Plan SP Err :' || spsp.response;

            ELSE

              --insert x_xervice_plan_hist
	      c_step := 'Create Service Plan Site Part hist';

              sph.plan_hist2site_part_objid := sp.site_part_objid;
              sph.start_date                := c_sysdate;
              sph.plan_hist2service_plan    := spsp.service_plan_id;
              sph.insert_date               := c_sysdate;
              sph.last_modified_date        := c_sysdate;

              ins_service_plan_hist (i_service_plan_hist_type  => sph,
                                     o_response                => o_response);

              DBMS_OUTPUT.put_line ('service plan hist   ' || sph.response);

            --insert x_xervice_plan_hist
              IF sph.response NOT LIKE '%SUCCESS%' THEN
                c_response := c_response || '|' || 'Service Plan H Err :' || sph.response;
              END IF;

            END IF;

          ELSE
            c_response := c_response || '|' || 'Service Plan Not Found';
          END IF;

        IF  data(i).pah_indicator ='Y' AND data(i).email  IS NOT NULL THEN --create account only  for PAH
          -- Check whether WEB contact is created already
	  c_web_contact_objid := NULL; --resetting to null






          BEGIN

	    IF n_old_web_user_objid  IS NOT NULL THEN 	 -- IF old web user exists then go by that web user id

             SELECT  web_user2contact
             INTO    c_web_contact_objid
             FROM    table_web_user
             WHERE   objid                = n_old_web_user_objid
             AND     web_user2bus_org     = n_bus_org_objid;

	   ELSE

            SELECT  web_user2contact
            INTO    c_web_contact_objid
            FROM    table_web_user
            WHERE   s_login_name         = UPPER (data(i).email)
            AND     web_user2bus_org     = n_bus_org_objid;

	    END IF;

          EXCEPTION
	    WHEN   OTHERS THEN
              c_web_contact_objid :=  0;
          END;

          IF NVL(c_web_contact_objid,0) = 0
          THEN
            -- create contact that doesn not associate to any ESN, specifially to link WEB USER

	    c_step := 'Create Web Contact';

            contact_pkg.createcontact_prc (  p_esn                => '',
                                             p_first_name         => data (i).first_name,
                                             p_last_name          => data (i).last_name,
                                             p_middle_name        => NULL,
                                             p_phone              => '',
                                             p_add1               => data (i).address_1,
                                             p_add2               => data (i).address_2,
                                             p_fax                => NULL,
                                             p_city               => NVL (c_city,data(i).city),
                                             p_st                 => NVL (c_state,data(i).state),
                                             p_zip                => data (i).zipcode,
                                             p_email              => data (i).email,
                                             p_email_status       => NULL,
                                             p_roadside_status    => NULL,
                                             p_no_name_flag       => NULL,
                                             p_no_phone_flag      => NULL,
                                             p_no_address_flag    => NULL,
                                             p_sourcesystem       => i_source_system,
                                             p_brand_name         => data (i).bus_org_id,
                                             p_do_not_email       => data (i).do_not_mail_flag,
                                             p_do_not_phone       => data (i).do_not_phone_flag,
                                             p_do_not_mail        => data (i).do_not_mail_flag,
                                             p_do_not_sms         => data (i).do_not_sms_flag,
                                             p_ssn                => NULL,
                                             p_dob                => data (i).date_of_birth,
                                             p_do_not_mobile_ads  => NULL,
                                             p_contact_objid      => c_web_contact_objid,
                                             p_err_code           => c_contact_o_err_code,
                                             p_err_msg            => c_contact_o_err_msg);
          ELSE

           c_step := 'Update Web Contact';

	   contact_pkg.updatecontact_prc (   i_esn                => NULL ,
                                             i_first_name         => data (i).first_name,
                                             i_last_name          => data (i).last_name,
                                             i_middle_name        => NULL,
                                             i_phone              => '',
                                             i_add1               => data (i).address_1,
                                             i_add2               => data (i).address_2,
                                             i_fax                => NULL,
                                             i_city               => NVL (c_city,data (i).city),
                                             i_st                 => NVL (c_state,data (i).state),
                                             i_zip                => data (i).zipcode,
                                             i_email              => data (i).email,
                                             i_email_status       => NULL,
                                             i_roadside_status    => NULL,
                                             i_no_name_flag       => NULL,
                                             i_no_phone_flag      => NULL,
                                             i_no_address_flag    => NULL,
                                             i_sourcesystem       => i_source_system,
                                             i_brand_name         => data (i).bus_org_id,
                                             i_do_not_email       => data (i).do_not_mail_flag,
                                             i_do_not_phone       => data (i).do_not_phone_flag,
                                             i_do_not_mail        => data (i).do_not_mail_flag,
                                             i_do_not_sms         => data (i).do_not_sms_flag,
                                             i_ssn                => NULL,
                                             i_dob                => data (i).date_of_birth,
                                             i_do_not_mobile_ads  => NULL,
                                             i_contact_objid      => c_web_contact_objid,
                                             o_err_code           => c_contact_o_err_code,
                                             o_err_msg            => c_contact_o_err_msg);
          END IF;
          --
          IF c_contact_o_err_code <> '0' AND c_contact_o_err_msg <> 'Contact Created Successfully'
          THEN
            c_response := c_response || '|' || 'Create BAN Contact Err :' || c_contact_o_err_msg;
          ELSE

	      --CR49721 update account level security pin

            UPDATE table_x_contact_add_info
            SET    x_lang_pref = CASE
                                   WHEN data (i).language = 'EN' THEN 'EN'
                                   WHEN data (i).language = 'SP' THEN 'ES'
                                   ELSE 'EN'
                                 END,
                   x_pin       = data(i).security_pin
            WHERE  add_info2contact = c_web_contact_objid;

            c_step := 'Create Web user';

            IF n_old_web_user_objid  IS NOT NULL  THEN  --assigning the old web user so that it updates login information against old web user objid
               wu.web_user_objid := n_old_web_user_objid   ;
            END IF;

            wu.login_name           := data(i).email;
            wu.s_login_name         := UPPER (data(i).email);
            wu.password             := data(i).login_password;
            wu.user_key             := NULL;
            wu.status               := 1;                                  --need to confirm
            wu.passwd_chg           := NULL;
            wu.dev                  := NULL;
            wu.ship_via             := NULL;
            wu.secret_questn        := data(i).secret_question;
            wu.s_secret_questn      := UPPER(data(i).secret_question);
            wu.secret_ans           := data(i).secret_answer;
            wu.s_secret_ans         := UPPER(data(i).secret_answer);
            wu.web_user2user        := NULL;
            wu.web_user2contact     := c_web_contact_objid;
            wu.web_user2lead        := NULL;
            wu.web_user2bus_org     := n_bus_org_objid;
            wu.last_update_date     := c_sysdate;
            wu.validated            := NULL;             --need to confirm value
            wu.validated_counter    := NULL;              --need to confirm value
            wu.named_userid         := NULL;
            wu.insert_timestamp     := c_sysdate;


            ins_web_user ( i_web_user_type => wu,
                           o_response      => o_response);

            IF wu.response NOT LIKE '%SUCCESS%' THEN
              c_response := c_response || '|' || 'Web User Err :' || wu.response;
            END IF;

           -- c_web_contact_objid      := wu.web_user2contact;  --Insert the same web user contact for all the members in the BAN


            DBMS_OUTPUT.put_line ('web user response   ' || wu.response);
          END IF;
        END IF;



	 --query to get ban contact objid
	 BEGIN

	  SELECT
          wbu.web_user2contact INTO c_web_contact_objid
          FROM
          x_wfm_acct_migration_bill_stg stg,
          table_web_user wbu
          WHERE stg.ban             = data(i).ban
           AND stg.pah_indicator    = 'Y'
           AND stg.email            = wbu.login_name
           AND wbu.web_user2bus_org = n_bus_org_objid;

	 EXCEPTION
	  WHEN NO_DATA_FOUND  THEN
	        BEGIN
		  --pah min call was delayed by TMO and non pah call comes in ,web user may not exist in below sceanrios
		     -- new activation not received in premigration
		     -- change in email when compared to premigration
		  --call this procedure to create pah web user  or update pah web user if email id changes in async call
                  create_pah_web_user ( i_min               => data(i).min,
                                        o_web_user_objid    => n_pah_web_user_objid,
                                        o_web_contact_objid => c_web_contact_objid,
                                        o_response          => o_response  );

           dbms_output.put_line ('web contact objid after create_pah_web_user'||c_web_contact_objid);

           dbms_output.put_line ('web contact objid response'||o_response);

		  IF o_response NOT LIKE '%SUCCESS%' THEN
                      c_response := c_response || '|' || 'Pah Web User Err :' || o_response;
                  END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    c_response := c_response || '|' || 'Pah Web User Call Err  :' || substr(sqlerrm,1,200);
                END;

	  WHEN OTHERS THEN
             c_web_contact_objid := NULL;
         END ;

         --   Table_x_contact_part_inst

          IF c_web_contact_objid IS NOT NULL THEN


         -- cpi.contact_part_inst2contact   := NVL(c_web_contact_objid,c_contact_o_objid);
	    cpi.contact_part_inst2contact   := c_web_contact_objid;
            cpi.contact_part_inst2part_inst := pi.part_inst_objid;
            cpi.esn_nick_name               := NULL;

	    --set the is_default field based on PAH
            IF  data(i).pah_indicator ='Y' AND data(i).email IS NOT NULL THEN  --assigning is_default for PAH
              cpi.is_default                  := 1;
            ELSE
              cpi.is_default                 := 0;
            END IF;  --need to confirm value	  --need to confirm value

            cpi.transfer_flag               := 0;                    --need to confirm value
            cpi.verified                    := 'Y';                       --need to confirm value
            cpi.response                    := NULL;

            --

            ins_contact_part_inst ( i_contact_part_inst_type => cpi,
                                    o_response               => o_response);

            IF cpi.response NOT LIKE '%SUCCESS%' THEN
              c_response := c_response || '|' || 'Contact PI Err :' || cpi.response;
            END IF;


           DBMS_OUTPUT.put_line ('contact part inst response   ' || cpi.response);
	  ELSE

            c_response := c_response || '|' || 'Web User Not Found  ' ;

	  END IF;

	 --query to get web user objid

	 BEGIN

	  SELECT
          wbu.objid  INTO n_web_user_objid
          FROM  table_x_contact_part_inst cpi,
                table_web_user wbu
          WHERE cpi.x_contact_part_inst2part_inst  = pi.part_inst_objid
          AND   cpi.x_contact_part_inst2contact    = wbu.web_user2contact;

	 EXCEPTION
	  WHEN OTHERS THEN
             n_web_user_objid := NULL;
         END ;


           --*******************************************
           --Group creation in X_ACCOUNT_GROUP_MEMBER.
           --*******************************************
           IF n_web_user_objid IS NOT NULL THEN
             l_group_return := sa.create_member( i_esn               => data(i).esn,
                                                 i_web_user_objid    => n_web_user_objid,
                                                 i_service_plan_id   => data(i).service_plan,
                                                 i_bus_org_objid     => n_bus_org_objid,
                                                 i_group_status      => 'ACTIVE',
                                                 i_member_status     => 'ACTIVE',
                                                 i_force_create_flag => 'N',
                                                 i_retrieve_only_flag=> 'N',
                                                 o_account_group_uid => l_account_group_uid,
                                                 o_account_group_id  => l_account_group_id,
                                                 o_subscriber_uid    => l_subscriber_uid,
                                                 o_err_code          => l_group_err_code,
                                                 o_err_msg           => l_group_err_msg);



              IF l_group_err_code <> '0' THEN
               c_response := c_response || '|' || 'Group creation Err :' || l_group_err_msg;
              END IF;

              UPDATE sa.x_account_group_member
               SET site_part_id       = sp.site_part_objid
               WHERE account_group_id = l_account_group_id;

	   ELSE

             c_response := c_response || '|' || 'Group creation Err Web user not found :' || l_group_err_msg;   --specific error to reprocess

	   END IF;





             -- insert esn pi hist

          -- wrap code to avoid errors and continue process
          BEGIN

           ph := pi_hist_type();  --Insert Pi hist for Phone

           ph.pi_hist_objid             := NULL;
           ph.status_hist2code_table    := pi.status2x_code_table; --Active
           ph.change_date               := c_sysdate;
           ph.change_reason             := 'ACTIVATE';
           ph.creation_date             := pi.creation_date;
           ph.domain                    := pi.domain;
           ph.insert_date               := pi.insert_date;
           ph.part_inst_status          := pi.part_inst_status;
           ph.part_serial_no            := pi.part_serial_no;
           ph.part_status               := 'Active';
           ph.pi_hist2carrier_mkt       := pi.part_inst2carrier_mkt;
           ph.pi_hist2inv_bin           := pi.part_inst2inv_bin;
           ph.pi_hist2part_mod          := pi.n_part_inst2part_mod;
           ph.pi_hist2user              := n_user_objid;                      --'sa'
           ph.warr_end_date             := pi.warr_end_date;
           ph.last_trans_time           := c_sysdate;
           ph.order_number              := pi.order_number;
           ph.pi_hist2site_part         := sp.site_part_objid;
           ph.msid                      := pi.msid;
           ph.pi_hist2contact           := c_contact_o_objid;
           ph.iccid                     := pi.iccid;

           -- insert part inst history of the esn (phone)
           ins_pi_hist ( i_pi_hist_type => ph,
                         o_response     => o_response );

           IF ph.response NOT LIKE '%SUCCESS%' THEN
             c_response := c_response || '|' || 'Create PI Hist (ESN) Err :' || ph.response;
           END IF;


	     -- For LINE entry calling constructor to retrive updated data.
          -- l_step := 'Create PI Hist record (TABLE_X_PI_HIST) - For LINE entry.';
          -- insert line pi hist
           ph := pi_hist_type();

           pi_line := part_inst_type (i_esn => data(i).MIN);

           ph.pi_hist_objid           := NULL;
           ph.status_hist2code_table  := pi_line.status2x_code_table; --Active
           ph.change_date             := c_sysdate;
           ph.change_reason           := 'ACTIVATE';
           ph.creation_date           := pi_line.creation_date;
           ph.domain                  := pi_line.domain;
           ph.insert_date             := pi_line.insert_date;
           ph.part_inst_status        := pi_line.part_inst_status;
           ph.part_serial_no          := pi_line.part_serial_no;
           ph.part_status             := 'Active';
           ph.pi_hist2carrier_mkt     := pi_line.part_inst2carrier_mkt;
           ph.pi_hist2inv_bin         := pi_line.part_inst2inv_bin;
           ph.pi_hist2part_mod        := pi_line.n_part_inst2part_mod;
           ph.pi_hist2user            := n_user_objid; --'sa'
           ph.warr_end_date           := pi_line.warr_end_date;
           ph.last_trans_time         := c_sysdate;
           ph.order_number            := pi_line.order_number;
           ph.pi_hist2site_part       := sp.site_part_objid;
           ph.msid                    := pi_line.msid;
           ph.pi_hist2contact         := c_contact_o_objid;
           ph.iccid                   := pi_line.iccid;

           -- insert part inst history of the line (min)
           ins_pi_hist ( i_pi_hist_type => ph,
                         o_response     => o_response);

           --
           IF ph.response NOT LIKE '%SUCCESS%' THEN
             c_response :=  c_response || '|' || 'Create PI Hist (MIN) Err :' || ph.response;
           END IF;



        EXCEPTION
           WHEN OTHERS THEN
             NULL;
        END;

         /* IF UPPER (c_response) NOT LIKE '%SUCCESS%'
             AND c_response IS NOT NULL
          THEN
            -- increase row count
            n_failed_rows := n_failed_rows + 1;
            -- maybe update the staging table with the failed response message

            -- maybe continue to next iteration row
            -- CONTINUE

          END IF;*/




          --code to update migration status
          UPDATE x_wfm_acct_migration_bill_stg
          SET    migration_status = CASE
                                      WHEN c_response IS NULL THEN 'FINAL_MIGRATION_COMPLETED'
                                      ELSE 'FINAL_MIGRATION_FAILED'
                                    END,
                 migration_response = CASE
                                        WHEN c_response IS NULL THEN 'SUCCESS'
                                        ELSE c_response
                                      END,
                 part_inst_objid  = pi.part_inst_objid,
                 site_part_objid  = sp.site_part_objid,
                 contact_objid    = c_contact_o_objid,
                 web_user_objid   = wu.web_user_objid,
                 old_esn          = CASE  WHEN c_old_esn IS NOT NULL THEN c_old_esn
		                          ELSE old_esn
				    END	  ,
		 old_sim          = CASE  WHEN c_old_sim IS NOT NULL THEN c_old_sim
		                          ELSE old_esn
				    END,
		customer_status   = CASE WHEN i_customer_status  IS NOT NULL THEN i_customer_status
                                    ELSE customer_status END,  --updating to async call customer_status if there is mismatch
                 update_timestamp = c_sysdate
          WHERE  objid = data (i).objid;

          -- reset response as null for reuse
          --o_response := NULL;


          -- increase row count
          n_count_rows := n_count_rows + 1;



          IF (MOD (n_count_rows, i_commit_every_rows) = 0) THEN
            -- Save changes
            COMMIT;
          END IF;
        --


        EXCEPTION                                           --loop exception
          WHEN OTHERS THEN
            c_response := c_response || ' : '||c_step||' sqlcode-sqlerrm' || SQLCODE || ' - ' || SUBSTR (SQLERRM, 1, 500);

            UPDATE x_wfm_acct_migration_bill_stg
            SET    migration_status       = 'FINAL_MIGRATION_FAILED',
                   migration_response     = c_response,
                   part_inst_objid        = pi.part_inst_objid,
                   site_part_objid        = sp.site_part_objid,
                   contact_objid          = c_contact_o_objid,
                   web_user_objid         = wu.web_user_objid,
                   old_esn                = CASE  WHEN c_old_esn IS NOT NULL THEN c_old_esn
                                            ELSE old_esn END	  ,
                   old_sim                = CASE  WHEN c_old_sim IS NOT NULL THEN c_old_sim
                                             ELSE old_esn   END,
                   customer_status        = CASE WHEN i_customer_status  IS NOT NULL THEN i_customer_status
                                            ELSE customer_status END,
                   update_timestamp       = c_sysdate
            WHERE  objid = data (i).objid;
        END;
      END LOOP;                                                    -- c_data

      --
  --    EXIT WHEN c_get_data%NOTFOUND;
    --
  --  END LOOP;

  ---  CLOSE c_get_data;


  --
  DBMS_OUTPUT.PUT_LINE (n_count_rows || ' rows processed');
  --
  DBMS_OUTPUT.PUT_LINE (n_failed_rows || ' rows failed');


  -- Save changes
  --COMMIT; commented since it will be called in async and the caller will commit

  -- Set response
  o_response := CASE
                  WHEN c_response IS NULL THEN 'SUCCESS'
                  ELSE c_response
                END;
--
--
EXCEPTION
  WHEN OTHERS THEN
    --
    o_response := 'ERROR IN LOAD_WFM_PREMIGRATION: ' || SQLERRM;

    -- possibly log in the error table
    -- sa.util_pkg.log_error
    --
    RAISE;
END load_wfm_final_migration;
--
--  WFM async procedure with mandatory parameters only for final migration
-- This procedure will internally call process_wfm_async_full
PROCEDURE process_wfm_async ( i_esn                          IN   VARCHAR2                    ,
                              i_min                          IN   VARCHAR2                    ,
                              i_sim                          IN   VARCHAR2                    ,
                              i_customer_status              IN   VARCHAR2                    ,
                              i_igtb_wfm_async_tab           IN   igtb_wfm_async_tab       ,
                              o_response                     OUT  VARCHAR2                )
IS
--
--
BEGIN
  --
  /* calling the procedure process_wfm_async_full with mandatory parameters only
     so that rest of the parameters are set with default values */
  migration_pkg.process_wfm_async_full (  i_esn                     =>    i_esn,
                                          i_min                     =>    i_min,
                                          i_sim                     =>    i_sim,
                                          i_customer_status         =>    i_customer_status,
                                          i_igtb_wfm_async_tab      =>    i_igtb_wfm_async_tab,
                                          o_response                =>    o_response  );
  --
EXCEPTION
--
  WHEN OTHERS
  THEN
    o_response := o_response||'|'||'ERROR IN PROCESS WFM ASYNC'||sqlerrm;
    dbms_output.put_line('Error '||sqlerrm);
--
END process_wfm_async;
--
PROCEDURE process_wfm_async_full ( i_esn                IN  VARCHAR2                      ,
                                   i_min                IN  VARCHAR2                      ,
                                   i_sim                IN  VARCHAR2                      ,
                                   i_customer_status    IN  VARCHAR2                      ,
                                   i_order_type         IN  VARCHAR2 DEFAULT 'Data Migration Handler'        ,
                                   i_action_type        IN  VARCHAR2 DEFAULT '1'          ,
                                   i_action_text        IN  VARCHAR2 DEFAULT 'Activation' ,
                                   i_igtb_wfm_async_tab IN  igtb_wfm_async_tab         ,
                                   i_policy_name        IN  VARCHAR2 DEFAULT 'policy70'   , -- THIS IS A PLACEHOLDER
                                   i_source_system      IN  VARCHAR2 DEFAULT 'BATCH'      ,
                                   i_skip_migration     IN  VARCHAR2 DEFAULT 'N'          ,--flag to skip migration in case of rerun
                                   i_skip_async         IN  VARCHAR2 DEFAULT 'N'    ,--if passed as 'Y' insert log and update bill_stg status nd return
                                   i_reprocess_flag     IN  VARCHAR2 DEFAULT 'N',--Y/N Y--override migration status and skip group failedreprocess
                                   i_call_trans_result  IN  VARCHAR2 DEFAULT 'Migrated'   ,
                                   i_cc_algorithm       IN  VARCHAR2 DEFAULT 'http://www.w3.org/2001/04/xmlenc#aes256-cbc',
                                   i_key_algorithm      IN  VARCHAR2 DEFAULT 'http://www.w3.org/2001/04/xmlenc#rsa-1_5',
                                   i_cert               IN  VARCHAR2 DEFAULT 'gw-ccn-encrypt-cert-koz-20070717',
                                   o_response           OUT VARCHAR2                      ) IS

  n_user_objid         NUMBER;
  n_async_req_objid    NUMBER;
  cst                  sa.customer_type         := sa.customer_type ();
  ct                   sa.call_trans_type       := sa.call_trans_type ();
  tt                   sa.task_type             := sa.task_type ();
  t                    sa.task_type             := sa.task_type ();
  ig                   sa.ig_transaction_type   := sa.ig_transaction_type ();
  igt                  sa.ig_transaction_type   := sa.ig_transaction_type ();
  c_cos                VARCHAR2(50);
  c_throttle_err_code  NUMBER;
  c_throttle_response  VARCHAR2(1000);
  sub                  sa.subscriber_type       := sa.subscriber_type();
  pcrf                 sa.pcrf_transaction_type := sa.pcrf_transaction_type();
  n_migration_check    NUMBER;
  n_acct_bill_stg_objid NUMBER;
  n_interact_objid      NUMBER;
  c_migration_response VARCHAR2(2000);

  igtb_tab igtb_wfm_async_tab := igtb_wfm_async_tab();

  n_phone_status_objid      NUMBER;
  c_phone_status_code       VARCHAR2(50);
  n_line_status_objid       NUMBER;
  c_line_status_code        VARCHAR2(50);
  n_sim_status_objid        NUMBER;
  c_sim_status_code         VARCHAR2(50);
  c_site_part_status        VARCHAR2(50);
  c_payment_source_id       NUMBER;
  billdateextract           billdateextract_tbl;
  c_reprocess_response      VARCHAR2(1000);
  c_cc_err_num              NUMBER;
  c_cc_err_msg              VARCHAR2(1000);
  c_login_name              VARCHAR2(255);
  c_bucket_type             VARCHAR2(50);
  c_enqueue_response        VARCHAR2(1000);
  c_ldap_err_num            NUMBER;
  c_ldap_err_msg            VARCHAR2(1000);
  c_status_response         VARCHAR2(1000);
  c_sp_part_class_name      VARCHAR2(40);
  c_upp_err_code            VARCHAR2(100);
  c_upp_err_msg             VARCHAR2(1000);


/*  CURSOR c_group_failed (i_ban IN VARCHAR2) IS
    SELECT *
    FROM   x_wfm_acct_migration_bill_stg stg
    WHERE  stg.migration_status  = 'FINAL_MIGRATION_FAILED'
    AND    stg.migration_response LIKE '%Group creation Err Web user not found%'
    AND    stg.ban               = i_ban
    AND    stg.pah_indicator     = 'N';*/

BEGIN
  dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' Begin async ');
  n_phone_status_objid  := NULL;
  c_phone_status_code   := NULL;
  n_line_status_objid   := NULL;
  c_line_status_code    := NULL;
  n_sim_status_objid    := NULL;
  c_sim_status_code     := NULL;
  c_site_part_status    := NULL;
  c_enqueue_response    := NULL;
  c_ldap_err_num        := NULL;
  c_ldap_err_msg        := NULL;
  c_status_response     := NULL;
  c_migration_response  := NULL;
  c_sp_part_class_name  := NULL;
  c_upp_err_code        := NULL;
  c_upp_err_msg         := NULL;

  -- check conditions for reequired input parameters
  IF i_min IS NULL OR
     i_sim IS NULL OR
     i_esn IS NULL OR
     i_customer_status IS NULL
  THEN
    --o_response := 'MISSING MANDATORY INPUT PARAMETER ESN/MIN/SIM/STATUS';
    SELECT 'MISSING MANDATORY INPUT PARAMETER '|| NVL2(i_min,NULL,'|MIN')
                                               || NVL2(i_sim,NULL,'|SIM')
                                               || NVL2(i_esn,NULL,'|ESN')
                                               || NVL2(i_customer_status,NULL,'|STATUS')
     INTO o_response from dual;
    --
    RETURN;
  END IF;

  -- LOG THE REQUEST IN X_WFM_ASYNC_REQUEST_LOG TABLE
  BEGIN
    INSERT
    INTO   x_wfm_async_request_log
           ( objid,
             esn,
             min,
             sim,
             order_type,
             action_type,
             action_text,
             policy_name,
             source_system,
             customer_status,
             call_trans_result,
             status_message,
             buckets,
             insert_timestamp,
             update_timestamp
           )
    VALUES ( seq_wfm_async_request_log.NEXTVAL,
             i_esn,
             i_min,
             i_sim,
             i_order_type,
             i_action_type,
             i_action_text,
             i_policy_name,
             i_source_system,
             i_customer_status,
             i_call_trans_result,
             NULL,
             i_igtb_wfm_async_tab,
             SYSDATE,
             SYSDATE
           )
    RETURNING objid
    INTO n_async_req_objid;
   EXCEPTION
     WHEN OTHERS THEN
       NULL;
  END;

  -- check if the esn/min/sim combination is present in migration staging table
  BEGIN
    SELECT *
    BULK COLLECT
    INTO   billdateextract
    FROM   x_wfm_acct_migration_bill_stg
    WHERE  min = i_min
    --AND    migration_status||'' = 'READYTOMIGRATE'
    ;
   EXCEPTION
     WHEN OTHERS THEN
       o_response := 'ERROR FETCHING MIGRATION RECORD ';
       UPDATE x_wfm_async_request_log
       SET    status_message = o_response
       WHERE  objid = n_async_req_objid;
       --
       RETURN;
  END;
  --
  IF billdateextract IS NULL THEN
    o_response := 'MIN NOT FOUND IN MIGRATION STAGING TABLE';
    UPDATE x_wfm_async_request_log
    SET    status_message = o_response
    WHERE  objid = n_async_req_objid;
    --
    RETURN;
  END IF;
  --
  IF billdateextract.COUNT = 0 THEN
    o_response := 'MIN NOT FOUND IN MIGRATION STAGING TABLE';
    UPDATE x_wfm_async_request_log
    SET    status_message = o_response
    WHERE  objid = n_async_req_objid;
    --
    RETURN;
  END IF;

  IF billdateextract(1).migration_status <> 'READYTOMIGRATE' THEN
    o_response := CASE WHEN billdateextract(1).migration_status ='FINAL_MIGRATION_COMPLETED' THEN
                             'MIN IS ALREADY MIGRATED'
                       ELSE  'MIN NOT IN READYTOMIGRATE STATUS IN MIGRATION STAGING TABLE'
                  END;
    UPDATE x_wfm_async_request_log
    SET    status_message = o_response
    WHERE  objid = n_async_req_objid;
    --
    RETURN;
  END IF;


  -- flag used to skip async for performance concerns and process later by batch
  IF i_skip_async = 'Y' THEN
    --
    o_response := 'SUCCESS';
    --
    UPDATE x_wfm_async_request_log
    SET    status_message = 'QUEUED_FOR_BATCH'
    WHERE  objid = n_async_req_objid;
    --
    UPDATE x_wfm_acct_migration_bill_stg
    SET    migration_status = 'QUEUED_FOR_BATCH'
    WHERE  objid = billdateextract(1).objid;
    --
    RETURN;

  END IF;


  -- CALL MIGRATION PROCEDURE TO CREATE SITEPART/PARTINST ETC RECORDS IN CLARIFY

  -- translate customer status to Phone/line and sim status

  dbms_output.put_line ('reprocess flag '|| i_reprocess_flag);
  dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' Before get status mappings ');
  --
  get_wfm_status_mappings ( i_status              => i_customer_status,
                            o_phone_status_objid  => n_phone_status_objid,
                            o_phone_status_code   => c_phone_status_code,
                            o_line_status_objid   => n_line_status_objid,
                            o_line_status_code    => c_line_status_code,
                            o_sim_status_objid    => n_sim_status_objid,
                            o_sim_status_code     => c_sim_status_code,
                            o_site_part_status    => c_site_part_status,
                            o_response            => c_status_response);
  --
  IF c_status_response NOT LIKE 'SUCCESS'
  THEN
    --
    o_response := c_status_response;
    --
    UPDATE x_wfm_async_request_log
    SET    status_message = o_response
    WHERE  objid = n_async_req_objid;
    --
    RETURN;
    --
  END IF;
  --
  dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' After get status mappings ');
  IF i_skip_migration  <> 'Y' THEN

    dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' Before Final Migration call');

    load_wfm_final_migration ( o_response                  => c_migration_response,
                               i_min                       => i_min,
                               i_sim                       => i_sim,
                               i_esn                       => i_esn,
                               i_customer_status           => i_customer_status,
                               i_billdateextract_tbl       => billdateextract,
                               i_phone_part_inst_status    => c_phone_status_code,
                               i_line_part_inst_status     => c_line_status_code,
                               i_sim_status                => c_sim_status_code,
                               i_site_part_status          => c_site_part_status
                             ) ;

    dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' After Final Migration call');

  END IF;

  -- if the call returns with an error return with the error response
  IF c_migration_response NOT LIKE '%SUCCESS%' AND
     i_skip_migration <> 'Y'
  THEN
     o_response := 'ERROR IN FINAL MIGRATION UPDATE';--: '||c_migration_respone;

    UPDATE x_wfm_async_request_log
    SET    status_message = o_response
    WHERE  objid          = n_async_req_objid;


     --
     RETURN;
  END IF;

  dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' Before customer type  call');

  -- get reduced customer type attributes
  cst := get_customer_type_attributes ( i_esn => i_esn );

  dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' After customer type  call');

  -- check for response, it should be success
  IF cst.response NOT LIKE '%SUCCESS%'
  THEN
     o_response := 'ERROR IN RETRIEVING CUSTOMER ATTRIBUTES';

     UPDATE x_wfm_acct_migration_bill_stg
     SET    async_status   = 'ASYNC_FAILED',
            async_response =  cst.response
     WHERE  objid = billdateextract(1).objid;

     UPDATE x_wfm_async_request_log
     SET    status_message = o_response
     WHERE  objid          = n_async_req_objid;

     RETURN;
  END IF;

  -- check for other mandatory input parameters as well, they should not be null
  IF cst.site_part_objid IS NULL
  THEN
     o_response := 'FAILED: SITE PART NOT FOUND';
     --
     UPDATE x_wfm_acct_migration_bill_stg
     SET    async_status   = 'ASYNC_FAILED',
            async_response =  o_response
     WHERE objid         = billdateextract(1).objid;

     UPDATE x_wfm_async_request_log
     SET    status_message = o_response
     WHERE  objid          = n_async_req_objid;

     --
     RETURN;
  END IF;

  IF cst.carrier_objid IS NULL
  THEN
     o_response := 'FAILED: CARRIER NOT FOUND';
     --
     UPDATE x_wfm_acct_migration_bill_stg
     SET    async_status   = 'ASYNC_FAILED',
            async_response =  o_response
     WHERE  objid         = billdateextract(1).objid;

     UPDATE x_wfm_async_request_log
     SET    status_message = o_response
     WHERE  objid          = n_async_req_objid;
     --
     RETURN;
  END IF;

  IF cst.inv_bin_objid IS NULL
  THEN
     o_response := 'FAILED: DEALER NOT FOUND';


      UPDATE x_wfm_acct_migration_bill_stg
      SET  async_status   = 'ASYNC_FAILED',
           async_response =  o_response
      WHERE objid         = billdateextract(1).objid;

     UPDATE x_wfm_async_request_log
     SET    status_message = o_response
     WHERE  objid          = n_async_req_objid;

     RETURN;
  END IF;

  -- THIS SHOULD NOT HAPPEN, HOWEVER CHECKING JUST IN CASE
  IF cst.bus_org_id IS NULL
  THEN
     o_response := 'FAILED: BRAND NOT FOUND';
     --
     UPDATE x_wfm_acct_migration_bill_stg
     SET  async_status   = 'ASYNC_FAILED',
           async_response =  o_response
     WHERE objid         = billdateextract(1).objid;

     UPDATE x_wfm_async_request_log
     SET    status_message = o_response
     WHERE  objid          = n_async_req_objid;

     RETURN;
  END IF;

  IF cst.contact_objid IS NULL
  THEN
    o_response := 'FAILED: CONTACT NOT FOUND';
    --
    UPDATE x_wfm_acct_migration_bill_stg
    SET    async_status = 'ASYNC_FAILED',
           async_response = o_response
    WHERE  objid = billdateextract(1).objid;

     UPDATE x_wfm_async_request_log
     SET    status_message = o_response
     WHERE  objid          = n_async_req_objid;

    --
    RETURN;
  END IF;


  -- need the user objid for call trans
  n_user_objid := 268435556;

  dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' Before LDAP Update ');

  -- update contact details min and security pin to ldap
  contact_pkg.p_update_ldap ( i_esn        => i_esn          ,
                              o_error_code => c_ldap_err_num ,
                              o_error_msg  => c_ldap_err_msg );

  --
  IF c_ldap_err_msg NOT LIKE '%SUCCESS%' THEN
    o_response := 'LDAP WARNING :' || c_ldap_err_msg; -- Error capturing starts here ,we will append error to o_response after this
  END IF;
  --
  dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' After LDAP Update ');
  dbms_output.put_line ('CT ESN '||cst.esn);

  IF cst.site_part_status  = 'Active'  THEN
    --
    ct := call_trans_type ();
    -- populate call trans type with all information
    ct := call_trans_type (i_call_trans2site_part            => cst.site_part_objid,
                           i_action_type                     => i_action_type,
                           i_call_trans2carrier              => cst.carrier_objid,
                           i_call_trans2dealer               => cst.inv_bin_objid,
                           i_call_trans2user                 => n_user_objid,
                           i_line_status                     => NULL,
                           i_min                             => cst.min,
                           i_esn                             => cst.esn,
                           i_sourcesystem                    => i_source_system,
                           i_transact_date                   => SYSDATE,
                           i_total_units                     => 0,
                           i_action_text                     => i_action_text,
                           i_reason                          => INITCAP (i_action_text),
                           i_result                          => i_call_trans_result, -- Migrated
                           i_sub_sourcesystem                => cst.bus_org_id,
                           i_iccid                           => cst.iccid,
                           i_ota_req_type                    => NULL,
                           i_ota_type                        => NULL,
                           i_call_trans2x_ota_code_hist      => NULL,
                           i_new_due_date                    => cst.expiration_date );
    -- call save method
    -- insert does a retrieve internally which is unnecessary in this case as all information is already being passed
      --
  -- dbms_output.put_line ('CTT ESN '||ct.esn);
    ct := ct.save;

    IF ct.response NOT LIKE '%SUCCESS%'
    THEN
       --
      o_response := 'ERROR CREATING CALL TRANS'; -- || ct.response;
      --
      UPDATE x_wfm_acct_migration_bill_stg
      SET  async_status   = 'ASYNC_FAILED',
           async_response =  'ERROR CREATING CALL TRANS :' || ct.response
      WHERE objid         = billdateextract(1).objid;

      UPDATE x_wfm_async_request_log
      SET    status_message = o_response
      WHERE  objid          = n_async_req_objid;


      RETURN;
    END IF;
    dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' After call trans ');
    -- CREATE TASK
   /* tt := task_type ( i_call_trans_objid       => ct.call_trans_objid,
                      i_contact_objid          => cst.contact_objid,
                      i_order_type             => i_order_type,
                      i_bypass_order_type      => 0,
                      i_case_code              => 0);  */

    -- hardcode the order_type_objid = 268937437 to use wfm carrier and order type
    t.order_type_objid := 268937437 ;
   /* t.order_type_objid := t.get_order_type_objid (  i_min           => cst.min ,
                                                    i_order_type    => i_order_type ,
                                                    i_carrier_objid => cst.carrier_objid ,
                                                    i_technology    => cst.technology );*/
    --
    t.title            :=  'T-MOBILE WFM DATA MIGRATION HANDLER';
    t.notes            := ':  ********** New Action Item *********** :' || CHR(10) || CHR(13) || ' ActionTitle:  ' || tt.title || CHR(10) || CHR(13) || 'Originator: ' || USER || CHR(10) || CHR(13) || ' Create Time: ' || SYSDATE;

     dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' Before task type call ');
		--
    t := task_type ( i_title                       => 'T-MOBILE WFM DATA MIGRATION HANDLER',
                     i_case_code                   => NULL,
                     i_notes                       => t.notes,
                     i_update_stamp                => SYSDATE,
                     i_original_method             => 'AOL',
                     i_current_method              => 'AOL',
                     i_task_priority2gbst_elm      => NULL,
                     i_task_sts2gbst_elm           => NULL,
                     i_type_task2gbst_elm          => NULL,
                     i_contact_objid               => cst.contact_objid,
                     i_task_wip2wipbin             => NULL,
                     i_call_trans_objid            => ct.call_trans_objid,
                     i_task_originator2user        => n_user_objid,
                     i_order_type_objid            => t.order_type_objid,--need to check
                     i_ota_type                    => NULL);

    dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' Before task type call save ');
    --
    -- CALL Save METHOD TO CREATE TASK
    tt.response := tt.save(t) ;

    IF tt.response NOT LIKE '%SUCCESS%'
    THEN
      o_response := 'ERROR CREATING TASK';-- || tt.response;
      --
      UPDATE x_wfm_acct_migration_bill_stg
      SET  async_status   = 'ASYNC_FAILED',
           async_response =  'ERROR CREATING TASK :' || tt.response
      WHERE objid         = billdateextract(1).objid;

      UPDATE x_wfm_async_request_log
      SET    status_message = o_response
      WHERE  objid          = n_async_req_objid;

      RETURN;
    END IF;
    dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' Before taskt type');
    --IF EVERYTHING IS SUCCESSFUL SO FAR, THEN ITS TIME TO CREATE IG
    -- GET THE CARRIER_ID

    --assign direct value hard coded
    ig.carrier_id := '180260';

    -- load template: juda: maybe we can hardcode it
    ig.template :=  'TMOBILE';

    -- get order type
    ig.order_type := 'DMH';

    -- call constructor to initialize ig transaction
     dbms_output.put_line ('cst rate plan :'||cst.rate_plan);

    ig := ig_transaction_type ( i_action_item_id            => t.task_id,
                                i_carrier_id                => ig.carrier_id, --need to add as input parameter
                                i_order_type                => ig.order_type,
                                i_min                       => cst.MIN,
                                i_esn                       => cst.esn,
                                i_esn_hex                   => NULL,
                                i_old_esn                   => NULL,
                                i_old_esn_hex               => NULL,
                                i_pin                       => NULL,
                                i_phone_manf                => cst.phone_manufacturer,
                                i_end_user                  => NULL,
                                i_account_num               => NULL,
                                i_market_code               => NULL,
                                i_rate_plan                 => cst.rate_plan,
                                i_ld_provider               => NULL,
                                i_sequence_num              => NULL,
                                i_dealer_code               => NULL,
                                i_transmission_method       => 'AOL',
                                i_fax_num                   => NULL,
                                i_online_num                => NULL,
                                i_email                     => NULL,
                                i_network_login             => CASE WHEN ig.template IN ('TMOBILE','TMOSM','TMOUN') THEN 'tracfone' ELSE NULL END,
                                i_network_password          => CASE WHEN ig.template IN ('TMOBILE','TMOSM','TMOUN') THEN 'Tr@cfon3' ELSE NULL END,
                                i_system_login              => NULL,
                                i_system_password           => NULL,
                                i_template                  => ig.template,
                                i_exe_name                  => NULL,
                                i_com_port                  => NULL,
                                i_status                    => 'S',
                                i_status_message            => 'Migration Successful',
                                i_fax_batch_size            => NULL,
                                i_fax_batch_q_time          => NULL,
                                i_expidite                  => NULL,
                                i_trans_prof_key            => NULL,
                                i_q_transaction             => NULL,
                                i_online_num2               => NULL,
                                i_fax_num2                  => NULL,
                                i_creation_date             => SYSDATE,
                                i_update_date               => SYSDATE,
                                i_blackout_wait             => SYSDATE,
                                i_tux_iti_server            => NULL,
                                i_transaction_id            => gw1.trans_id_seq.NEXTVAL,
                                i_technology_flag           => SUBSTR (cst.technology, 1, 1),
                                i_voice_mail                => NULL,
                                i_voice_mail_package        => NULL,
                                i_caller_id                 => NULL,
                                i_caller_id_package         => NULL,
                                i_call_waiting              => NULL,
                                i_call_waiting_package      => NULL,
                                i_rtp_server                => NULL,
                                i_digital_feature_code      => NULL,
                                i_state_field               => NULL,
                                i_zip_code                  => cst.zipcode,
                                i_msid                      => cst.MIN,
                                i_new_msid_flag             => NULL,
                                i_sms                       => NULL,
                                i_sms_package               => NULL,
                                i_iccid                     => cst.iccid,
                                i_old_min                   => NULL,
                                i_digital_feature           => NULL,
                                i_ota_type                  => NULL,
                                i_rate_center_no            => NULL,
                                i_application_system        => 'IG',
                                i_subscriber_update         => NULL,
                                i_download_date             => NULL,
                                i_prl_number                => NULL,
                                i_amount                    => NULL,
                                i_balance                   => NULL,
                                i_language                  => NULL,
                                i_exp_date                  => NULL,
                                i_x_mpn                     => NULL,
                                i_x_mpn_code                => NULL,
                                i_x_pool_name               => NULL,
                                i_imsi                      => NULL,
                                i_new_imsi_flag             => NULL );

    -- call ins method
    --ig.response := NULL; -- resetting the response from constructor
    igt := ig.ins;

    dbms_output.put_line ('ig response  '||igt.response);

    -- IG SHOULD NOT FAIL, HOWEVER IT IT DOES, WE SHOULD LOG IT
    IF igt.response  LIKE '%ERROR INSERTING IG RECORD%'
    THEN
      o_response := 'ERROR CREATING IG'; -- || igt.response;
      --
      UPDATE x_wfm_acct_migration_bill_stg
      SET    async_status   = 'ASYNC_FAILED',
             async_response =  'ERROR CREATING IG :' || igt.response  ,
             call_trans_objid = ct.call_trans_objid
      WHERE  objid = billdateextract(1).objid;

      UPDATE x_wfm_async_request_log
      SET    status_message = o_response
      WHERE  objid          = n_async_req_objid;

      RETURN;
    END IF;

    dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' After IG insert');

    -- create spr
    sub := subscriber_type();

    sub.pcrf_esn := cst.esn;

    -- call insert method for spr
    sub := sub.ins;

    -- check status, if not successful
    IF sub.status NOT LIKE '%SUCCESS%' THEN
      -- CONFIRM IF IGNORE THE ERROR OR APPEND TO RESPONSE
      o_response := o_response||'|'||'SPR WARNING :'||sub.status;
    END IF;

    --update program parameter in SPR
    IF billdateextract(1).auto_refill_flag = 'Y' THEN

      -- query the pivot and part number table to get the app part class name
       BEGIN
        SELECT
         pc.name INTO c_sp_part_class_name
         FROM service_plan_feat_pivot_mv mv,
         table_part_num pn,
         table_part_class pc
        WHERE
         mv.service_plan_objid            = cst.service_plan_objid
         AND mv.plan_purchase_part_number = pn.part_number
         AND pn.part_num2part_class       = pc.objid ;
       EXCEPTION
         WHEN OTHERS THEN
         c_sp_part_class_name := NULL;
       END ;

       IF c_sp_part_class_name IS NOT NULL THEN
        sa.service_profile_pkg.update_program_parameter ( i_min                =>  i_min  ,
                                                          i_part_class_name    =>  c_sp_part_class_name,
                                                          i_action             =>  'ENROLL' ,
                                                          o_err_code           =>  c_upp_err_code ,
                                                          o_err_msg            =>  c_upp_err_msg);


        IF c_upp_err_msg NOT LIKE '%SUCCESS%' THEN
          o_response := o_response||'|'||'PP UPDATE WARNING :'||c_upp_err_msg;
        END IF;

       END IF;



     END IF;

     -- juda: added this condition
     IF sub.status LIKE '%SUCCESS%' THEN

      -- create pcrf transaction records
      pcrf := pcrf_transaction_type ( i_esn               => sub.pcrf_esn,
                                      i_min               => sub.pcrf_min,
                                      i_order_type        => 'UP',
                                      i_zipcode           => sub.zipcode,
                                      i_sourcesystem      => i_source_system,
                                      i_pcrf_status_code  => 'Q');

      -- call insert method to create pcrf transaction row
      pcrf := pcrf.ins;

      IF pcrf.status NOT LIKE '%SUCCESS%' THEN
        o_response := o_response||'|'||'PCRF WARNING :' || pcrf.status;
      END IF;
    END IF;


    dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' Before enqueue call');

    -- enqueue transaction for BRM
--    sa.enqueue_transactions_pkg.enqueue_migration (i_esn               =>  i_esn                ,
--                                                   i_min               =>  i_min                ,
--                                                   i_web_user_objid    =>  cst.web_user_objid   ,
--                                                   i_bus_org_id        =>  cst.bus_org_id       ,
--                                                   i_sourcesystem      =>  i_source_system      ,
--                                                   i_ct_objid          =>  ct.call_trans_objid  ,
--                                                   i_ct_action_type    =>  ct.action_type       ,
--                                                   i_ct_action_text    =>  ct.action_text       ,
--                                                   i_ct_reason         =>  ct.reason            ,
--                                                   i_ig_order_type     =>  igt.order_type       ,
--                                                   i_ig_transaction_id =>  igt.transaction_id   ,
--                                                   i_event_name        =>  i_order_type         ,
--                                                   o_response          =>  c_enqueue_response   );
--
--    dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' After enqueue call');
--
--    dbms_output.put_line ('ENQ RESP'|| c_enqueue_response);
--
--    IF c_enqueue_response NOT LIKE '%SUCCESS%' THEN
--      o_response := o_response||'|'||'ENQUEUE WARNING :' || c_enqueue_response;
--    END IF;

    dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' Before throttle processing ');

    -- IG WAS SUCCESSFUL, PROCESSING BUCKETS (IF PASSED)
    IF   i_igtb_wfm_async_tab IS NOT NULL
    THEN
      IF i_igtb_wfm_async_tab.COUNT > 0
      THEN

        -- LOOP THROUGH THE COLLECTION TO CREATE IG_TRANSACTION_BUCKETS RECORD
        FOR i IN 1 .. i_igtb_wfm_async_tab.COUNT
        LOOP
          -- RESET VARIABLES FOR EACH EXECUTION OF LOOP
          c_cos               := NULL;
          c_throttle_err_code := NULL;
          c_throttle_response := NULL;
          c_bucket_type       := NULL;

          -- CHECK BUCKET_ID AND BUCKET_VALUE..IF MISSING, SKIP CREATING RECORDS
          IF    i_igtb_wfm_async_tab (i).bucket_id IS NULL
             OR i_igtb_wfm_async_tab (i).bucket_value IS NULL
          THEN
            o_response := o_response ||'|'|| ' SKIPPED CREATING BUCKET '|| i_igtb_wfm_async_tab (i).bucket_id;
            CONTINUE;
          END IF;

          --
          igate.insert_ig_transaction_buckets ( i_ig_transaction_id      => igt.transaction_id                        ,
                                                i_bucket_id              => i_igtb_wfm_async_tab (i).bucket_id       ,
                                                i_bucket_value           => i_igtb_wfm_async_tab (i).bucket_value    ,
                                                i_bucket_balance         => NULL                                     ,
                                                i_bucket_expiration_date => i_igtb_wfm_async_tab (i).expiration_date ,
                                                i_benefit_type           => NULL    );

          -- update to update recharge date
          UPDATE ig_transaction_buckets
          SET    recharge_date  = i_igtb_wfm_async_tab(i).effective_date
          WHERE  transaction_id = igt.transaction_id
          AND    bucket_id      = i_igtb_wfm_async_tab(i).bucket_id;
          --
        END LOOP;
      END IF; -- IF i_igtb_wfm_async_tab.COUNT > 0
    END IF; -- IF i_igtb_wfm_async_tab IS NOT NULL
    --
  END IF; -- IF cst.site_part_status = 'Active';
  --
  dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' After throttle processing ');


  -- return success
  o_response := CASE WHEN o_response IS NULL THEN 'SUCCESS' ELSE 'SUCCESS'||'|'||o_response END;

  --
  UPDATE x_wfm_acct_migration_bill_stg
  SET    async_status     = 'ASYNC_COMPLETED',
         async_response   = o_response,
	       call_trans_objid = ct.call_trans_objid
  WHERE  objid = billdateextract(1).objid;

  o_response  := 'SUCCESS'; -- returning success to mask warning errors

  UPDATE x_wfm_async_request_log
  SET    status_message = o_response
  WHERE  objid          = n_async_req_objid;

 EXCEPTION
   WHEN OTHERS
   THEN
     o_response := o_response||'|'||'ERROR IN PROCESS WFM ASYNC: '||sqlerrm;
     dbms_output.put_line('Error '||sqlerrm);

     UPDATE x_wfm_async_request_log
     SET    status_message = o_response
     WHERE  objid = n_async_req_objid   ;

     IF billdateextract.COUNT > 0 THEN
       UPDATE x_wfm_acct_migration_bill_stg
       SET    migration_response = migration_response||'|'||'ASYNC RESPONSE : '||o_response
       WHERE  objid = billdateextract(1).objid;
     END IF;
END process_wfm_async_full;

--Function to return legacy flag
FUNCTION get_sim_legacy_flag  (i_sim IN VARCHAR2)
RETURN VARCHAR2
IS
--
  c_sim_legacy_flag VARCHAR2(1);
BEGIN
  --
  SELECT  wssm.legacy_flag
  INTO    c_sim_legacy_flag
  FROM    table_part_num pn,
          table_mod_level ml,
          table_x_sim_inv si,
          wfmmig.x_wfm_sim_sku_mapping wssm
  WHERE   1                  = 1
  AND     pn.objid           = ml.part_info2part_num
  AND     ml.objid           = si.x_sim_inv2part_mod
  AND     si.x_sim_serial_no = i_sim
  AND     wssm.tf_partnum    = pn.s_part_number
  AND     rownum =1;
  --
  RETURN NVL(c_sim_legacy_flag,'N');
  --
EXCEPTION
  WHEN OTHERS THEN
  c_sim_legacy_flag := 'N';
  RETURN c_sim_legacy_flag;
END get_sim_legacy_flag;
-- procedure used to update the sim status to not migrated
PROCEDURE update_wfm_sim_status(o_response              OUT VARCHAR2,
                                i_bulk_collection_limit IN NUMBER DEFAULT 500 )
IS
CURSOR c_get_data
  IS
    SELECT * FROM etladmin.x_wfm_sim_inv_stg where sim_sku<>'WFM128PSIMT6';

TYPE datalist
IS
  TABLE OF c_get_data%ROWTYPE;
  data datalist;
  n_status_code_objid  NUMBER;

BEGIN

  SELECT objid
  INTO n_status_code_objid
  FROM table_x_code_table
  WHERE x_code_number ='180';

  OPEN c_get_data;
  LOOP
    FETCH c_get_data bulk collect INTO data limit i_bulk_collection_limit;
    --EXIT WHEN data.count = 0;

    FORALL i IN 1 .. data.count
      UPDATE sa.table_x_sim_inv
      SET x_sim_inv_status          = '180',
          x_sim_status2x_code_table = n_status_code_objid
      WHERE x_sim_serial_no = data(i).sim
      AND x_sim_inv_status  = '253';

    --
    COMMIT;
    --
    EXIT WHEN c_get_data%NOTFOUND;

  END LOOP;

  CLOSE c_get_data;

  COMMIT;

  o_response := 'SUCCESS';
EXCEPTION
   WHEN OTHERS THEN
     o_response := 'FAILED - ' ||SUBSTR(SQLERRM,1,500);
END;

/*
FUNCTION get_esn_legacy_flag(i_esn IN VARCHAR2)  RETURN VARCHAR2 IS
c_legacy_flag VARCHAR2(1);
BEGIN

  SELECT wppm.legacy_flag
  INTO c_legacy_flag
  FROM table_part_num pn,
  table_mod_level ml,
  table_part_inst pi,
  wfmmig.x_wfm_phone_part_mapping wppm
  WHERE 1                = 1
  AND pn.objid           = ml.part_info2part_num
  AND ml.objid           = pi.n_part_inst2part_mod
  AND pi.part_serial_no  = i_esn
  AND pi.x_domain        = 'PHONES'
  AND wppm.part_number   = pn.s_part_number;


 RETURN NVL(c_legacy_flag,'N');

EXCEPTION
  WHEN OTHERS THEN
  c_legacy_flag := 'N';
  RETURN c_legacy_flag;

END get_esn_legacy_flag;
*/
--
--  WFM async procedure with mandatory parameters only for final migration
-- This procedure will internally call reprocess_wfm_async_full
PROCEDURE reprocess_wfm_async ( i_esn                          IN   VARCHAR2                    ,
                                i_min                          IN   VARCHAR2                    ,
                                i_sim                          IN   VARCHAR2                    ,
                                i_customer_status              IN   VARCHAR2                    ,
                                i_igtb_wfm_async_tab           IN   igtb_wfm_async_tab   ,
                                o_response                     OUT  VARCHAR2                )
IS
--
--
BEGIN
  --
  /* calling the procedure process_wfm_async_full with mandatory parameters only
     so that rest of the parameters are set with default values */
  migration_pkg.reprocess_wfm_async_full (  i_esn                     =>    i_esn,
                                            i_min                     =>    i_min,
                                            i_sim                     =>    i_sim,
                                            i_customer_status         =>    i_customer_status,
                                            i_igtb_wfm_async_tab      =>    i_igtb_wfm_async_tab,
                                            i_reprocess_flag          =>    'Y',
                                            o_response                =>    o_response  );
  --
EXCEPTION
--
  WHEN OTHERS
  THEN
    o_response := o_response||'|'||'ERROR IN REPROCESS WFM ASYNC'||sqlerrm;
    dbms_output.put_line('Error '||sqlerrm);
--
END reprocess_wfm_async;
--
-- process_wfm_async  with reprocess logic
PROCEDURE reprocess_wfm_async_full (  i_esn                          IN   VARCHAR2                      ,
                                      i_min                          IN   NUMBER                        ,
                                      i_sim                          IN   NUMBER                        ,
                                      i_customer_status              IN   VARCHAR2                      ,
                                      i_order_type                   IN   VARCHAR2 DEFAULT 'Data Migration Handler'        ,
                                      i_action_type                  IN   VARCHAR2 DEFAULT '1'          ,
                                      i_action_text                  IN   VARCHAR2 DEFAULT 'Activation' ,
                                      i_igtb_wfm_async_tab           IN   igtb_wfm_async_tab ,
                                      i_policy_name                  IN   VARCHAR2 DEFAULT 'policy54'   , -- THIS IS A PLACEHOLDER
                                      i_source_system                IN   VARCHAR2 DEFAULT 'BATCH'      ,
                                      i_skip_migration               IN   VARCHAR2 DEFAULT 'N'          ,--flag to skip migration in case of rerun
                                      i_skip_async                   IN   VARCHAR2 DEFAULT 'N'    ,--if passed as 'Y' insert log and update bill_stg status nd return
                                      i_reprocess_flag               IN   VARCHAR2 DEFAULT 'N',--Y/N Y--override migration status and skip group failed reprocess
                                      i_call_trans_result            IN   VARCHAR2 DEFAULT 'Migrated'   ,
                                      o_response                     OUT  VARCHAR2                      ) IS
  --
   n_user_objid         NUMBER;
  n_async_req_objid    NUMBER;
  cst                  sa.customer_type         := sa.customer_type ();
  ct                   sa.call_trans_type       := sa.call_trans_type ();
  tt                   sa.task_type             := sa.task_type ();
  t                    sa.task_type             := sa.task_type ();
  ig                   sa.ig_transaction_type   := sa.ig_transaction_type ();
  igt                  sa.ig_transaction_type   := sa.ig_transaction_type ();
  c_cos                VARCHAR2(50);
  c_throttle_err_code  NUMBER;
  c_throttle_response  VARCHAR2(1000);
  sub                  sa.subscriber_type       := sa.subscriber_type();
  pcrf                 sa.pcrf_transaction_type := sa.pcrf_transaction_type();
  n_migration_check    NUMBER;
  n_acct_bill_stg_objid NUMBER;
  n_interact_objid      NUMBER;
  c_migration_response VARCHAR2(2000);

  igtb_tab igtb_wfm_async_tab := igtb_wfm_async_tab();

  n_phone_status_objid      NUMBER;
  c_phone_status_code       VARCHAR2(50);
  n_line_status_objid       NUMBER;
  c_line_status_code        VARCHAR2(50);
  n_sim_status_objid        NUMBER;
  c_sim_status_code         VARCHAR2(50);
  c_site_part_status        VARCHAR2(50);
  c_payment_source_id       NUMBER;
  billdateextract           billdateextract_tbl;
  c_reprocess_response      VARCHAR2(1000);
  c_cc_err_num              NUMBER;
  c_cc_err_msg              VARCHAR2(1000);
  c_login_name              VARCHAR2(255);
  c_bucket_type             VARCHAR2(50);
  c_enqueue_response        VARCHAR2(1000);
  c_ldap_err_num            NUMBER;
  c_ldap_err_msg            VARCHAR2(1000);
  c_status_response         VARCHAR2(1000);
  c_sp_part_class_name      VARCHAR2(40);
  c_upp_err_code            VARCHAR2(100);
  c_upp_err_msg             VARCHAR2(1000);


/*  CURSOR c_group_failed (i_ban IN VARCHAR2) IS
    SELECT *
    FROM   x_wfm_acct_migration_bill_stg stg
    WHERE  stg.migration_status  = 'FINAL_MIGRATION_FAILED'
    AND    stg.migration_response LIKE '%Group creation Err Web user not found%'
    AND    stg.ban               = i_ban
    AND    stg.pah_indicator     = 'N';*/

BEGIN
  dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' Begin async ');
  n_phone_status_objid  := NULL;
  c_phone_status_code   := NULL;
  n_line_status_objid   := NULL;
  c_line_status_code    := NULL;
  n_sim_status_objid    := NULL;
  c_sim_status_code     := NULL;
  c_site_part_status    := NULL;
  c_enqueue_response    := NULL;
  c_ldap_err_num        := NULL;
  c_ldap_err_msg        := NULL;
  c_status_response     := NULL;
  c_migration_response  := NULL;
  c_sp_part_class_name  := NULL;
  c_upp_err_code        := NULL;
  c_upp_err_msg         := NULL;
  --
  -- CHECK CONDITIONS FOR REEQUIRED INPUT PARAMETERS
  IF i_min IS NULL OR i_sim IS NULL OR i_esn IS NULL OR i_customer_status IS NULL
  THEN
    --o_response := 'MISSING MANDATORY INPUT PARAMETER ESN/MIN/SIM/STATUS';
    SELECT 'MISSING MANDATORY INPUT PARAMETER '|| NVL2(i_min,NULL,'|MIN')
                                               || NVL2(i_sim,NULL,'|SIM')
                                               || NVL2(i_esn,NULL,'|ESN')
                                               || NVL2(i_customer_status,NULL,'|STATUS')
     INTO o_response from dual;

    UPDATE x_wfm_async_request_log
    SET    status_message = o_response
    WHERE  objid = n_async_req_objid;

    RETURN;
  END IF;
  --
  -- LOG THE REQUEST IN X_WFM_ASYNC_REQUEST_LOG TABLE
  IF i_reprocess_flag <> 'Y'
  THEN
    --
    INSERT INTO x_wfm_async_request_log
    (
    objid,
    esn,
    min,
    sim,
    order_type,
    action_type,
    action_text,
    policy_name,
    source_system,
    customer_status,
    call_trans_result,
    status_message,
    buckets,
    insert_timestamp,
    update_timestamp
    )
    VALUES
    (
    seq_wfm_async_request_log.NEXTVAL,
    i_esn,
    i_min,
    i_sim,
    i_order_type,
    i_action_type,
    i_action_text,
    i_policy_name,
    i_source_system,
    i_customer_status,
    i_call_trans_result,
    NULL,
    i_igtb_wfm_async_tab,
    SYSDATE,
    SYSDATE
    )
    RETURNING objid INTO n_async_req_objid;
    --
  ELSE
    --
    BEGIN
      SELECT MAX (objid) INTO   n_async_req_objid
      FROM x_wfm_async_request_log WHERE min = i_min ;
    EXCEPTION
      WHEN OTHERS THEN
        n_async_req_objid := NULL;
    END ;
    --
  END IF;

  -- check if the esn/min/sim combination is present in migration staging table
  BEGIN
    SELECT *
    BULK COLLECT
    INTO   billdateextract
    FROM   x_wfm_acct_migration_bill_stg
    WHERE  min = i_min
    --AND    migration_status||'' = 'READYTOMIGRATE'
    ;
   EXCEPTION
     WHEN OTHERS THEN
       o_response := 'ERROR FETCHING MIGRATION RECORD ';
       UPDATE x_wfm_async_request_log
       SET    status_message = o_response
       WHERE  objid = n_async_req_objid;
       --
       RETURN;
  END;
  --
  IF billdateextract IS NULL THEN
    o_response := 'MIN NOT FOUND IN MIGRATION STAGING TABLE';
    UPDATE x_wfm_async_request_log
    SET    status_message = o_response
    WHERE  objid = n_async_req_objid;
    --
    RETURN;
  END IF;
  --
  IF billdateextract.COUNT = 0 THEN
    o_response := 'MIN NOT FOUND IN MIGRATION STAGING TABLE';
    UPDATE x_wfm_async_request_log
    SET    status_message = o_response
    WHERE  objid = n_async_req_objid;
    --
    RETURN;
  END IF;

  IF billdateextract(1).migration_status <> 'READYTOMIGRATE' THEN
    o_response := CASE WHEN billdateextract(1).migration_status ='FINAL_MIGRATION_COMPLETED' THEN
                             'MIN IS ALREADY MIGRATED'
                       ELSE  'MIN NOT IN READYTOMIGRATE STATUS IN MIGRATION STAGING TABLE'
                  END;
    UPDATE x_wfm_async_request_log
    SET    status_message = o_response
    WHERE  objid = n_async_req_objid;
    --
    RETURN;
  END IF;
  -- flag used to skip async for performance concerns and process later by batch
  IF i_skip_async = 'Y' THEN
    --
    o_response := 'SUCCESS';
    --
    UPDATE x_wfm_async_request_log
    SET    status_message = 'QUEUED_FOR_BATCH'
    WHERE  objid = n_async_req_objid;
    --
    UPDATE x_wfm_acct_migration_bill_stg
    SET    migration_status = 'QUEUED_FOR_BATCH'
    WHERE  objid = billdateextract(1).objid;
    --
    RETURN;

  END IF;


  -- CALL MIGRATION PROCEDURE TO CREATE SITEPART/PARTINST ETC RECORDS IN CLARIFY

  -- translate customer status to Phone/line and sim status

  dbms_output.put_line ('reprocess flag '|| i_reprocess_flag);
  dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' Before get status mappings ');
  --
  get_wfm_status_mappings ( i_status              => i_customer_status,
                            o_phone_status_objid  => n_phone_status_objid,
                            o_phone_status_code   => c_phone_status_code,
                            o_line_status_objid   => n_line_status_objid,
                            o_line_status_code    => c_line_status_code,
                            o_sim_status_objid    => n_sim_status_objid,
                            o_sim_status_code     => c_sim_status_code,
                            o_site_part_status    => c_site_part_status,
                            o_response            => c_status_response);
  --
  IF c_status_response NOT LIKE 'SUCCESS'
  THEN
    --
    o_response := c_status_response;
    --
    UPDATE x_wfm_async_request_log
    SET    status_message = o_response
    WHERE  objid = n_async_req_objid;
    --
    RETURN;
    --
  END IF;
  --
  dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' After get status mappings ');

   IF i_skip_migration  <> 'Y' THEN

    dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' Before Final Migration call');

    load_wfm_final_migration ( o_response                  => c_migration_response,
                               i_min                       => i_min,
                               i_sim                       => i_sim,
                               i_esn                       => i_esn,
                               i_customer_status           => i_customer_status,
                               i_billdateextract_tbl       => billdateextract,
                               i_phone_part_inst_status    => c_phone_status_code,
                               i_line_part_inst_status     => c_line_status_code,
                               i_sim_status                => c_sim_status_code,
                               i_site_part_status          => c_site_part_status
                             ) ;

    dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' After Final Migration call');

  END IF;

  -- if the call returns with an error return with the error response
  IF c_migration_response NOT LIKE '%SUCCESS%' AND
     i_skip_migration <> 'Y'
  THEN
     o_response := 'ERROR IN FINAL MIGRATION UPDATE';--: '||c_migration_respone;

    UPDATE x_wfm_async_request_log
    SET    status_message = o_response
    WHERE  objid          = n_async_req_objid;


     --
     RETURN;
  END IF;

  dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' Before customer type  call');

  -- get reduced customer type attributes
  cst := get_customer_type_attributes ( i_esn => i_esn );

  dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' After customer type  call');

  -- check for response, it should be success
  IF cst.response NOT LIKE '%SUCCESS%'
  THEN
     o_response := 'ERROR IN RETRIEVING CUSTOMER ATTRIBUTES';

     UPDATE x_wfm_acct_migration_bill_stg
     SET    async_status   = 'ASYNC_FAILED',
            async_response =  cst.response
     WHERE  objid = billdateextract(1).objid;

     UPDATE x_wfm_async_request_log
     SET    status_message = o_response
     WHERE  objid          = n_async_req_objid;

     RETURN;
  END IF;

  -- check for other mandatory input parameters as well, they should not be null
  IF cst.site_part_objid IS NULL
  THEN
     o_response := 'FAILED: SITE PART NOT FOUND';
     --
     UPDATE x_wfm_acct_migration_bill_stg
     SET    async_status   = 'ASYNC_FAILED',
            async_response =  o_response
     WHERE objid         = billdateextract(1).objid;

     UPDATE x_wfm_async_request_log
     SET    status_message = o_response
     WHERE  objid          = n_async_req_objid;

     --
     RETURN;
  END IF;

  IF cst.carrier_objid IS NULL
  THEN
     o_response := 'FAILED: CARRIER NOT FOUND';
     --
     UPDATE x_wfm_acct_migration_bill_stg
     SET    async_status   = 'ASYNC_FAILED',
            async_response =  o_response
     WHERE  objid         = billdateextract(1).objid;

     UPDATE x_wfm_async_request_log
     SET    status_message = o_response
     WHERE  objid          = n_async_req_objid;
     --
     RETURN;
  END IF;

  IF cst.inv_bin_objid IS NULL
  THEN
     o_response := 'FAILED: DEALER NOT FOUND';


      UPDATE x_wfm_acct_migration_bill_stg
      SET  async_status   = 'ASYNC_FAILED',
           async_response =  o_response
      WHERE objid         = billdateextract(1).objid;

     UPDATE x_wfm_async_request_log
     SET    status_message = o_response
     WHERE  objid          = n_async_req_objid;

     RETURN;
  END IF;

  -- THIS SHOULD NOT HAPPEN, HOWEVER CHECKING JUST IN CASE
  IF cst.bus_org_id IS NULL
  THEN
     o_response := 'FAILED: BRAND NOT FOUND';
     --
     UPDATE x_wfm_acct_migration_bill_stg
     SET  async_status   = 'ASYNC_FAILED',
           async_response =  o_response
     WHERE objid         = billdateextract(1).objid;

     UPDATE x_wfm_async_request_log
     SET    status_message = o_response
     WHERE  objid          = n_async_req_objid;

     RETURN;
  END IF;

  IF cst.contact_objid IS NULL
  THEN
    o_response := 'FAILED: CONTACT NOT FOUND';
    --
    UPDATE x_wfm_acct_migration_bill_stg
    SET    async_status = 'ASYNC_FAILED',
           async_response = o_response
    WHERE  objid = billdateextract(1).objid;

     UPDATE x_wfm_async_request_log
     SET    status_message = o_response
     WHERE  objid          = n_async_req_objid;

    --
    RETURN;
  END IF;


  -- need the user objid for call trans
  n_user_objid := 268435556;

  dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' Before LDAP Update ');

  -- update contact details min and security pin to ldap
  contact_pkg.p_update_ldap ( i_esn        => i_esn          ,
                              o_error_code => c_ldap_err_num ,
                              o_error_msg  => c_ldap_err_msg );

  --
  IF c_ldap_err_msg NOT LIKE '%SUCCESS%' THEN
    o_response := 'LDAP WARNING :' || c_ldap_err_msg; -- Error capturing starts here ,we will append error to o_response after this
  END IF;
  --
  dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' After LDAP Update ');
  dbms_output.put_line ('CT ESN '||cst.esn);

  IF cst.site_part_status  = 'Active'  THEN
    --
    ct := call_trans_type ();
    -- populate call trans type with all information
    ct := call_trans_type (i_call_trans2site_part            => cst.site_part_objid,
                           i_action_type                     => i_action_type,
                           i_call_trans2carrier              => cst.carrier_objid,
                           i_call_trans2dealer               => cst.inv_bin_objid,
                           i_call_trans2user                 => n_user_objid,
                           i_line_status                     => NULL,
                           i_min                             => cst.min,
                           i_esn                             => cst.esn,
                           i_sourcesystem                    => i_source_system,
                           i_transact_date                   => SYSDATE,
                           i_total_units                     => 0,
                           i_action_text                     => i_action_text,
                           i_reason                          => INITCAP (i_action_text),
                           i_result                          => i_call_trans_result, -- Migrated
                           i_sub_sourcesystem                => cst.bus_org_id,
                           i_iccid                           => cst.iccid,
                           i_ota_req_type                    => NULL,
                           i_ota_type                        => NULL,
                           i_call_trans2x_ota_code_hist      => NULL,
                           i_new_due_date                    => cst.expiration_date );
    -- call save method
    -- insert does a retrieve internally which is unnecessary in this case as all information is already being passed
      --
  -- dbms_output.put_line ('CTT ESN '||ct.esn);
    ct := ct.save;

    IF ct.response NOT LIKE '%SUCCESS%'
    THEN
       --
      o_response := 'ERROR CREATING CALL TRANS'; -- || ct.response;
      --
      UPDATE x_wfm_acct_migration_bill_stg
      SET  async_status   = 'ASYNC_FAILED',
           async_response =  'ERROR CREATING CALL TRANS :' || ct.response
      WHERE objid         = billdateextract(1).objid;

      UPDATE x_wfm_async_request_log
      SET    status_message = o_response
      WHERE  objid          = n_async_req_objid;


      RETURN;
    END IF;
    dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' After call trans ');
    -- CREATE TASK
   /* tt := task_type ( i_call_trans_objid       => ct.call_trans_objid,
                      i_contact_objid          => cst.contact_objid,
                      i_order_type             => i_order_type,
                      i_bypass_order_type      => 0,
                      i_case_code              => 0);  */

    -- hardcode the order_type_objid = 268937437 to use wfm carrier and order type
    t.order_type_objid := 268937437 ;
   /* t.order_type_objid := t.get_order_type_objid (  i_min           => cst.min ,
                                                    i_order_type    => i_order_type ,
                                                    i_carrier_objid => cst.carrier_objid ,
                                                    i_technology    => cst.technology );*/
    --
    t.title            :=  'T-MOBILE WFM DATA MIGRATION HANDLER';
    t.notes            := ':  ********** New Action Item *********** :' || CHR(10) || CHR(13) || ' ActionTitle:  ' || tt.title || CHR(10) || CHR(13) || 'Originator: ' || USER || CHR(10) || CHR(13) || ' Create Time: ' || SYSDATE;

     dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' Before task type call ');
		--
    t := task_type ( i_title                       => 'T-MOBILE WFM DATA MIGRATION HANDLER',
                     i_case_code                   => NULL,
                     i_notes                       => t.notes,
                     i_update_stamp                => SYSDATE,
                     i_original_method             => 'AOL',
                     i_current_method              => 'AOL',
                     i_task_priority2gbst_elm      => NULL,
                     i_task_sts2gbst_elm           => NULL,
                     i_type_task2gbst_elm          => NULL,
                     i_contact_objid               => cst.contact_objid,
                     i_task_wip2wipbin             => NULL,
                     i_call_trans_objid            => ct.call_trans_objid,
                     i_task_originator2user        => n_user_objid,
                     i_order_type_objid            => t.order_type_objid,--need to check
                     i_ota_type                    => NULL);

    dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' Before task type call save ');
    --
    -- CALL Save METHOD TO CREATE TASK
    tt.response := tt.save(t) ;

    IF tt.response NOT LIKE '%SUCCESS%'
    THEN
      o_response := 'ERROR CREATING TASK';-- || tt.response;
      --
      UPDATE x_wfm_acct_migration_bill_stg
      SET  async_status   = 'ASYNC_FAILED',
           async_response =  'ERROR CREATING TASK :' || tt.response
      WHERE objid         = billdateextract(1).objid;

      UPDATE x_wfm_async_request_log
      SET    status_message = o_response
      WHERE  objid          = n_async_req_objid;

      RETURN;
    END IF;
    dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' Before taskt type');
    --IF EVERYTHING IS SUCCESSFUL SO FAR, THEN ITS TIME TO CREATE IG
    -- GET THE CARRIER_ID

    --assign direct value hard coded
    ig.carrier_id := '180260';

    -- load template: juda: maybe we can hardcode it
    ig.template :=  'TMOBILE';

    -- get order type
    ig.order_type := 'DMH';

    -- call constructor to initialize ig transaction
     dbms_output.put_line ('cst rate plan :'||cst.rate_plan);

    ig := ig_transaction_type ( i_action_item_id            => t.task_id,
                                i_carrier_id                => ig.carrier_id, --need to add as input parameter
                                i_order_type                => ig.order_type,
                                i_min                       => cst.MIN,
                                i_esn                       => cst.esn,
                                i_esn_hex                   => NULL,
                                i_old_esn                   => NULL,
                                i_old_esn_hex               => NULL,
                                i_pin                       => NULL,
                                i_phone_manf                => cst.phone_manufacturer,
                                i_end_user                  => NULL,
                                i_account_num               => NULL,
                                i_market_code               => NULL,
                                i_rate_plan                 => cst.rate_plan,
                                i_ld_provider               => NULL,
                                i_sequence_num              => NULL,
                                i_dealer_code               => NULL,
                                i_transmission_method       => 'AOL',
                                i_fax_num                   => NULL,
                                i_online_num                => NULL,
                                i_email                     => NULL,
                                i_network_login             => CASE WHEN ig.template IN ('TMOBILE','TMOSM','TMOUN') THEN 'tracfone' ELSE NULL END,
                                i_network_password          => CASE WHEN ig.template IN ('TMOBILE','TMOSM','TMOUN') THEN 'Tr@cfon3' ELSE NULL END,
                                i_system_login              => NULL,
                                i_system_password           => NULL,
                                i_template                  => ig.template,
                                i_exe_name                  => NULL,
                                i_com_port                  => NULL,
                                i_status                    => 'S',
                                i_status_message            => 'Migration Successful',
                                i_fax_batch_size            => NULL,
                                i_fax_batch_q_time          => NULL,
                                i_expidite                  => NULL,
                                i_trans_prof_key            => NULL,
                                i_q_transaction             => NULL,
                                i_online_num2               => NULL,
                                i_fax_num2                  => NULL,
                                i_creation_date             => SYSDATE,
                                i_update_date               => SYSDATE,
                                i_blackout_wait             => SYSDATE,
                                i_tux_iti_server            => NULL,
                                i_transaction_id            => gw1.trans_id_seq.NEXTVAL,
                                i_technology_flag           => SUBSTR (cst.technology, 1, 1),
                                i_voice_mail                => NULL,
                                i_voice_mail_package        => NULL,
                                i_caller_id                 => NULL,
                                i_caller_id_package         => NULL,
                                i_call_waiting              => NULL,
                                i_call_waiting_package      => NULL,
                                i_rtp_server                => NULL,
                                i_digital_feature_code      => NULL,
                                i_state_field               => NULL,
                                i_zip_code                  => cst.zipcode,
                                i_msid                      => cst.MIN,
                                i_new_msid_flag             => NULL,
                                i_sms                       => NULL,
                                i_sms_package               => NULL,
                                i_iccid                     => cst.iccid,
                                i_old_min                   => NULL,
                                i_digital_feature           => NULL,
                                i_ota_type                  => NULL,
                                i_rate_center_no            => NULL,
                                i_application_system        => 'IG',
                                i_subscriber_update         => NULL,
                                i_download_date             => NULL,
                                i_prl_number                => NULL,
                                i_amount                    => NULL,
                                i_balance                   => NULL,
                                i_language                  => NULL,
                                i_exp_date                  => NULL,
                                i_x_mpn                     => NULL,
                                i_x_mpn_code                => NULL,
                                i_x_pool_name               => NULL,
                                i_imsi                      => NULL,
                                i_new_imsi_flag             => NULL );

    -- call ins method
    --ig.response := NULL; -- resetting the response from constructor
    igt := ig.ins;

    dbms_output.put_line ('ig response  '||igt.response);

    -- IG SHOULD NOT FAIL, HOWEVER IT IT DOES, WE SHOULD LOG IT
    IF igt.response  LIKE '%ERROR INSERTING IG RECORD%'
    THEN
      o_response := 'ERROR CREATING IG'; -- || igt.response;
      --
      UPDATE x_wfm_acct_migration_bill_stg
      SET    async_status   = 'ASYNC_FAILED',
             async_response =  'ERROR CREATING IG :' || igt.response  ,
             call_trans_objid = ct.call_trans_objid
      WHERE  objid = billdateextract(1).objid;

      UPDATE x_wfm_async_request_log
      SET    status_message = o_response
      WHERE  objid          = n_async_req_objid;

      RETURN;
    END IF;

    dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' After IG insert');

    -- create spr
    sub := subscriber_type();

    sub.pcrf_esn := cst.esn;

    -- call insert method for spr
    sub := sub.ins;

    -- check status, if not successful
    IF sub.status NOT LIKE '%SUCCESS%' THEN
      -- CONFIRM IF IGNORE THE ERROR OR APPEND TO RESPONSE
      o_response := o_response||'|'||'SPR WARNING :'||sub.status;
    END IF;

    --update program parameter in SPR
    IF billdateextract(1).auto_refill_flag = 'Y' THEN

      -- query the pivot and part number table to get the app part class name
       BEGIN
        SELECT
         pc.name INTO c_sp_part_class_name
         FROM service_plan_feat_pivot_mv mv,
         table_part_num pn,
         table_part_class pc
        WHERE
         mv.service_plan_objid            = cst.service_plan_objid
         AND mv.plan_purchase_part_number = pn.part_number
         AND pn.part_num2part_class       = pc.objid ;
       EXCEPTION
         WHEN OTHERS THEN
         c_sp_part_class_name := NULL;
       END ;

       IF c_sp_part_class_name IS NOT NULL THEN
        sa.service_profile_pkg.update_program_parameter ( i_min                =>  i_min  ,
                                                          i_part_class_name    =>  c_sp_part_class_name,
                                                          i_action             =>  'ENROLL' ,
                                                          o_err_code           =>  c_upp_err_code ,
                                                          o_err_msg            =>  c_upp_err_msg);

        IF c_upp_err_msg NOT LIKE '%SUCCESS%' THEN
          o_response := o_response||'|'||'PP UPDATE WARNING :'||c_upp_err_msg;
        END IF;

       END IF;



     END IF;

     -- juda: added this condition
     IF sub.status LIKE '%SUCCESS%' THEN

      -- create pcrf transaction records
      pcrf := pcrf_transaction_type ( i_esn               => sub.pcrf_esn,
                                      i_min               => sub.pcrf_min,
                                      i_order_type        => 'UP',
                                      i_zipcode           => sub.zipcode,
                                      i_sourcesystem      => i_source_system,
                                      i_pcrf_status_code  => 'Q');

      -- call insert method to create pcrf transaction row
      pcrf := pcrf.ins;

      IF pcrf.status NOT LIKE '%SUCCESS%' THEN
        o_response := o_response||'|'||'PCRF WARNING :' || pcrf.status;
      END IF;
    END IF;


    dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' Before enqueue call');

    -- enqueue transaction for BRM
    sa.enqueue_transactions_pkg.enqueue_migration (i_esn               =>  i_esn                ,
                                                   i_min               =>  i_min                ,
                                                   i_web_user_objid    =>  cst.web_user_objid   ,
                                                   i_bus_org_id        =>  cst.bus_org_id       ,
                                                   i_sourcesystem      =>  i_source_system      ,
                                                   i_ct_objid          =>  ct.call_trans_objid  ,
                                                   i_ct_action_type    =>  ct.action_type       ,
                                                   i_ct_action_text    =>  ct.action_text       ,
                                                   i_ct_reason         =>  ct.reason            ,
                                                   i_ig_order_type     =>  igt.order_type       ,
                                                   i_ig_transaction_id =>  igt.transaction_id   ,
                                                   i_event_name        =>  i_order_type         ,
                                                   o_response          =>  c_enqueue_response   );

    dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' After enqueue call');

    dbms_output.put_line ('ENQ RESP'|| c_enqueue_response);

    IF c_enqueue_response NOT LIKE '%SUCCESS%' THEN
      o_response := o_response||'|'||'ENQUEUE WARNING :' || c_enqueue_response;
    END IF;

    dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' Before throttle processing ');

    -- IG WAS SUCCESSFUL, PROCESSING BUCKETS (IF PASSED)
    IF   i_igtb_wfm_async_tab IS NOT NULL
    THEN
      IF i_igtb_wfm_async_tab.COUNT > 0
      THEN

        -- LOOP THROUGH THE COLLECTION TO CREATE IG_TRANSACTION_BUCKETS RECORD
        FOR i IN 1 .. i_igtb_wfm_async_tab.COUNT
        LOOP
          -- RESET VARIABLES FOR EACH EXECUTION OF LOOP
          c_cos               := NULL;
          c_throttle_err_code := NULL;
          c_throttle_response := NULL;
          c_bucket_type       := NULL;

          -- CHECK BUCKET_ID AND BUCKET_VALUE..IF MISSING, SKIP CREATING RECORDS
          IF    i_igtb_wfm_async_tab (i).bucket_id IS NULL
             OR i_igtb_wfm_async_tab (i).bucket_value IS NULL
          THEN
            o_response := o_response ||'|'|| ' SKIPPED CREATING BUCKET '|| i_igtb_wfm_async_tab (i).bucket_id;
            CONTINUE;
          END IF;

          --
          igate.insert_ig_transaction_buckets ( i_ig_transaction_id      => igt.transaction_id                        ,
                                                i_bucket_id              => i_igtb_wfm_async_tab (i).bucket_id       ,
                                                i_bucket_value           => i_igtb_wfm_async_tab (i).bucket_value    ,
                                                i_bucket_balance         => NULL                                     ,
                                                i_bucket_expiration_date => i_igtb_wfm_async_tab (i).expiration_date ,
                                                i_benefit_type           => NULL    );

          -- update to update recharge date
          UPDATE ig_transaction_buckets
          SET    recharge_date  = i_igtb_wfm_async_tab(i).effective_date
          WHERE  transaction_id = igt.transaction_id
          AND    bucket_id      = i_igtb_wfm_async_tab(i).bucket_id;
          --
        END LOOP;
      END IF; -- IF i_igtb_wfm_async_tab.COUNT > 0
    END IF; -- IF i_igtb_wfm_async_tab IS NOT NULL
    --
  END IF; -- IF cst.site_part_status = 'Active';
  --
  dbms_output.put_line (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss')||' After throttle processing ');


  -- return success
  o_response := CASE WHEN o_response IS NULL THEN 'SUCCESS' ELSE 'SUCCESS'||'|'||o_response END;

  --
  UPDATE x_wfm_acct_migration_bill_stg
  SET    async_status     = 'ASYNC_COMPLETED',
         async_response   = o_response,
	       call_trans_objid = ct.call_trans_objid
  WHERE  objid = billdateextract(1).objid;

  o_response  := 'SUCCESS'; -- returning success to mask warning errors

  UPDATE x_wfm_async_request_log
  SET    status_message = o_response
  WHERE  objid          = n_async_req_objid;

  --
EXCEPTION
  WHEN OTHERS
  THEN
     o_response := o_response||'|'||'ERROR IN PROCESS WFM ASYNC'||sqlerrm;
     dbms_output.put_line('Error '||sqlerrm);

     UPDATE x_wfm_async_request_log
     SET    status_message = o_response
     WHERE  objid = n_async_req_objid   ;

     IF billdateextract.COUNT > 0 THEN
       UPDATE x_wfm_acct_migration_bill_stg
       SET    migration_response = migration_response||'|'||'ASYNC RESPONSE : '||o_response
       WHERE  objid = billdateextract(1).objid;
     END IF;
    --
END reprocess_wfm_async_full;
--
--
-- Procedure to load credit card data
PROCEDURE load_wfm_cc_data ( i_max_row_limit      IN    NUMBER DEFAULT 1000 ,
                             i_commit_every_rows  IN    NUMBER DEFAULT 5000 ,
                             o_response           OUT   VARCHAR2            ) IS
  --cursor declaration
  --CR47564 changes by Sagar start
  CURSOR credit_card_cur
  IS
    SELECT ccp.rowid cc_stg_rowid, ccp.*
    FROM   x_wfm_cc_payment_stg ccp
    WHERE  record_status = 'PENDING'
     AND exists (select 1 from wfmmig.x_wfm_acct_migration_bill_stg stg where stg.ban = ccp.ban   AND     stg.pah_indicator  = 'Y'    AND     stg.async_status   = 'ASYNC_COMPLETED')
    AND    ROWNUM <= i_max_row_limit;

  CURSOR acct_migration_cur (c_ban IN VARCHAR2)
  IS
    SELECT  web_user_objid, zipcode, email, address_1, address_2, city, state,first_name, last_name,min,bus_org_id
    FROM    x_wfm_acct_migration_bill_stg
    WHERE   ban            = c_ban
    AND     pah_indicator  = 'Y'
    AND     async_status   = 'ASYNC_COMPLETED';

  acct_migration_rec  acct_migration_cur%ROWTYPE;

  lv_email              VARCHAR2(100);
  lv_address_1          VARCHAR2(200);
  lv_address_2          VARCHAR2(200);
  lv_city               VARCHAR2(50);
  lv_state              VARCHAR2(2);
  lv_country            VARCHAR2(300);
  lv_zipcode            VARCHAR2(30);
  n_count_rows          NUMBER := 0;
  --CR47564 changes by Sagar end
  psd_cc                sa.payment_source_detail_type := sa.payment_source_detail_type();
  n_err_num             NUMBER       ;
  c_err_msg             VARCHAR2(100);
  n_payment_source_id   NUMBER;
BEGIN
  --Loop through the cursor to retrieve each credit card record_status
  FOR cc_rec IN credit_card_cur
  LOOP
    c_err_msg := NULL;
    --CR47564 changes by Sagar start
    --Check if the BAN exists in the migration stg table
    OPEN acct_migration_cur (cc_rec.ban);
    FETCH acct_migration_cur INTO acct_migration_rec;
    IF acct_migration_cur%NOTFOUND
    THEN
      UPDATE  wfmmig.x_wfm_cc_payment_stg
      SET     record_status        =  'FAILED',
              record_response      =  'BAN DOES NOT EXIST IN MIGRATION STAGING TABLE'
      WHERE   rowid  = cc_rec.cc_stg_rowid;
      CLOSE acct_migration_cur;
      CONTINUE;
    END IF;
	--
    CLOSE acct_migration_cur;

    IF acct_migration_rec.web_user_objid IS NULL
    THEN
      UPDATE  wfmmig.x_wfm_cc_payment_stg
      SET     record_status        =  'FAILED',
              record_response      =  'WEB USER DOES NOT EXIST FOR THE GIVEN BAN'
      WHERE   rowid  = cc_rec.cc_stg_rowid;
      CONTINUE;
    END IF;

    --Check if CC zipcode matches with BAN zipcode
    IF cc_rec.cc_zipcode = acct_migration_rec.zipcode
    THEN
      --Assign BAN address details
      lv_email      := acct_migration_rec.email;
      lv_address_1  := acct_migration_rec.address_1;
      lv_address_2  := acct_migration_rec.address_2;

      --Get the city and state from table_x_zip_code
      BEGIN
        SELECT x_city,
               x_state
        INTO   lv_city,
               lv_state
        FROM   table_x_zip_code
        WHERE  x_zip = cc_rec.cc_zipcode;
      EXCEPTION
        WHEN OTHERS THEN
          lv_city := acct_migration_rec.city;
          lv_state := acct_migration_rec.state;
      END;

      lv_country    := 'USA';
    ELSE
      --Assign hardcoded address details along with credit card zipcode
      lv_email      := acct_migration_rec.email;
      lv_address_1  := '1295 Charleston Road';
      lv_address_2  := NULL;
      lv_city       := 'Mountain View';
      lv_state      := 'CA';
      lv_country    := 'USA';
    END IF;

    lv_zipcode    := cc_rec.cc_zipcode;
    --CR47564 changes by Sagar end

    psd_cc := sa.payment_source_detail_type(NULL,                                                             --PAYMENT_SOURCE_ID
                                            'CREDITCARD',                                                     --PAYMENT_TYPE
                                            cc_rec.cc_status,                                                 --PAYMENT_STATUS
                                            NULL,                                                             --PAYMENT_SRC_NAME
                                            NULL,                                                             --IS_DEFAULT
                                            lv_email,                                                         --USER_ID
                                            acct_migration_rec.first_name,                                    --FIRST_NAME
                                            acct_migration_rec.last_name,                                     --LAST_NAME
                                            lv_email,                                                         --EMAIL
                                            acct_migration_rec.min,                                           --PHONE_NUMBER
                                            NULL,                                                             --SECURE_DATE
                                            sa.address_type_rec(lv_address_1,                                 --ADDRESS_1
                                                                lv_address_2,                                 --ADDRESS_2
                                                                lv_city,                                      --CITY
                                                                lv_state,                                     --STATE
                                                                lv_country,                                   --COUNTRY
                                                                lv_zipcode                                    --ZIPCODE
                                                                ),
                                            sa.typ_creditcard_info(cc_rec.cc_number,                          --MASKED_CARD_NUMBER
                                                                   cc_rec.cc_type,                            --CARD_TYPE
                                                                   cc_rec.cc_expmo||'-'||cc_rec.cc_expyr,     --EXP_DATE
                                                                   NULL,                                      --SECURITY_CODE
                                                                   cc_rec.cc_customer_cv_number,              --CVV
                                                                   cc_rec.cc_num_enc,                         --CC_ENC_NUMBER
                                                                   cc_rec.cc_num_key,                         --CC_NUM_KEY
                                                                   cc_rec.cc_cert_cc_algo,                    --CC_ENC_ALGORITHM
                                                                   cc_rec.CC_CERT_KEY_ALGO,                   --KEY_ENC_ALGORITHM
                                                                   cc_rec.CC_CERT                             --CC_ENC_CERT
                                                                  ),
                                            sa.typ_ach_info(NULL,                                             --ROUTING_NUMBER
                                                            NULL,                                             --ACCOUNT_NUMBER
                                                            NULL,                                             --ACCOUNT_TYPE
                                                            NULL,                                             --CUSTOMER_ACCT_KEY
                                                            NULL,                                             --CUSTOMER_ACCT_ENC
                                                            NULL,                                             --CERT
                                                            NULL,                                             --KEY_ALGO
                                                            NULL                                              --CC_ALGO
                                                           ),
                                            sa.typ_aps_info(NULL,                                             --ALT_PYMT_SOURCE
                                                            NULL,                                             --ALT_PYMT_SOURCE_TYPE
                                                            NULL                                              --APPLICATION_KEY
                                                           )
                                            );

    --Invoking the addpaymentsource for given login name
    sa.payment_services_pkg.addpaymentsource(i_esn                       => NULL               ,
                                             i_min                       => NULL               ,
                                             i_login_name                => acct_migration_rec.email,
                                             i_bus_org                   => acct_migration_rec.bus_org_id,
                                             i_payment_source_detail_rec => psd_cc             ,
                                             o_payment_source_id         => n_payment_source_id,
                                             o_err_num                   => n_err_num          ,
                                             o_err_msg                   => c_err_msg);

    --DBMS_OUTPUT.PUT_LINE('n_payment_source_id:'||n_payment_source_id);
    --DBMS_OUTPUT.PUT_LINE('n_err_num          :'||n_err_num);
    --DBMS_OUTPUT.PUT_LINE('c_err_msg          :'||c_err_msg);

    UPDATE  wfmmig.x_wfm_cc_payment_stg
    SET     payment_source_objid =  n_payment_source_id,
             web_user_objid      = acct_migration_rec.web_user_objid,
            record_status        =  DECODE (UPPER(c_err_msg), 'SUCCESS',  'COMPLETED' ,'FAILED') ,
            record_response      =  DECODE (UPPER(c_err_msg), 'SUCCESS',  'SUCCESS' ,c_err_msg)
    WHERE   rowid  = cc_rec.cc_stg_rowid;



    -- increase row count
    n_count_rows := n_count_rows + 1;

    IF (MOD (n_count_rows, i_commit_every_rows) = 0)
    THEN
      -- Save changes
      COMMIT;
    END IF;
  END LOOP;

  --DBMS_OUTPUT.PUT_LINE('STATUS          :'||'SUCCESS');

  o_response := 'SUCCESS';
 COMMIT;
 EXCEPTION
   WHEN OTHERS THEN
     o_response := 'ERROR IN LOAD_WFM_CC_DATA: ' || SQLERRM;
END load_wfm_cc_data;

--  Procedure to load ach details
PROCEDURE load_wfm_ach_data ( i_max_row_limit      IN    NUMBER DEFAULT 1000,
                              i_commit_every_rows  IN    NUMBER DEFAULT 5000,
                              o_response           OUT   VARCHAR2           ) IS
  --cursor declaration
  --CR47564 changes by Sagar start
  CURSOR ach_cur
  IS
    SELECT ach.rowid ach_stg_rowid, ach.*
    FROM   x_wfm_ach_payment_stg        ach
    WHERE  record_status = 'PENDING'
    AND exists (select 1 from wfmmig.x_wfm_acct_migration_bill_stg stg where stg.ban = ach.ban   AND     stg.pah_indicator  = 'Y'    AND     stg.async_status   = 'ASYNC_COMPLETED')
    AND    ROWNUM <= i_max_row_limit;


  CURSOR acct_migration_cur (c_ban IN VARCHAR2)
  IS
    SELECT  web_user_objid, zipcode, email, address_1, address_2, city, state,first_name, last_name,min,bus_org_id
    FROM    x_wfm_acct_migration_bill_stg
    WHERE   ban            = c_ban
    AND     pah_indicator  = 'Y'
    AND     async_status   = 'ASYNC_COMPLETED';


  acct_migration_rec  acct_migration_cur%ROWTYPE;

  lv_email              VARCHAR2(100);
  lv_address_1          VARCHAR2(200);
  lv_address_2          VARCHAR2(200);
  lv_city               VARCHAR2(50);
  lv_state              VARCHAR2(2);
  lv_country            VARCHAR2(300);
  lv_zipcode            VARCHAR2(30);
  n_count_rows         NUMBER := 0;
  --CR47564 changes by Sagar end
  psd_ach               sa.payment_source_detail_type := sa.payment_source_detail_type();
  n_err_num             NUMBER;
  c_err_msg             VARCHAR2(100);
  n_payment_source_id   NUMBER;
BEGIN
  --Loop through the cursor to load ach data
  FOR ach_rec IN ach_cur
  LOOP
    --CR47564 changes by Sagar start
    c_err_msg := NULL;

    --Check if the BAN exists in the migration stg table
    OPEN acct_migration_cur (ach_rec.ban);
    FETCH acct_migration_cur INTO acct_migration_rec;
    IF acct_migration_cur%NOTFOUND
    THEN
      UPDATE  wfmmig.x_wfm_ach_payment_stg
      SET     record_status        =  'FAILED',
              record_response      =  'BAN DOES NOT EXISTS IN MIGRATION STAGING TABLE'
      WHERE   rowid  = ach_rec.ach_stg_rowid;
      CLOSE acct_migration_cur;
      CONTINUE;
    END IF;
    CLOSE acct_migration_cur;

    IF acct_migration_rec.web_user_objid IS NULL
    THEN
      UPDATE  wfmmig.x_wfm_ach_payment_stg
      SET     record_status        =  'FAILED',
              record_response      =  'WEB USER DOES NOT EXIST FOR THE GIVEN BAN'
      WHERE   rowid  = ach_rec.ach_stg_rowid;
      CONTINUE;
    END IF;

    -- Check if ACH zipcode matches with BAN zipcode
    IF ach_rec.ach_zipcode = acct_migration_rec.zipcode
    THEN
      --Assign BAN address details
      lv_email      := acct_migration_rec.email;
      lv_address_1  := acct_migration_rec.address_1;
      lv_address_2  := acct_migration_rec.address_2;

      --Get the city and state from table_x_zip_code
      BEGIN
        SELECT x_city,
               x_state
        INTO   lv_city,
               lv_state
        FROM   table_x_zip_code
        WHERE  x_zip = ach_rec.ach_zipcode;
      EXCEPTION
        WHEN OTHERS THEN
          lv_city := acct_migration_rec.city;
          lv_state := acct_migration_rec.state;
      END;

      lv_country    := 'USA';
    ELSE
      --Assign hardcoded address details
      lv_email      := acct_migration_rec.email;
      lv_address_1  := '1295 Charleston Road';
      lv_address_2  := NULL;
      lv_city       := 'Mountain View';
      lv_state      := 'CA';
      lv_country    := 'USA';
    END IF;

    lv_zipcode    := ach_rec.ach_zipcode;
    --CR47564 changes by Sagar end

    psd_ach := sa.payment_source_detail_type(NULL,                                                --PAYMENT_SOURCE_ID
                                             'ACH',                                               --PAYMENT_TYPE
                                             ach_rec.ach_status,                                  --PAYMENT_STATUS
                                             NULL,                                                --PAYMENT_SRC_NAME
                                             NULL,                                                --IS_DEFAULT
                                             lv_email,                                            --USER_ID
                                             acct_migration_rec.first_name,                      --FIRST_NAME
                                             acct_migration_rec.last_name,                       --LAST_NAME
                                             lv_email,                                            --EMAIL
                                             acct_migration_rec.min,                              --PHONE_NUMBER
                                             NULL,                                                --SECURE_DATE
                                             sa.address_type_rec(lv_address_1,                    --ADDRESS_1
                                                                 lv_address_2,                    --ADDRESS_2
                                                                 lv_city,                         --CITY
                                                                 lv_state,                        --STATE
                                                                 lv_country,                      --COUNTRY
                                                                 lv_zipcode                       --ZIPCODE
                                                                 ),
                                             sa.typ_creditcard_info(NULL,                         --MASKED_CARD_NUMBER
                                                                    NULL,                         --CARD_TYPE
                                                                    NULL,                         --EXP_DATE
                                                                    NULL,                         --SECURITY_CODE
                                                                    NULL,                         --CVV
                                                                    NULL,                         --CC_ENC_NUMBER
                                                                    NULL,                         --CC_NUM_KEY
                                                                    NULL,                         --CC_ENC_ALGORITHM
                                                                    NULL,                         --KEY_ENC_ALGORITHM
                                                                    NULL                          --CC_ENC_CERT
                                                                   ),
                                             sa.typ_ach_info(ach_rec.ach_routing_number,          --ROUTING_NUMBER
                                                             ach_rec.ach_account_number,          --ACCOUNT_NUMBER
                                                             ach_rec.ach_account_type,            --ACCOUNT_TYPE
                                                             ach_rec.ach_customer_acct_key,       --CUSTOMER_ACCT_KEY
                                                             ach_rec.ach_customer_acct_enc,       --CUSTOMER_ACCT_ENC
                                                             ach_rec.ach_cert,                    --CERT
                                                             ach_rec.ach_cert_key_algo,           --KEY_ALGO
                                                             ach_rec.ach_cert_cc_algo             --ach_ALGO
                                                            ),
                                             sa.typ_aps_info(NULL,                                --ALT_PYMT_SOURCE
                                                             NULL,                                --ALT_PYMT_SOURCE_TYPE
                                                             NULL                                 --APPLICATION_KEY
                                                            )
                                             );

    --Invoking the addpaymentsource for given login name
    sa.payment_services_pkg.addpaymentsource ( i_esn                       => NULL,
                                               i_min                       => NULL,
                                               i_login_name                => acct_migration_rec.email,
                                               i_bus_org                   => acct_migration_rec.bus_org_id,
                                               i_payment_source_detail_rec => psd_ach,
                                               o_payment_source_id         => n_payment_source_id,
                                               o_err_num                   => n_err_num,
                                               o_err_msg                   => c_err_msg);
    --
    --DBMS_OUTPUT.PUT_LINE('n_payment_source_id:'||n_payment_source_id);
    --DBMS_OUTPUT.PUT_LINE('n_err_num          :'||n_err_num          );
    --DBMS_OUTPUT.PUT_LINE('c_err_msg          :'||c_err_msg          );
    --
    UPDATE  wfmmig.x_wfm_ach_payment_stg
    SET     payment_source_objid =  n_payment_source_id,
            web_user_objid       = acct_migration_rec.web_user_objid,
             record_status       =  DECODE (UPPER(c_err_msg), 'SUCCESS',  'COMPLETED' ,'FAILED') ,
            record_response      =  DECODE (UPPER(c_err_msg), 'SUCCESS',  'SUCCESS' ,c_err_msg)
    WHERE   rowid  = ach_rec.ach_stg_rowid;

    -- increase row count
    n_count_rows := n_count_rows + 1;

    IF (MOD (n_count_rows, i_commit_every_rows) = 0)
    THEN
      -- Save changes
      COMMIT;
    END IF;
  END LOOP;

  --DBMS_OUTPUT.PUT_LINE('STATUS          :'||'SUCCESS');

  o_response := 'SUCCESS';
  COMMIT;
EXCEPTION
  WHEN OTHERS
  THEN
    o_response := 'ERROR IN LOAD_WFM_ACH_DATA: ' || SQLERRM;
END load_wfm_ach_data;

--WFM CR47564 Load  WFM Interactions
PROCEDURE load_wfm_interaction (  i_max_row_limit      IN  NUMBER DEFAULT 1000,
                                  i_commit_every_rows  IN  NUMBER DEFAULT 5000,
                                  i_divisor            IN  NUMBER DEFAULT  1,
                                  i_remainder          IN  NUMBER DEFAULT  0,
                                  o_response           OUT VARCHAR2 ) IS
  CURSOR c_wfm_acct_migration
  IS
    SELECT  *
    FROM   (SELECT *
            FROM   x_wfm_acct_migration_stg
            WHERE  migration_status     = 'PREMIGRATION_COMPLETED'
            AND    MOD(ban,i_divisor)   = i_remainder
            AND    migration_response   NOT LIKE '%Interaction Loaded%'
           -- ORDER BY ban ASC, pah_indicator DESC
           )
    WHERE  ROWNUM <= i_max_row_limit;

  CURSOR c_get_interactions (i_min IN VARCHAR2)
  IS
    SELECT /*+ index (stg idx1_wfm_interactions_stg) */ *
    FROM   x_wfm_interactions_stg stg
    WHERE  min = i_min
    AND    record_status = 'PENDING';

  n_interact_objid NUMBER;
  n_count          NUMBER :=0;
  n_count_rows     NUMBER :=0;
  c_response       VARCHAR2(1000);

BEGIN

  FOR rec_acct_migration IN c_wfm_acct_migration
  LOOP
    BEGIN
      n_count  := 0; --reset for each  MIN
      FOR rec_interactions IN c_get_interactions (rec_acct_migration.min )
      LOOP
        n_interact_objid := NULL;
	c_response       := NULL;
                    /*Populating table_phone_log , table_interact, table_interact_ext tables */
        IF(rec_acct_migration.contact_objid IS NOT NULL AND rec_acct_migration.esn IS NOT NULL) THEN
          ins_interaction ( i_contact_objid  => rec_acct_migration.contact_objid ,
                            i_reason_1       => rec_interactions.memo_code_desc,
                            i_reason_2       => rec_interactions.memo_code||' - '||rec_interactions.memo_code_desc,
                            i_notes          => NVL(rec_interactions.memo_system_text,rec_interactions.memo_manual_text),
                            i_rslt           => 'Successful',
                            i_user           => 'SA',
                            i_esn            => rec_acct_migration.esn,
                            i_create_date    => NVL(rec_interactions.memo_date,SYSDATE),
                            i_start_date     => NVL(rec_interactions.memo_date,SYSDATE),
                            i_end_date       => NVL(rec_interactions.memo_date,SYSDATE),
                            o_interact_objid => n_interact_objid ,
                            o_response       => c_response);
        END IF;
      /*Updating record status  in x_wfm_interactions_stg table*/
        IF c_response NOT LIKE '%SUCCESS%' THEN
          UPDATE x_wfm_interactions_stg
          SET record_status  = 'FAILED',
            record_response  = c_response,
            update_timestamp = SYSDATE
          WHERE objid        = rec_interactions.objid;
        ELSE
          UPDATE x_wfm_interactions_stg
          SET record_status      = 'COMPLETED',
            record_response      = 'SUCCESS',
            update_timestamp     = SYSDATE,
            table_interact_objid = n_interact_objid
          WHERE objid            = rec_interactions.objid;
          --
          n_count:=n_count+1;
          --
        END IF;



       /* IF (MOD (n_count_rows, i_commit_every_rows) = 0)
        THEN
          -- Save changes
          COMMIT;
        END IF;    */

        --
      END LOOP;
    EXCEPTION
    WHEN OTHERS THEN
      CONTINUE;
    END;
    --
    IF (n_count>0) THEN
      UPDATE x_wfm_acct_migration_stg
      SET    migration_response = migration_response || '|'||'Interaction Loaded',
             update_timestamp   = SYSDATE
      WHERE  objid = rec_acct_migration.objid;
    END IF;

      n_count_rows := n_count_rows + 1;  --Committing by ESN count

    IF (MOD (n_count_rows, i_commit_every_rows) = 0) THEN
          -- Save changes
       COMMIT;
    END IF;
    --
  END LOOP;

  o_response := 'SUCCESS';
  COMMIT;
  --
 EXCEPTION
   WHEN OTHERS THEN
     o_response := 'ERROR LOADING INTERACTIONS: ' || SUBSTR(SQLERRM,1,1000);
END load_wfm_interaction;

PROCEDURE load_wfm_bill_interaction (  i_max_row_limit      IN  NUMBER DEFAULT 1000,
                                       i_commit_every_rows  IN  NUMBER DEFAULT 5000,
                                       i_divisor            IN  NUMBER DEFAULT  1,
                                       i_remainder          IN  NUMBER DEFAULT  0,
                                       o_response           OUT VARCHAR2 ) IS
  CURSOR c_wfm_acct_migration
  IS
    SELECT  *
    FROM   (SELECT *
            FROM   x_wfm_acct_migration_bill_stg
            WHERE  async_status     = 'ASYNC_COMPLETED'
            AND    MOD(ban,i_divisor)   = i_remainder
            AND    migration_response   NOT LIKE '%Interaction Loaded%'
           -- ORDER BY ban ASC, pah_indicator DESC
           )
    WHERE  ROWNUM <= i_max_row_limit;

  CURSOR c_get_interactions (i_min IN VARCHAR2)
  IS
    SELECT /*+ index (stg idx1_wfm_interactions_stg) */ *
    FROM   x_wfm_interactions_stg stg
    WHERE  min = i_min
    AND    record_status = 'PENDING';

  n_interact_objid NUMBER;
  n_count          NUMBER :=0;
  n_count_rows     NUMBER :=0;
  c_response       VARCHAR2(1000);

BEGIN

  FOR rec_acct_migration IN c_wfm_acct_migration
  LOOP
    BEGIN
      n_count  := 0; --reset for each  MIN
      FOR rec_interactions IN c_get_interactions (rec_acct_migration.min )
      LOOP
        n_interact_objid := NULL;
	c_response       := NULL;
                    /*Populating table_phone_log , table_interact, table_interact_ext tables */
        IF(rec_acct_migration.contact_objid IS NOT NULL AND rec_acct_migration.esn IS NOT NULL) THEN
          ins_interaction ( i_contact_objid  => rec_acct_migration.contact_objid ,
                            i_reason_1       => rec_interactions.memo_code_desc,
                            i_reason_2       => rec_interactions.memo_code||' - '||rec_interactions.memo_code_desc,
                            i_notes          => NVL(rec_interactions.memo_system_text,rec_interactions.memo_manual_text),
                            i_rslt           => 'Successful',
                            i_user           => 'SA',
                            i_esn            => rec_acct_migration.esn,
                            i_create_date    => NVL(rec_interactions.memo_date,SYSDATE),
                            i_start_date     => NVL(rec_interactions.memo_date,SYSDATE),
                            i_end_date       => NVL(rec_interactions.memo_date,SYSDATE),
                            o_interact_objid => n_interact_objid ,
                            o_response       => c_response);
        END IF;
      /*Updating record status  in x_wfm_interactions_stg table*/
        IF c_response NOT LIKE '%SUCCESS%' THEN
          UPDATE x_wfm_interactions_stg
          SET record_status  = 'FAILED',
            record_response  = c_response,
            update_timestamp = SYSDATE
          WHERE objid        = rec_interactions.objid;
        ELSE
          UPDATE x_wfm_interactions_stg
          SET record_status      = 'COMPLETED',
            record_response      = 'SUCCESS',
            update_timestamp     = SYSDATE,
            table_interact_objid = n_interact_objid
          WHERE objid            = rec_interactions.objid;
          --
          n_count:=n_count+1;
          --
        END IF;


       /* IF (MOD (n_count_rows, i_commit_every_rows) = 0)
        THEN
          -- Save changes
          COMMIT;
        END IF;    */

        --
      END LOOP;
    EXCEPTION
    WHEN OTHERS THEN
      CONTINUE;
    END;
    --
    IF (n_count>0) THEN
      UPDATE x_wfm_acct_migration_bill_stg
      SET    migration_response = migration_response || '|'||'Interaction Loaded',
             update_timestamp   = SYSDATE
      WHERE  objid = rec_acct_migration.objid;
    END IF;

    n_count_rows := n_count_rows + 1;

    IF (MOD (n_count_rows, i_commit_every_rows) = 0) THEN
          -- Save changes
       COMMIT;
    END IF;
    --
  END LOOP;

  o_response := 'SUCCESS';
  COMMIT;
  --
 EXCEPTION
   WHEN OTHERS THEN
     o_response := 'ERROR LOADING INTERACTIONS: ' || SUBSTR(SQLERRM,1,1000);
END load_wfm_bill_interaction;
--
END migration_pkg;
/