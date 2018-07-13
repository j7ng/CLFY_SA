CREATE OR REPLACE FUNCTION sa."CREATE_GROUP" ( i_web_user_objid     IN  NUMBER   ,
                                          i_service_plan_id    IN  NUMBER   ,
                                          i_bus_org_objid      IN  NUMBER   ,
                                          i_status             IN  VARCHAR2 ,
                                          o_account_group_uid  OUT VARCHAR2 ,
                                          o_err_code           OUT NUMBER   ,
                                          o_err_msg            OUT VARCHAR2 ) RETURN NUMBER IS
--------------------------------------------------------------------------------------------
--$RCSfile: create_group.sql,v $
--$Revision: 1.4 $
--$Author: aganesan $
--$Date: 2015/05/22 17:17:10 $
--$ $Log: create_group.sql,v $
--$ Revision 1.4  2015/05/22 17:17:10  aganesan
--$ CR34909 - Super Carrier changes
--$
--$ Revision 1.1  2015/04/14 22:29:23  jpena
--$ CR34081 Super Carrier
--$
--------------------------------------------------------------------------------------------
  l_group_objid         NUMBER;
  l_account_group_name  x_account_group.account_group_name%TYPE;
BEGIN

  --
  IF i_bus_org_objid IS NULL THEN
    o_err_code := 10;
    o_err_msg  := 'BRAND NOT FOUND';
  END IF;

  --
  IF i_bus_org_objid IS NULL THEN
    o_err_code := 11;
    o_err_msg  := 'SERVICE PLAN NOT FOUND';
  END IF;

  -- Get the group name (nickname)
  sa.brand_x_pkg.get_default_group_name ( ip_web_user_objid      => i_web_user_objid,
                                          op_account_group_name => l_account_group_name);

  INSERT
  INTO   x_account_group
         ( objid                     ,
           account_group_name        ,
           service_plan_id           ,
           service_plan_feature_date ,
           program_enrolled_id       ,
           status                    ,
           insert_timestamp          ,
           update_timestamp          ,
           bus_org_objid             ,
           start_date                ,
           end_date                  ,
           account_group_uid
         )
  VALUES
  ( sa.sequ_account_group.NEXTVAL ,
    NVL(l_account_group_name,'GROUP 1') ,
    i_service_plan_id             ,
    NULL                          ,
    NULL                          ,
    i_status                      ,
    SYSDATE                       ,
    SYSDATE                       ,
    i_bus_org_objid               ,
    SYSDATE                       ,
    NULL                          ,
    RandomUUID
  )
  RETURNING objid,
            account_group_uid
  INTO      l_group_objid,
            o_account_group_uid;

  o_err_code := 0;
  o_err_msg  := 'SUCCESS';

  RETURN l_group_objid;

EXCEPTION
  WHEN OTHERS THEN
    o_err_code := SQLCODE;
    o_err_msg  := SUBSTR(SQLERRM,1,100);
END;
/