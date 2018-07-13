CREATE OR REPLACE PROCEDURE sa."SP_CLOSE_OPEN_CASES_PRC" (p_number_of_records IN NUMBER DEFAULT 9999) IS
  /********************************************************************************/
  /* Copyright ? 2005 Tracfone Wireless Inc. All rights reserved                  */
  /*                                                                              */
  /* Name         :   SP_close_open_cases_prc.sql                                */
  /* Purpose      :   Close all open cases greater then 40 days        */
  /*                                         */
  /*                                                                              */
  /* Parameters   :                                           */
  /* Platforms    :   Oracle 8.0.6 AND newer versions                            */
  /* Author      :   Muralidhar Chinta                                       */
  /*                  TCS                                           */
  /* Date         :   April 26,2005                                               */
  /* Revisions   :   Version    Date      Who       Purpose                        */
  /*                  -------  --------  -------   ------------------------------ */
  /*                 1.0     04/26/05   TCS     To close all Open cases 60 days*/
  /*                    old without any activity       */
  /********************************************************************************/
  --
  --********************************************************************************
  --$RCSfile: SP_CLOSE_OPEN_CASES_PRC.sql,v $
  --$Revision: 1.3 $
  --$Author: kacosta $
  --$Date: 2012/03/21 19:14:04 $
  --$ $Log: SP_CLOSE_OPEN_CASES_PRC.sql,v $
  --$ Revision 1.3  2012/03/21 19:14:04  kacosta
  --$ CR20261 Modify job that closes cases for No Activity
  --$
  --$ Revision 1.2  2012/03/20 17:43:43  kacosta
  --$ CR20261 Modify job that closes cases for No Activity
  --$
  --$
  --********************************************************************************
  --
  --Get all open cases that were opened more that 60 Days ago.
  CURSOR case_c IS
  -- CR20261 Start kacosta 03/19/2012
  --SELECT c.*
  --  FROM table_case      c
  --      ,table_condition co
  -- WHERE c.case_state2condition = co.objid
  --   AND co.title LIKE 'Open%'
  --   AND c.s_title <> 'UNITS VERIFICATION'
  --   AND c.x_case_type <> 'Loss Prevention'
  --   AND creation_time BETWEEN (SYSDATE - 150) AND (SYSDATE - 60);
    SELECT tbc.objid
          ,tbc.id_number
      FROM table_case tbc
      JOIN table_condition tcd
        ON tbc.case_state2condition = tcd.objid
     WHERE tbc.creation_time <= TRUNC(SYSDATE) - 60
       AND tbc.s_title <> 'UNITS VERIFICATION'
       AND tbc.x_case_type <> 'Loss Prevention'
       AND tcd.title LIKE 'Open%'
       AND ROWNUM <= NVL(p_number_of_records
                        ,9999);
  -- CR20261 End kacosta 03/19/2012

  rec_case_c case_c%ROWTYPE;

  --Get the last actentry record for the case
  CURSOR actlog_c(cobjid VARCHAR2) IS
  -- CR20261 Start kacosta 03/19/2012
  --SELECT a.entry_time
  --  FROM table_case      c
  --      ,table_act_entry a
  -- WHERE a.act_entry2case = c.objid
  --   AND c.objid = cobjid
  -- ORDER BY a.objid DESC;
    SELECT MAX(a.entry_time) entry_time
      FROM table_act_entry a
     WHERE a.act_entry2case = cobjid;
  -- CR20261 End kacosta 03/19/2012

  -- CR20261 Start kacosta 03/19/2012
  CURSOR get_sa_user_objid_curs IS
    SELECT objid user_objid
      FROM table_user
     WHERE s_login_name = 'SA';
  --
  get_sa_user_objid_rec get_sa_user_objid_curs%ROWTYPE;
  -- CR20261 End kacosta 03/19/2012

  rec_actentry_c actlog_c%ROWTYPE;
  v_actdate      DATE;
  v_return       VARCHAR2(10);
  v_return_msg   VARCHAR2(200);
BEGIN
  --
  -- CR20261 Start kacosta 03/19/2012
  IF get_sa_user_objid_curs%ISOPEN THEN
    --
    CLOSE get_sa_user_objid_curs;
    --
  END IF;
  --
  OPEN get_sa_user_objid_curs;
  FETCH get_sa_user_objid_curs
    INTO get_sa_user_objid_rec;
  CLOSE get_sa_user_objid_curs;
  -- CR20261 End kacosta 03/19/2012
  --
  FOR rec_case_c IN case_c LOOP
    -- CR20261 Start kacosta 03/19/2012
    rec_actentry_c := NULL;
    -- CR20261 End kacosta 03/19/2012
    OPEN actlog_c(rec_case_c.objid);

    FETCH actlog_c
      INTO rec_actentry_c;

    IF actlog_c%FOUND THEN
      v_actdate := TRUNC(rec_actentry_c.entry_time);

      IF v_actdate < TRUNC(SYSDATE - 60) THEN
        -- CR20261 Start kacosta 03/19/2012
        --igate.sp_close_case(rec_case_c.id_number
        --                   ,'SA'
        --                   ,'open_cases'
        --                   ,'Inactivity Cases'
        --                   ,v_return
        --                   ,v_return_msg);
        sa.clarify_case_pkg.close_case(p_case_objid => rec_case_c.objid
                                      ,p_user_objid => get_sa_user_objid_rec.user_objid
                                      ,p_source     => 'open_cases'
                                      ,p_resolution => 'Inactivity Cases'
                                      ,p_status     => NULL
                                      ,p_error_no   => v_return
                                      ,p_error_str  => v_return_msg);
        -- CR20261 End kacosta 03/19/2012
        dbms_output.put_line('Case ID ' || rec_case_c.id_number || ' Last Activity Date ' || v_actdate || ': Closed Date ' || SYSDATE);
      END IF;

      COMMIT;
    ELSE
      -- CR20261 Start kacosta 03/19/2012
      --igate.sp_close_case(rec_case_c.id_number
      --                   ,'SA'
      --                   ,'open_cases'
      --                   ,'Inactivity Cases'
      --                   ,v_return
      --                   ,v_return_msg);
      sa.clarify_case_pkg.close_case(p_case_objid => rec_case_c.objid
                                    ,p_user_objid => get_sa_user_objid_rec.user_objid
                                    ,p_source     => 'open_cases'
                                    ,p_resolution => 'Inactivity Cases'
                                    ,p_status     => NULL
                                    ,p_error_no   => v_return
                                    ,p_error_str  => v_return_msg);
      -- CR20261 End kacosta 03/19/2012
      COMMIT;
      dbms_output.put_line('No Activity record Case ID ' || rec_case_c.id_number || ':Closed Date ' || SYSDATE);
    END IF;

    CLOSE actlog_c;
  END LOOP;
END sp_close_open_cases_prc;
/