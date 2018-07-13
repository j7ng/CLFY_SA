CREATE OR REPLACE PROCEDURE sa."SEND_TRACKING_EMAIL" (case_objid IN NUMBER) AS
  --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: SEND_TRACKING_EMAIL.sql,v $
  --$Revision: 1.14 $
  --$Author: lsatuluri $
  --$Date: 2013/03/22 15:33:49 $
  --$ $Log: SEND_TRACKING_EMAIL.sql,v $
  --$ Revision 1.14  2013/03/22 15:33:49  lsatuluri
  --$ CR22420
  --$
  --$ Revision 1.13  2013/03/20 16:35:29  lsatuluri
  --$ CR22420
  --$
  --$ Revision 1.12  2013/03/20 12:49:42  lsatuluri
  --$ CR22420
  --$
  --$ Revision 1.11  2013/03/19 18:41:05  lsatuluri
  --$ CR22420  Parameter set up done.
  --$
  --$ Revision 1.9  2012/10/04 19:50:45  kacosta
  --$ CR21834 Straight talk shipping Confirmation
  --$
  --$ Revision 1.8  2012/10/04 14:58:26  kacosta
  --$ CR21834 Straight talk shipping Confirmation
  --$
  --$ Revision 1.7  2011/11/28 21:46:49  kacosta
  --$ CR16577 Send email to customer with tracking # information for ST
  --$
  --$ Revision 1.6  2011/10/31 15:29:41  kacosta
  --$ CR16577 Send email to customer with tracking # information for ST
  --$
  --$ Revision 1.5  2011/10/24 20:54:49  kacosta
  --$ CR16577 Send email to customer with tracking # information for ST
  --$
  --$ Revision 1.4  2011/10/18 17:02:30  kacosta
  --$ CR16577 Send email to customer with tracking # information for ST
  --$
  --$ Revision 1.3  2011/10/11 19:15:03  kacosta
  --$ CR16577 Send email to customer with tracking # information for ST
  --$
  --$ Revision 1.2  2011/10/06 14:15:05  kacosta
  --$ CR16577 Send email to customer with tracking # information for ST
  --$
  --$ Revision 1.1  2011/10/05 19:07:02  kacosta
  --$ CR16577 Send email to customer with tracking # information for ST
  --$
  --$
  ---------------------------------------------------------------------------------------------
  --
  script_txt_1    VARCHAR2(4000);
  script_txt_2    VARCHAR2(4000);
  script_txt_grid VARCHAR2(4000);
  script_txt_3    VARCHAR2(4000);
  email_body      VARCHAR2(4000);
  email_subjet    VARCHAR2(200);
  --Increased the variable size to avoid
  -- ORA-06502: PL/SQL: numeric or value error: character string buffer too small
  -- Set it to little more than MS explorer URL maximum
  --email_from       VARCHAR2(30);
  email_from       VARCHAR2(2500);
  email_result     VARCHAR2(500);
  shipping_address VARCHAR2(1000);
  op_objid         VARCHAR2(200);
  op_description   VARCHAR2(200);
  op_publish_by    VARCHAR2(30);
  op_publish_date  DATE;
  op_sm_link       VARCHAR2(200);

  l_v_first_name table_case.alt_first_name%TYPE;
  l_v_last_name  table_case.alt_last_name%TYPE;

  CURSOR c1 IS
    SELECT DISTINCT pr.x_courier
                   ,pr.x_tracking_no
                   ,xc.courier_tracking_link || pr.x_tracking_no tracking_link
                   ,c.id_number
                   ,c.alt_first_name
                   ,c.alt_last_name
                   ,c.alt_address
                   ,c.alt_city
                   ,c.alt_state
                   ,c.alt_zipcode
                   ,c.alt_e_mail
                   ,c.case_type_lvl2
                   ,bo.org_id
                   ,bo.name company_name
                   ,bo.web_site

      FROM table_x_courier      xc
          ,table_x_part_request pr
          ,table_case           c
          ,table_bus_org        bo
     WHERE pr.request2case = case_objid
       AND c.objid = pr.request2case
       AND pr.x_status = 'SHIPPED'
       AND pr.x_courier IS NOT NULL
       AND pr.x_tracking_no IS NOT NULL
      --CR22420 Start
       and pr.x_repl_part_num NOT in(SELECT PN.PART_NUMBER FROM
                                    table_x_part_class_values pv,
                                    table_x_part_class_params pcp ,
                                    table_part_num pn
                                  WHERE PV.value2class_param= pcp.objid
                                  AND  pn.part_num2part_class=PV.Value2part_Class
                                  and PV.x_param_value ='N'
                                  AND pcp.x_param_name = 'EMAIL_CONFIRM')
      --CR22420 End
       AND NVL(pr.dev
              ,0) = 0
       AND CASE
             WHEN UPPER(c.case_type_lvl2) = 'LIFELINE' THEN
              'SAFELINK'
             ELSE
              UPPER(c.case_type_lvl2)
           END = UPPER(bo.org_id)
       AND pr.x_courier = xc.x_courier_id

         --CR21834 Start KACOSTA 10/04/2012

     --  AND pr.x_repl_part_num <> 'ST-EX-AIRBILL'
    --CR21834 End KACOSTA 10/04/2012

    ;

  CURSOR c2(v_tracking VARCHAR2) IS
    SELECT b.part_number
          ,b.description part_description
          ,a.x_courier
          ,a.x_part_num_domain
          ,pc.name part_class
          ,a.x_shipping_method
          ,a.x_tracking_no
          ,d.x_alt_name
          ,NVL(a.x_quantity
              ,1) quantity
      FROM table_x_part_request    a
          ,table_part_num          b
          ,table_x_courier         c
          ,table_x_shipping_method d
          ,table_part_class        pc
     WHERE 1 = 1
       AND a.request2case = case_objid
       AND a.x_tracking_no = v_tracking
       AND a.x_status = 'SHIPPED'
       AND b.part_number = a.x_repl_part_num
       AND b.part_num2part_class = pc.objid
       AND c.x_courier_id = a.x_courier
       AND d.method2courier = c.objid
       AND a.x_shipping_method = d.x_shipping_method
       AND x_courier IS NOT NULL
       AND x_tracking_no IS NOT NULL
       AND NVL(a.dev
              ,0) = 0
      ---START 22420
        and  pc.objid NOT IN (select pv.value2part_class
                        from table_x_part_class_values pv,
                        table_x_part_class_params pcp
                        where pv.x_param_value = 'N'
                         and value2class_param= pcp.objid
                         and pcp.x_param_name = 'EMAIL_CONFIRM')
       ---END 22420
          --CR21834 Start KACOSTA 10/04/2012
          --CR21834 Start KACOSTA 10/04/2012
 --      AND a.x_repl_part_num <> 'ST-EX-AIRBILL'
 ;
    --CR21834 End KACOSTA 10/04/2012


