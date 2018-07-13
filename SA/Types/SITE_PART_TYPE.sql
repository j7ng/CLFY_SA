CREATE OR REPLACE TYPE sa."SITE_PART_TYPE" AS OBJECT
------------------------------------------------------------------------
--$RCSfile: site_part_type_spec.sql,v $
--$Revision: 1.1 $
--$Author: vnainar $
--$Date: 2016/11/29 20:42:37 $
--$ $Log: site_part_type_spec.sql,v $
--$ Revision 1.1  2016/11/29 20:42:37  vnainar
--$ CR44729 New file added
--$
--$
-------------------------------------------------------------------------
(
  site_part_objid                     NUMBER        ,
  instance_name                       VARCHAR2(80)  ,
  serial_no                           VARCHAR2(30)  ,
  s_serial_no                         VARCHAR2(30)  ,
  invoice_no                          VARCHAR2(30)  ,
  ship_date                           DATE          ,
  install_date                        DATE          ,
  warranty_date                       DATE          ,
  quantity                            NUMBER        ,
  mdbk                                VARCHAR2(80)  ,
  state_code                          NUMBER        ,
  state_value                         VARCHAR2(20)  ,
  modified                            NUMBER        ,
  level_to_part                       NUMBER        ,
  selected_prd                        VARCHAR2(5)   ,
  part_status                         VARCHAR2(40)  ,
  comments                            VARCHAR2(255) ,
  level_to_bin                        NUMBER        ,
  bin_objid                           NUMBER        ,
  site_objid                          NUMBER        ,
  inst_objid                          NUMBER        ,
  dir_site_objid                      NUMBER        ,
  machine_id                          VARCHAR2(80)  ,
  service_end_dt                      DATE          ,
  dev                                 NUMBER        ,
  service_id                          VARCHAR2(30)  ,
  min                                 VARCHAR2(30)  ,
  pin                                 VARCHAR2(20)  ,
  deact_reason                        VARCHAR2(30)  ,
  min_change_flag                     NUMBER        ,
  notify_carrier                      NUMBER        ,
  expire_dt                           DATE          ,
  zipcode                             VARCHAR2(20)  ,
  site_part2productbin                NUMBER        ,
  site_part2site                      NUMBER        ,
  site_part2site_part                 NUMBER        ,
  site_part2part_info                 NUMBER        ,
  site_part2primary                   NUMBER        ,
  site_part2backup                    NUMBER        ,
  all_site_part2site                  NUMBER        ,
  site_part2part_detail               NUMBER        ,
  site_part2x_new_plan                NUMBER        ,
  site_part2x_plan                    NUMBER        ,
  msid                                VARCHAR2(30)  ,
  refurb_flag                         NUMBER        ,
  cmmtmnt_end_dt                      DATE          ,
  instance_id                         VARCHAR2(30)  ,
  site_part_ind                       NUMBER        ,
  status_dt                           DATE          ,
  iccid                               VARCHAR2(30)  ,
  actual_expire_dt                    DATE          ,
  update_stamp                        DATE          ,
  response                            VARCHAR2(1000),
  numeric_value                       NUMBER        ,
  varchar2_value                      VARCHAR2(2000),
  CONSTRUCTOR FUNCTION site_part_type RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION site_part_type ( i_site_part_objid IN NUMBER ) RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION site_part_type ( i_esn IN VARCHAR2, i_min VARCHAR2 ) RETURN SELF AS RESULT,
  MEMBER FUNCTION exist RETURN BOOLEAN,
  MEMBER FUNCTION exist ( i_site_part_type IN OUT site_part_type )RETURN BOOLEAN,
  MEMBER FUNCTION ins ( i_site_part_type IN site_part_type ) RETURN site_part_type,
  MEMBER FUNCTION ins RETURN site_part_type,
  MEMBER FUNCTION upd ( i_site_part_type IN site_part_type ) RETURN site_part_type,
  MEMBER FUNCTION del ( i_site_part_objid IN  NUMBER ) RETURN BOOLEAN,
  MEMBER FUNCTION del RETURN BOOLEAN
);
/
CREATE OR REPLACE TYPE BODY sa."SITE_PART_TYPE" AS
------------------------------------------------------------------------
--$RCSfile: site_part_type.sql,v $
--$Revision: 1.6 $
--$Author: vnainar $
--$Date: 2017/04/07 19:01:11 $
--$ $Log: site_part_type.sql,v $
--$ Revision 1.6  2017/04/07 19:01:11  vnainar
--$ CR48944 index hint added for table_site_part as suggested  by DBA
--$
--$ Revision 1.5  2017/02/14 22:28:09  sgangineni
--$ Removed the grants to the below roles ROLE_SA_UPDATE, ROLE_REPORT_UPDATE  ROLE_SA_SELECT
--$
--$ Revision 1.4  2017/02/09 20:05:51  sraman
--$ CR47564 - changed the Exist function to do only look by MIN
--$
--$ Revision 1.3  2017/02/07 18:37:56  vnainar
--$ reset objid to null in ins menthod in case of error
--$
--$ Revision 1.2  2016/12/27 19:56:40  vnainar
--$ CR44729 exception added in exist method
--$
--$ Revision 1.1  2016/11/29 20:42:37  vnainar
--$ CR44729 New file added
--$
--$
-------------------------------------------------------------------------

