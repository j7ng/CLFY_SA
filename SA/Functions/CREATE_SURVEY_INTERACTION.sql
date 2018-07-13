CREATE OR REPLACE FUNCTION sa."CREATE_SURVEY_INTERACTION" (p_contact_objid varchar2,
                            p_reason varchar2 DEFAULT 'SURVEY OFFER',
                            p_result varchar2,
                            p_user varchar2,
                            p_esn  varchar2,
                            p_min  varchar2,
                            p_brand_name  varchar2,
                            p_channel  varchar2
                            )
return varchar2
as
--------------------------------------------------------------------------------------------
--$RCSfile: CREATE_SURVEY_INTERACTION.sql,v $
--$Revision: 1.1 $
--$Author: mmunoz $
--$Date: 2017/06/05 22:27:31 $
--$ $Log: CREATE_SURVEY_INTERACTION.sql,v $
--$ Revision 1.1  2017/06/05 22:27:31  mmunoz
--$ CR50846: 611611 Survey integration
--$
--------------------------------------------------------------------------------------------
  PRAGMA AUTONOMOUS_TRANSACTION;
  n_user_objid              number;
  v_user_name               varchar2(30);
  n_tab_interact_objid      number;         -- table_interact objid
  n_interaction_id          number;         -- interaction id
  v_datadump                varchar2(4000); -- info we don't need

begin
    ------------------------------------------------------------------------------
    -- CREATE TABLE_INTERACT OBJIDS AND INTERACTION ID
    ------------------------------------------------------------------------------
    begin
      select obj_num
      into   n_tab_interact_objid
      from   adp_tbl_oid
      where  type_id = 5225;

      sa.next_id('Interaction ID',n_interaction_id,v_datadump);
    exception
    when others then
        return 'ERROR - Not able to create the required objid or the interaction_id';
    end;

    ---------------------------------
    -- GET CONTACT and AGENT INFORMATION
    ---------------------------------
    begin
      select objid,
             login_name
      into   n_user_objid,
             v_user_name
      from   table_user
      where  s_login_name = upper(p_user);
    exception
      when others then
        return 'ERROR - Not able to obtain the agent information';
    end;
  ------------------------------------------------------------------------------
  -- CREATE INTERACTION
  ------------------------------------------------------------------------------
  begin
    insert into table_interact
      (objid,
       interact_id,
       create_date,
       inserted_by,
       type,
       s_type,
       origin,
       reason_1,
       s_reason_1,
       result,
       start_date,
       end_date,
       agent,
       s_agent,
       serial_no,
       mobile_phone,
       x_service_type,
       interact2contact,
       interact2user)
    values
      (n_tab_interact_objid,
       n_interaction_id,
       sysdate,
       v_user_name,
       trim(p_brand_name),
       upper(trim(p_brand_name)),
       upper(trim(p_channel)),
       trim(p_reason),
       upper(trim(p_reason)),
       upper(trim(p_result)),
       sysdate,
       sysdate,
       v_user_name,
       UPPER(V_USER_NAME),
       nvl(trim(p_esn),''),
       nvl(trim(p_min),''),
       'Wireless',
       p_contact_objid,
       n_user_objid);

  exception
    when others then
      return 'ERROR - Unable to create interaction '||sqlerrm;
  end;

  COMMIT;
  return 'Created Interaction';

exception
  when others then
    return 'ERROR - Unable to complete create interaction call '||sqlerrm;
end create_survey_interaction;
/