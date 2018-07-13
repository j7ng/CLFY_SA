CREATE OR REPLACE PACKAGE BODY sa.organization_services_pkg
AS
  ---------------------------------------------------------------------------------------------
  --$RCSfile: ORGANIZATION_SERVICES_PKB.sql,v $
  --$Revision: 1.13 $
  --$Author: vlaad $
  --$Date: 2017/05/12 21:43:46 $
  --$ $Log: ORGANIZATION_SERVICES_PKB.sql,v $
  --$ Revision 1.13  2017/05/12 21:43:46  vlaad
  --$ Updated a defect
  --$
  --$ Revision 1.11  2014/04/25 15:16:28  cpannala
  --$ CR25490
  --$
  ---------------------------------------------------------------------------------------------
function validateInputsUO(in_org_dtls org_type_rec,
                          op_site_objid out number,
                          op_site_type out varchar2,
                          op_parent_site_objid out number,
                          op_orgChildSite2Site out number,
                          op_parChildSite2Site out number)
return number is
    v_err_num number := 0;
    orgName table_site.s_name%type;
    parName table_site.s_name%type;
    ParentCount number :=0;
begin
  --
 begin
  select s_name,objid,site_type,child_site2site
  into orgName,op_site_objid,op_site_type,op_orgChildSite2Site
  from table_site
  where x_commerce_id = in_org_dtls.commerce_id;
 exception
  when others then
    orgName := null;
 end;

  if in_org_dtls.parent_commerce_id is not null then
     begin
       select s_name,objid,child_site2site
       into parName,op_parent_site_objid,op_parChildSite2Site
       from table_site
       where x_commerce_id = in_org_dtls.parent_commerce_id;
     exception
       when others then
         parName := null;
     end;
  end if;
  IF (orgName is null ) THEN
    v_err_num                 := 732; -- 'Organization name is null.'
  ELSIF (IN_ORG_DTLS.parent_commerce_id IS not NULL and parName is null )  THEN
    v_err_num                  := 733; -- 'Parent name is null.'
  END IF;
  return v_err_num;
end;
function validateInputsCO(in_org_dtls org_type_rec) return number is
 v_err_num number := 0;
begin
  --
  IF (IN_ORG_DTLS.org_name IS NULL) THEN
    v_err_num                 := 726; -- 'Organization name is null.'
  ELSIF (IN_ORG_DTLS.org_type) IS NULL THEN
    v_err_num                  := 727; -- 'Organization type is null.'
  --CR47608 removing this check for intangible orders
  /*ELSIF (IN_ORG_DTLS.cust_id IS NULL) THEN
    v_err_num                := 728; -- 'Customer ID is null.'*/
  ELSIF (IN_ORG_DTLS.commerce_id IS NULL) THEN
    v_err_num                    := 730; -- 'Commerce ID is null.'
    --CR47608 removing this check for intangible orders
  /*ELSIF IN_ORG_DTLS.ship_loc_id IS NULL THEN
    v_err_num                   := 731; -- 'Ship location ID is null.'*/

 -- ELSIF (IN_ORG_DTLS.cust_acct_number IS NULL) THEN
 --   v_err_num                         := 729; -- 'Customer account number is null.'
  END IF;

  return v_err_num;

end;
--
FUNCTION determine_b2b_site_type
  (
    in_parent_org_objid   IN table_site.objid%TYPE,
    in_fin_cust_id        IN table_site.x_fin_cust_id%TYPE,
    in_parent_commerce_id IN table_site.x_commerce_id%TYPE,
    in_parent_ship_loc_id IN table_site.x_ship_loc_id%TYPE
  )
  RETURN table_site.site_type%TYPE