CONSTRUCTOR FUNCTION site_part_type RETURN SELF AS RESULT AS
BEGIN
  RETURN;
END site_part_type;

CONSTRUCTOR FUNCTION site_part_type ( i_site_part_objid IN NUMBER ) RETURN SELF AS RESULT AS
BEGIN
    --
  IF i_site_part_objid IS NULL THEN
    SELF.response                   := 'SITE PART ID NOT PASSED';
    RETURN;
  END IF;

  --Query the table
  SELECT site_part_type(  objid                  ,
                          instance_name          ,
                          serial_no              ,
                          s_serial_no            ,
                          invoice_no             ,
                          ship_date              ,
                          install_date           ,
                          warranty_date          ,
                          quantity               ,
                          mdbk                   ,
                          state_code             ,
                          state_value            ,
                          modified               ,
                          level_to_part          ,
                          selected_prd           ,
                          part_status            ,
                          comments               ,
                          level_to_bin           ,
                          bin_objid              ,
                          site_objid             ,
                          inst_objid             ,
                          dir_site_objid         ,
                          machine_id             ,
                          service_end_dt         ,
                          dev                    ,
                          x_service_id           ,
                          x_min                  ,
                          x_pin                  ,
                          x_deact_reason         ,
                          x_min_change_flag      ,
                          x_notify_carrier       ,
                          x_expire_dt            ,
                          x_zipcode              ,
                          site_part2productbin   ,
                          site_part2site         ,
                          site_part2site_part    ,
                          site_part2part_info    ,
                          site_part2primary      ,
                          site_part2backup       ,
                          all_site_part2site     ,
                          site_part2part_detail  ,
                          site_part2x_new_plan   ,
                          site_part2x_plan       ,
                          x_msid                 ,
                          x_refurb_flag          ,
                          cmmtmnt_end_dt         ,
                          instance_id            ,
                          site_part_ind          ,
                          status_dt              ,
                          x_iccid                ,
                          x_actual_expire_dt     ,
                          update_stamp           ,
                          null                   ,
                          null                   ,
                          null
                        )
  INTO SELF
  FROM table_site_part
  WHERE objid = i_site_part_objid;
  --
  SELF.response := 'SUCCESS';

  RETURN;
 EXCEPTION
    WHEN OTHERS THEN
      SELF.response   := 'SITE PART NOT FOUND' || SUBSTR(SQLERRM,1,100);
      SELF.site_part_objid := i_site_part_objid;

      --
      RETURN;
END site_part_type;

CONSTRUCTOR FUNCTION site_part_type ( i_esn IN VARCHAR2, i_min VARCHAR2 ) RETURN SELF AS RESULT AS

