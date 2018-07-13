CREATE OR REPLACE PACKAGE sa.igateindvpkg
AS
/***************************************************************************
    Name         :  SA.IGATEINDVPKG
    Purpose      :  Recod type specifications
    Author       :  Gerald Pintado / Vanisri Adapa
    Date         :  ???
    Revisions    :
    Version     Date      Who       Purpose
    -------   --------  -------     --------------------------
    1.0         ???     GPintado    Initial revision
                        VAdapa
    1.1       07/07/04  VAdapa      CR2739 Changes
                                    A) Return SUI,TIMEOUT,DEBUG fields
                                    for a given transmission method based
                                    on technology
                                    B) Remove p_curr_method input parameter
                                        and Do not return current method
                                    C) Return OLD MIN
   1.2        05/26/05  VAdapa      CR3918 - Cingular MIN Change
                                    Return rate_center_no
   1.3      01/30/05    NLalovic    Cingular Next Available project changes:
                                    Record Type igateinforec was modified. New field "last_order_type"
                                    was added to it so that cursor variable can accept the value for this field
                                    in sp_ig_info procedure.
   /**************************************************************************/
   TYPE igateinforec
   IS
   RECORD(
      --      action_item_id                VARCHAR2 (25),
      --      current_method                VARCHAR2 (30),
      call_waiting VARCHAR2 (1),
      call_waiting_package VARCHAR2 (30),
      caller_id VARCHAR2 (1),
      caller_id_package VARCHAR2 (30),
      carrier_objid NUMBER,
      carrier_id NUMBER,
      carrier_mrkt_name VARCHAR2 (30),
      carrier_name VARCHAR2 (30),
      digital_feature_code VARCHAR2 (30),
      esn VARCHAR2 (30),
      esn_hex VARCHAR2 (20),
      ld_provider VARCHAR2 (50),
      MIN VARCHAR2 (30),
      msid VARCHAR2 (30),
      old_esn VARCHAR2 (30),
      old_esn_hex VARCHAR2 (20),
      pin VARCHAR2 (20),
      rate_plan VARCHAR2 (30),
      state_field VARCHAR2 (30),
      technology_flag VARCHAR2 (1),
      esn_technology VARCHAR2 (20),
      voice_mail VARCHAR2 (1),
      voice_mail_package VARCHAR2 (30),
      zip_code VARCHAR2 (20),
      line_status VARCHAR2 (10),
      sms NUMBER,
      sms_package VARCHAR2 (30),
      gsm_info VARCHAR2 (30),
      manf_info VARCHAR2 (20),
      old_min VARCHAR2(20),
      rate_center_no VARCHAR2(20),
      last_order_type VARCHAR2(30)
   );
   TYPE igateinfocursor
   IS
   REF CURSOR
   RETURN igateinforec;
   TYPE igateorderrec
   IS
   RECORD(
      order_type VARCHAR2 (1),
      account_num VARCHAR2 (30),
      market_code VARCHAR2 (30),
      dealer_code VARCHAR2 (30),
      network_login VARCHAR2 (30),
      network_password VARCHAR2 (30),
      transmission_method VARCHAR2 (30),
      template VARCHAR2 (80),
      sui NUMBER,  --CR2739 Changes
      timeout NUMBER,  --CR2739 Changes
      debug NUMBER --CR2739 Changes
   );
   TYPE igateordercursor
   IS
   REF CURSOR
   RETURN igateorderrec;
END igateindvpkg;
/