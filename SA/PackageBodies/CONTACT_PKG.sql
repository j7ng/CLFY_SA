CREATE OR REPLACE PACKAGE BODY sa."CONTACT_PKG" AS
 /**********************************************************************************************/
 /* */
 /* Name : SA.CONTACT_PKG BODY */
 /* */
 /* Purpose : Prepared for Exceeding demand for more information on our customers */
 /* */
 /* */
 /* Platforms : Oracle 9i and above */
 /* */
 /* Author : NGuada */
 /* */
 /* Date : 08-28-2009 */
 /* REVISIONS: */
 /* VERSION DATE WHO PURPOSE */
 /* ------- ---------- ----- -------------------------------------------- */
 /* 1.0 08/27/09 Initial Revision */
 /* 1.1 09/02/09 Latest */
 /* 1.2 03/09/2011 kacosta CR14767 Mobile Advertising Opt-In Option */
 /* Added the passing of the opt in option */
 /* 1.3 08/22/2011 kacosta CR15656 WEBSCR OPT OUT/IN SYNCHRONIZATIO */
 /* 1.6 04/4/2013 Clindner CR22451 Simple Mobile System Integration - WEBCSR */
 /* 1.7 07/08/2013 YMillan CR24253 LTE PROject */
 /* 1.8 05/04/2015 Kedar Parkhi Added 2 new procedures sp_GetDeviceSummary and */
 /* Sp_SetLanguagePref as part of CR33420. */
 /**********************************************************************************************/
 --
 ---------------------------------------------------------------------------------------------
 --$RCSfile: CONTACT_PKG.sql,v $
 --$Revision: 1.91 $
 --$Author: spagidala $
 --$Date: 2018/03/16 14:21:22 $
 --$ $Log: CONTACT_PKG.sql,v $
 --$ Revision 1.91  2018/03/16 14:21:22  spagidala
 --$ CR55771 Removed error log insert statements
 --$
 --$ Revision 1.86  2017/11/30 18:46:36  tbaney
 --$ Added source system column.
 --$
 --$ Revision 1.85  2017/11/28 19:36:54  tbaney
 --$ Removed check for part status.
 --$
 --$ Revision 1.84  2017/11/23 00:16:57  tbaney
 --$ Modified reference to io table to o table.
 --$
 --$ Revision 1.83  2017/11/22 19:15:29  tbaney
 --$ Correct issue with additional info.
 --$
 --$ Revision 1.82  2017/11/22 15:02:15  tbaney
 --$ Modified logic to handle multiple rows in get procedure.  login / brand.
 --$
 --$ Revision 1.81  2017/11/21 21:29:55  tbaney
 --$ Removed commit to avoid error issue.
 --$
 --$ Revision 1.80  2017/11/21 16:23:44  tbaney
 --$ Added insert to try to trap error.
 --$
 --$ Revision 1.79  2017/11/20 20:12:24  tbaney
 --$ Added error messages.
 --$
 --$ Revision 1.78  2017/11/20 17:40:05  tbaney
 --$ Changed update to ESN brand and Get to Login Brand.
 --$
 --$ Revision 1.77  2017/11/20 14:40:31  tbaney
 --$ Added table contact eliminate duplicate rows.
 --$
 --$ Revision 1.76  2017/11/17 21:40:10  tbaney
 --$ Modifed logic to use ESN and bus org instead of Login Name and bus org combination.
 --$
 --$ Revision 1.74  2017/11/16 19:32:48  tbaney
 --$ Correct issue with part class and part number.
 --$
 --$ Revision 1.73  2017/11/16 15:17:56  tbaney
 --$ Modified logic for upper case and added part class.
 --$
 --$ Revision 1.72  2017/11/09 20:53:47  tbaney
 --$ Merged with corrected Production code CR52329
 --$
 --$ Revision 1.71  2017/11/09 20:10:15  tbaney
 --$ Merged with production.
 --$
 --$ Revision 1.69  2017/10/10 18:40:58  rmorthala
 --$ *** empty log message ***
 --$
 --$ Revision 1.68  2017/10/06 15:39:47  mtholkappian
 --$ production merge
 --$
 --$ Revision 1.61  2017/09/28 16:02:12  sgangineni
 --$ CR49915 - Fix for defect#31287
 --$
 --$ Revision 1.52  2017/05/16 14:28:05  sgangineni
 --$ CR50134 - fix for defect#23440
 --$
 --$ Revision 1.51  2017/04/11 16:31:44  sgangineni
 --$ CR48944 - Fixed oracle version issue occurred during SCI deployment
 --$
 --$ Revision 1.50  2017/04/06 20:10:18  smeganathan
 --$ Added overloaded procedure p_get_min_security_pin
 --$
 --$ Revision 1.49  2017/04/05 19:28:12  smeganathan
 --$ changes in p_get_min_security_pin
 --$
 --$ Revision 1.48  2017/04/05 16:22:11  sgangineni
 --$ CR47564 - Fix for defect #23729 by Naresh
 --$
 --$ Revision 1.47  2017/04/03 14:17:06  vnainar
 --$ CR47564 esn validation updated in updatecontact_prc procedure unmerge amazon changes
 --$
 --$ Revision 1.46  2017/04/03 14:12:53  vnainar
 --$ CR47564 esn validation updated in updatecontact_prc procedure
 --$
 --$ Revision 1.45  2017/03/21 18:01:39  sgangineni
 --$ CR47564 - Merged WFM changes with Rel 853 changes
 --$
 --$ Revision 1.43  2017/02/17 19:16:28  rpednekar
 --$ CR45761
 --$
 --$ Revision 1.42  2017/02/06 17:06:13  rpednekar
 --$ CR45761 - Error code and error msg parameters added to procedure get_customer_contact_info.
 --$
 --$ Revision 1.29  2017/01/27 22:45:53  rpednekar
 --$ CR45761 - New procedure get_customer_contact_info.
 --$
 --$ Revision 1.24  2016/12/28 18:13:29  vnainar
 --$ CR44729 updatecontactprc updated to map zip code correctly
 --$
 --$ Revision 1.23  2016/12/02 19:52:10  vlaad
 --$ Updated to return REPORTING_LINE as GO_SMART
 --$
 --$ Revision 1.22  2016/12/01 22:44:07  sgururajan
 --$ Added SUB_BRAND output on get device details procedure. Used pcpv table to fetch the same
 --$
 --$ Revision 1.21  2016/11/29 18:39:49  aganesan
 --$ CR44729 New stored procedure update contact prc to update contact information
 --$
 --$ Revision 1.20  2016/08/30 13:05:57  ddudhankar
 --$ CR44294 - fetching only one row in cursor contact_curs
 --$
 --$ Revision 1.19  2016/02/29 23:41:26  vnainar
 --$ CR40157 sql%rowcount replaced with variable in setlanguagepref procedure
 --$
 --$ Revision 1.18  2016/02/24 21:42:47  vnainar
 --$ CR40157 procedure sp_GetDeviceSummary updated for language pref
 --$
 --$ Revision 1.17  2016/02/24 20:15:00  vnainar
 --$ CR40157 customer type added to get web  user attributes
 --$
 --$ Revision 1.16  2016/02/24 15:55:29  vnainar
 --$ CR40157 update statement modified in SP_SETLANGUAGEPREF procedure
 --$
 --$ Revision 1.15  2016/02/03 16:33:35  vnainar
 --$ CR40157 procedure SP_SETLANGUAGEPREF updated for error code check
 --$
 --$ Revision 1.14 2015/07/08 16:59:55 nguada
 --$ 35936    International order front-end defects
 --$
 --$ Revision 1.13 2015/05/12 15:47:14 kparkhi
 --$ CR33420 changes
 --$
 --$ Revision 1.9 2014/01/28 21:17:03 mvadlapally
 --$ CR25065 - Safelink friends
 --$
 --$ Revision 1.7 2013/07/08 21:43:56 ymillan
 --$ CR22799 CR24253
 --$
 --$ Revision 1.6 2013/04/04 15:45:05 ymillan
 --$ CR22451 TAS simple mobile
 --$
 --$ Revision 1.5 2012/04/19 15:02:46 kacosta
 --$ CR20077 Unsubscribe Backend Process
 --$
 --$ Revision 1.4 2012/04/03 15:28:02 kacosta
 --$ CR20077 Unsubscribe Backend Process
 --$
 --$
 ---------------------------------------------------------------------------------------------
 --
 PROCEDURE createcontact_prc
 (
 p_esn IN VARCHAR2
 ,p_first_name IN VARCHAR2
 ,p_last_name IN VARCHAR2
 ,p_middle_name IN VARCHAR2
 ,p_phone IN VARCHAR2
 ,p_add1 IN VARCHAR2
 ,p_add2 IN VARCHAR2
 ,p_fax IN VARCHAR2
 ,p_city IN VARCHAR2
 ,p_st IN VARCHAR2
 ,p_zip IN VARCHAR2
 ,p_email IN VARCHAR2
 ,p_email_status IN NUMBER
 ,p_roadside_status IN NUMBER
 ,p_no_name_flag IN NUMBER
 ,p_no_phone_flag IN NUMBER
 ,p_no_address_flag IN NUMBER
 ,p_sourcesystem IN VARCHAR2
 ,p_brand_name IN VARCHAR2
 ,p_do_not_email IN NUMBER
 ,p_do_not_phone IN NUMBER
 ,p_do_not_mail IN NUMBER
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
   ,p_add_info2web_user IN NUMBER DEFAULT NULL   -- CR51354 Tim 9/21/17 Added four fields source_system, add_info2web_user, x_esn, x_min to table_x_contact_add_info
   ,p_min               IN VARCHAR2 DEFAULT NULL
  ) IS
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
         AND c.s_first_name || '' = UPPER(c_first_name)
         AND c.s_last_name || '' = UPPER(c_last_name)
         -- CR44294 for fetching only one row
         AND rownum <= 1;

    contact_rec contact_curs%ROWTYPE;

    CURSOR contact_add_info_curs(c_contact_objid IN NUMBER) IS
      SELECT bo.s_name
            ,cai.*
        FROM sa.table_bus_org            bo
            ,sa.table_x_contact_add_info cai
       WHERE 1 = 1
            --AND bo.s_name = DECODE (SUBSTR (UPPER (p_sourcesystem), 1, 3),'NET', 'NET10','TRACFONE')
         AND bo.org_id = p_brand_name
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
       WHERE org_id = p_brand_name;

    --WHERE s_name =
    --         DECODE (SUBSTR (UPPER (p_sourcesystem), 1, 3),
    --                 'NET', 'NET10',
    --                 'TRACFONE'
    --                );
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
       WHERE s_name = UPPER(c_st)
         AND state_prov2country = c_country_objid;

    state_rec state_curs%ROWTYPE;

    CURSOR gbst_curs IS
      SELECT elm.objid
        FROM table_gbst_elm elm
            ,table_gbst_lst lst
       WHERE lst.objid = elm.gbst_elm2gbst_lst
         AND elm.title = 'Default'
         AND lst.title = 'Contact Role';

    gbst_rec gbst_curs%ROWTYPE;
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
    OPEN gbst_curs;

    FETCH gbst_curs
      INTO gbst_rec;

    CLOSE gbst_curs;

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
          ,p_sourcesystem   -- CR51354 Tim 9/21/17
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
              ,source_system       = p_sourcesystem     -- CR51354 Tim 9/21/17
              ,add_info2web_user   = l_add_info2web_user
              ,x_esn               = p_esn
              ,x_min               = p_min
        -- CR14767 End kacosta 03/09/2011
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

    IF (LENGTH(LTRIM(RTRIM(p_phone))) < 10 OR p_phone IS NULL OR LTRIM(RTRIM(p_phone)) = '3057150000' OR LTRIM(RTRIM(p_phone)) = '0000000000') THEN   --CR22799 CR24253
      l_phone :=  CASE WHEN UPPER(p_brand_name)='WFM' THEN NULL ELSE l_cust_id END; -- CR47564
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

    OPEN state_curs(l_st
                   ,country_rec.objid);

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
      ,alert_ind
      ,country)
    VALUES
      (l_contact_objid
      ,l_first_name
      ,UPPER(l_first_name)
      ,l_last_name
      ,UPPER(l_last_name)
      ,l_phone
      ,LTRIM(RTRIM(l_add1))
      ,LTRIM(RTRIM(p_add2))
      ,zip_rec.x_city
      ,zip_rec.x_state
      ,zip_rec.x_zip
      ,DECODE(p_sourcesystem
             ,'NETCSR'
             ,0
             ,'WEBCSR'
             ,0
             ,'TAS'   --CR22451
             ,0
             ,p_no_address_flag)
      ,DECODE(l_first_name || l_last_name
             ,l_cust_id || l_cust_id
             ,DECODE(p_sourcesystem
                    ,'NETCSR'
                    ,0
                    ,'WEBCSR'
                    ,0
                    ,'TAS'   --CR22451
                    ,0
                    ,1)
             ,p_no_name_flag)
      ,DECODE(p_sourcesystem
             ,'NETCSR'
             ,0
             ,'WEBCSR'
             ,0
             ,'TAS'   --CR22451
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
      ,1
      ,country_rec.name);

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
      ,gbst_rec.objid
      ,SYSDATE);

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
      ,p_sourcesystem  -- CR51354 Tim 9/21/17
      ,l_add_info2web_user
      ,p_esn
      ,p_min
       );

    p_err_code := '0';
    p_err_msg  := 'Contact Created Successfully';
  END;


