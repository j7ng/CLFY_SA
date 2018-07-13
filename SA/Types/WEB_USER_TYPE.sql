CREATE OR REPLACE TYPE sa."WEB_USER_TYPE" AS OBJECT
------------------------------------------------------------------------
--$RCSfile: web_user_type_spec.sql,v $
--$Revision: 1.3 $
--$Author: sraman $
--$Date: 2017/03/03 01:13:49 $
--$ $Log: web_user_type_spec.sql,v $
--$ Revision 1.3  2017/03/03 01:13:49  sraman
--$ CR47564 new function del added
--$
--$ Revision 1.2  2017/03/02 21:57:51  vnainar
--$ CR47564 new function del added
--$
--$ Revision 1.1  2016/11/29 20:42:37  vnainar
--$ CR44729 New file added
--$
--$
-------------------------------------------------------------------------
(
  web_user_objid    NUMBER,
  login_name        VARCHAR2(50 BYTE),
  s_login_name      VARCHAR2(50 BYTE),
  password          VARCHAR2(255 BYTE),
  user_key          VARCHAR2(30 BYTE),
  status            NUMBER,
  passwd_chg        DATE,
  dev               NUMBER,
  ship_via          VARCHAR2(80 BYTE),
  secret_questn     VARCHAR2(200 BYTE),
  s_secret_questn   VARCHAR2(200 BYTE),
  secret_ans        VARCHAR2(200 BYTE),
  s_secret_ans      VARCHAR2(200 BYTE),
  web_user2user     NUMBER,
  web_user2contact  NUMBER,
  web_user2lead     NUMBER,
  web_user2bus_org  NUMBER,
  last_update_date  DATE,
  validated         NUMBER,
  validated_counter NUMBER,
  named_userid      VARCHAR2(255 BYTE),
  insert_timestamp  DATE,
  response          VARCHAR2(1000),
  numeric_value     NUMBER ,
  varchar2_value    VARCHAR2(1000),
  constructor function web_user_type return SELF as result,
  CONSTRUCTOR FUNCTION web_user_type ( i_web_user_objid IN NUMBER) RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION web_user_type ( i_s_login_name IN VARCHAR2, i_web_user2bus_org IN NUMBER) RETURN SELF AS RESULT,
  MEMBER FUNCTION exist RETURN BOOLEAN,
  MEMBER FUNCTION exist ( i_web_user_type IN OUT web_user_type )RETURN BOOLEAN,
  MEMBER FUNCTION ins ( i_web_user_type IN web_user_type ) RETURN web_user_type,
  MEMBER FUNCTION ins RETURN web_user_type,
  MEMBER FUNCTION upd (  i_web_user_type IN web_user_type) RETURN web_user_type,
  MEMBER FUNCTION del ( i_s_login_name IN VARCHAR2,i_web_user2bus_org IN NUMBER, i_override_flag IN VARCHAR2) RETURN web_user_type
);
/
CREATE OR REPLACE TYPE BODY sa."WEB_USER_TYPE" AS
------------------------------------------------------------------------
--$RCSfile: web_user_type.sql,v $
--$Revision: 1.7 $
--$Author: vnainar $
--$Date: 2017/04/14 14:25:59 $
--$ $Log: web_user_type.sql,v $
--$ Revision 1.7  2017/04/14 14:25:59  vnainar
--$ CR49087 web user update changes
--$
--$ Revision 1.6  2017/03/03 01:14:30  sraman
--$ CR47564 - added overrride flag
--$
--$ Revision 1.5  2017/03/02 22:00:21  vnainar
--$ CR47564 new function del added
--$
--$ Revision 1.4  2017/02/07 18:32:52  vnainar
--$ webuserobjid reset to null in insert method in case of failure
--$
--$ Revision 1.3  2016/12/09 15:23:47  sraman
--$ CR44729 - removed exists error in response
--$
--$ Revision 1.2  2016/11/30 16:29:49  vnainar
--$ CR44729 dbms_output removed
--$
--$ Revision 1.1  2016/11/29 20:42:37  vnainar
--$ CR44729 New file added
--$
--$
-------------------------------------------------------------------------

  constructor function web_user_type return SELF as result AS
  BEGIN
    -- TODO: Implementation required for function web_user_type.web_user_type
    RETURN;
  END web_user_type;

  CONSTRUCTOR FUNCTION web_user_type ( i_web_user_objid IN NUMBER) RETURN SELF AS RESULT AS
  BEGIN

	IF i_web_user_objid is  NULL THEN
	SELF.response := 'ID NOT PASSED';
  RETURN;
	END IF;

	--Query the table
	select web_user_type (  objid                   ,
                          login_name              ,
                          s_login_name            ,
                          password                ,
                          user_key                ,
                          status                  ,
                          passwd_chg              ,
                          dev                     ,
                          ship_via                ,
                          x_secret_questn         ,
                          s_x_secret_questn       ,
                          x_secret_ans            ,
                          s_x_secret_ans          ,
                          web_user2user           ,
                          web_user2contact        ,
                          web_user2lead           ,
                          web_user2bus_org        ,
                          x_last_update_date      ,
                          x_validated             ,
                          x_validated_counter     ,
                          named_userid            ,
                          insert_timestamp        ,
                          null					          ,
                          null					          ,
                          null
                          )
	INTO SELF
	FROM TABLE_WEB_USER
	WHERE objid= i_web_user_objid;
	--G5

	SELF.response := 'SUCCESS';

	RETURN;

 EXCEPTION
	WHEN OTHERS THEN
	SELF.response := 'NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
	SELF.web_user_objid := i_web_user_objid;
	--


		RETURN;
  END web_user_type;

  CONSTRUCTOR FUNCTION web_user_type ( i_s_login_name IN VARCHAR2, i_web_user2bus_org IN NUMBER) RETURN SELF AS RESULT AS
  BEGIN

	IF i_s_login_name IS  NULL OR i_web_user2bus_org IS NULL THEN
	SELF.response := 'Login_name or bus_org is Not PASSED';
  RETURN;
	END IF;

	--Query the table
	select web_user_type (  objid                   ,
                          login_name              ,
                          s_login_name            ,
                          password                ,
                          user_key                ,
                          status                  ,
                          passwd_chg              ,
                          dev                     ,
                          ship_via                ,
                          x_secret_questn         ,
                          s_x_secret_questn       ,
                          x_secret_ans            ,
                          s_x_secret_ans          ,
                          web_user2user           ,
                          web_user2contact        ,
                          web_user2lead           ,
                          web_user2bus_org        ,
                          x_last_update_date      ,
                          x_validated             ,
                          x_validated_counter     ,
                          named_userid            ,
                          insert_timestamp        ,
                          null					          ,
                          null					          ,
                          null
                          )
	INTO SELF
	FROM TABLE_WEB_USER
	WHERE s_login_name     = i_s_login_name
    AND web_user2bus_org = i_web_user2bus_org;

	SELF.response := 'SUCCESS';

	RETURN;

 EXCEPTION
	WHEN OTHERS THEN
	SELF.response := 'NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
	SELF.web_user_objid := NULL;
	--
	RETURN;
  END web_user_type;

  MEMBER FUNCTION exist RETURN BOOLEAN AS
  BEGIN
    -- TODO: Implementation required for FUNCTION web_user_type.exist
    RETURN NULL;
  END exist;

  MEMBER FUNCTION exist ( i_web_user_type IN OUT web_user_type )RETURN BOOLEAN AS
  BEGIN
       IF i_web_user_type.s_login_name IS  NULL OR i_web_user_type.web_user2bus_org IS NULL THEN
          i_web_user_type.response := 'Login_name or bus_org is Not PASSED';
           RETURN FALSE;
       END IF;

       IF i_web_user_type.web_user_objid IS NOT NULL THEN  -- check against old web user objid

         SELECT objid INTO i_web_user_type.web_user_objid
	  FROM table_web_user WHERE  objid = i_web_user_type.web_user_objid
	  AND web_user2bus_org = i_web_user_type.web_user2bus_org;

	  i_web_user_type.response := 'SUCCESS';
	  RETURN TRUE;

       END IF;

	--Query the table
	SELECT objid INTO i_web_user_type.web_user_objid
	FROM TABLE_WEB_USER
	WHERE s_login_name     = i_web_user_type.s_login_name
        AND web_user2bus_org = i_web_user_type.web_user2bus_org;

	i_web_user_type.response := 'SUCCESS';

	RETURN TRUE;

 EXCEPTION
	WHEN OTHERS THEN
	--i_web_user_type.response := 'NOT FOUND: ' || SUBSTR(SQLERRM,1,100);
	i_web_user_type.web_user_objid := NULL;
	--
	RETURN FALSE;
  END exist;

  MEMBER FUNCTION ins RETURN web_user_type IS
  i_webuser     web_user_type := SELF;
  i      web_user_type;
  begin
  i := i_webuser.ins ( i_web_user_type => i_webuser );
  RETURN i;
  END ins;


  MEMBER FUNCTION ins ( i_web_user_type IN web_user_type ) RETURN web_user_type IS

  i_webuser  web_user_type := i_web_user_type;

