CREATE OR REPLACE PROCEDURE sa."CREATECONTACT_PRC"
(
  p_esn             IN VARCHAR2
 ,p_first_name      IN VARCHAR2
 ,p_last_name       IN VARCHAR2
 ,p_middle_name     IN VARCHAR2
 ,p_phone           IN VARCHAR2
 ,p_add1            IN VARCHAR2
 ,p_add2            IN VARCHAR2
 ,p_fax             IN VARCHAR2
 ,p_city            IN VARCHAR2
 ,p_st              IN VARCHAR2
 ,p_zip             IN VARCHAR2
 ,p_email           IN VARCHAR2
 ,p_email_status    IN NUMBER
 ,p_roadside_status IN NUMBER
 ,p_no_name_flag    IN NUMBER
 ,p_no_phone_flag   IN NUMBER
 ,p_no_address_flag IN NUMBER
 ,p_sourcesystem    IN VARCHAR2
 ,p_do_not_email    IN NUMBER
 ,p_do_not_phone    IN NUMBER
 ,p_do_not_mail     IN NUMBER
 ,p_do_not_sms      IN NUMBER
 ,p_ssn             IN VARCHAR2
 ,p_dob             IN DATE
 ,
  -- CR14767 Start kacosta 03/09/2011
  p_do_not_mobile_ads IN NUMBER
 ,
  -- CR14767 End kacosta 03/09/2011
  p_contact_objid OUT NUMBER
 ,p_err_code      OUT VARCHAR2
 ,p_err_msg       OUT VARCHAR2
 ,p_add_info2web_user IN     NUMBER   DEFAULT NULL /* CR51354 */
 ,p_min               IN     VARCHAR2 DEFAULT NULL /* CR51354 */
) IS
  /******************************************************************************/
  /*    Copyright ) 2006 Tracfone  Wireless Inc. All rights reserved            */
  /*                                                                            */
  /* NAME:         createcontact.sql                                                      */
  /* PURPOSE:                                                                   */
  /* FREQUENCY:                                                                 */
  /* PLATFORMS:    Oracle 8.0.6 AND newer versions.                             */
  /* REVISIONS:    VERSION  DATE        WHO               PURPOSE               */
  /*               -------  ----------  ---------------   -------------------   */
  /*               1.0      06/23/06    Curt Linder             CR5391 - Initial Revision      */
  /*           1.1    06/30/06    Vani Adapa           CR5391 - Fix defect
  /*        1.2  07/05/06 VA / NG            CR5391 - More fixes
  /*      1.3   07/06/06 VA              CR5391 - More fixes
  /*       1.4 11/28/06      NG       CR5569  WEBCSR Re-Write
  /*       1.5 12/27/06      NG       CR5569  WEBCSR Re-Write
  /*       1.7 03/19/06      NG       CR5955  2007 Q1 Handsets
  /*       1.8 06/07/07      NG       CR6379  Dummy Phone Fix for Voice recog
  /*       1.9 06/20/07      NG       CR6047  -1 Error
  /*       1.91 08/01/07    HM      CR6556  Dummy Phone Fix for Voice Recog
  /*New CVS                                                                     */
  /*                1.2      03/09/2011  kacosta      CR14767 Mobile Advertising Opt-In Option  */
  /*                                   Added the passing of the opt in option                   */
  /*               1.3      08/22/2011  kacosta           CR15656 WEBSCR OPT OUT/IN SYNCHRONIZATION */
  /*               1.6      04/04/2013  CLindner     CR22451 Simple Mobile System Integration - WEBCSR  */
  /******************************************************************************/
  --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: CREATECONTACT_PRC.sql,v $
  --$Revision: 1.11 $
  --$Author: tbaney $
  --$Date: 2017/10/02 16:36:28 $
  --$ $Log: CREATECONTACT_PRC.sql,v $
  --$ Revision 1.11  2017/10/02 16:36:28  tbaney
  --$ CR51354
  --$
  --$ Revision 1.10  2017/09/25 17:41:46  tbaney
  --$ Modified Logic for CR51354
  --$
  --$ Revision 1.6  2013/04/04 15:54:05  ymillan
  --$ CR22451 TAS simple mobile
  --$
  --$ Revision 1.5  2012/04/19 15:02:46  kacosta
  --$ CR20077 Unsubscribe Backend Process
  --$
  --$ Revision 1.4  2012/04/03 15:28:02  kacosta
  --$ CR20077 Unsubscribe Backend Process
  --$
  --$
  ---------------------------------------------------------------------------------------------
  --
  l_first_name          VARCHAR2(100) := NULL;
  l_last_name           VARCHAR2(100) := NULL;
  l_middle_name         VARCHAR2(100) := NULL;
  l_phone               VARCHAR2(100) := NULL;
  l_city                VARCHAR2(100) := NULL;
  l_st                  VARCHAR2(100) := NULL;
  l_ssn                 VARCHAR2(100) := NULL;
  l_site_id             NUMBER := NULL;
  l_cust_id             NUMBER := NULL;
  l_site_id_format      VARCHAR2(100) := NULL;
  l_site_objid          NUMBER := NULL;
  l_add_objid           NUMBER := NULL;
  l_bus_site_role_objid NUMBER := NULL;
  l_contact_objid       NUMBER := NULL;
  l_pin                 VARCHAR2(30) := '1234';
  l_add1                VARCHAR2(200) := NULL;
  l_add2                VARCHAR2(200) := NULL;
  l_add_info2web_user   NUMBER := p_add_info2web_user;

  CURSOR contact_curs
  (
    c_phone      IN VARCHAR2
   ,c_first_name IN VARCHAR2
   ,c_last_name  IN VARCHAR2
  ) IS
    SELECT c.objid
           -- CR20077 Start kacosta 03/06/2012
          ,c.x_email_status
    -- CR20077 End kacosta 03/06/2012
      FROM table_contact c
     WHERE 1 = 1
       AND c.phone = c_phone
       AND c.s_first_name = UPPER(c_first_name)
       AND c.s_last_name = UPPER(c_last_name);

	-- CR44294
      /*FROM table_contact c
     WHERE 1 = 1
       AND c.phone = c_phone
       AND c.s_first_name || '' = UPPER(c_first_name)
       AND c.s_last_name || '' = UPPER(c_last_name);*/

  contact_rec contact_curs%ROWTYPE;

  CURSOR contact_add_info_curs(c_contact_objid IN NUMBER) IS
    SELECT bo.s_name
          ,cai.*
      FROM sa.table_bus_org            bo
          ,sa.table_x_contact_add_info cai
     WHERE 1 = 1
       AND bo.s_name = DECODE(SUBSTR(UPPER(p_sourcesystem)
                                    ,1
                                    ,3)
                             ,'NET'
                             ,'NET10'
                             ,'TRACFONE')
       AND bo.objid = cai.add_info2bus_org
       AND cai.add_info2contact = c_contact_objid;

  contact_add_info_rec contact_add_info_curs%ROWTYPE;

  CURSOR esn_curs IS
    SELECT *
      FROM table_part_inst
     WHERE part_serial_no = p_esn;

  esn_rec esn_curs%ROWTYPE;

  CURSOR user_curs IS
    SELECT objid
      FROM table_user
     WHERE s_login_name = UPPER(USER);

  user_rec user_curs%ROWTYPE;

  CURSOR bus_org_curs IS
    SELECT objid
      FROM table_bus_org
     WHERE s_name = DECODE(SUBSTR(UPPER(p_sourcesystem)
                                 ,1
                                 ,3)
                          ,'NET'
                          ,'NET10'
                          ,'TRACFONE');

  bus_org_rec bus_org_curs%ROWTYPE;

  CURSOR zip_curs IS
    SELECT *
      FROM sa.table_x_zip_code
     WHERE x_zip = p_zip;

  zip_rec       zip_curs%ROWTYPE;
  zip_rec_extra zip_curs%ROWTYPE;

  CURSOR timezone_curs IS
    SELECT *
      FROM table_time_zone
     WHERE NAME = 'EST';

  timezone_rec timezone_curs%ROWTYPE;

  CURSOR country_curs IS
    SELECT *
      FROM table_country
     WHERE NAME = 'USA';

  country_rec country_curs%ROWTYPE;

  CURSOR state_curs
  (
    c_st            IN VARCHAR2
   ,c_country_objid IN NUMBER
  ) IS
    SELECT *
      FROM table_state_prov
    --       WHERE s_name = UPPER (p_st) AND state_prov2country = c_country_objid;
     WHERE s_name = UPPER(c_st)
       AND state_prov2country = c_country_objid;

  --1.1
  state_rec state_curs%ROWTYPE;

  --1.2
  CURSOR gbst_curs IS
    SELECT elm.objid
      FROM table_gbst_elm elm
          ,table_gbst_lst lst
     WHERE lst.objid = elm.gbst_elm2gbst_lst
       AND elm.title = 'Default'
       AND lst.title = 'Contact Role';

  gbst_rec gbst_curs%ROWTYPE;
  --1.2
  --
  -- CR20077 Start kacosta 03/06/2012
  l_n_email_status table_contact.x_email_status%TYPE;
  l_n_do_not_email table_x_contact_add_info.x_do_not_email%TYPE;
  -- CR20077 End kacosta 03/06/2012
  --