PROCEDURE createcontact_prc(in_esn                 IN     VARCHAR2,
                            in_first_name          IN     VARCHAR2,
                            in_last_name           IN     VARCHAR2,
                            in_middle_name         IN     VARCHAR2,
                            in_phone               IN     VARCHAR2,
                            in_shp_add1            IN     VARCHAR2,
                            in_shp_add2            IN     VARCHAR2,
                            in_shp_fax             IN     VARCHAR2,
                            in_shp_city            IN     VARCHAR2,
                            in_shp_st              IN     VARCHAR2,
                            in_shp_zip             IN     VARCHAR2,
                            in_bil_add1            IN     VARCHAR2,
                            in_bil_add2            IN     VARCHAR2,
                            in_bil_fax             IN     VARCHAR2,
                            in_bil_city            IN     VARCHAR2,
                            in_bil_st              IN     VARCHAR2,
                            in_bil_zip             IN     VARCHAR2,
                            in_email               IN     VARCHAR2,
                            in_email_status        IN     NUMBER,
                            in_roadside_status     IN     NUMBER,
                            in_no_name_flag        IN     NUMBER,
                            in_no_phone_flag       IN     NUMBER,
                            in_no_address_flag     IN     NUMBER,
                            in_sourcesystem        IN     VARCHAR2,
                            in_brand_name          IN     VARCHAR2,
                            in_do_not_email        IN     NUMBER,
                            in_do_not_phone        IN     NUMBER,
                            in_do_not_mail         IN     NUMBER,
                            in_do_not_sms          IN     NUMBER,
                            in_ssn                 IN     VARCHAR2,
                            in_dob                 IN     DATE,
                            in_do_not_mobile_ads   IN     NUMBER,
                            out_contact_objid         OUT NUMBER,
                            out_err_code              OUT VARCHAR2,
                            out_err_msg               OUT VARCHAR2,
                            in_add_info2web_user  IN      NUMBER   DEFAULT NULL,   -- CR51354 Tim 9/21/17 Added four fields source_system, add_info2web_user, x_esn, x_min to table_x_contact_add_info
                            in_min                IN      VARCHAR2 DEFAULT NULL)
IS
    CURSOR zip_curs
    IS
    SELECT *
      FROM sa.table_x_zip_code
     WHERE x_zip = in_bil_zip;

    zip_rec         zip_curs%ROWTYPE;
    zip_rec_extra   zip_curs%ROWTYPE;

    CURSOR timezone_curs
    IS
    SELECT *
      FROM table_time_zone
     WHERE name = 'EST';

    timezone_rec    timezone_curs%ROWTYPE;

    CURSOR country_curs
    IS
    SELECT *
      FROM table_country
     WHERE name = 'USA';

    country_rec     country_curs%ROWTYPE;

    CURSOR state_curs (c_st IN VARCHAR2, c_country_objid IN NUMBER)
    IS
    SELECT *
      FROM table_state_prov
     WHERE s_name = UPPER(c_st)
       AND state_prov2country = c_country_objid;

    state_rec state_curs%ROWTYPE;
     /* Fix for defect #31287 start by Sagar*/
    --l_err_code          PLS_INTEGER := 0;
    --l_contact_objid     PLS_INTEGER;
    --l_add_objid         PLS_INTEGER;

    l_err_code          NUMBER := 0;
    l_contact_objid     NUMBER;
    l_add_objid         NUMBER;
    /* Fix for defect #31287 end by Sagar*/
    l_err_msg           VARCHAR2(200) := NULL;
    l_bil_add1          VARCHAR2(200) := NULL;
    l_bil_add2          VARCHAR2(200) := NULL;
    l_st                VARCHAR2(100) := NULL;

BEGIN
    BEGIN
    createcontact_prc (
        p_esn                 => in_esn,
        p_first_name          => in_first_name,
        p_last_name           => in_last_name,
        p_middle_name         => in_middle_name,
        p_phone               => in_phone,
        p_add1                => in_shp_add1,
        p_add2                => in_shp_add2,
        p_fax                 => in_shp_fax,
        p_city                => in_shp_city,
        p_st                  => in_shp_st,
        p_zip                 => in_shp_zip,
        p_email               => in_email,
        p_email_status        => in_email_status,
        p_roadside_status     => in_roadside_status,
        p_no_name_flag        => in_no_name_flag,
        p_no_phone_flag       => in_no_phone_flag,
        p_no_address_flag     => in_no_address_flag,
        p_sourcesystem        => in_sourcesystem,
        p_brand_name          => in_brand_name,
        p_do_not_email        => in_do_not_email,
        p_do_not_phone        => in_do_not_phone,
        p_do_not_mail         => in_do_not_mail,
        p_do_not_sms          => in_do_not_sms,
        p_ssn                 => in_ssn,
        p_dob                 => in_dob,
        p_do_not_mobile_ads   => in_do_not_mobile_ads,
        p_contact_objid       => l_contact_objid,
        p_err_code            => l_err_code,
        p_err_msg             => l_err_msg,
        p_add_info2web_user   => in_add_info2web_user,
        p_min                 => in_min);
    EXCEPTION
        WHEN OTHERS
        THEN
        ota_util_pkg.err_log('in_esn: '||in_esn||' in_phone: '||in_phone,
                             SYSDATE ,
                             'Failed to call createcontact_prc',
                             'CONTACT_PKG',
                             SUBSTR(SQLERRM, 1, 200));
    END;

    IF in_bil_add1 IS NOT NULL AND l_err_code = 0
    THEN
        l_bil_add1 := LTRIM(RTRIM(in_bil_add1));
        l_bil_add2 := LTRIM(RTRIM(in_bil_add2));

        IF LTRIM(RTRIM(in_bil_st)) IS NULL THEN
        l_st := 'FL';
        ELSE
        l_st := in_bil_st;
        END IF;

        OPEN zip_curs;
        FETCH zip_curs INTO zip_rec;
            IF zip_curs%FOUND THEN
            FETCH zip_curs INTO zip_rec_extra;
                IF zip_curs%FOUND THEN
                CLOSE zip_curs;
                out_err_code := '301';
                out_err_msg  := 'Multiple zipcode data found';
                RETURN;
                END IF;
            ELSE
            CLOSE zip_curs;

            out_err_code := '201';
            out_err_msg  := 'Invalid Zipcode';
            RETURN;
            END IF;
        CLOSE zip_curs;

        OPEN timezone_curs;
        FETCH timezone_curs INTO timezone_rec;
            IF timezone_curs%NOTFOUND THEN
            out_err_code := '206';
            out_err_msg  := 'No Valid Time Zone found';
            RETURN;
            END IF;
        CLOSE timezone_curs;

        OPEN country_curs;
        FETCH country_curs INTO country_rec;
            IF country_curs%NOTFOUND THEN
            out_err_code := '203';
            out_err_msg  := 'No Valid Country found';
            RETURN;
            END IF;
        CLOSE country_curs;

        OPEN state_curs(l_st ,country_rec.objid);
        FETCH state_curs INTO state_rec;
            IF state_curs%NOTFOUND THEN
            out_err_code := '204';
            out_err_msg  := 'No Valid State Code found';
            RETURN;
            END IF;
        CLOSE state_curs;


        l_add_objid := sa.seq ('address');
        BEGIN
            INSERT INTO table_address (objid,
                                       address,
                                       s_address,
                                       city,
                                       s_city,
                                       state,
                                       s_state,
                                       zipcode,
                                       address_2,
                                       dev,
                                       address2time_zone,
                                       address2country,
                                       address2state_prov,
                                       update_stamp)
                 VALUES (l_add_objid,
                         l_bil_add1,
                         UPPER (l_bil_add1),
                         zip_rec.x_city,
                         UPPER (zip_rec.x_city),
                         zip_rec.x_state,
                         UPPER (zip_rec.x_state),
                         zip_rec.x_zip,
                         l_bil_add2,
                         NULL,
                         timezone_rec.objid,
                         country_rec.objid,
                         state_rec.objid,
                         SYSDATE);
        EXCEPTION
            WHEN OTHERS
            THEN
            dbms_output.put_line('EXCEPTION: INSERT INTO table_address');
            ota_util_pkg.err_log('in_esn: '||in_esn||' in_phone: '||in_phone,
                     SYSDATE ,
                     'Excep: INSERT INTO table_address',
                     'CONTACT_PKG',
                     SUBSTR(SQLERRM, 1, 200));
        END;
        BEGIN
            UPDATE table_site
               SET cust_billaddr2address = l_add_objid
             WHERE objid = (SELECT contact_role2site
                              FROM table_contact_role
                             WHERE contact_role2contact = l_contact_objid);
        EXCEPTION
            WHEN OTHERS
            THEN
            ota_util_pkg.err_log('l_contact_objid: '||l_contact_objid||' l_add_objid: '||l_add_objid,
                     SYSDATE ,
                     'Excep: UPDATE table_site',
                     'CONTACT_PKG',
                     SUBSTR(SQLERRM, 1, 200));
        END;
        out_contact_objid   := l_contact_objid;
        out_err_code        := l_err_code;
        out_err_msg         := l_err_msg;
    ELSE
    out_contact_objid   := l_contact_objid;
    out_err_code        := l_err_code;
    out_err_msg         := l_err_msg;
    END IF;