l_site_part_objid NUMBER;
BEGIN
    --
  IF i_esn IS NULL OR i_min IS NULL THEN
    SELF.response                   := 'ESN or MIN IS NOT PASSED';
    RETURN;
  END IF;

 --Find site part record with ESN and MIN condition, if not found lookup with ESN, again no match then lookup with MIN
  BEGIN
      SELECT objid INTO l_site_part_objid
      FROM   TABLE_SITE_PART
      WHERE  x_service_id = i_esn AND
             x_min = i_min;
  EXCEPTION
      WHEN no_data_found THEN
      BEGIN
            SELECT objid INTO l_site_part_objid
            FROM   TABLE_SITE_PART
            WHERE  x_service_id = i_esn;
        EXCEPTION
            WHEN no_data_found THEN
            BEGIN
                  SELECT objid INTO l_site_part_objid
                  FROM   TABLE_SITE_PART
                  WHERE  x_min = i_min;
              EXCEPTION
                  WHEN no_data_found THEN
                    NULL;
            END;
        END;
  END;

  --Query the table
  SELECT site_part_type(  objid                  ,
                          instance_name          ,
                          serial_no              ,
                          s_serial_no            ,
                          invoice_no             ,
                          ship_date              ,
                          install_date           ,
                          warranty_date          ,
                          quantity               ,
                          mdbk                   ,
                          state_code             ,
                          state_value            ,
                          modified               ,
                          level_to_part          ,
                          selected_prd           ,
                          part_status            ,
                          comments               ,
                          level_to_bin           ,
                          bin_objid              ,
                          site_objid             ,
                          inst_objid             ,
                          dir_site_objid         ,
                          machine_id             ,
                          service_end_dt         ,
                          dev                    ,
                          x_service_id           ,
                          x_min                  ,
                          x_pin                  ,
                          x_deact_reason         ,
                          x_min_change_flag      ,
                          x_notify_carrier       ,
                          x_expire_dt            ,
                          x_zipcode              ,
                          site_part2productbin   ,
                          site_part2site         ,
                          site_part2site_part    ,
                          site_part2part_info    ,
                          site_part2primary      ,
                          site_part2backup       ,
                          all_site_part2site     ,
                          site_part2part_detail  ,
                          site_part2x_new_plan   ,
                          site_part2x_plan       ,
                          x_msid                 ,
                          x_refurb_flag          ,
                          cmmtmnt_end_dt         ,
                          instance_id            ,
                          site_part_ind          ,
                          status_dt              ,
                          x_iccid                ,
                          x_actual_expire_dt     ,
                          update_stamp           ,
                          null                   ,
                          null                   ,
                          null
                        )
  INTO SELF
  FROM table_site_part
  WHERE objid = l_site_part_objid;
  --
  SELF.response := 'SUCCESS';

  RETURN;
 EXCEPTION
    WHEN OTHERS THEN
      SELF.response   := 'SITE PART NOT FOUND' || SUBSTR(SQLERRM,1,100);
      SELF.site_part_objid := NULL;

      --
      RETURN;
END site_part_type;

MEMBER FUNCTION exist RETURN BOOLEAN AS
BEGIN
  RETURN NULL;
END exist;

MEMBER FUNCTION exist ( i_site_part_type IN OUT site_part_type )RETURN BOOLEAN AS

CURSOR c_min IS
	SELECT /*+ index(table_site_part, x_x_min) */  objid
	FROM   table_site_part
	WHERE  x_min = i_site_part_type.min
      AND  part_status = 'NotMigrated'
	ORDER BY objid desc;
	min_rec c_min%ROWTYPE;
BEGIN

  IF i_site_part_type.min IS NULL THEN
    i_site_part_type.response                   := 'MIN IS NOT PASSED';
    RETURN false;
  END IF;

  OPEN c_min;
  FETCH c_min INTO min_rec;
  IF c_min%FOUND THEN
	 i_site_part_type.site_part_objid := min_rec.objid;
	 CLOSE c_min;
	 RETURN TRUE;
  END IF;
  CLOSE c_min;

 -- No Match
  i_site_part_type.site_part_objid := NULL;
  RETURN FALSE;

EXCEPTION
 WHEN OTHERS THEN
   i_site_part_type.site_part_objid := NULL;
   RETURN FALSE;
