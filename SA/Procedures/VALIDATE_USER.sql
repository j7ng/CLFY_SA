CREATE OR REPLACE procedure sa.VALIDATE_USER(l_name in varchar2, pin in varchar2, v_client in varchar2, v_code out number) as
/******************************************************************************/
/* Copyright (r) 2001 Tracfone Wireless Inc. All rights reserved              */
/*                                                                            */
/* Name         :   validate_user_new.sql                                     */
/* Purpose      :   To reset password for users for Clarify and Webcsr        */
/*                  Uses sa.create_clarify_user procedure to create           */
/* Parameters   :   LOGIN NAME, PIN                                           */
/* Platforms    :   Oracle 10.2.0.3.0 AND newer versions                      */
/* Author       :   Srinivas Chakravarthy Karumuri                            */
/* Reviewed By  :   Muhammad Nazir                                            */
/* Date         :   06/21/2010                                                */
/*                                                                            */
/* Revisions    :                                                             */
/* Version      Date        Who           Purpose                             */
/* -------      --------    -------       ----------------------------------- */
/* 1.0          06/03/2010  SKarumuri     Initial revision - To reset password*/
/* 2.0          06/21/2010  SKarumuri     Included Option for Clarify/Webcsr  */
/*******************************************************************************/
/* 1.1          04/04/2013  CLindner      Simple Mobile System Integration - WEBCSR */
/******************************************************************************/
    v_user          table_user%rowtype;
    v_emp           table_employee%rowtype;
    inactive_user   exception;
begin
    select  *
    into    v_user
    from    sa.table_user
    where   s_login_name=upper(l_name);

    select  *
    into    v_emp
    from    sa.table_employee
    where   employee2user=v_user.objid
    and     employee_no=nvl(pin,'NA');

    if v_user.status=0 then
        raise  inactive_user;
    end if;
    IF UPPER(L_NAME)=V_USER.S_LOGIN_NAME AND PIN = V_EMP.EMPLOYEE_NO THEN
       if v_client in ('TAS', 'Webcsr') then  --CR22451
            update  sa.table_user
            set     web_password ='Y2fEjdGT1W6nsLqtJbGUVeUp9e4=',
                    web_passwd_chg = '01-JAN-1753',
                    web_last_login = sysdate,
                    submitter_ind=0,
                    dev=1,
                    status=1,
                    user2rc_config=268436363
            where   objid = v_user.objid;
            commit;
            v_code:=1;
        else if v_client = 'Clarify' then
            update  sa.table_user
            set     password='[ScBhozpV1nkzzNPrE/',
                    passwd_chg='01-JAN-1753',
                    last_login = sysdate,
                    submitter_ind=0,
                    dev=1,
                    status=1,
                    user2rc_config=268436363
            where   objid = v_user.objid;
            commit;
            v_code:=0;
        end if; end if;
    end if;
exception
when no_data_found
then    v_code:=2;
when inactive_user
then   v_code:=3;
end;
/