EXCEPTION
    WHEN OTHERS
    THEN
    ota_util_pkg.err_log('in_esn: '||in_esn||' in_phone: '||in_phone,
                     SYSDATE ,
                     'overloading proc createcontact_prc',
                     'CONTACT_PKG',
                     SUBSTR(SQLERRM, 1, 200));
END;

PROCEDURE log_error ( ip_error_text   IN VARCHAR2,
                      ip_error_date   IN DATE,
                      ip_action       IN VARCHAR2,
                      ip_key          IN VARCHAR2,
                      ip_program_name IN VARCHAR2) AS

  PRAGMA AUTONOMOUS_TRANSACTION; -- Declare block as an autonomous transaction

BEGIN
--------------------------------------------------------------------------------------------
  --Author: Kedar Parkhi
  --Date: 05/04/2015
  --This procedure will Insert log message.
  --------------------------------------------------------------------------------------------

  INSERT
  INTO error_table
       ( error_text,
         error_date,
         action,
         key,
         program_name
       )
  VALUES
  ( ip_error_text,
    ip_error_date,
    ip_action ,
    ip_key,
    ip_program_name
  );

  -- Save changes
  COMMIT;
EXCEPTION WHEN OTHERS THEN
   ROLLBACK;
   --RAISE;
END log_error;

procedure sp_GetDeviceSummary
(
        ip_MIN                IN varchar2,
        RESPONSE_CODE      OUT number,
        RESPONSE_MESSAGE   OUT varchar2,
        ESN                OUT varchar2,
        ESN_STATUS          OUT varchar2,
        REPORTING_LINE     OUT varchar2,
        BRAND_NAME         OUT varchar2,
        CARRIER_ID         OUT number,
        CARRIER_NAME       OUT varchar2,
        IVR_PLAN_ID          OUT number,
        DEVICE_TYPE        OUT varchar2,
        LANG_PREF          OUT varchar2,
        LANG_PREF_UPD_TIME    OUT date
)
is
    is_b2b_count number :=0;
 --CR44729 Added for Go Smart
 c_sub_brand VARCHAR2(50);

begin
--------------------------------------------------------------------------------------------
  --Author: Kedar Parkhi
  --Date: 05/04/2015
  --This procedure will fetch all customer information who calls to 611.
  --The information fetched will include ESN, ESN_status, brand name, carrier name, service plan ID,Device type, reporting line.
--------------------------------------------------------------------------------------------
    begin
        SELECT
            esn.part_serial_no,
            esn.x_part_inst_status,
            bo.org_id,
            pa.x_parent_id,
            nvl(pa.x_queue_name,pa.x_parent_name),
            spsp.x_service_plan_id,
            pv.device_type,
            pv.sub_brand
        INTO
            ESN,
            ESN_STATUS,
            BRAND_NAME,
            CARRIER_ID,
            CARRIER_NAME,
            IVR_PLAN_ID,
            DEVICE_TYPE,
            c_sub_brand
        FROM TABLE_PART_INST esn
             join TABLE_PART_INST line
                on LINE.PART_TO_ESN2PART_INST = ESN.OBJID
             join TABLE_MOD_LEVEL ML
                on ml.objid = esn.n_part_inst2part_mod
             join TABLE_PART_NUM PN
                on pn.objid = ml.part_info2part_num
             join TABLE_X_CARRIER CA
                on ca.objid = line.part_inst2carrier_mkt
             join TABLE_X_CARRIER_GROUP CG
                on cg.objid = ca.carrier2carrier_group
             join TABLE_X_PARENT PA
                on pa.objid = cg.x_carrier_group2x_parent
             join TABLE_BUS_ORG BO
                on pn.part_num2bus_org = bo.objid
             join table_part_class pc
                on pn.part_num2part_class = pc.objid
             join sa.pcpv_mv pv --CR47564 WFM changed to use pcpv_mv from pcpv view
                on PV.PC_OBJID = PC.OBJID
             left join TABLE_SITE_PART TSP
                on esn.part_serial_no = tsp.x_service_id
             and lower(tsp.part_status) = 'active'
             left join X_SERVICE_PLAN_SITE_PART SPSP
                on tsp.objid = spsp.table_site_part_id
             where ESN.X_DOMAIN = 'PHONES'
             and LINE.X_DOMAIN = 'LINES'
             and line.part_serial_no not like 'T%'
             and (esn.part_serial_no = ip_MIN
                  or LINE.PART_SERIAL_NO = ip_MIN) ;
    EXCEPTION
        when no_data_found then
            RESPONSE_CODE:=1001;
            RESPONSE_MESSAGE:= 'NO CUSTOMER DATA FOUND';
            -- Log error message
			-- Commented error table insert statement : CR55771 : spagidala on 2018/01/08
            --log_error( ip_error_text   => 'NO CUSTOMER DATA FOUND',
            --    ip_error_date   => SYSDATE,
            --    ip_action       => 'exception when no_data_found clause for ip_MIN = ' || ip_MIN,
            --    ip_key          => ip_min,
            --    ip_program_name => 'contact_pkg.sp_GetDeviceSummary');
            return;
        when others then
            RESPONSE_CODE:=1002;
            RESPONSE_MESSAGE:= sqlerrm;
            -- Log error message
            log_error( ip_error_text   => 'SQLERRM: ' || SQLERRM,
                ip_error_date   => SYSDATE,
                ip_action       => 'exception when others clause for ip_MIN = ' || ip_MIN,
                ip_key          => ip_min,
                ip_program_name => 'contact_pkg.sp_GetDeviceSummary');
            return;
    end;

    begin
        select
            cai.x_lang_pref,
            cai.X_Lang_Pref_Time
        into
            LANG_PREF,
            LANG_PREF_UPD_TIME
        from
            sa.TABLE_X_CONTACT_ADD_INFO cai,
            sa.TABLE_CONTACT tc,
            sa.table_x_contact_part_inst cpi,
            sa.table_part_inst pi
            where 1=1
            and cai.ADD_INFO2CONTACT = TC.OBJID
            and cpi.X_CONTACT_PART_INST2CONTACT = TC.OBJID
            and cpi.X_CONTACT_PART_INST2PART_INST = PI.OBJID
            and pi.part_serial_no = ESN;
            --and pi.part_serial_no = '268435458401707819';
    exception
        when no_data_found then
        --CR40157 changes to lookup esn contact when there is no web contact
        begin
         select
             cai.x_lang_pref,
             cai.X_Lang_Pref_Time
         into
             LANG_PREF,
             LANG_PREF_UPD_TIME
         from
            sa.TABLE_X_CONTACT_ADD_INFO cai,
            sa.TABLE_CONTACT tc,
            sa.table_part_inst pi
            where 1=1
            and cai.ADD_INFO2CONTACT = TC.OBJID
            and pi.x_part_inst2contact= TC.objid
            and pi.part_serial_no = ESN;
        Exception
          when others then
            null;
        end;
        --CR40157 changes
    end;

    begin
    -- This code is to lookup tables to know if Reporting line is for CLEARWAY.
        select  count(*)
        into is_b2b_count
        from TABLE_WEB_USER WU,
             TABLE_X_CONTACT_PART_INST CPI,
             TABLE_PART_INST PI,
             X_SITE_WEB_ACCOUNTS SWA
        where WU.WEB_USER2CONTACT = CPI.X_CONTACT_PART_INST2CONTACT
        and CPI.X_CONTACT_PART_INST2PART_INST = PI.OBJID
        and SWA.SITE_WEB_ACCT2WEB_USER = WU.OBJID
        and  PI.PART_SERIAL_NO = ESN;
    EXCEPTION
        when no_data_found then
         is_b2b_count := 0;
    END;

    if is_b2b_count > 0 then
      REPORTING_LINE := 'CLEARWAY';
    else
        begin
        -- This code is to lookup tables to know if Reporting line is for SAFELINK.
            select count(*)
            into is_b2b_count
            from X_SL_HIST sh
            where sh.x_esn = ESN;
        EXCEPTION
        when no_data_found then
            is_b2b_count := 0;
        end;
        if is_b2b_count > 0 then
            REPORTING_LINE := 'SAFELINK';
            --CR44729 GO SMART
            -- IF SUB BRAND IS PRESENT THEN RETURN SUB BRAND INSTEAD OF BRAND NAME
        elsif c_sub_brand IS NOT NULL THEN
            REPORTING_LINE := c_sub_brand;
        else
            REPORTING_LINE:=BRAND_NAME;
        end if;
    end if;

    RESPONSE_CODE:=0;
    RESPONSE_MESSAGE:= 'SUCCESS';