IS
  --
  v_site_type table_site.site_type%TYPE;
  --
  CURSOR cur_site
  IS
    SELECT ts.objid,
      ts.child_site2site,
      ts.site_type
    FROM table_site ts
    WHERE ts.TYPE        = 3
    AND (ts.objid        = in_parent_org_objid
    OR ( ts.x_fin_cust_id = nvl(in_fin_cust_id,ts.x_fin_cust_id)   --CR47608 previously ts.x_fin_cust_id = in_fin_cust_id
    AND ts.x_commerce_id = in_parent_commerce_id
    AND ts.x_ship_loc_id=  nvl(in_parent_ship_loc_id,ts.x_ship_loc_id) )); --CR47608 previously ts.x_ship_loc_id  = in_parent_ship_loc_id
  rec_site cur_site%ROWTYPE;
  --
BEGIN
  --
  OPEN cur_site;
  FETCH cur_site INTO rec_site;
  CLOSE cur_site;
  -- based on site_typeof the parent we determine the child's site_type
  IF (rec_site.objid       IS NULL) THEN
    v_site_type            := 'ORG';
  ELSIF (rec_site.site_type = 'ORG') THEN
    v_site_type            := 'DIV';
  ELSIF (rec_site.site_type = 'DIV') THEN
    v_site_type            := 'SDIV';
  END IF;
  --
  RETURN v_site_type;
  --
END determine_b2b_site_type;
PROCEDURE createOrganization(
           in_org_dtls IN org_type_rec,
           out_org_objid OUT table_site.objid%TYPE,
           out_err_num OUT NUMBER,
           out_err_msg OUT VARCHAR2)
IS
  v_billaddr_objid table_address.objid%TYPE;
  v_shipaddr_objid table_address.objid%TYPE;
  v_parent_site_objid table_site.objid%TYPE;
  v_site_type table_site.site_type%TYPE;
  v_err_loc varchar2(100);
  --
  v_business_error_excp EXCEPTION;
  dummy_bool boolean;
  --
BEGIN
   out_err_num := validateInputsCO(in_org_dtls);
   if out_err_num > 0 then
      raise v_business_error_excp;
   end if;
   --dbms_output.put_line('Calling 1');
   if in_org_dtls.orgexists(out_org_objid) then
       OUT_ERR_NUM          := -3;
       OUT_ERR_MSG          := 'Organization already exists.';
       return;
   end if;
   --dbms_output.put_line('Calling 2');
   if not in_org_dtls.bill_to.is_null then
        dummy_bool := in_org_dtls.bill_to.write2db(v_billaddr_objid);
   end if;
   if not in_org_dtls.ship_to.is_null then
        dummy_bool := in_org_dtls.ship_to.write2db(v_shipaddr_objid);
   end if;
   if in_org_dtls.parent_commerce_id is not null then
     BEGIN
       select objid
       into v_parent_site_objid
       from table_site
       where x_commerce_id = in_org_dtls.parent_commerce_id;
     EXCEPTION
      when others then
          v_parent_site_objid :=null;
     END;
   end if;
   --dbms_output.put_line('Calling 3');
   v_site_type := DETERMINE_B2B_SITE_TYPE(v_PARENT_SITE_OBJID,
                                          in_org_dtls.CUST_ID,
                                          in_org_dtls.commerce_id,
                                          in_org_dtls.ship_loc_id);

   --dbms_output.put_line('Calling CreateOrg');
   if not in_org_dtls.createorg(v_parent_site_objid,
                         v_site_type,
                         v_billaddr_objid,
                         v_shipaddr_objid,
                         out_org_objid,
                         v_err_loc,
                         out_err_num,
                         out_err_msg) then
      raise value_error; --just to make sure that it goes to when others
   end if;

  out_err_num := 0;
  out_err_msg := 'Success';

exception
when v_business_error_excp then
  out_err_msg:= sa.get_code_fun('ORGANIZATION_SERVICES_PKG', out_err_num, 'ENGLISH');
  UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => 'Invalid parameters',
                       IP_KEY => IN_ORG_DTLS.CUST_ID || '-' ||IN_ORG_DTLS.SHIP_LOC_ID,
                       Ip_program_name => 'ORGANIZATION_SERVICES_PKG.CREATEORGANIZATION',
                       Ip_error_text => out_err_msg);