BEGIN
  --
  -- CR20077 Start kacosta 03/06/2012
  l_n_email_status := NVL(p_email_status
                         ,0);
  l_n_do_not_email := NVL(p_do_not_email
                         ,0);
  --
  IF (l_n_email_status = 4 AND l_n_do_not_email = 0) THEN
    --
    l_n_do_not_email := 1;
    --
  ELSIF (l_n_email_status <> 4 AND l_n_do_not_email <> 0) THEN
    --
    l_n_email_status := 4;
    --
  END IF;
  -- CR20077 End kacosta 03/06/2012
  --
  --1.2
  OPEN gbst_curs;

  FETCH gbst_curs
    INTO gbst_rec;

  CLOSE gbst_curs;

  --1.2
  OPEN user_curs;

  FETCH user_curs
    INTO user_rec;

  CLOSE user_curs;

  -- CR51354 TAS exception
  IF p_sourcesystem = 'TAS' THEN
     -- Set the user to agent from parameter.
     user_rec.objid := l_add_info2web_user;
     l_add_info2web_user := NULL;
  END IF;



  OPEN bus_org_curs;

  FETCH bus_org_curs
    INTO bus_org_rec;

  CLOSE bus_org_curs;

  ------------------------------------------------------------------------------------------------------
  -- contact exists code
  ------------------------------------------------------------------------------------------------------
  OPEN contact_curs(p_phone
                   ,p_first_name
                   ,p_last_name);

  FETCH contact_curs
    INTO contact_rec;

  IF contact_curs%FOUND THEN
    p_contact_objid := contact_rec.objid;
    p_err_code      := '0';
    p_err_msg       := 'Contact Already Exists';

    IF LTRIM(p_ssn) IS NOT NULL THEN
      UPDATE table_contact
         SET x_ss_number = p_ssn
       WHERE objid = p_contact_objid;
    END IF;
    --
    -- CR20077 Start kacosta 03/06/2012
    IF (l_n_email_status = 4 AND NVL(contact_rec.x_email_status
                                    ,0) <> l_n_email_status) THEN
      --
      UPDATE table_contact
         SET x_email_status = l_n_email_status
       WHERE objid = p_contact_objid;
      --
    END IF;
    -- CR20077 End kacosta 03/06/2012
    --
    OPEN esn_curs;

    FETCH esn_curs
      INTO esn_rec;

    IF esn_curs%FOUND THEN
      UPDATE table_part_inst
         SET x_part_inst2contact = contact_rec.objid
       WHERE objid = esn_rec.objid;
    END IF;

    CLOSE esn_curs;

    OPEN contact_add_info_curs(contact_rec.objid);

    FETCH contact_add_info_curs
      INTO contact_add_info_rec;

    IF contact_add_info_curs%NOTFOUND THEN
      INSERT INTO table_x_contact_add_info
        (objid
        ,x_do_not_email
        ,x_do_not_phone
        ,x_do_not_sms
        ,x_do_not_mail
        ,add_info2contact
        ,add_info2user
        ,x_last_update_date
        ,add_info2bus_org
        ,x_dateofbirth
         -- CR14767 Start kacosta 03/09/2011
        ,x_do_not_mobile_ads
         -- CR14767 End kacosta 03/09/2011
        ,source_system
        ,add_info2web_user
        ,x_esn
        ,x_min
         )
      VALUES
        (sa.seq('x_contact_add_info')
         -- CR20077 Start kacosta 03/06/2012
         --,p_do_not_email
        ,l_n_do_not_email
         -- CR20077 End kacosta 03/06/2012
        ,p_do_not_phone
        ,p_do_not_sms
        ,p_do_not_mail
        ,contact_rec.objid
        ,user_rec.objid
        ,SYSDATE
        ,bus_org_rec.objid
        ,p_dob
         -- CR14767 Start kacosta 03/09/2011
        ,p_do_not_mobile_ads
         -- CR14767 End kacosta 03/09/2011
        ,p_sourcesystem
        ,l_add_info2web_user
        ,p_esn
        ,p_min
         );

      --
      --CR15656 Start kacosta 08/22/2011
      UPDATE table_x_contact_add_info
      -- CR20077 Start kacosta 03/06/2012
      --SET x_do_not_email      = p_do_not_email
         SET x_do_not_email = l_n_do_not_email
             -- CR20077 End kacosta 03/06/2012
            ,x_do_not_phone      = p_do_not_phone
            ,x_do_not_sms        = p_do_not_sms
            ,x_do_not_mail       = p_do_not_mail
            ,add_info2user       = user_rec.objid
            ,x_last_update_date  = SYSDATE
            ,x_dateofbirth       = p_dob
            ,x_do_not_mobile_ads = p_do_not_mobile_ads
       WHERE add_info2contact = contact_rec.objid
         AND add_info2bus_org <> bus_org_rec.objid;
      --CR15656 End kacosta 08/22/2011
      --

    ELSE
      UPDATE table_x_contact_add_info
      -- CR20077 Start kacosta 03/06/2012
      --SET x_do_not_email      = p_do_not_email
         SET x_do_not_email = l_n_do_not_email
             -- CR20077 End kacosta 03/06/2012
            ,x_do_not_phone     = p_do_not_phone
            ,x_do_not_sms       = p_do_not_sms
            ,x_do_not_mail      = p_do_not_mail
            ,x_last_update_date = SYSDATE
            ,x_dateofbirth      = p_dob
             -- CR14767 Start kacosta 03/09/2011
            ,x_do_not_mobile_ads = p_do_not_mobile_ads
      -- CR14767 End kacosta 03/09/2011
            ,source_system       = p_sourcesystem
            ,add_info2web_user   = l_add_info2web_user
            ,x_esn               = p_esn
            ,x_min               = p_min
       WHERE add_info2contact = contact_rec.objid;
    END IF;

    CLOSE contact_add_info_curs;

    CLOSE contact_curs;

    RETURN;
  END IF;

  CLOSE contact_curs;

  ------------------------------------------------------------------------------------------------------
  -- contact exists code
  ------------------------------------------------------------------------------------------------------
  sa.next_id('Individual ID'
            ,l_site_id
            ,l_site_id_format);
  l_cust_id := l_site_id;

  --
  IF LTRIM(p_city) IS NULL THEN
    l_city := 'No City Provided';
  ELSE
    l_city := p_city;
  END IF;

  IF LTRIM(RTRIM(p_st)) IS NULL THEN
    l_st := 'FL';
  ELSE
    l_st := p_st;
  END IF;

  IF (LENGTH(LTRIM(RTRIM(p_phone))) <= 10 OR p_phone IS NULL OR LTRIM(RTRIM(p_phone)) = '3057150000' OR LTRIM(RTRIM(p_phone)) = '0000000000') THEN
    l_phone := l_cust_id;
  ELSE
    l_phone := p_phone;
  END IF;

  IF LTRIM(p_first_name) IS NULL THEN
    l_first_name := l_cust_id;
  ELSE
    l_first_name := LTRIM(RTRIM(p_first_name));
  END IF;

  IF LTRIM(p_last_name) IS NULL THEN
    l_last_name := l_cust_id;
  ELSE
    l_last_name := LTRIM(RTRIM(p_last_name));
  END IF;

  IF LTRIM(p_ssn) IS NULL THEN
    l_ssn := NULL;
  ELSE
    l_ssn := LTRIM(RTRIM(p_ssn));
  END IF;

  --1.2
  IF LTRIM(p_add1) IS NULL THEN
    l_add1 := l_cust_id;
  ELSE
    l_add1 := LTRIM(RTRIM(p_add1));
  END IF;

  IF LTRIM(p_add2) IS NULL THEN
    l_add2 := l_cust_id;
  ELSE
    l_add2 := LTRIM(RTRIM(p_add2));
  END IF;

  --1.2
  --
  OPEN zip_curs;

  FETCH zip_curs
    INTO zip_rec;

  IF zip_curs%FOUND THEN
    FETCH zip_curs
      INTO zip_rec_extra;

    IF zip_curs%FOUND THEN
      CLOSE zip_curs;

      p_err_code := '301';
      p_err_msg  := 'Multiple zipcode data found';
      RETURN;
    END IF;
  ELSE
    CLOSE zip_curs;

    p_err_code := '201';
    p_err_msg  := 'Invalid Zipcode';
    RETURN;
  END IF;

  CLOSE zip_curs;

  OPEN timezone_curs;

  FETCH timezone_curs
    INTO timezone_rec;

  IF timezone_curs%NOTFOUND THEN
    p_err_code := '206';
    p_err_msg  := 'No Valid Time Zone found';
    RETURN;
  END IF;

  CLOSE timezone_curs;

  OPEN country_curs;

  FETCH country_curs
    INTO country_rec;

  IF country_curs%NOTFOUND THEN
    p_err_code := '203';
    p_err_msg  := 'No Valid Country found';
    RETURN;
  END IF;

  CLOSE country_curs;

  --1.1
  --   OPEN state_curs (p_st, country_rec.objid);
  OPEN state_curs(l_st
                 ,country_rec.objid);

  --1.1
  FETCH state_curs
    INTO state_rec;

  IF state_curs%NOTFOUND THEN
    p_err_code := '204';
    p_err_msg  := 'No Valid State Code found';
    RETURN;
  END IF;

  CLOSE state_curs;

  l_contact_objid := sa.seq('contact');

  INSERT INTO table_contact
    (objid
    ,first_name
    ,s_first_name
    ,last_name
    ,s_last_name
    ,phone
    ,address_1
    ,address_2
    ,city
    ,state
    ,zipcode
    ,x_no_address_flag
    ,x_no_name_flag
    ,x_no_phone_flag
    ,x_ss_number
    ,status
    ,x_cust_id
    ,e_mail
    ,x_middle_initial
    ,fax_number
    ,x_email_status
    ,x_roadside_status
    ,x_dateofbirth
    ,alert_ind)
  VALUES
    (l_contact_objid
    ,l_first_name
    ,UPPER(l_first_name)
    ,l_last_name
    ,UPPER(l_last_name)
    ,l_phone
    ,
     --                LTRIM (RTRIM (p_add1)), LTRIM (RTRIM (p_add2)),
     LTRIM(RTRIM(l_add1))
    ,LTRIM(RTRIM(p_add2))
    ,zip_rec.x_city
    ,zip_rec.x_state
    ,zip_rec.x_zip
    ,DECODE(p_sourcesystem
           ,'NETCSR'
           ,0
           ,'WEBCSR'
           ,0
           ,'TAS'          --CR22451
           ,0
           ,p_no_address_flag)
    ,DECODE(l_first_name || l_last_name
           ,l_cust_id || l_cust_id
           ,DECODE(p_sourcesystem
                  ,'NETCSR'
                  ,0
                  ,'WEBCSR'
                  ,0
                  ,'TAS'    --CR22451
                  ,0
                  ,1)
           ,p_no_name_flag)
    ,DECODE(p_sourcesystem
           ,'NETCSR'
           ,0
           ,'WEBCSR'
           ,0
           ,'TAS'    --CR22451
           ,0
           ,p_no_phone_flag)
    ,l_ssn
    ,0
    ,l_cust_id
    ,LTRIM(RTRIM(p_email))
    ,SUBSTR(LTRIM(RTRIM(p_middle_name))
           ,1
           ,3)
    ,p_fax
     -- CR20077 Start kacosta 03/06/2012
     --,p_email_status
    ,l_n_email_status
     -- CR20077 End kacosta 03/06/2012
    ,p_roadside_status
    ,p_dob
    ,1);

  l_add_objid := sa.seq('address');

  INSERT INTO table_address
    (objid
    ,address
    ,s_address
    ,city
    ,s_city
    ,state
    ,s_state
    ,zipcode
    ,address_2
    ,dev
    ,address2time_zone
    ,address2country
    ,address2state_prov
    ,update_stamp)
  VALUES
    (l_add_objid
    ,l_add1
    ,UPPER(l_add1)
    ,zip_rec.x_city
    ,UPPER(zip_rec.x_city)
    ,zip_rec.x_state
    ,UPPER(zip_rec.x_state)
    ,zip_rec.x_zip
    ,l_add2
    ,NULL
    ,timezone_rec.objid
    ,country_rec.objid
    ,state_rec.objid
    ,SYSDATE);

  l_site_objid := sa.seq('site');

  INSERT INTO table_site
    (objid
    ,NAME
    ,phone
    ,site_id
    ,site_type
    ,status
    ,TYPE
    ,cust_primaddr2address
    ,cust_billaddr2address
    ,cust_shipaddr2address
    ,primary2bus_org --1.2
     )
  VALUES
    (l_site_objid
    ,SUBSTR(l_first_name || ' ' || l_last_name || ' ' || LTRIM(RTRIM(l_add1))
           ,1
           ,80)
    ,l_phone
    ,l_site_id
    ,'INDV'
    ,0
    ,4
    ,l_add_objid
    ,l_add_objid
    ,l_add_objid
    ,bus_org_rec.objid --1.2
     );

  l_bus_site_role_objid := sa.seq('bus_site_role');

  INSERT INTO table_bus_site_role
    (objid
    ,role_name
    ,focus_type
    ,active
    ,dev
    ,bus_site_role2site
    ,bus_site_role2bus_org)
  VALUES
    (l_bus_site_role_objid
    ,'OWNER'
    ,172
    ,0
    ,NULL
    ,l_site_objid
    ,bus_org_rec.objid);

  INSERT INTO table_contact_role
    (objid
    ,role_name
    ,s_role_name
    ,primary_site
    ,dev
    ,contact_role2site
    ,contact_role2contact
    ,contact_role2gbst_elm
    ,update_stamp)
  VALUES
    (sa.seq('contact_role')
    ,'Default'
    ,'DEFAULT'
    ,1
    ,NULL
    ,l_site_objid
    ,l_contact_objid
    ,
     --null,
     gbst_rec.objid
    , --1.2
     SYSDATE);

  OPEN esn_curs;

  FETCH esn_curs
    INTO esn_rec;

  IF esn_curs%FOUND THEN
    UPDATE table_part_inst
       SET x_part_inst2contact = l_contact_objid
     WHERE objid = esn_rec.objid;
  END IF;

  CLOSE esn_curs;

  p_contact_objid := l_contact_objid;

  INSERT INTO table_x_contact_add_info
    (objid
    ,x_do_not_email
    ,x_do_not_phone
    ,x_do_not_sms
    ,x_do_not_mail
    ,add_info2contact
    ,add_info2user
    ,x_last_update_date
    ,add_info2bus_org
    ,x_dateofbirth
     -- CR14767 Start kacosta 03/09/2011
    ,x_do_not_mobile_ads
     -- CR14767 End kacosta 03/09/2011
    ,source_system
    ,add_info2web_user
    ,x_esn
    ,x_min
     )
  VALUES
    (sa.seq('x_contact_add_info')
     -- CR20077 Start kacosta 03/06/2012
     --,p_do_not_email
    ,l_n_do_not_email
     -- CR20077 End kacosta 03/06/2012
    ,p_do_not_phone
    ,p_do_not_sms
    ,p_do_not_mail
    ,l_contact_objid
    ,user_rec.objid
    ,SYSDATE
    ,bus_org_rec.objid
    ,p_dob
     -- CR14767 Start kacosta 03/09/2011
    ,p_do_not_mobile_ads
     -- CR14767 End kacosta 03/09/2011
    ,p_sourcesystem
    ,l_add_info2web_user
    ,p_esn
    ,p_min
     );

  p_err_code := '0';
  p_err_msg  := 'Contact Created Successfully';
END;
/