end;

PROCEDURE SP_SETLANGUAGEPREF
(
    ip_MIN                IN varchar2,
    ip_LANG_PREF          IN varchar2,
    RESPONSE_CODE      OUT number,
    RESPONSE_MESSAGE   OUT varchar2
)
AS
v_esn varchar2(30);
l_count NUMBER:=0;
rc     sa.customer_type  := sa.customer_type ();
cst    sa.customer_type;
BEGIN
  --------------------------------------------------------------------------------------------
  --Author: Kedar Parkhi
  --Date: 05/04/2015
  --This procedure will take input as language preference from customer and updates into table.
--------------------------------------------------------------------------------------------
    begin
        select esn.part_serial_no
        into v_esn
        from table_part_inst esn,
             table_part_inst line
        where LINE.PART_TO_ESN2PART_INST = ESN.OBJID
        and ESN.X_DOMAIN = 'PHONES'
        and LINE.X_DOMAIN = 'LINES'
        and line.part_serial_no not like 'T%'
        and (esn.part_serial_no = ip_MIN
             or LINE.PART_SERIAL_NO = ip_MIN);
    exception
        when no_data_found then
            RESPONSE_CODE:=1;
            RESPONSE_MESSAGE:= 'NO CUSTOMER DATA FOUND';
            return;
        when others then
            RESPONSE_CODE:=2;
            RESPONSE_MESSAGE:= sqlerrm;
            return;
    end;

    --CR40157
    rc.esn := v_esn;
    cst := rc.get_web_user_attributes;
    --CR40157

    BEGIN              --  CR40157 (defect 10794) sethiraj

      IF  cst.web_contact_objid IS NOT NULL THEN
          UPDATE table_x_contact_add_info cai
           SET  cai.x_lang_pref       =    ip_lang_pref,
                cai.X_Lang_Pref_Time  =  sysdate
          WHERE cai.add_info2contact = cst.web_contact_objid ;

        BEGIN
         SELECT COUNT(1)
         INTO l_count
         FROM table_x_contact_add_info
         WHERE add_info2contact = cst.web_contact_objid
         AND x_lang_pref       =    ip_lang_pref;
        EXCEPTION
         WHEN NO_DATA_FOUND THEN
           l_count :=0;
         WHEN OTHERS THEN
            RESPONSE_CODE:=2;
            RESPONSE_MESSAGE:= sqlerrm;
        END;

      END IF;

       /* and exists (select 1
                    from sa.TABLE_CONTACT tc,
                         sa.table_x_contact_part_inst cpi,
                         sa.table_part_inst pi
                    where 1=1
                    and cai.ADD_INFO2CONTACT = TC.OBJID
                    and cpi.X_CONTACT_PART_INST2CONTACT = TC.OBJID
                    and cpi.X_CONTACT_PART_INST2PART_INST = PI.OBJID
                    and pi.part_serial_no = v_esn
                      );*/
        /*update
        (
        select
                cai.x_lang_pref    old_lang,
                Cai.X_Lang_Pref_Time old_time
            from
                SA.TABLE_X_CONTACT_ADD_INFO cai,
                sa.TABLE_CONTACT tc,
                sa.table_x_contact_part_inst cpi,
                sa.table_part_inst pi
                where 1=1
                and cai.ADD_INFO2CONTACT = TC.OBJID
                and cpi.X_CONTACT_PART_INST2CONTACT = TC.OBJID
                and cpi.X_CONTACT_PART_INST2PART_INST = PI.OBJID
                and pi.part_serial_no = v_esn
        )
        set old_lang = ip_LANG_PREF,
            old_time = sysdate ;*/
    EXCEPTION
        WHEN no_data_found THEN
            RESPONSE_CODE:=1001;
            RESPONSE_MESSAGE:= 'NO CUSTOMER DATA FOUND';
            RETURN;
        WHEN OTHERS then
            RESPONSE_CODE:=2;
            RESPONSE_MESSAGE:= sqlerrm;
            RETURN;
    end;
    IF l_count =0 THEN

      UPDATE table_x_contact_add_info cai
          SET  cai.x_lang_pref        =    ip_lang_pref,
                cai.X_Lang_Pref_Time  =  sysdate
        WHERE cai.add_info2contact = cst.contact_objid  ; --update by ESN contact

      BEGIN
         SELECT COUNT(1)
         INTO l_count
         FROM table_x_contact_add_info
         WHERE add_info2contact = cst.contact_objid
         AND  x_lang_pref       =    ip_lang_pref;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
           l_count :=0;
         WHEN OTHERS THEN
            RESPONSE_CODE:=2;
            RESPONSE_MESSAGE:= sqlerrm;
      END;

      IF l_count =0 THEN
       RESPONSE_CODE:=1001;
       RESPONSE_MESSAGE:= 'NO CUSTOMER DATA FOUND';
       return;
      END IF;
    END IF;
    COMMIT;
    RESPONSE_CODE:=0;
    RESPONSE_MESSAGE:= 'SUCCESS';

END SP_SETLANGUAGEPREF;

--CR44729 Go Smart --Start
PROCEDURE updatecontact_prc ( i_contact_objid     IN NUMBER    ,
                              i_esn               IN VARCHAR2  ,
                              i_first_name        IN VARCHAR2  ,
                              i_last_name         IN VARCHAR2  ,
                              i_middle_name       IN VARCHAR2  ,
                              i_phone             IN VARCHAR2  ,
                              i_add1              IN VARCHAR2  ,
                              i_add2              IN VARCHAR2  ,
                              i_fax               IN VARCHAR2  ,
                              i_city              IN VARCHAR2  ,
                              i_st                IN VARCHAR2  ,
                              i_zip               IN VARCHAR2  ,
                              i_email             IN VARCHAR2  ,
                              i_email_status      IN NUMBER    ,
                              i_roadside_status   IN NUMBER    ,
                              i_no_name_flag      IN NUMBER    ,
                              i_no_phone_flag     IN NUMBER    ,
                              i_no_address_flag   IN NUMBER    ,
                              i_sourcesystem      IN VARCHAR2  ,
                              i_brand_name        IN VARCHAR2  ,
                              i_do_not_email      IN NUMBER    ,
                              i_do_not_phone      IN NUMBER    ,
                              i_do_not_mail       IN NUMBER    ,
                              i_do_not_sms        IN NUMBER    ,
                              i_ssn               IN VARCHAR2  ,
                              i_dob               IN DATE      ,
                              i_do_not_mobile_ads IN NUMBER    ,
                              o_err_code          OUT VARCHAR2 ,
                              o_err_msg           OUT VARCHAR2 ) IS

  -- Local variables
  n_contact_cnt NUMBER;
  n_esn_cnt     NUMBER;
  n_addr_objid  NUMBER;

BEGIN -- Main Section

  IF i_contact_objid IS NULL THEN
    o_err_code := 1001;
    o_err_msg  := 'CONTACT OBJID NOT PASSED';
    RETURN;
  END IF;

  -- Check for the valid contact information
  BEGIN
    SELECT COUNT(1)
    INTO   n_contact_cnt
    FROM   table_contact
    WHERE  objid = i_contact_objid;
   EXCEPTION
     WHEN OTHERS THEN
       n_contact_cnt := 0;
  END;

  --
  IF n_contact_cnt = 0 THEN
    o_err_code := 1006;
    o_err_msg  := 'PLEASE PASS VALID CONTACT OBJID INPUT';
    RETURN;
  END IF;

  -- only validate the esn when it is passed
  IF i_esn IS NOT NULL THEN
    BEGIN
      SELECT COUNT(1)
      INTO   n_esn_cnt
      FROM   table_part_inst pi
      WHERE  pi.part_serial_no = i_esn;
     EXCEPTION
       WHEN OTHERS THEN
         n_esn_cnt := 0;
    END;
    -- if esn is not found in part inst
    IF n_esn_cnt = 0 THEN
      o_err_code := 1007;
      o_err_msg  := 'INVALID ESN PASSED';
      RETURN;
    END IF;
  END IF;

  -- updating table_contact
  BEGIN
    UPDATE table_contact
    SET    first_name           = i_first_name,
           last_name            = i_last_name ,
           s_first_name         = UPPER(i_first_name),
           s_last_name          = UPPER(i_last_name),
           phone                = i_phone     ,
           fax_number           = i_fax       ,
           e_mail               = i_email     ,
           address_1            = i_add1      ,
           address_2            = i_add2      ,
           city                 = i_city      ,
           state                = i_st        ,
           zipcode              = i_zip       ,
           x_dateofbirth        = i_dob       ,
           x_middle_initial     = SUBSTR(LTRIM(RTRIM(i_middle_name)),1,3),
           x_no_address_flag    = DECODE( i_sourcesystem,
                                          'NETCSR'      ,
                                          0             ,
                                          'WEBCSR'      ,
                                          0             ,
                                          'TAS'         ,
                                          0             ,
                                          i_no_address_flag
                                          ),
           x_no_name_flag       = DECODE( i_sourcesystem,
                                          'NETCSR'      ,
                                          0             ,
                                          'WEBCSR'      ,
                                          0             ,
                                          'TAS'         ,
                                          0             ,
                                          i_no_name_flag
                                          ),
           x_ss_number          = i_ssn                ,
           x_no_phone_flag      = DECODE( i_sourcesystem,
                                          'NETCSR'      ,
                                          0             ,
                                          'WEBCSR'      ,
                                          0             ,
                                          'TAS'         ,
                                          0             ,
                                          i_no_phone_flag
                                          ),
           update_stamp         = SYSDATE              ,
           x_email_status       = NVL(i_email_status,0),
           x_roadside_status    = i_roadside_status
    WHERE  objid                = i_contact_objid;
   EXCEPTION
     WHEN OTHERS THEN
        o_err_code := 1008;
        o_err_msg  := 'ERROR UPDATING TABLE_CONTACT: '||SUBSTR (SQLERRM, 1, 500);
        RETURN;
  END;

  -- Retrieve address objid for given contact
  BEGIN
    SELECT ts.cust_billaddr2address
    INTO   n_addr_objid
    FROM   table_contact_role tcr,
           table_site          ts
    WHERE  tcr.contact_role2contact = i_contact_objid
    AND    tcr.contact_role2site    = ts.objid;
   EXCEPTION
     WHEN OTHERS THEN
       o_err_code := 1012;
        o_err_msg  := 'ERROR GETTING ADDRESS: '||SUBSTR (SQLERRM, 1, 500);
       RETURN;
  END;

  -- Updating table_address
  BEGIN
    UPDATE table_address
    SET    address             = i_add1       ,
           s_address           = UPPER(i_add1),
           city                = i_city,
           s_city              = UPPER(i_city),
           state               = i_st,
           s_state             = UPPER(i_st),
           zipcode             = i_zip,
           address_2           = UPPER(i_add2),
           update_stamp        = SYSDATE
    WHERE  objid               = n_addr_objid;
   EXCEPTION
     WHEN OTHERS THEN
        o_err_code := 1009;
        o_err_msg  := 'ERROR UPDATING TABLE_ADDRESS: '||SUBSTR (SQLERRM, 1, 500);
        RETURN;
  END;

  --Updating table_x_contact_add_info
  BEGIN
    UPDATE table_x_contact_add_info
    SET    x_do_not_email      = i_do_not_email,
           x_do_not_phone      = i_do_not_phone,
           x_do_not_sms        = i_do_not_sms  ,
           x_do_not_mail       = i_do_not_mail ,
           x_last_update_date  = SYSDATE       ,
           x_dateofbirth       = i_dob         ,
           x_do_not_mobile_ads = i_do_not_mobile_ads
    WHERE  add_info2contact    = i_contact_objid;
   EXCEPTION
     WHEN OTHERS THEN
        o_err_code := 1010;
        o_err_msg  := 'ERROR UPDATING TABLE_X_CONTACT_ADD_INFO: '||SUBSTR (SQLERRM, 1, 500);
        RETURN;
  END;

  -- return success
  o_err_code := 0;
  o_err_msg  := 'Success';

 EXCEPTION
   WHEN OTHERS THEN
     o_err_code := 1011;
     o_err_msg  := SQLCODE||' '||SUBSTR (SQLERRM, 1, 100);