BEGIN

   IF i_webuser.web_user_objid IS NULL THEN
    i_webuser.web_user_objid := sa.SEQU_WEB_USER.NEXTVAL;
  END IF;


  -- Inserting into TABLE_WEB_USER
  INSERT INTO sa.TABLE_WEB_USER (objid                  ,
                                login_name              ,
                                s_login_name            ,
                                password                ,
                                user_key                ,
                                status                  ,
                                passwd_chg              ,
                                dev                     ,
                                ship_via                ,
                                x_secret_questn         ,
                                s_x_secret_questn       ,
                                x_secret_ans            ,
                                s_x_secret_ans          ,
                                web_user2user           ,
                                web_user2contact        ,
                                web_user2lead           ,
                                web_user2bus_org        ,
                                x_last_update_date      ,
                                x_validated             ,
                                x_validated_counter     ,
                                named_userid            ,
                                insert_timestamp
                                )
                          VALUES
                               (i_webuser.web_user_objid          ,
                                i_webuser.login_name              ,
                                i_webuser.s_login_name            ,
                                i_webuser.password                ,
                                i_webuser.user_key                ,
                                i_webuser.status                  ,
                                i_webuser.passwd_chg              ,
                                i_webuser.dev                     ,
                                i_webuser.ship_via                ,
                                i_webuser.secret_questn           ,
                                i_webuser.s_secret_questn         ,
                                i_webuser.secret_ans              ,
                                i_webuser.s_secret_ans            ,
                                i_webuser.web_user2user           ,
                                i_webuser.web_user2contact        ,
                                i_webuser.web_user2lead           ,
                                i_webuser.web_user2bus_org        ,
                                i_webuser.last_update_date        ,
                                i_webuser.validated               ,
                                i_webuser.validated_counter       ,
                                i_webuser.named_userid            ,
                                i_webuser.insert_timestamp
                                );

 -- dbms_output.put_line(NVL(SQL%ROWCOUNT,0) || ' row(s) created in i_webuser (' || i_webuser.web_user_objid || ')');

  i_webuser.response := 'SUCCESS';
  RETURN i_webuser;

 EXCEPTION WHEN OTHERS THEN
   i_webuser.response := i_webuser.response || '|ERROR INSERTING i_webuser RECORD: ' || SUBSTR(SQLERRM,1,100);
   i_webuser.web_user_objid := NULL; --added to nullify objid when there is an error
   --
   RETURN i_webuser;