when others then
  rollback;
  dbms_output.put_line(v_err_loc||'-'||sqlerrm);
  UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => 'Creating Organization - '||v_err_loc,
                       IP_KEY => IN_ORG_DTLS.CUST_ID || '-' ||IN_ORG_DTLS.SHIP_LOC_ID,
                       Ip_program_name => 'ORGANIZATION_SERVICES_PKG.CREATEORGANIZATION',
                       Ip_error_text => out_err_msg);

end;
PROCEDURE deleteOrganization
  (
    in_Commerce_Id IN table_site.x_commerce_id%TYPE,
    out_err_num OUT NUMBER,
    out_err_msg OUT VARCHAR2
  )
IS
    v_business_error_excp exception;
BEGIN
  IF (in_Commerce_Id IS NULL) THEN
    out_err_num        := 725; -- 'Organization ID is null.'
    out_err_msg        := sa.get_code_fun('ORGANIZATION_SERVICES_PKG', out_err_num, 'ENGLISH');
    RAISE v_business_error_excp;
  END IF;
--   if not in_org_dtls.deleteorg(in_commerce_id,out_err_num,out_err_msg ) then
--      raise value_error;
--   END IF;
  --
  out_err_num := 0;
  out_err_msg := 'Success';
  --
EXCEPTION
WHEN OTHERS THEN
  --
  out_err_num := SQLCODE;
  out_err_msg :=sqlerrm;
  OTA_UTIL_PKG.ERR_LOG(P_ACTION => 'Delete',
                       P_ERROR_DATE => sysdate,
                       P_KEY => TO_CHAR('abcd'),
                       p_program_name => 'ORGANIZATION_SERVICES_PKG.DELETEORGANIZATION',
                       p_error_text => out_err_msg);
  --
END deleteOrganization;
--
PROCEDURE updateOrganization(
    in_org_dtls IN org_type_rec,
    out_err_num OUT NUMBER,
    out_err_msg OUT VARCHAR2)
IS
  --
  v_business_error_excp EXCEPTION;
  v_parent_site_objid number;
  v_orgChildSite2Site number;
  v_parChildSite2Site number;
  v_site_type         table_site.site_type%TYPE; --varchar2(80);
  org_site_type       table_site.site_type%TYPE; --varchar2(80);
  org_site_objid      table_site.objid%type;
  v_site_id           table_site.site_id%TYPE;
  v_site_id_seq         NUMBER;
  v_upd_inv_tbls boolean := false;
  dummy_bool boolean;
  --
BEGIN
    out_err_num := validateInputsUO(in_org_dtls,
                                    org_site_objid,
                                  org_site_type,
                                  v_parent_site_objid,
                                  v_orgChildSite2Site,
                                  v_parChildSite2Site);
    if out_err_num > 0 then
      RAISE v_business_error_excp;
    end if;

  -- if the exisitng org structure is modified then the
  -- child_site2site, site_type, site_id will have to be
  -- modified accordingly
  IF v_orgChildSite2Site != NVL(v_parent_site_objid, v_orgChildSite2Site) THEN
    --
    v_site_type := determine_b2b_site_type(v_parent_site_objid,
                                          IN_ORG_DTLS.cust_id,
                                          IN_ORG_DTLS.PARENT_COMMERCE_ID,
                                          IN_ORG_DTLS.parent_ship_loc_id);
    --
    IF v_site_type != org_site_type THEN
      --
      SELECT v_site_type||seq_site_id.NEXTVAL
      INTO v_site_id
      FROM dual;
      v_upd_inv_tbls := TRUE;
      --
    END IF;
    --
  END IF;
  if not in_org_dtls.updateOrg(v_site_type,
                                      v_site_id,
                                      v_parent_site_objid,
                                      v_upd_inv_tbls,
                                      out_err_num,
                                      out_err_msg) then
    raise value_error;
  end if;
  --
  --
  --
  out_err_num := 0;
  out_err_msg := 'Success';
  --