--
END updatecontact_prc;
--CR44729 Go Smart --End

procedure get_customer_contact_info    (ip_esn                VARCHAR2
                    ,op_x_do_not_email    OUT    VARCHAR2
                    ,op_x_do_not_phone    OUT    VARCHAR2
                    ,op_x_do_not_sms    OUT    VARCHAR2
                    ,op_x_do_not_mail    OUT    VARCHAR2
                    ,op_error_code        OUT    VARCHAR2
                    ,op_error_msg        OUT    VARCHAR2
                    )

IS

    cst                    sa.customer_type := sa.customer_type ();
    c                      sa.customer_type;

BEGIN

    op_error_code        :=    '0';
    op_error_msg        :=    'SUCCESS';
    op_x_do_not_email    :=    '0';
    op_x_do_not_phone    :=    '0';
    op_x_do_not_sms        :=    '0';
    op_x_do_not_mail    :=    '0';
    c := cst.get_contact_add_info ( i_esn => ip_esn );
    op_x_do_not_email    :=    NVL(c.do_not_email,0);
    op_x_do_not_phone    :=    NVL(c.do_not_phone,0);
    op_x_do_not_sms        :=    NVL(c.do_not_sms,0);
    op_x_do_not_mail    :=    NVL(c.do_not_mail,0);

EXCEPTION WHEN OTHERS
THEN
    op_error_code    :=    '99';
    op_error_msg    :=    'Fail - Main Exception '||'CONTACT_PKG.GET_CUSTOMER_CONTACT_INFO '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;

util_pkg.insert_error_tab ( i_action         =>    'get_customer_contact_info Main exception',
                             i_key            =>   ip_esn,
                             i_program_name   =>   'get_customer_contact_info',
                             i_error_text     =>   trim(substr(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,500)));


END get_customer_contact_info;

--CR47564 WFM --Start
PROCEDURE get_security_pin
 (i_min               IN VARCHAR2 ,
  i_esn               IN VARCHAR2,
  o_pin               OUT VARCHAR2,
  o_err_code          OUT VARCHAR2,
  o_err_msg           OUT VARCHAR2
  )
IS
 --Local variables here
   l_esn  table_part_inst.part_serial_no%type;
BEGIN

--Initial Validation
  IF i_min is NULL and i_esn is NULL THEN
    o_err_code := '1';
    o_err_msg  := 'Please provide either MIN or ESN';
    RETURN;
 ELSIF i_esn is NOT NULL THEN
   l_esn  := i_esn ;
 ELSIF i_esn is NULL and i_min is NOT NULL THEN
   SELECT sa.customer_info.get_esn(i_min => i_min)
     INTO l_esn
     FROM DUAL;
 END IF;

   --Retrive PIN
   SELECT sa.customer_info.get_contact_add_info (i_esn => l_esn, i_value => 'PIN')
    INTO o_pin
   FROM DUAL;

  --Return Success
  o_err_code := '0';
  o_err_msg  := 'Success';
EXCEPTION
  WHEN NO_DATA_FOUND THEN
      o_err_code := '1';
      o_pin      := NULL;
      o_err_msg  := 'No Record found : '||SQLCODE||' '||SUBSTR (SQLERRM, 1, 100);
  WHEN OTHERS THEN
      o_err_code := '2';
      o_pin      := NULL;
      o_err_msg  := SQLCODE||' '||SUBSTR (SQLERRM, 1, 100);
END get_security_pin;

PROCEDURE update_security_pin
 (i_min               IN VARCHAR2 ,
  i_esn               IN VARCHAR2,
  i_pin               IN VARCHAR2 ,
  o_err_code          OUT VARCHAR2,
  o_err_msg           OUT VARCHAR2
  ) IS

 --Local variables here
  l_contact_objid   NUMBER;
  l_min             table_part_inst.part_serial_no%type;
  l_esn             table_part_inst.part_serial_no%type;
  c                 sa.customer_type  :=  customer_type ();
  l_bus_org_objid   table_bus_org.objid%type;

BEGIN

 --Initial Validation - PIN
 --Fix for defect#23440 start
 /*IF i_pin IS NULL THEN
    o_err_code := '1';
    o_err_msg  := 'PIN cannot be NULL';
    RETURN;
 END IF;*/
 --Fix for defect#23440 end

 --Initial Validation - ESN/MIN
 IF i_min is NULL and i_esn is NULL THEN
    o_err_code := '2';
    o_err_msg  := 'Please provide either MIN or ESN';
    RETURN;
 ELSIF i_esn is NOT NULL THEN
    l_esn  := i_esn ;
 ELSIF i_esn is NULL and i_min is NOT NULL THEN
    SELECT sa.customer_info.get_esn(i_min => i_min)
    INTO l_esn
    FROM DUAL;
 END IF;

  --Retrieve bus_org_objid
  SELECT sa.customer_info.get_bus_org_objid(i_esn =>l_esn)
    INTO l_bus_org_objid
    FROM  DUAL;

  --Retrieve contact objid
  SELECT sa.customer_info.get_contact_add_info (i_esn => l_esn, i_value => 'CONTACT_OBJID')
    INTO l_contact_objid
   FROM DUAL;

  --Updating security_pin
  UPDATE table_x_contact_add_info
  SET    x_pin = i_pin
  WHERE  add_info2contact = l_contact_objid
    AND  add_info2bus_org = l_bus_org_objid;
  --
  -- Update the changes to LDAP
  contact_pkg.p_update_ldap ( i_esn               =>  NVL(i_esn,l_esn),
                              o_error_code        =>  o_err_code,
                              o_error_msg         =>  o_err_msg);
 --Return Success
  o_err_code := '0';
  o_err_msg  := 'Success';

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    o_err_code := '1';
    o_err_msg  := 'No Record found : '||SQLCODE||' '||SUBSTR (SQLERRM, 1, 100);
  WHEN OTHERS THEN
    o_err_code := '2';
    o_err_msg  := SQLCODE||' '||SUBSTR (SQLERRM, 1, 100);
END update_security_pin;

   --CR47564 - New Overloading procedure createcontact_prc with security_pin as a new IN parameter --vidyasagar--
   PROCEDURE createcontact_prc (p_esn                 IN VARCHAR2,
                                p_first_name          IN VARCHAR2,
                                p_last_name           IN VARCHAR2,
                                p_middle_name         IN VARCHAR2,
                                p_phone               IN VARCHAR2,
                                p_add1                IN VARCHAR2,
                                p_add2                IN VARCHAR2,
                                p_fax                 IN VARCHAR2,
                                p_city                IN VARCHAR2,
                                p_st                  IN VARCHAR2,
                                p_zip                 IN VARCHAR2,
                                p_email               IN VARCHAR2,
                                p_email_status        IN NUMBER,
                                p_roadside_status     IN NUMBER,
                                p_no_name_flag        IN NUMBER,
                                p_no_phone_flag       IN NUMBER,
                                p_no_address_flag     IN NUMBER,
                                p_sourcesystem        IN VARCHAR2,
                                p_brand_name          IN VARCHAR2,
                                p_do_not_email        IN NUMBER,
                                p_do_not_phone        IN NUMBER,
                                p_do_not_mail         IN NUMBER,
                                p_do_not_sms          IN NUMBER,
                                p_ssn                 IN VARCHAR2,
                                p_dob                 IN DATE, -- CR14767 Start kacosta 03/09/2011
                                p_do_not_mobile_ads   IN NUMBER, -- CR14767 End kacosta 03/09/2011
                                p_security_pin        IN VARCHAR2, -- CR47564
                                p_contact_objid       OUT NUMBER,
                                p_err_code            OUT VARCHAR2,
                                p_err_msg             OUT VARCHAR2
                               )
    IS
        ln_bo_objid            NUMBER := NULL;
        lv_err_code            VARCHAR2(200)    := NULL;
        lv_err_msg            VARCHAR2(4000)    := NULL;
    BEGIN
        --Get the bus org id
      SELECT objid
        INTO ln_bo_objid
        FROM table_bus_org
       WHERE org_id = p_brand_name;

      --Execute the original procedure to create contact
      BEGIN
         createcontact_prc (p_esn                 => p_esn,
                            p_first_name          => p_first_name,
                            p_last_name           => p_last_name,
                            p_middle_name         => p_middle_name,
                            p_phone               => p_phone,
                            p_add1                => p_add1,
                            p_add2                => p_add2,
                            p_fax                 => p_fax,
                            p_city                => p_city,
                            p_st                  => p_st,
                            p_zip                 => p_zip,
                            p_email               => p_email,
                            p_email_status        => p_email_status,
                            p_roadside_status     => p_roadside_status,
                            p_no_name_flag        => p_no_name_flag,
                            p_no_phone_flag       => p_no_phone_flag,
                            p_no_address_flag     => p_no_address_flag,
                            p_sourcesystem        => p_sourcesystem,
                            p_brand_name          => p_brand_name,
                            p_do_not_email        => p_do_not_email,
                            p_do_not_phone        => p_do_not_phone,
                            p_do_not_mail         => p_do_not_mail,
                            p_do_not_sms          => p_do_not_sms,
                            p_ssn                 => p_ssn,
                            p_dob                 => p_dob,
                            p_do_not_mobile_ads   => p_do_not_mobile_ads,
                            p_contact_objid       => p_contact_objid,
                            p_err_code            => p_err_code,
                            p_err_msg             => p_err_msg
                           );
      EXCEPTION
         WHEN OTHERS
         THEN
            lv_err_code := SQLCODE;
            lv_err_msg  := 'Unexpected error while updating the security pin for the given contact. '||SUBSTR(SQLERRM,1,2000);
      END;

      --Update the security pin for the contact created above
      BEGIN
         UPDATE table_x_contact_add_info
            SET x_pin = p_security_pin
          WHERE add_info2contact = p_contact_objid
            AND add_info2bus_org = ln_bo_objid;
      EXCEPTION
         WHEN OTHERS
         THEN
            lv_err_code         := SQLCODE;
            lv_err_msg         := 'Unexpected error while updating the security pin for the given contact. '||SUBSTR(SQLERRM,1,2000);
      END;
      p_err_code    := lv_err_code;
      p_err_msg    := lv_err_msg;
   END createcontact_prc;
   --CR47564 - End of Overloading procedure Validate_phone_prc with security_pin as a new IN parameter --vidyasagar--

   --  New function which was copied from trigger trg_web_user2