END ins;


MEMBER FUNCTION upd ( i_web_user_type IN web_user_type ) RETURN web_user_type IS

  i_webuser  web_user_type := web_user_type();

BEGIN
  i_webuser := i_web_user_type;

  UPDATE sa.TABLE_WEB_USER Set
                                login_name              = NVL(i_webuser.login_name          ,login_name               ) ,
                                s_login_name            = NVL(i_webuser.s_login_name        ,s_login_name             ) ,
                                password                = NVL(i_webuser.password            ,password                 ) ,
                                user_key                = NVL(i_webuser.user_key            ,user_key                 ) ,
                                status                  = NVL(i_webuser.status              ,status                   ) ,
                                passwd_chg              = NVL(i_webuser.passwd_chg          ,passwd_chg               ) ,
                                dev                     = NVL(i_webuser.dev                 ,dev                      ) ,
                                ship_via                = NVL(i_webuser.ship_via            ,ship_via                 ) ,
                                x_secret_questn         = NVL(i_webuser.secret_questn       ,x_secret_questn          ) ,
                                s_x_secret_questn       = NVL(i_webuser.s_secret_questn     ,s_x_secret_questn        ) ,
                                x_secret_ans            = NVL(i_webuser.secret_ans          ,x_secret_ans             ) ,
                                s_x_secret_ans          = NVL(i_webuser.s_secret_ans        ,s_x_secret_ans           ) ,
                                web_user2user           = NVL(i_webuser.web_user2user       ,web_user2user            ) ,
                                web_user2contact        = NVL(i_webuser.web_user2contact    ,web_user2contact         ) ,
                                web_user2lead           = NVL(i_webuser.web_user2lead       ,web_user2lead            ) ,
                                web_user2bus_org        = NVL(i_webuser.web_user2bus_org    ,web_user2bus_org         ) ,
                                x_last_update_date      = NVL(i_webuser.last_update_date    ,x_last_update_date       ) ,
                                x_validated             = NVL(i_webuser.validated           ,x_validated              ) ,
                                x_validated_counter     = NVL(i_webuser.validated_counter   ,x_validated_counter      ) ,
                                named_userid            = NVL(i_webuser.named_userid        ,named_userid             ) ,
                                insert_timestamp        = NVL(i_webuser.insert_timestamp    ,insert_timestamp         )
  WHERE objid = i_webuser.web_user_objid;

  --dbms_output.put_line(NVL(SQL%ROWCOUNT,0) || ' row(s) updated in i_webuser (' || i_webuser.web_user_objid || ')');

  i_webuser          := web_user_type ( i_web_user_objid => i_webuser.web_user_objid);
  i_webuser.response := 'SUCCESS';

  RETURN i_webuser;

 EXCEPTION WHEN OTHERS THEN
   i_webuser.response := i_webuser.response || '|ERROR UPDATING i_webuser RECORD: ' || SUBSTR(SQLERRM,1,100);
   --
   RETURN i_webuser;
