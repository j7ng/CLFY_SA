CREATE OR REPLACE TYPE sa."CONTACT_PART_INST_TYPE" AS OBJECT
------------------------------------------------------------------------
--$RCSfile: contact_part_inst_type_spec.sql,v $
--$Revision: 1.1 $
--$Author: vnainar $
--$Date: 2016/11/29 20:42:36 $
--$ $Log: contact_part_inst_type_spec.sql,v $
--$ Revision 1.1  2016/11/29 20:42:36  vnainar
--$ CR44729 New file added
--$
--$
-------------------------------------------------------------------------
(
 contact_part_inst_objid     NUMBER          ,
 contact_part_inst2contact   NUMBER          ,
 contact_part_inst2part_inst NUMBER          ,
 esn_nick_name               VARCHAR2(30)    ,
 is_default                  NUMBER          ,
 transfer_flag               NUMBER          ,
 verified                    VARCHAR2(1)     ,
 response                    VARCHAR2(1000)  ,
 numeric_value               NUMBER          ,
 varchar2_value              VARCHAR2(2000)  ,

 CONSTRUCTOR FUNCTION contact_part_inst_type RETURN SELF AS RESULT,
 CONSTRUCTOR FUNCTION contact_part_inst_type ( i_contact_part_inst_objid IN NUMBER ) RETURN SELF AS RESULT,
 CONSTRUCTOR FUNCTION contact_part_inst_type ( i_contact_part_inst_type IN contact_part_inst_type ) RETURN SELF AS RESULT,
 MEMBER FUNCTION exist RETURN BOOLEAN,
 MEMBER FUNCTION exist ( i_contact_part_inst_type IN OUT contact_part_inst_type ) RETURN BOOLEAN,
 MEMBER FUNCTION ins ( i_contact_part_inst_type IN contact_part_inst_type ) RETURN contact_part_inst_type,
 MEMBER FUNCTION ins RETURN contact_part_inst_type,
 MEMBER FUNCTION upd ( i_contact_part_inst_type IN contact_part_inst_type ) RETURN contact_part_inst_type
);
/
CREATE OR REPLACE TYPE BODY sa."CONTACT_PART_INST_TYPE" AS
------------------------------------------------------------------------
--$RCSfile: contact_part_inst_type.sql,v $
--$Revision: 1.3 $
--$Author: sraman $
--$Date: 2017/02/13 20:24:25 $
--$ $Log: contact_part_inst_type.sql,v $
--$ Revision 1.3  2017/02/13 20:24:25  sraman
--$ CR47564 - Changed the exist function
--$
--$ Revision 1.2  2016/12/09 15:26:50  sraman
--$ CR44729 removed exist error in response
--$
--$ Revision 1.1  2016/11/29 20:42:36  vnainar
--$ CR44729 New file added
--$
--$
-------------------------------------------------------------------------

CONSTRUCTOR FUNCTION contact_part_inst_type RETURN SELF AS RESULT AS
BEGIN
  RETURN;
END contact_part_inst_type;

CONSTRUCTOR FUNCTION contact_part_inst_type ( i_contact_part_inst_objid IN NUMBER ) RETURN SELF AS RESULT AS
BEGIN
  --
  IF i_contact_part_inst_objid IS NOT NULL THEN
    SELF.response := 'CONTACT PART INST ID NOT PASSED';
  END IF;

  --Query the table
  SELECT contact_part_inst_type( objid                              ,
                                 x_contact_part_inst2contact        ,
                                 x_contact_part_inst2part_inst      ,
                                 x_esn_nick_name                    ,
                                 x_is_default                       ,
                                 x_transfer_flag                    ,
                                 x_verified                         ,
                                 NULL                               ,
                                 NULL                               ,
                                 NULL
                                )
  INTO SELF
  FROM table_x_contact_part_inst
  WHERE objid = i_contact_part_inst_objid;
  --
  SELF.response := 'SUCCESS';

  RETURN;
 EXCEPTION
    WHEN OTHERS THEN
      SELF.response                := 'CONTACT PART INST NOT FOUND' || SUBSTR(SQLERRM,1,100);
      SELF.contact_part_inst_objid := i_contact_part_inst_objid;

      --
      RETURN;
END contact_part_inst_type;

CONSTRUCTOR FUNCTION contact_part_inst_type ( i_contact_part_inst_type IN contact_part_inst_type ) RETURN SELF AS RESULT AS
BEGIN
  --
  IF i_contact_part_inst_type.contact_part_inst2contact IS NULL OR i_contact_part_inst_type.contact_part_inst2part_inst IS NULL THEN
    SELF.response := 'Ccontact_part_inst2contact and/or contact_part_inst2part_inst are NOT PASSED';
    RETURN;
  END IF;

  --Query the table
  SELECT contact_part_inst_type( objid                              ,
                                 x_contact_part_inst2contact        ,
                                 x_contact_part_inst2part_inst      ,
                                 x_esn_nick_name                    ,
                                 x_is_default                       ,
                                 x_transfer_flag                    ,
                                 x_verified                         ,
                                 NULL                               ,
                                 NULL                               ,
                                 NULL
                                )
  INTO SELF
  FROM table_x_contact_part_inst
  WHERE x_contact_part_inst2contact   = i_contact_part_inst_type.contact_part_inst2contact
    AND x_contact_part_inst2part_inst = i_contact_part_inst_type.contact_part_inst2part_inst ;
  --
  SELF.response := 'SUCCESS';

  RETURN;
 EXCEPTION
    WHEN OTHERS THEN
      SELF.response                := 'CONTACT PART INST NOT FOUND' || SUBSTR(SQLERRM,1,100);
      SELF.contact_part_inst_objid := NULL;

      --
      RETURN;