BEGIN

  FOR r1 IN c1 LOOP

    l_v_first_name := INITCAP(r1.alt_first_name);
    l_v_last_name  := INITCAP(r1.alt_last_name);

    scripts_pkg.get_script_prc(ip_sourcesystem => 'WEB'
                              ,ip_brand_name   => 'GENERIC'
                              ,ip_script_type  => 'EMAIL'
                              ,ip_script_id    => '00010'
                              ,ip_language     => 'ENGLISH'
                              ,ip_carrier_id   => NULL
                              ,ip_part_class   => NULL
                              ,op_objid        => op_objid
                              ,op_description  => op_description
                              ,op_script_text  => script_txt_1
                              ,op_publish_by   => op_publish_by
                              ,op_publish_date => op_publish_date
                              ,op_sm_link      => op_sm_link);

    scripts_pkg.get_script_prc(ip_sourcesystem => 'WEB'
                              ,ip_brand_name   => 'GENERIC'
                              ,ip_script_type  => 'EMAIL'
                              ,ip_script_id    => '00030'
                              ,ip_language     => 'ENGLISH'
                              ,ip_carrier_id   => NULL
                              ,ip_part_class   => NULL
                              ,op_objid        => op_objid
                              ,op_description  => op_description
                              ,op_script_text  => script_txt_3
                              ,op_publish_by   => op_publish_by
                              ,op_publish_date => op_publish_date
                              ,op_sm_link      => op_sm_link);

    script_txt_grid := '<table width="50%" border="1" cellspacing="0" cellpadding="0"><tr><td>Part Number</td><td>Description</td><td>Qty</td></tr>';

    FOR r2 IN c2(r1.x_tracking_no) LOOP
      IF r2.x_part_num_domain = 'PHONES' THEN
        scripts_pkg.get_script_prc(ip_sourcesystem => 'WEB'
                                  ,ip_brand_name   => r1.org_id
                                  ,ip_script_type  => 'EMAIL'
                                  ,ip_script_id    => '00020'
                                  ,ip_language     => 'ENGLISH'
                                  ,ip_carrier_id   => NULL
                                  ,ip_part_class   => r2.part_class
                                  ,op_objid        => op_objid
                                  ,op_description  => op_description
                                  ,op_script_text  => script_txt_2
                                  ,op_publish_by   => op_publish_by
                                  ,op_publish_date => op_publish_date
                                  ,op_sm_link      => op_sm_link);
      END IF;
      script_txt_grid := script_txt_grid || '<tr>';
      script_txt_grid := script_txt_grid || '<td>';
      script_txt_grid := script_txt_grid || TRIM(r2.part_number);
      script_txt_grid := script_txt_grid || '</td>';
      script_txt_grid := script_txt_grid || '<td>';
      script_txt_grid := script_txt_grid || TRIM(r2.part_description);
      script_txt_grid := script_txt_grid || '</td>';
      script_txt_grid := script_txt_grid || '<td>';
      script_txt_grid := script_txt_grid || TRIM(TO_CHAR(r2.quantity));
      script_txt_grid := script_txt_grid || '</td>';
      script_txt_grid := script_txt_grid || '</tr>';

    END LOOP;
    script_txt_grid := script_txt_grid || '</table>';
    email_body      := script_txt_1 || '<br>';
    email_body      := email_body || script_txt_grid || '<br>';
    IF script_txt_2 LIKE '%SCRIPT MISSING%' THEN
      NULL;
    ELSE
      email_body := email_body || script_txt_2 || '<br>';
    END IF;
    email_body       := email_body || script_txt_3;
    email_body       := REPLACE(email_body
                               ,'[company_brand_name]'
                               ,r1.company_name);
    email_body       := REPLACE(email_body
                               ,'[ticket_number]'
                               ,r1.id_number);
    email_body       := REPLACE(email_body
                               ,'[customer_first_name]'
                               ,l_v_first_name);
    email_body       := REPLACE(email_body
                               ,'[customer_last_name]'
                               ,l_v_last_name);
    shipping_address := l_v_first_name || ' ' || l_v_last_name || '<br>';
    shipping_address := shipping_address || r1.alt_address || '<br>';
    shipping_address := REPLACE(shipping_address
                               ,'||'
                               ,' ');
    shipping_address := shipping_address || r1.alt_city || ', ' || r1.alt_state || ' ' || r1.alt_zipcode || '<br>';
    email_body       := REPLACE(email_body
                               ,'[customer_shipping_address]'
                               ,shipping_address);
    email_body       := REPLACE(email_body
                               ,'[mail_carrier]'
                               ,r1.x_courier);
    email_body       := REPLACE(email_body
                               ,'[tracking_number]'
                               ,'<a href="' || r1.tracking_link || '">' || r1.x_tracking_no || '</a>');
    email_body       := REPLACE(email_body
                               ,'[website]'
                               ,r1.web_site);
    email_body       := REPLACE(email_body
                               ,'_'
                               ,' ');

    email_subjet := r1.company_name || ' Shipping Confirmation';
    email_subjet := REPLACE(email_subjet
                           ,'_'
                           ,' ');

    email_from := 'noreply' || r1.web_site;
    email_from := REPLACE(email_from
                         ,'www.'
                         ,'@');
    --send email
    send_mail(subject_txt => email_subjet
             ,msg_from    => email_from
             ,send_to     => r1.alt_e_mail
             ,message_txt => email_body
             ,RESULT      => email_result);

    UPDATE table_x_part_request
       SET dev = 1
     WHERE request2case = case_objid
       AND x_status = 'SHIPPED'
       AND x_courier = r1.x_courier
       AND x_tracking_no = r1.x_tracking_no
       AND NVL(dev
              ,0) = 0;
  END LOOP;

END send_tracking_email;
/