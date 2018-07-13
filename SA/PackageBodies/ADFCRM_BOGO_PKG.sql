CREATE OR REPLACE PACKAGE BODY sa.ADFCRM_BOGO_PKG
IS
  /*******************************************************************************************************
  --$RCSfile: ADFCRM_BOGO_PKB.sql,v $
  --$ $Log: ADFCRM_BOGO_PKB.sql,v $
  --$ Revision 1.6  2017/08/17 14:37:53  epaiva
  --$ CR48916 - additional logging
  --$
  --$ Revision 1.5  2017/08/02 20:38:30  epaiva
  --$ CR48916 update to Query  (used by uC140)
  --$
  --$
  *******************************************************************************************************/
  function get_bogopromotions_func(
    ip_part_class in varchar2,
    ip_part_number in varchar2,
    ip_bogo_part_number in varchar2)
  return get_bogo_rec_tab pipelined
    is

   channel_text varchar(10000);
   dealer_text varchar(10000);
   servPlan_text varchar(10000);

   get_bogo_rslt get_bogo_rec;
    cursor c_bogo_promo_info (p_part_number varchar2,p_bogo_part_number varchar2,p_brand varchar2,p_part_class varchar2) is
    SELECT  distinct APPL_EXECUTION_ID,
          BRAND,
          BOGO_PART_NUMBER,
          CARD_PIN_PART_CLASS,
          ESN_PART_CLASS,
          ESN_PART_NUMBER,
         -- ESN_DEALER_ID,
        --  ESN_DEALER_NAME,
          --ELIGIBLE_SERVICE_PLAN,
         -- CHANNEL,
          ACTION_TYPE,
          MSG_SCRIPT_ID,
          BOGO_START_DATE,
          BOGO_END_DATE,
          BOGO_STATUS,
          CREATED_BY,
          CREATED_DATE,
          UPDATED_BY,
          UPDATED_DATE
  FROM sa.X_BOGO_CONFIGURATION
  where (ESN_PART_CLASS = p_part_class
  or ESN_PART_NUMBER=p_part_number
  or BOGO_PART_NUMBER=p_bogo_part_number
  )
  and BRAND= p_brand
  and APPL_EXECUTION_ID is not null;
          r_bogo_promo_info c_bogo_promo_info%ROWTYPE ;

     /*
    cursor pc_bogo_promo_info (p_part_class varchar2,p_bogo_part_number varchar2) is
    SELECT  distinct APPL_EXECUTION_ID,
          BRAND,
          BOGO_PART_NUMBER,
          CARD_PIN_PART_CLASS,
          ESN_PART_CLASS,
          ESN_PART_NUMBER,
         -- ESN_DEALER_ID,
        --  ESN_DEALER_NAME,
          --ELIGIBLE_SERVICE_PLAN,
         -- CHANNEL,
          ACTION_TYPE,
          MSG_SCRIPT_ID,
          BOGO_START_DATE,
          BOGO_END_DATE,
          BOGO_STATUS,
          CREATED_BY,
          CREATED_DATE,
          UPDATED_BY,
          UPDATED_DATE
  FROM SA.X_BOGO_CONFIGURATION
  where (ESN_PART_CLASS = p_part_class
  or ESN_PART_NUMBER=p_part_number
  or BOGO_PART_NUMBER=p_bogo_part_number
  or BRAND= p_brand)
  and APPL_EXECUTION_ID is not null;
          pr_bogo_promo_info pc_bogo_promo_info%ROWTYPE ; */

    v_brand varchar2(100);

    begin

     dbms_output.put_line('Input Values===================='||ip_part_number||'-'||ip_bogo_part_number||'-'||ip_part_class);

    begin
          SELECT DISTINCT tbo.org_id into v_brand
        FROM sa.table_part_num pn,
             sa.table_part_class pc,
             sa.table_bus_org tbo
       WHERE pn.part_num2part_class  = pc.objid
         AND pn.part_num2bus_org     = tbo.objid
         AND (pn.part_number         = ip_part_number  --ESN_PART_Number or BOGO_PART_Number
          OR  pc.name                = ip_part_class
          or pn.part_number = ip_bogo_part_number)               --ESN_PART_Number
         AND ROWNUM = 1;

    exception
    when no_data_found then
    v_brand:='';
    end;

	 dbms_output.put_line('Input Values===================='||v_brand);

    for bogo_rec in c_bogo_promo_info(ip_part_number,ip_bogo_part_number,v_brand,ip_part_class)  --CR49808 Tracfone Safelink Assist
        loop
            dbms_output.put_line('Appn Execution Id===================='||bogo_rec.APPL_EXECUTION_ID);
            get_bogo_rslt.x_APPL_EXECUTION_ID         := bogo_rec.APPL_EXECUTION_ID;
            get_bogo_rslt.x_BRAND             := bogo_rec.BRAND;
            get_bogo_rslt.x_BOGO_PART_NUMBER:=bogo_rec.BOGO_PART_NUMBER;
            get_bogo_rslt.x_CARD_PIN_PART_CLASS       := bogo_rec.CARD_PIN_PART_CLASS;
            get_bogo_rslt.x_ESN_PART_CLASS          := bogo_rec.ESN_PART_CLASS;
            get_bogo_rslt.x_ESN_PART_NUMBER       := bogo_rec.ESN_PART_NUMBER;
            get_bogo_rslt.x_ACTION_TYPE          := bogo_rec.ACTION_TYPE;
            get_bogo_rslt.x_MSG_SCRIPT_ID      := bogo_rec.MSG_SCRIPT_ID;
            get_bogo_rslt.x_BOGO_START_DATE   := bogo_rec.BOGO_START_DATE;
            get_bogo_rslt.x_BOGO_END_DATE       := bogo_rec.BOGO_END_DATE;
            get_bogo_rslt.x_BOGO_STATUS          := bogo_rec.BOGO_STATUS;
            get_bogo_rslt.x_CREATED_BY          := bogo_rec.CREATED_BY;
            get_bogo_rslt.x_CREATED_DATE                := bogo_rec.CREATED_DATE;
            get_bogo_rslt.x_UPDATED_BY         := bogo_rec.UPDATED_BY;
            get_bogo_rslt.x_UPDATED_DATE              := bogo_rec.UPDATED_DATE;

            --collate channels
            channel_text:='';
              FOR x IN ( select distinct channel from  sa.X_BOGO_CONFIGURATION where APPL_EXECUTION_ID=bogo_rec.APPL_EXECUTION_ID) LOOP
                channel_text := channel_text || ',' || x.channel ;
              END LOOP;
              channel_text:=substr(channel_text,2);
              get_bogo_rslt.x_channel:=channel_text;
              dbms_output.put_line('Channels===================='||channel_text);
            --collate dealer id
            dealer_text:='';
               FOR x IN ( select distinct esn_dealer_id from  sa.X_BOGO_CONFIGURATION where APPL_EXECUTION_ID=bogo_rec.APPL_EXECUTION_ID) LOOP
                dealer_text := dealer_text || ',' || x.esn_dealer_id ;
              END LOOP;
               dealer_text:=substr(dealer_text,2);
              get_bogo_rslt.x_esn_dealer_id:=dealer_text;
               dbms_output.put_line('Dealer Ids===================='||dealer_text);
            --collate service plan
            servPlan_text:='';
             FOR x IN ( select distinct ELIGIBLE_SERVICE_PLAN from  sa.X_BOGO_CONFIGURATION where APPL_EXECUTION_ID=bogo_rec.APPL_EXECUTION_ID) LOOP
                servPlan_text := servPlan_text || ',' || x.ELIGIBLE_SERVICE_PLAN ;
              END LOOP;
                    servPlan_text:=substr(servPlan_text,2);
              get_bogo_rslt.x_ELIGIBLE_SERVICE_PLAN:=servPlan_text;
              dbms_output.put_line('Eligible Service Plan===================='||servPlan_text);

            pipe row (get_bogo_rslt);
        end loop;