END contact_part_inst_type;

MEMBER FUNCTION exist RETURN BOOLEAN AS
BEGIN
  RETURN NULL;
END exist;

MEMBER FUNCTION exist ( i_contact_part_inst_type IN OUT contact_part_inst_type ) RETURN BOOLEAN AS
BEGIN
  --
  IF i_contact_part_inst_type.contact_part_inst2contact IS NULL OR i_contact_part_inst_type.contact_part_inst2part_inst IS NULL THEN
    i_contact_part_inst_type.response := 'Ccontact_part_inst2contact and/or contact_part_inst2part_inst are NOT PASSED';
    RETURN FALSE;
  END IF;

  --Query the table
  SELECT objid INTO i_contact_part_inst_type.contact_part_inst_objid
  FROM table_x_contact_part_inst
  WHERE --x_contact_part_inst2contact   = i_contact_part_inst_type.contact_part_inst2contact;
        X_CONTACT_PART_INST2PART_INST = i_contact_part_inst_type.contact_part_inst2part_inst
	AND ROWNUM <=1;

  i_contact_part_inst_type.response := 'SUCCESS';

  RETURN TRUE;
 EXCEPTION
    WHEN OTHERS THEN
      --i_contact_part_inst_type.response                := 'CONTACT PART INST NOT FOUND' || SUBSTR(SQLERRM,1,100);
      i_contact_part_inst_type.contact_part_inst_objid := NULL;

      RETURN FALSE;
END exist;


MEMBER FUNCTION ins ( i_contact_part_inst_type IN contact_part_inst_type ) RETURN contact_part_inst_type AS
i_cpi  contact_part_inst_type := i_contact_part_inst_type;
BEGIN
  IF i_cpi.contact_part_inst_objid IS NULL THEN
    i_cpi.contact_part_inst_objid  := sa.SEQU_X_CONTACT_PART_INST.nextval;
  END IF;

  INSERT
  INTO table_x_contact_part_inst
    (
      objid ,
      x_contact_part_inst2contact         ,
      x_contact_part_inst2part_inst       ,
      x_esn_nick_name                     ,
      x_is_default                        ,
      x_transfer_flag                     ,
      x_verified
    )
    VALUES
    (
      i_cpi.contact_part_inst_objid       ,
      i_cpi.contact_part_inst2contact     ,
      i_cpi.contact_part_inst2part_inst   ,
      i_cpi.esn_nick_name                 ,
      i_cpi.is_default                    ,
      i_cpi.transfer_flag                 ,
      i_cpi.verified
    );

  -- set Success Response
  i_cpi.response := CASE WHEN i_cpi.response IS NULL THEN 'SUCCESS' ELSE i_cpi.response || '|SUCCESS' END;
  RETURN i_cpi;
EXCEPTION
WHEN OTHERS THEN
  i_cpi.response := i_cpi.response || '|ERROR INSERTING CONTACT PART INST RECORD: ' || SUBSTR(SQLERRM,1,100);
  --
  RETURN i_cpi;
END ins;

MEMBER FUNCTION ins RETURN contact_part_inst_type AS
  i_cpi     contact_part_inst_type := SELF;
  i         contact_part_inst_type;
BEGIN
  i := i_cpi.ins ( i_contact_part_inst_type => i_cpi );
  RETURN i;
END ins;

MEMBER FUNCTION upd ( i_contact_part_inst_type IN contact_part_inst_type ) RETURN contact_part_inst_type AS
i_cpi  contact_part_inst_type := i_contact_part_inst_type;
BEGIN

  UPDATE
    table_x_contact_part_inst
  SET
      x_contact_part_inst2contact       = NVL(i_cpi.contact_part_inst2contact     ,x_contact_part_inst2contact    ),
      x_contact_part_inst2part_inst     = NVL(i_cpi.contact_part_inst2part_inst   ,x_contact_part_inst2part_inst  ),
      x_esn_nick_name                   = NVL(i_cpi.esn_nick_name                 ,x_esn_nick_name                ),
      x_is_default                      = NVL(i_cpi.is_default                    ,x_is_default                   ),
      x_transfer_flag                   = NVL(i_cpi.transfer_flag                 ,x_transfer_flag                ),
      x_verified                        = NVL(i_cpi.verified                      ,x_verified                    )
  WHERE objid = i_cpi.contact_part_inst_objid ;

  -- set Success Response
  i_cpi := contact_part_inst_type ( i_contact_part_inst_objid  => i_cpi.contact_part_inst_objid );
  i_cpi.response  := 'SUCCESS';
  RETURN i_cpi;

EXCEPTION
WHEN OTHERS THEN
  i_cpi.response := i_cpi.response || '|ERROR INSERTING CONTACT PART INST RECORD: ' || SUBSTR(SQLERRM,1,100);
  --
  RETURN i_cpi;
END upd;

END;
/