END exist;
MEMBER FUNCTION ins ( i_site_part_type IN site_part_type ) RETURN site_part_type AS
sp  site_part_type := i_site_part_type;
BEGIN
  IF sp.site_part_objid IS NULL THEN
    sp.site_part_objid  := sa.sequ_site_part.nextval;
  END IF;

  --Assign Time stamp attributes
  IF sp.update_stamp IS NULL THEN
   sp.update_stamp  := SYSDATE;
  END IF;

  IF  sp.install_date  IS NULL THEN
   sp.install_date  := SYSDATE;
  END IF;

  INSERT
  INTO table_site_part
  (
   objid                    ,
   instance_name            ,
   serial_no                ,
   s_serial_no              ,
   invoice_no               ,
   ship_date                ,
   install_date             ,
   warranty_date            ,
   quantity                 ,
   mdbk                     ,
   state_code               ,
   state_value              ,
   modified                 ,
   level_to_part            ,
   selected_prd             ,
   part_status              ,
   comments                 ,
   level_to_bin             ,
   bin_objid                ,
   site_objid               ,
   inst_objid               ,
   dir_site_objid           ,
   machine_id               ,
   service_end_dt           ,
   dev                      ,
   x_service_id             ,
   x_min                    ,
   x_pin                    ,
   x_deact_reason           ,
   x_min_change_flag        ,
   x_notify_carrier         ,
   x_expire_dt              ,
   x_zipcode                ,
   site_part2productbin     ,
   site_part2site           ,
   site_part2site_part      ,
   site_part2part_info      ,
   site_part2primary        ,
   site_part2backup         ,
   all_site_part2site       ,
   site_part2part_detail    ,
   site_part2x_new_plan     ,
   site_part2x_plan         ,
   x_msid                   ,
   x_refurb_flag            ,
   cmmtmnt_end_dt           ,
   instance_id              ,
   site_part_ind            ,
   status_dt                ,
   x_iccid                  ,
   x_actual_expire_dt       ,
   update_stamp
  )
  VALUES
  (
   sp.site_part_objid       ,
   sp.instance_name         ,
   sp.serial_no             ,
   sp.s_serial_no           ,
   sp.invoice_no            ,
   sp.ship_date             ,
   sp.install_date          ,
   sp.warranty_date         ,
   sp.quantity              ,
   sp.mdbk                  ,
   sp.state_code            ,
   sp.state_value           ,
   sp.modified              ,
   sp.level_to_part         ,
   sp.selected_prd          ,
   sp.part_status           ,
   sp.comments              ,
   sp.level_to_bin          ,
   sp.bin_objid             ,
   sp.site_objid            ,
   sp.inst_objid            ,
   sp.dir_site_objid        ,
   sp.machine_id            ,
   sp.service_end_dt        ,
   sp.dev                   ,
   sp.service_id            ,
   sp.min                   ,
   sp.pin                   ,
   sp.deact_reason          ,
   sp.min_change_flag       ,
   sp.notify_carrier        ,
   sp.expire_dt             ,
   sp.zipcode               ,
   sp.site_part2productbin  ,
   sp.site_part2site        ,
   sp.site_part2site_part   ,
   sp.site_part2part_info   ,
   sp.site_part2primary     ,
   sp.site_part2backup      ,
   sp.all_site_part2site    ,
   sp.site_part2part_detail ,
   sp.site_part2x_new_plan  ,
   sp.site_part2x_plan      ,
   sp.msid                  ,
   sp.refurb_flag           ,
   sp.cmmtmnt_end_dt        ,
   sp.instance_id           ,
   sp.site_part_ind         ,
   sp.status_dt             ,
   sp.iccid                 ,
   sp.actual_expire_dt      ,
   sp.update_stamp
   );

  -- set Success Response
  sp.response  := 'SUCCESS'; -- CASE WHEN sp.response IS NULL THEN 'SUCCESS' ELSE sp.response || '|SUCCESS' END;
  RETURN sp;
EXCEPTION
WHEN OTHERS THEN
  sp.response := sp.response || '|ERROR INSERTING TABLE_SITE_PART RECORD: ' || SUBSTR(SQLERRM,1,100);
  sp.site_part_objid  := NULL; --reset objid to null in case of error
  --
  RETURN sp;

END ins;

MEMBER FUNCTION ins RETURN site_part_type AS
  sp   site_part_type := SELF;
  i    site_part_type;
BEGIN
  i := sp.ins ( i_site_part_type => sp );
  RETURN i;

END ins;

MEMBER FUNCTION upd ( i_site_part_type IN site_part_type ) RETURN site_part_type AS
sp  site_part_type := site_part_type();
BEGIN
  sp := i_site_part_type;