EXCEPTION
WHEN v_business_error_excp THEN
    out_err_msg := sa.get_code_fun('ORGANIZATION_SERVICES_PKG', out_err_num, 'ENGLISH');
    UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => 'Invalid Inputs',
                       IP_KEY => org_site_objid,
                       IP_PROGRAM_NAME => 'ORGANIZATION_SERVICES_PKG.UPDATEORGANIZATION',
                       Ip_error_text => out_err_msg);

WHEN OTHERS THEN
  UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => '',
                       IP_KEY => org_site_objid,
                       IP_PROGRAM_NAME => 'ORGANIZATION_SERVICES_PKG.UPDATEORGANIZATION',
                       Ip_error_text => out_err_msg);
  --
END updateOrganization;
PROCEDURE getOrganization(
    in_Commerce_Id IN table_site.x_commerce_id%TYPE,
    out_org_structure_dtls OUT SYS_REFCURSOR,
    out_err_num OUT NUMBER,
    out_err_msg OUT VARCHAR2)
IS
  --
  v_location            VARCHAR2(1000);
  v_business_error_excp EXCEPTION;
  v_err_num             INTEGER;
  v_err_msg             VARCHAR2(1000);
  --
BEGIN
  -- Validate Inputs
  v_location := 'Started getOrganization';
  IF g_v_debug THEN
    dbms_output.put_line(v_location);
  END IF;
  IF (in_Commerce_Id IS NULL) THEN
    v_err_num        := 725; -- 'Organization ID is null.'
    v_err_msg        := sa.get_code_fun('ORGANIZATION_SERVICES_PKG', v_err_num, 'ENGLISH');
    RAISE v_business_error_excp;
  END IF;
  --
  OPEN OUT_ORG_STRUCTURE_DTLS FOR
  SELECT Ts.S_Name Site_Name,
      Ts.Status,
      Ts.Type Type_Code,
      Ts.Site_Type,
      Ts.Site_Id,
      Ts.X_Fin_Cust_Id,
      Ts.X_Ship_Loc_Id,
      Ts.X_Commerce_Id,
      CHLD_TS.S_NAME CHILD_SITE_NAME,
      CHLD_TS.STATUS CHILD_SITE_STATUS,
      CHLD_TS.TYPE CHILD_SITE_TYPE_CODE,
      Chld_Ts.Site_Id Child_Site_Id,
      Chld_Ts.Site_Type Child_Site_Type,
      Chld_Ts.X_Fin_Cust_Id Chld_Ts_Fin_Cust_Id,
      CHLD_TS.X_SHIP_LOC_ID CHLD_TS_SHIP_LOC_ID,
      Chld_Ts.x_commerce_id Chld_Ts_commerce_id
      FROM table_site ts,
      table_site chld_ts
      WHERE 1  =1
      AND TS.X_COMMERCE_ID = IN_COMMERCE_ID--'587694'
      AND CHLD_TS.CHILD_SITE2SITE = TS.OBJID
  UNION ALL
  SELECT Ts.S_Name Site_Name,
        Ts.Status,
        Ts.Type Type_Code,
        Ts.Site_Type,
        Ts.Site_Id,
        Ts.X_Fin_Cust_Id,
        Ts.X_Ship_Loc_Id,
        Ts.X_Commerce_Id,
        CHLD_TS.S_NAME CHILD_SITE_NAME,
        CHLD_TS.STATUS CHILD_SITE_STATUS,
        CHLD_TS.TYPE CHILD_SITE_TYPE_CODE,
        Chld_Ts.Site_Id Child_Site_Id,
        Chld_Ts.Site_Type Child_Site_Type,
        Chld_Ts.X_Fin_Cust_Id Chld_Ts_Fin_Cust_Id,
        CHLD_TS.X_SHIP_LOC_ID CHLD_TS_SHIP_LOC_ID,
        Chld_Ts.x_commerce_id Chld_Ts_commerce_id
        FROM Table_Site Ts,
        TABLE_SITE CHLD_TS
        WHERE 1                     =1
        AND Chld_Ts.X_Commerce_Id   = IN_COMMERCE_ID
        AND Chld_Ts.Child_Site2site = Ts.Objid;
  --
  out_err_num := 0;
  out_err_msg := 'Success';
  COMMIT;
  --