--
FUNCTION fn_get_social_media_links(p_wu_objid IN NUMBER)
RETURN VARCHAR2 IS
  ret_str VARCHAR2(2000);
BEGIN
  FOR i in ( SELECT X_SOCIAL_MEDIA_UID,x_status FROM x_sme_2mobileuser
            WHERE X_SME_MOBILEUSER2WEBUSER = p_wu_objid)
  LOOP
    IF i.x_status = 1 THEN
     ret_str := ret_str||'|'||i.X_SOCIAL_MEDIA_UID||' facebook';
    END IF;
  END LOOP;
  --
  RETURN SUBSTR(ret_str,2);
--
END fn_get_social_media_links;
--
-- gets the concatenated list of MIN, Security pin and update /insert LDAP table
--
PROCEDURE p_update_ldap ( i_esn               IN    VARCHAR2,
                          o_error_code        OUT   NUMBER,
                          o_error_msg         OUT   VARCHAR2)
IS
--
c                     sa.customer_type := customer_type();
l_min_contact_pin     VARCHAR2(1000);
l_mins                VARCHAR2(1000);
l_web_user_objid      NUMBER;
l_web_user2bus_org    NUMBER;
--
BEGIN
--
  IF i_esn  IS NULL
  THEN
    o_error_code    :=  '200';
    o_error_msg     :=  'ESN cannot be null';
    RETURN;
  END IF;
  --
  c.esn               :=  i_esn;
  c                   :=  c.get_web_user_attributes;

  --CR53621 Changes
    IF Account_Maintenance_pkg.get_account_status(i_login_name=> c.web_login_name ,i_bus_org_objid => c.bus_org_objid  ) =  'DUMMY_ACCOUNT'
    THEN

        o_error_code  :=  0;
        o_error_msg   :=  'FAILURE';

     RETURN ;
   END IF;

  --
  contact_pkg.p_get_min_security_pin (i_web_user_objid      =>  c.web_user_objid,
                                      i_web_user2bus_org    =>  c.bus_org_objid,
                                      i_esn                 =>  i_esn,
                                      i_action              =>  'UPDATE',
                                      o_min_contact_pin     =>  l_min_contact_pin,
                                      o_mins                =>  l_mins,
                                      o_err_code            =>  o_error_code,
                                      o_err_msg             =>  o_error_msg);


 MERGE
  INTO  tdi.ccduser ccd
  USING ( SELECT  wu.* ,
                  (SELECT name FROM table_bus_org WHERE objid = wu.WEB_USER2BUS_ORG) org_id_name,
                  (SELECT first_name FROM table_contact WHERE objid = wu.web_user2contact) first_name,
                  (SELECT last_name FROM table_contact  WHERE objid = wu.web_user2contact) last_name,
                  (SELECT MAX(ROWID) from tdi.ccduser WHERE clfy_wu_objid =wu.objid) mrid
          FROM    table_web_user  wu
          WHERE   wu.objid    = c.web_user_objid
        ) wuccd
  ON    (ccd.clfy_wu_objid  = wuccd.objid AND
         ccd.ROWID          = wuccd.mrid    AND
         nvl(ccd.who,'WU') <> 'WU')
  WHEN MATCHED THEN
    UPDATE  SET
            clfy_contact_pin  = l_min_contact_pin,
            mobiles           = l_mins
  WHEN NOT MATCHED THEN
    INSERT (ibmsnap_commitseq,
            ibmsnap_intentseq,
            ibmsnap_operation,
            ibmsnap_logmarker,
            clfy_wu_objid,
            clfy_con_objid,
            clfy_contact_pin,
            mobiles,
            who,
            password,
            brand,
            firstname,
            lastname,
            email,
            socialmedia_link_tokens)
    VALUES (LPAD(TO_CHAR(tdi.SGENERATOR001.NEXTVAL),20,'0'),
            LPAD(TO_CHAR(tdi.SGENERATOR002.NEXTVAL),20,'0'),
            'U',
            SYSDATE,
            wuccd.objid,
            wuccd.web_user2contact,
            l_min_contact_pin,
            l_mins,
            'WU',
            wuccd.password,
            wuccd.org_id_name,
            wuccd.first_name,
            wuccd.last_name,
            wuccd.s_login_name,
            contact_pkg.fn_get_social_media_links(wuccd.objid));
  --

  o_error_code  :=  0;
  o_error_msg   :=  'SUCCESS';
--
EXCEPTION
  WHEN OTHERS THEN
    o_error_code  :=  201;
    o_error_msg   :=  'Inside when others p_update_ldap '|| SUBSTR(SQLERRM,1,1000);
END p_update_ldap;
-- procedure to update the contact pin based on the flag in x_ig_order_type
--
PROCEDURE p_update_contact_pin  ( i_esn               IN    VARCHAR2,
                                  i_ig_order_type     IN    VARCHAR2,
                                  i_program_name      IN    VARCHAR2 DEFAULT  'SP_INSERT_IG_TRANSACTION',
                                  i_ig_status         IN    VARCHAR2,
                                  i_ig_transaction_id IN    VARCHAR2,
                                  o_error_code        OUT   NUMBER,
                                  o_error_msg         OUT   VARCHAR2)
IS
  l_min_contact_pin             VARCHAR2(1000);
  l_err_code                    VARCHAR2(1000);
  l_err_msg                     VARCHAR2(1000);
  l_web_user_objid              NUMBER;
  l_web_user2bus_org            NUMBER;
  c                             sa.customer_type := customer_type();
  l_contact_pin_update_flag     VARCHAR2(1) :=  'N';
--
BEGIN
--
  IF i_esn  IS NULL
  THEN
    o_error_code    :=  100;
    o_error_msg     :=  'ESN cannot be null';
    RETURN;
  END IF;
  --
  -- Get the contact pin update flag from x_ig_order_type
  BEGIN
    SELECT  NVL(contact_pin_update_flag, 'N')
    INTO    l_contact_pin_update_flag
    FROM    x_ig_order_type
    WHERE   x_programme_name                  =   i_program_name
    AND     x_ig_order_type                   =   i_ig_order_type;
  EXCEPTION
    WHEN OTHERS THEN
      l_contact_pin_update_flag :=  'N';
  END;
  --
  IF l_contact_pin_update_flag  = 'Y'
  THEN
    --
    contact_pkg.p_update_ldap  (  i_esn               =>  i_esn,
                                  o_error_code        =>  o_error_code,
                                  o_error_msg         =>  o_error_msg);
  END IF;
  --
  o_error_code  :=  0;
  o_error_msg   :=  'SUCCESS';
--
EXCEPTION
  WHEN OTHERS THEN
    o_error_code  :=  101;
    o_error_msg   :=  'Inside when others p_update_contact_pin '|| SUBSTR(SQLERRM,1,1000);
END p_update_contact_pin;
--
-- new procedure to get concatenated min and security pin for the contact
-- and also to get concatenated list of mins for the contact
PROCEDURE p_get_min_security_pin (i_web_user_objid      IN    NUMBER,
                                  i_web_user2bus_org    IN    NUMBER,
                                  i_min                 IN    VARCHAR2 DEFAULT NULL,
                                  i_esn                 IN    VARCHAR2 DEFAULT NULL,
                                  i_action              IN    VARCHAR2,
                                  o_min_contact_pin     OUT   VARCHAR2,
                                  o_mins                OUT   VARCHAR2,
                                  o_err_code            OUT   VARCHAR2,
                                  o_err_msg             OUT   VARCHAR2)
IS
--
  l_min_contact_pin       VARCHAR2(1000);
  l_min                   VARCHAR2(30);
  l_mins                  VARCHAR2(1000);
  c                       sa.customer_type := customer_type();