UPDATE table_site_part SET
   instance_name            = NVL(sp.instance_name           , instance_name           ),
   serial_no                = NVL(sp.serial_no               , serial_no               ),
   s_serial_no              = NVL(sp.s_serial_no             , s_serial_no             ),
   invoice_no               = NVL(sp.invoice_no              , invoice_no              ),
   ship_date                = NVL(sp.ship_date               , ship_date               ),
   install_date             = NVL(sp.install_date            , install_date            ),
   warranty_date            = NVL(sp.warranty_date           , warranty_date           ),
   quantity                 = NVL(sp.quantity                , quantity                ),
   mdbk                     = NVL(sp.mdbk                    , mdbk                    ),
   state_code               = NVL(sp.state_code              , state_code              ),
   state_value              = NVL(sp.state_value             , state_value             ),
   modified                 = NVL(sp.modified                , modified                ),
   level_to_part            = NVL(sp.level_to_part           , level_to_part           ),
   selected_prd             = NVL(sp.selected_prd            , selected_prd            ),
   part_status              = NVL(sp.part_status             , part_status             ),
   comments                 = NVL(sp.comments                , comments                ),
   level_to_bin             = NVL(sp.level_to_bin            , level_to_bin            ),
   bin_objid                = NVL(sp.bin_objid               , bin_objid               ),
   site_objid               = NVL(sp.site_objid              , site_objid              ),
   inst_objid               = NVL(sp.inst_objid              , inst_objid              ),
   dir_site_objid           = NVL(sp.dir_site_objid          , dir_site_objid          ),
   machine_id               = NVL(sp.machine_id              , machine_id              ),
   service_end_dt           = NVL(sp.service_end_dt          , service_end_dt          ),
   dev                      = NVL(sp.dev                     , dev                     ),
   x_service_id             = NVL(sp.service_id              , x_service_id            ),
   x_min                    = NVL(sp.min                     , x_min                   ),
   x_pin                    = NVL(sp.pin                     , x_pin                   ),
   x_deact_reason           = NVL(sp.deact_reason            , x_deact_reason          ),
   x_min_change_flag        = NVL(sp.min_change_flag         , x_min_change_flag       ),
   x_notify_carrier         = NVL(sp.notify_carrier          , x_notify_carrier        ),
   x_expire_dt              = NVL(sp.expire_dt               , x_expire_dt             ),
   x_zipcode                = NVL(sp.zipcode                 , x_zipcode               ),
   site_part2productbin     = NVL(sp.site_part2productbin    , site_part2productbin    ),
   site_part2site           = NVL(sp.site_part2site          , site_part2site          ),
   site_part2site_part      = NVL(sp.site_part2site_part     , site_part2site_part     ),
   site_part2part_info      = NVL(sp.site_part2part_info     , site_part2part_info     ),
   site_part2primary        = NVL(sp.site_part2primary       , site_part2primary       ),
   site_part2backup         = NVL(sp.site_part2backup        , site_part2backup        ),
   all_site_part2site       = NVL(sp.all_site_part2site      , all_site_part2site      ),
   site_part2part_detail    = NVL(sp.site_part2part_detail   , site_part2part_detail   ),
   site_part2x_new_plan     = NVL(sp.site_part2x_new_plan    , site_part2x_new_plan    ),
   site_part2x_plan         = NVL(sp.site_part2x_plan        , site_part2x_plan        ),
   x_msid                   = NVL(sp.msid                    , x_msid                  ),
   x_refurb_flag            = NVL(sp.refurb_flag             , x_refurb_flag           ),
   cmmtmnt_end_dt           = NVL(sp.cmmtmnt_end_dt          , cmmtmnt_end_dt          ),
   instance_id              = NVL(sp.instance_id             , instance_id             ),
   site_part_ind            = NVL(sp.site_part_ind           , site_part_ind           ),
   status_dt                = NVL(sp.status_dt               , status_dt               ),
   x_iccid                  = NVL(sp.iccid                   , x_iccid                 ),
   x_actual_expire_dt       = NVL(sp.actual_expire_dt        , x_actual_expire_dt      ),
   update_stamp             = NVL(sp.update_stamp            , update_stamp            )
 WHERE objid =  sp.site_part_objid ;

  -- set Success Response
  sp := site_part_type ( i_site_part_objid  => sp.site_part_objid);
  sp.response  := 'SUCCESS';
  RETURN sp;
EXCEPTION
WHEN OTHERS THEN
  sp.response := sp.response || '|ERROR UPDATING TABLE_SITE_PART RECORD: ' || SUBSTR(SQLERRM,1,100);
  --
  RETURN sp;

END upd;

MEMBER FUNCTION del ( i_site_part_objid IN  NUMBER ) RETURN BOOLEAN AS
BEGIN
  RETURN NULL;
END del;

MEMBER FUNCTION del RETURN BOOLEAN AS
BEGIN
  RETURN NULL;
END del;

END;
/