END upd;

MEMBER FUNCTION del ( i_s_login_name IN VARCHAR2,i_web_user2bus_org IN NUMBER, i_override_flag IN VARCHAR2) RETURN web_user_type IS

wu  web_user_type := web_user_type( i_s_login_name => i_s_login_name, i_web_user2bus_org => i_web_user2bus_org );
n_active_cnt NUMBER :=0;

BEGIN

  IF wu.response NOT LIKE '%SUCCESS%' THEN
    RETURN wu;
  END IF;

  BEGIN
    SELECT COUNT(1)
    INTO   n_active_cnt
    FROM   table_part_inst pi,
           table_x_contact_part_inst cpi
    WHERE  1 = 1
    AND    cpi.x_contact_part_inst2contact   = wu.web_user2contact -- from constructor
    AND    pi.objid                          = cpi.x_contact_part_inst2part_inst
    AND    pi.x_part_inst_status             = '52';
   EXCEPTION
     WHEN OTHERS THEN
       n_active_cnt := 0;
  END;

  IF n_active_cnt > 0 AND NVL(i_override_flag,'N') = 'N' THEN
    wu.response := 'FAILURE: THIS ACCOUNT HAS ONE OR MORE ACTIVE SUBSCRIBERS';
    RETURN wu;
  END IF;

  --
  DELETE
  FROM   table_web_user
  WHERE  s_login_name = i_s_login_name
  AND    web_user2bus_org = i_web_user2bus_org;

  wu.response := 'SUCCESS';

  RETURN wu;

 EXCEPTION
   WHEN OTHERS THEN
     wu.response := 'ERROR DELETING WEB ACCOUNT: '||SUBSTR(SQLERRM,1,500);
     RETURN wu;
END del;

END;
/