BEGIN
--
  -- Input validation
  IF  NVL(i_web_user2bus_org, 0)   = 0  OR
      NVL(i_web_user_objid, 0)     = 0
  THEN
    o_err_code  :=  '100';
    o_err_msg   :=  'Input values cannot be null';
    RETURN;
  END IF;
  --
  IF i_action IS NULL
  THEN
    o_err_code  :=  '110';
    o_err_msg   :=  'Action cannot be null';
    RETURN;
  END IF;
  --
  FOR each IN ( SELECT  wu.web_user2contact,pi.part_serial_no, pi.x_part_inst2contact, cai.x_pin
                FROM    table_x_contact_add_info    cai,
                        table_part_inst             pi,
                        table_x_contact_part_inst   cpi,
                        table_web_user              wu
                WHERE   pi.x_part_inst2contact            = cai.add_info2contact
                AND     cpi.x_contact_part_inst2part_inst = pi.objid
                AND     wu.web_user2contact               = cpi.x_contact_part_inst2contact
                AND     wu.web_user2bus_org               = i_web_user2bus_org
                AND     wu.objid                          = i_web_user_objid
              )
  LOOP
    l_min             := c.get_min (i_esn =>  each.part_serial_no);
    --
    -- Exclude T Mins and ESNs without MIN (Not Active)
    IF l_min IS NOT NULL AND
       l_min NOT LIKE  'T%'
    THEN
      --
      l_min_contact_pin := l_min_contact_pin || l_min||' '||each.x_pin||'|' ;
      --
      l_mins            :=  l_mins  ||  l_min||'|' ;
      --
    END IF;
    --
  END LOOP;
  --
  o_min_contact_pin :=  l_min_contact_pin;
  o_mins            :=  l_mins;
  o_err_code        :=  '0';
  o_err_msg         :=  'SUCCESS';
--
EXCEPTION
WHEN OTHERS THEN
  o_err_code  :=  '130';
  o_err_msg   :=  'Failed in when others of p_get_min_security_pin '|| SQLERRM;
END p_get_min_security_pin;
--
-- procedure that will be called from trigger on web user
PROCEDURE p_get_min_security_pin (i_web_user_objid      IN    NUMBER,
                                  i_web_user2bus_org    IN    NUMBER,
                                  i_web_contact         IN    NUMBER,
                                  i_action              IN    VARCHAR2,
                                  o_min_contact_pin     OUT   VARCHAR2,
                                  o_mins                OUT   VARCHAR2,
                                  o_err_code            OUT   VARCHAR2,
                                  o_err_msg             OUT   VARCHAR2)
IS
--
  l_min_contact_pin       VARCHAR2(1000);
  l_min                   VARCHAR2(30);
  l_mins                  VARCHAR2(1000);
  c                       sa.customer_type := customer_type();
BEGIN
--
  -- Input validation
  IF  NVL(i_web_user2bus_org, 0)   = 0  OR
      NVL(i_web_user_objid, 0)     = 0
  THEN
    o_err_code  :=  '100';
    o_err_msg   :=  'Input values cannot be null';
    RETURN;
  END IF;
  --
  IF i_action IS NULL
  THEN
    o_err_code  :=  '110';
    o_err_msg   :=  'Action cannot be null';
    RETURN;
  END IF;
  --
  FOR each IN ( SELECT  cpi.x_contact_part_inst2contact,pi.part_serial_no, pi.x_part_inst2contact, cai.x_pin
                FROM    table_x_contact_add_info    cai,
                        table_part_inst             pi,
                        table_x_contact_part_inst   cpi
                WHERE   pi.x_part_inst2contact            = cai.add_info2contact
                AND     cpi.x_contact_part_inst2part_inst = pi.objid
                AND     cpi.x_contact_part_inst2contact   = i_web_contact
              )
  LOOP
    l_min             := c.get_min (i_esn =>  each.part_serial_no);
    --
    -- Exclude T Mins and ESNs without MIN (Not Active)
    IF l_min IS NOT NULL AND
       l_min NOT LIKE  'T%'
    THEN
      --
      l_min_contact_pin := l_min_contact_pin || l_min||' '||each.x_pin||'|' ;
      --
      l_mins            :=  l_mins  ||  l_min||'|' ;
      --
    END IF;
    --
  END LOOP;
  --
  o_min_contact_pin :=  l_min_contact_pin;
  o_mins            :=  l_mins;
  o_err_code        :=  '0';
  o_err_msg         :=  'SUCCESS';
--
EXCEPTION
WHEN OTHERS THEN
  o_err_code  :=  '130';
  o_err_msg   :=  'Failed in when others of p_get_min_security_pin '|| SQLERRM;
END p_get_min_security_pin;
--
-- CR47564 changes ends.
--

-- CR52329_ST_WEB_Customize_Communication_Preference start
PROCEDURE upd_customer_contact_info_tab(io_customer_contact_info_tab IN OUT customer_contact_info_type_tab,
                                                          o_error_code                    OUT VARCHAR2,
                                                          error_msg                       OUT VARCHAR2
                                                         )
  AS
  -- CR52329_ST_WEB_Customize_Communication_Preference
  -- Tim 10/30/2017
  -- Takes table and applies the updates requested.
  -- o_error_code and error_msg are at the procedure level.
  -- error_code error_msg are at the esn level.
  v_current_row    NUMBER;
  v_err_num        NUMBER;
  v_err_msg        VARCHAR2(200);

  BEGIN
     o_error_code         := '0';
     error_msg            := 'SUCCESS';



     FOR indx IN io_customer_contact_info_tab.FIRST .. io_customer_contact_info_tab.LAST
     LOOP

        v_current_row := indx;

        -- Find the ESN and MIN associated with this esn and brand
        FOR each_row IN (SELECT DISTINCT tpi.part_serial_no esn,
                                (SELECT part_serial_no
                                    FROM table_part_inst tpi1
                                   WHERE part_to_esn2part_inst = tpi.objid
                                     AND tpi1.x_domain = 'LINES'
                                     AND ROWNUM < 2) x_min,
                                pn.part_number,
                                pc.name,
                                twu.s_login_name,
                                tbu.org_id
                           FROM table_web_user twu,
                                table_bus_org tbu,
                                table_part_inst tpi,
                                table_x_contact_part_inst tcpi,
                                table_mod_level ml,
                                table_part_num pn,
                                table_part_class pc,
                                table_contact tc
                          WHERE tbu.org_id = io_customer_contact_info_tab(v_current_row).x_org_id       -- Required
                            AND twu.web_user2bus_org = tbu.objid
                            AND tcpi.x_contact_part_inst2part_inst = tpi.objid
                            AND tcpi.x_contact_part_inst2contact = twu.web_user2contact
                            AND pn.objid = ml.part_info2part_num
                            AND ml.objid = tpi.n_part_inst2part_mod
                            AND pn.part_num2part_class = pc.objid
                            AND tpi.part_serial_no = io_customer_contact_info_tab(v_current_row).x_esn  -- Required
                            AND tpi.x_domain = 'PHONES'
                            AND tc.objid = tpi.x_part_inst2contact)  LOOP



                      --DBMS_OUTPUT.PUT_LINE ('x_esn '||         io_customer_contact_info_tab(v_current_row).x_esn);
                      --DBMS_OUTPUT.PUT_LINE ('source_system  '||io_customer_contact_info_tab(v_current_row).x_source_system);
                      --DBMS_OUTPUT.PUT_LINE ('x_do_not_email '||io_customer_contact_info_tab(v_current_row).x_do_not_email);
                      --DBMS_OUTPUT.PUT_LINE ('x_do_not_phone '||io_customer_contact_info_tab(v_current_row).x_do_not_phone);
                      --DBMS_OUTPUT.PUT_LINE ('x_do_not_sms '||  io_customer_contact_info_tab(v_current_row).x_do_not_sms);
                      --DBMS_OUTPUT.PUT_LINE ('x_do_not_mail '|| io_customer_contact_info_tab(v_current_row).x_do_not_mail);
                      --DBMS_OUTPUT.PUT_LINE ('error_code '||    io_customer_contact_info_tab(v_current_row).error_code);
                      --DBMS_OUTPUT.PUT_LINE ('error_msg '||     io_customer_contact_info_tab(v_current_row).error_msg);


                    io_customer_contact_info_tab(v_current_row).x_esn         := each_row.esn;
                    io_customer_contact_info_tab(v_current_row).x_min         := each_row.x_min;
                    io_customer_contact_info_tab(v_current_row).x_part_number := each_row.part_number;
                    io_customer_contact_info_tab(v_current_row).x_part_class  := each_row.name;
                    io_customer_contact_info_tab(v_current_row).x_login_name  := each_row.s_login_name;




                  BEGIN
                    UPDATE sa.table_x_contact_add_info
                    SET    source_system       = io_customer_contact_info_tab(v_current_row).x_source_system,
                           x_do_not_email      = io_customer_contact_info_tab(v_current_row).x_do_not_email,
                           x_do_not_phone      = io_customer_contact_info_tab(v_current_row).x_do_not_phone,
                           x_do_not_sms        = io_customer_contact_info_tab(v_current_row).x_do_not_sms  ,
                           x_do_not_mail       = io_customer_contact_info_tab(v_current_row).x_do_not_mail ,
                           x_last_update_date  = SYSDATE
                    WHERE  add_info2contact   IN (SELECT x_part_inst2contact
                                                    FROM table_part_inst tpi
                                                   WHERE tpi.part_serial_no = io_customer_contact_info_tab(v_current_row).x_esn);

                     io_customer_contact_info_tab(v_current_row).error_code := 0;
                     io_customer_contact_info_tab(v_current_row).error_msg := 'SUCCESS';


                   EXCEPTION
                     WHEN OTHERS THEN
                        io_customer_contact_info_tab(v_current_row).error_code := 1012;
                        io_customer_contact_info_tab(v_current_row).error_msg := 'ERROR UPDATING ESN '||io_customer_contact_info_tab(v_current_row).x_esn;

                        DBMS_OUTPUT.PUT_LINE ('x_esn '||         io_customer_contact_info_tab(v_current_row).x_esn);
                        DBMS_OUTPUT.PUT_LINE ('source_system  '||io_customer_contact_info_tab(v_current_row).x_source_system);
                        DBMS_OUTPUT.PUT_LINE ('x_do_not_email '||io_customer_contact_info_tab(v_current_row).x_do_not_email);
                        DBMS_OUTPUT.PUT_LINE ('x_do_not_phone '||io_customer_contact_info_tab(v_current_row).x_do_not_phone);
                        DBMS_OUTPUT.PUT_LINE ('x_do_not_sms '||  io_customer_contact_info_tab(v_current_row).x_do_not_sms);
                        DBMS_OUTPUT.PUT_LINE ('x_do_not_mail '|| io_customer_contact_info_tab(v_current_row).x_do_not_mail);
                        DBMS_OUTPUT.PUT_LINE ('error_code '||    io_customer_contact_info_tab(v_current_row).error_code);
                        DBMS_OUTPUT.PUT_LINE ('error_msg '||     io_customer_contact_info_tab(v_current_row).error_msg);

                  END;






         END LOOP;  -- FOR each_row

     END LOOP;  -- FOR indx




  EXCEPTION WHEN OTHERS THEN

     v_err_num := SQLCODE;
     v_err_msg := SUBSTR(SQLERRM, 1, 200);

     log_error ( v_err_num||' '||v_err_msg,
                 SYSDATE,
                 'upd_customer_contact_info_tab',
                 io_customer_contact_info_tab(v_current_row).x_esn,
                 'CONTACT_PKG');


     DBMS_OUTPUT.PUT_LINE ('err_num '  ||v_err_num);
     DBMS_OUTPUT.PUT_LINE ('err_msg '  ||v_err_msg);

     DBMS_OUTPUT.PUT_LINE ('x_login_name '  ||io_customer_contact_info_tab(v_current_row).x_login_name);
     DBMS_OUTPUT.PUT_LINE ('x_org_id '      ||io_customer_contact_info_tab(v_current_row).x_org_id);
     DBMS_OUTPUT.PUT_LINE ('x_esn '         ||io_customer_contact_info_tab(v_current_row).x_esn);
     DBMS_OUTPUT.PUT_LINE ('x_min '         ||io_customer_contact_info_tab(v_current_row).x_min);
     DBMS_OUTPUT.PUT_LINE ('x_do_not_email '||io_customer_contact_info_tab(v_current_row).x_do_not_email);
     DBMS_OUTPUT.PUT_LINE ('x_do_not_phone '||io_customer_contact_info_tab(v_current_row).x_do_not_phone);
     DBMS_OUTPUT.PUT_LINE ('x_do_not_sms '  ||io_customer_contact_info_tab(v_current_row).x_do_not_sms);
     DBMS_OUTPUT.PUT_LINE ('x_do_not_mail ' ||io_customer_contact_info_tab(v_current_row).x_do_not_mail);
     DBMS_OUTPUT.PUT_LINE ('error_code '    ||io_customer_contact_info_tab(v_current_row).error_code);
     DBMS_OUTPUT.PUT_LINE ('error_msg '     ||io_customer_contact_info_tab(v_current_row).error_msg);



     o_error_code := '1';
     error_msg    := 'Failed ';


  END upd_customer_contact_info_tab;