/*
    for pc_bogo_rec in pc_bogo_promo_info(ip_part_class,ip_bogo_part_number)  --CR49808 Tracfone Safelink Assist
        loop
            dbms_output.put_line('Appn Execution Id===================='||pc_bogo_rec.APPL_EXECUTION_ID);
            get_bogo_rslt.x_APPL_EXECUTION_ID         := pc_bogo_rec.APPL_EXECUTION_ID;
            get_bogo_rslt.x_BRAND             := pc_bogo_rec.BRAND;
            get_bogo_rslt.x_BOGO_PART_NUMBER:=pc_bogo_rec.BOGO_PART_NUMBER;
            get_bogo_rslt.x_CARD_PIN_PART_CLASS       := pc_bogo_rec.CARD_PIN_PART_CLASS;
            get_bogo_rslt.x_ESN_PART_CLASS          := pc_bogo_rec.ESN_PART_CLASS;
            get_bogo_rslt.x_ESN_PART_NUMBER       := pc_bogo_rec.ESN_PART_NUMBER;
            get_bogo_rslt.x_ACTION_TYPE          := pc_bogo_rec.ACTION_TYPE;
            get_bogo_rslt.x_MSG_SCRIPT_ID      := pc_bogo_rec.MSG_SCRIPT_ID;
            get_bogo_rslt.x_BOGO_START_DATE   := pc_bogo_rec.BOGO_START_DATE;
            get_bogo_rslt.x_BOGO_END_DATE       := pc_bogo_rec.BOGO_END_DATE;
            get_bogo_rslt.x_BOGO_STATUS          := pc_bogo_rec.BOGO_STATUS;
            get_bogo_rslt.x_CREATED_BY          := pc_bogo_rec.CREATED_BY;
            get_bogo_rslt.x_CREATED_DATE                := pc_bogo_rec.CREATED_DATE;
            get_bogo_rslt.x_UPDATED_BY         := pc_bogo_rec.UPDATED_BY;
            get_bogo_rslt.x_UPDATED_DATE              := pc_bogo_rec.UPDATED_DATE;

            --collate channels
            channel_text:='';
              FOR x IN ( select distinct channel from  SA.X_BOGO_CONFIGURATION where APPL_EXECUTION_ID=pc_bogo_rec.APPL_EXECUTION_ID) LOOP
                channel_text := channel_text || ',' || x.channel ;
              END LOOP;
              channel_text:=substr(channel_text,2);
              get_bogo_rslt.x_channel:=channel_text;
              dbms_output.put_line('Channels===================='||channel_text);
            --collate dealer id
            dealer_text:='';
               FOR x IN ( select distinct esn_dealer_id from  SA.X_BOGO_CONFIGURATION where APPL_EXECUTION_ID=pc_bogo_rec.APPL_EXECUTION_ID) LOOP
                dealer_text := dealer_text || ',' || x.esn_dealer_id ;
              END LOOP;
               dealer_text:=substr(dealer_text,2);
              get_bogo_rslt.x_esn_dealer_id:=dealer_text;
               dbms_output.put_line('Dealer Ids===================='||dealer_text);
            --collate service plan
            servPlan_text:='';
             FOR x IN ( select distinct ELIGIBLE_SERVICE_PLAN from  SA.X_BOGO_CONFIGURATION where APPL_EXECUTION_ID=pc_bogo_rec.APPL_EXECUTION_ID) LOOP
                servPlan_text := servPlan_text || ',' || x.ELIGIBLE_SERVICE_PLAN ;
              END LOOP;
                    servPlan_text:=substr(servPlan_text,2);
              get_bogo_rslt.x_ELIGIBLE_SERVICE_PLAN:=servPlan_text;
              dbms_output.put_line('Eligible Service Plan===================='||servPlan_text);

            pipe row (get_bogo_rslt);
        end loop;

    */
end;
end adfcrm_bogo_pkg;
/