EXCEPTION
WHEN v_business_error_excp THEN
  --
  out_err_num := v_err_num;
  out_err_msg := v_err_msg;
  --
WHEN OTHERS THEN
  --
  ROLLBACK;
  out_err_num := SQLCODE;
  out_err_msg :=sqlerrm;
  UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => V_LOCATION,
                       IP_KEY => TO_CHAR(IN_COMMERCE_ID),
                       Ip_program_name => 'ORGANIZATION_SERVICES_PKG.GETORGANIZATION',
                       Ip_error_text => out_err_msg);
  --
END getOrganization;
--
PROCEDURE assignBuyer(
    In_Commerce_Id IN Table_Site.X_Commerce_Id%Type,
    in_web_accnt   IN Table_Web_User.Login_Name%TYPE,
    in_brand       IN table_bus_org.org_id%TYPE,
    in_buyer_type  IN x_site_web_accounts.x_account_type%TYPE,
    out_err_num OUT NUMBER,
    out_err_msg OUT VARCHAR2)
IS
  --
  is_attached           NUMBER;
  Site_Objid            Number;
  bo_objid number;
  wu_Objid Number;

BEGIN
  -- Validate Inputs
  IF (in_buyer_type IS NULL) THEN
    out_err_num       := 735; -- 'Buyer/Account type is null.'
    out_err_msg       := sa.GET_CODE_FUN('ORGANIZATION_SERVICES_PKG', out_err_num, 'ENGLISH');
   RETURN;
  END IF;
  BEGIN
        select objid
        into bo_objid
        from table_bus_org
        WHERE Org_Id = nvl(in_brand, ' ');
  EXCEPTION
  WHEN OTHERS THEN
        Out_Err_Num := -1;
        out_Err_msg := 'Selecting bus_org '||Sqlerrm;
        RETURN;
  END;
      --
      BEGIN
        SELECT objid
        INTO wu_objid
        from table_web_user wu
        WHERE Wu.Login_Name     = nvl(in_web_accnt, ' ' )
        AND Wu.Web_User2bus_Org = Bo_Objid;
      EXCEPTION
      WHEN OTHERS THEN
        Out_Err_Num := -1;
        out_err_msg := 'Selecting web user for login name'||sqlerrm;
        return;
      END;
    --
    BEGIN
      SELECT Objid
      INTO Site_Objid
      from table_site
      WHERE X_Commerce_Id = nvl(In_Commerce_Id, ' ');
    EXCEPTION
    WHEN OTHERS THEN
      Out_Err_Num := -1;
      out_err_msg := 'Selecting site objid'||sqlerrm;
      return;
    end;
   --
    select count(*)
    into is_attached
    from sa.x_site_web_accounts
    where site_web_acct2web_user = wu_objid;

    if is_attached > 0 then
      out_err_num := -3;
      out_err_msg := 'Acoount already attached to org'||sqlerrm;
      return;
    end if;
    ---
    INSERT
    INTO x_site_web_accounts
      (
        objid,
        site_web_acct2site,
        site_web_acct2web_user,
        site_web_acct2web_user_parent,
        x_account_type,
        x_insert_date,
        x_update_date
      )
      VALUES
      (
        Sequ_Site_Web_Accounts.Nextval ,
        Site_Objid,
        wu_objid,
        NULL,
        in_buyer_type,
        SYSDATE,
        SYSDATE
      );
    --
    out_err_num := 0;
    out_err_msg := 'Success';
    --
  EXCEPTION
   WHEN OTHERS THEN
    --
    ROLLBACK;
    UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => null,
                         Ip_key => TO_CHAR(site_objid),
                         Ip_program_name => 'ORGANIZATION_SERVICES_PKG.ASSIGNBUYER',
                         Ip_error_text => out_err_msg);
    --
  END assignBuyer;
--
END organization_services_pkg;
/