PROCEDURE get_customer_contact_info_tab(io_customer_contact_info_tab    IN OUT customer_contact_info_type_tab,
                                                          o_error_code     OUT VARCHAR2,
                                                          error_msg        OUT VARCHAR2
                                                         )
  AS
  -- CR52329_ST_WEB_Customize_Communication_Preference
  -- Tim 10/30/2017
  -- Takes table and applies the updates requested.
  -- o_error_code and error_msg are at the procedure level.
  -- error_code error_msg are at the esn level.

  v_current_row               NUMBER;
  v_rec_row                   NUMBER := 0;
  v_err_num                   NUMBER;
  v_err_msg                   VARCHAR2(200);
  o_customer_contact_info_tab sa.customer_contact_info_type_tab := sa.customer_contact_info_type_tab();


  BEGIN
     o_error_code := '0';
     error_msg    := 'SUCCESS';

     FOR indx IN io_customer_contact_info_tab.FIRST .. io_customer_contact_info_tab.LAST
     LOOP

        v_current_row := indx;

        -- Find the ESN and MIN associated with this web login and brand
         FOR each_row IN (SELECT twu.s_login_name,
                                  tbu.org_id,
                                  tpi.part_serial_no esn,
                                 (SELECT part_serial_no
                                    FROM table_part_inst tpi1
                                   WHERE part_to_esn2part_inst = tpi.objid
                                     AND tpi1.x_domain = 'LINES'
                                     AND ROWNUM < 2) x_min,
                                 pn.part_number,
                                 pc.name
                            FROM table_web_user twu,
                                 table_bus_org tbu,
                                 table_part_inst tpi,
                                 table_x_contact_part_inst tcpi,
                                 table_mod_level ml,
                                 table_part_num pn,
                                 table_part_class pc,
                                 table_contact tc
                           WHERE twu.s_login_name = UPPER(io_customer_contact_info_tab(v_current_row).x_login_name)  -- Required
                             AND tbu.org_id = io_customer_contact_info_tab(v_current_row).x_org_id                   -- Required
                             AND twu.web_user2bus_org = tbu.objid
                             AND tcpi.x_contact_part_inst2part_inst = tpi.objid
                             AND tcpi.x_contact_part_inst2contact = twu.web_user2contact
                             AND pn.objid = ml.part_info2part_num
                             AND ml.objid = tpi.n_part_inst2part_mod
                             AND pn.part_num2part_class = pc.objid
                             AND tpi.x_domain = 'PHONES'
                             AND tc.objid = tpi.x_part_inst2contact) LOOP

          o_customer_contact_info_tab.EXTEND(1);
          v_rec_row := v_rec_row + 1;
          o_customer_contact_info_tab(v_rec_row)  := sa.customer_contact_info_type(NULL, NULL, NULL, NULL, NULL, NULL, NULL,   NULL,   NULL,   NULL,   NULL,   NULL, NULL);

          o_customer_contact_info_tab(v_rec_row).x_login_name  := each_row.s_login_name;
          o_customer_contact_info_tab(v_rec_row).x_org_id      := each_row.org_id;
          o_customer_contact_info_tab(v_rec_row).x_esn         := each_row.esn;
          o_customer_contact_info_tab(v_rec_row).x_min         := each_row.x_min;
          o_customer_contact_info_tab(v_rec_row).x_part_number := each_row.part_number;
          o_customer_contact_info_tab(v_rec_row).x_part_class  := each_row.name;

          --DBMS_OUTPUT.PUT_LINE ('x_login_name '  ||o_customer_contact_info_tab(v_rec_row).x_login_name);
          --DBMS_OUTPUT.PUT_LINE ('x_org_id '      ||o_customer_contact_info_tab(v_rec_row).x_org_id);
          --DBMS_OUTPUT.PUT_LINE ('x_esn '         ||o_customer_contact_info_tab(v_rec_row).x_esn);
          --DBMS_OUTPUT.PUT_LINE ('x_min '         ||o_customer_contact_info_tab(v_rec_row).x_min);
          --DBMS_OUTPUT.PUT_LINE ('part_number '   ||o_customer_contact_info_tab(v_rec_row).x_part_number);
          --DBMS_OUTPUT.PUT_LINE ('name '          ||o_customer_contact_info_tab(v_rec_row).x_part_class);


           sa.contact_pkg.get_customer_contact_info ( ip_esn        => o_customer_contact_info_tab(v_rec_row).x_esn
                                          ,op_x_do_not_email    => o_customer_contact_info_tab(v_rec_row).x_do_not_email
                                        ,op_x_do_not_phone    => o_customer_contact_info_tab(v_rec_row).x_do_not_phone
                                       ,op_x_do_not_sms    => o_customer_contact_info_tab(v_rec_row).x_do_not_sms
                                       ,op_x_do_not_mail    => o_customer_contact_info_tab(v_rec_row).x_do_not_mail
                                       ,op_error_code    => o_customer_contact_info_tab(v_rec_row).error_code
                                    ,op_error_msg    => o_customer_contact_info_tab(v_rec_row).error_msg
                                                       );

          --DBMS_OUTPUT.PUT_LINE ('x_do_not_email '||o_customer_contact_info_tab(v_rec_row).x_do_not_email);
          --DBMS_OUTPUT.PUT_LINE ('x_do_not_phone '||o_customer_contact_info_tab(v_rec_row).x_do_not_phone);
          --DBMS_OUTPUT.PUT_LINE ('x_do_not_sms '  ||o_customer_contact_info_tab(v_rec_row).x_do_not_sms);
          --DBMS_OUTPUT.PUT_LINE ('x_do_not_mail ' ||o_customer_contact_info_tab(v_rec_row).x_do_not_mail);
          --DBMS_OUTPUT.PUT_LINE ('error_code '    ||o_customer_contact_info_tab(v_rec_row).error_code);
          --DBMS_OUTPUT.PUT_LINE ('error_msg '     ||o_customer_contact_info_tab(v_rec_row).error_msg);


        END LOOP;  -- FOR each_row

     END LOOP;  -- FOR indx

  io_customer_contact_info_tab := o_customer_contact_info_tab;


  EXCEPTION WHEN OTHERS THEN

     v_err_num := SQLCODE;
     v_err_msg := SUBSTR(SQLERRM, 1, 200);

     log_error ( v_err_num||' '||v_err_msg,
                 SYSDATE,
                 'upd_customer_contact_info_tab',
                 io_customer_contact_info_tab(v_current_row).x_esn,
                 'CONTACT_PKG');


     DBMS_OUTPUT.PUT_LINE ('err_num '  ||v_err_num);
     DBMS_OUTPUT.PUT_LINE ('err_msg '  ||v_err_msg);


     --DBMS_OUTPUT.PUT_LINE ('x_login_name '  ||io_customer_contact_info_tab(v_rec_row).x_login_name);
     --DBMS_OUTPUT.PUT_LINE ('x_org_id '      ||io_customer_contact_info_tab(v_rec_row).x_org_id);
     --DBMS_OUTPUT.PUT_LINE ('x_esn '         ||io_customer_contact_info_tab(v_rec_row).x_esn);
     --DBMS_OUTPUT.PUT_LINE ('x_min '         ||io_customer_contact_info_tab(v_rec_row).x_min);
     --DBMS_OUTPUT.PUT_LINE ('x_do_not_email '||io_customer_contact_info_tab(v_rec_row).x_do_not_email);
     --DBMS_OUTPUT.PUT_LINE ('x_do_not_phone '||io_customer_contact_info_tab(v_rec_row).x_do_not_phone);
     --DBMS_OUTPUT.PUT_LINE ('x_do_not_sms '  ||io_customer_contact_info_tab(v_rec_row).x_do_not_sms);
     --DBMS_OUTPUT.PUT_LINE ('x_do_not_mail ' ||io_customer_contact_info_tab(v_rec_row).x_do_not_mail);
     --DBMS_OUTPUT.PUT_LINE ('error_code '    ||io_customer_contact_info_tab(v_rec_row).error_code);
     --DBMS_OUTPUT.PUT_LINE ('error_msg '     ||io_customer_contact_info_tab(v_rec_row).error_msg);

     o_error_code := '1';
     error_msg    := 'Failed ';

  END get_customer_contact_info_tab;

-- CR52329_ST_WEB_Customize_Communication_Preference end.

END contact_pkg;
/