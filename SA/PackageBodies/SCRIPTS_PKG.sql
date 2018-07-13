CREATE OR REPLACE PACKAGE BODY sa."SCRIPTS_PKG" as
----------------------------------------------------------------
----------------------------------------------------------------
--$RCSfile: SCRIPTS_PKG.sql,v $
--$Revision: 1.24 $
--$Author: hcampano $
--$Date: 2017/03/01 19:32:30 $
--$ $Log: SCRIPTS_PKG.sql,v $
--$ Revision 1.24  2017/03/01 19:32:30  hcampano
--$ REL853B_TAS - 3.21.2017 - CR48373 - update
--$
--$ Revision 1.23  2016/10/04 15:46:33  nmuthukkaruppan
--$ CR44680 - Getting Language as Input param
--$
--$ Revision 1.22  2016/07/06 19:18:57  clinder
--$ CR43885
--$
--$ Revision 1.21  2016/07/06 14:04:29  clinder
--$ CR43885
--$
--$ Revision 1.20  2015/09/28 15:30:49  smeganathan
--$ CR35913 changes added language in the condition
--$
--$ Revision 1.20  2015/09/28 15:53:00  sethiraj
--$ Changes for 35913 ? My accounts.
--$
--$ Revision 1.19  2015/08/11 17:52:43  sethiraj
--$ Changes for 35913 ? My accounts.
--$
--$ Revision 1.18  2015/08/12 14:14:00  smeganathan
--$ Changes for 35913 a?? My accounts a?? Merge with production release. V 1.13
--$
--$
--$ Revision 1.17  2015/08/11 19:38:43  smeganathan
--$ Changes for 35913 ? My accounts
--$
--$ Revision 1.16  2015/08/10 19:41:04  smeganathan
--$ Changes for 35913 ? My accounts
--$
--$ Revision 1.15  2015/08/10 19:35:05  smeganathan
--$ Changes for 35913 ? My accounts
--$
--$ Revision 1.14  2015/08/07 17:12:20  smeganathan
--$ Changes for 35913 ? My accounts
--$
--$ Revision 1.13  2015/07/09 19:37:32  hcampano
--$   	-- BASED OFF PRODUCTION CODE VERSION 1.9
--$   	-- ADDRESSING ISSUE FROM DEFECT BRANCH.Branch_2015 - Defect #3334 - CR36345
--$   	-- WHICH GAVE ISSUES IN SIT1 ON 7/9/2015
--$   	-- ISSUE CAME WHEN A DUPLICATE ERROR+FUNC+FLOW IS EXECUTED WITH A DIFFERENT MESSAGE
--$   	-- IN THE CASE OF THE DEFECT THERE ARE TWO DIFFERENT MESSAGES IN THE SOA SERVICE
--$   	-- THAT HAVE THE SAME KEY
--$   	-- TO SOLVE THIS UNCOMMON ISSUE, WE COMPARE THE MESSAGE COMING IN TO WHAT'S IN
--$   	-- THE DATABASE AND IF A MATCH IS NOT FOUND, WE CREATE A NEW ENTRY BASED OF THE
--$   	-- ERROR NUMBER + LENGTH OF THE MESSAGE PROVIDED
--$
--$ Revision 1.9  2014/09/04 18:36:59  dtunk
--$ Added for CR28413
--$
--$ Revision 1.8  2014/04/04 21:36:35  mmunoz
--$ Updated get_error_map_script to retrieve default message when go to exception
--$
--$ Revision 1.7  2013/08/27 14:59:38  hcampano
--$ Added function replace_script_token_variables to pkg
--$
--$ Revision 1.6  2013/07/16 12:31:17  hcampano
--$ Added new Procedure for next ADF release to get esn
--$
--$ Revision 1.5  2012/12/20 22:54:47  icanavan
--$ ADDED DECODE APP, WEB
--$
--$ Revision 1.4  2011/01/10 21:15:17  pmistry
--$ CR15166 WAP Redemption
--$
--$ Revision 1.3  2010/05/25 16:23:46  akhan
--$ Added default 'ENGLISH'
--$
--$ Revision 1.2  2010/04/21 17:57:50  akhan
--$ Modified get_script_prc for defect
----------------------------------------------------------------
----------------------------------------------------------------
  function error_number_generator(ip_msg varchar2)
  return varchar2
  is
    pos number := 1;
    asciisum number := 0;
    msglengh number := 0;
    v_msg varchar2(4000);
  begin
    -- REPLACE ALL NUMBERS
    v_msg := regexp_replace(replace(ip_msg,'.',''),'\d','');
    msglengh := length(v_msg);

    while pos <= msglengh
    loop
      asciisum := asciisum+ASCII(substr(v_msg,pos,1));
      pos := pos+1;
    end loop;
    return to_char(asciisum);
  end error_number_generator;
----------------------------------------------------------------
  function replace_script_token_variables (ip_script_text in varchar2,
                                           ip_bus_org in varchar2,
                                           ip_language in varchar2)
  return varchar2
  is
    source_string varchar2(4000) := ip_script_text;
  begin
    if instr(source_string,'[') = 0 then
       return source_string;
    end if;

    for i in (select t.var_name,t.var_value
              from   sa.adfcrm_script_token_variables t,
                     sa.table_bus_org b
              where  t.org_objid = b.objid
              and    b.org_id = ip_bus_org
              and    t.language = ip_language)
    loop
      source_string := replace(source_string,i.var_name,i.var_value);
    end loop;

    return source_string;

  end replace_script_token_variables;
-------------------------------------
-- PROCEDURE OVERLOADED DO NOT MODIFY
-------------------------------------
PROCEDURE GET_SCRIPT_PRC
  ( ip_sourcesystem IN VARCHAR2, --WEB,NETWEB or (WEBCSR,NETCSR,ALL) last group is considered the same, required
    ip_script_type  IN VARCHAR2, --required
    ip_script_id    IN VARCHAR2, -- if null it is assume to be part script
    ip_language     IN VARCHAR2, -- required
    ip_carrier_id   IN VARCHAR2, -- objid carrier null carrier ==> look by part_class
    ip_part_class   IN VARCHAR2, -- null part class ==> look generic
    op_objid OUT VARCHAR2,
    op_description OUT VARCHAR2,
    op_script_text OUT VARCHAR2,
    op_publish_by OUT VARCHAR2,
    op_publish_date OUT DATE,
    op_sm_link OUT VARCHAR2)

IS
  cursor part_class_cur(p_class_name varchar2) is
  select name
  from table_part_class
  where name = p_class_name;

  part_class_rec1 part_class_cur%rowtype;

  cursor pn_pc_cur(p_part_num varchar2) is
  select name
  from table_part_class, table_part_num
  where part_num2part_class = table_part_class.objid
  and part_number = p_part_num;

  part_class_rec2 pn_pc_cur%rowtype;

  CURSOR part_script_cur (c_script_type IN VARCHAR2, c_part_class_name IN VARCHAR2,c_language IN VARCHAR2)
                                        IS
     SELECT x_script_text
       FROM table_x_part_script sc,
      table_part_num pn           ,
      table_part_class pc
      WHERE sc.x_type LIKE c_script_type
    AND sc.part_script2part_num = pn.objid
    AND pn.part_num2part_class  = pc.objid
    AND pc.name                 = c_part_class_name
    AND upper(sc.x_language)    = upper(c_language)
    AND ROWNUM                  < 2;

  part_script_rec part_script_cur%rowtype;

  CURSOR carrier_script_cur (c_carrier_id IN NUMBER,c_sourcesystem IN VARCHAR2, c_script_type IN VARCHAR2, c_script_id IN VARCHAR2,c_language IN VARCHAR2)
                                          IS
     SELECT sa.table_x_scripts.*
       FROM sa.table_x_scripts     ,
      sa.MTM_X_CARRIER34_X_SCRIPTS0,
      sa.table_x_carrier
      WHERE sa.mtm_x_carrier34_x_scripts0.carrier2script= sa.table_x_carrier.objid
    AND sa.mtm_x_carrier34_x_scripts0.script2carrier    = sa.table_x_scripts.objid
    AND sa.table_x_carrier.objid                        = to_number(c_carrier_id)
    AND sa.table_x_scripts.x_script_type                = c_script_type
    AND sa.table_x_scripts.x_script_id                  = c_script_id
    AND sa.TABLE_X_SCRIPTS.X_LANGUAGE                   = C_LANGUAGE
    AND (sa.table_x_scripts.x_sourcesystem              = decode(c_sourcesystem, 'WAP','WEB',c_sourcesystem)    -- PMistry CR15166 07/01/2010 WAP Redemption.
    -- CR21961 VAS_APP                                  -- SMEGANATHAN CR35913 Removed 'APP' from the above decode stmnt. for MY account phase2
    OR sa.table_x_scripts.x_sourcesystem                = 'ALL')
    AND sa.table_x_scripts.SCRIPT2BUS_ORG IS NULL
   ORDER BY sa.table_x_scripts.x_sourcesystem desc, sa.table_x_scripts.x_published_date DESC;
  CURSOR part_class_script_cur (c_part_class_name IN VARCHAR2,c_sourcesystem IN VARCHAR2, c_script_type IN VARCHAR2, c_script_id IN VARCHAR2,c_language IN VARCHAR2)
                                                  IS

     SELECT sa.table_x_scripts.*
       FROM sa.TABLE_X_SCRIPTS     ,
      sa.MTM_PART_CLASS6_X_SCRIPTS1,
      sa.table_part_class
      WHERE sa.MTM_PART_CLASS6_X_SCRIPTS1.PART_CLASS2SCRIPT=sa.table_part_class.objid
    AND sa.MTM_PART_CLASS6_X_SCRIPTS1.SCRIPT2PART_CLASS    = sa.table_x_scripts.objid
    AND sa.table_x_scripts.x_script_type                   = c_script_type
    AND sa.table_x_scripts.x_script_id                     = c_script_id
    AND sa.table_x_scripts.x_language                      = c_language
    AND sa.table_part_class.name                           = c_part_class_name
    AND (sa.table_x_scripts.x_sourcesystem                 = decode(c_sourcesystem, 'WAP','WEB',c_sourcesystem)    -- PMistry CR15166 07/01/2010 WAP Redemption.
    -- CR21961 VAS_APP                                     -- SMEGANATHAN CR35913 Removed 'APP' from the above decode stmnt. for MY account phase2
    OR sa.table_x_scripts.x_sourcesystem                   = 'ALL')
    AND sa.table_x_scripts.SCRIPT2BUS_ORG IS NULL
   ORDER BY sa.table_x_scripts.x_sourcesystem desc, sa.table_x_scripts.x_published_date DESC;
  CURSOR generic_script_cur (c_sourcesystem IN VARCHAR2, c_script_type IN VARCHAR2, c_script_id IN VARCHAR2,c_language IN VARCHAR2)
                                            IS
     SELECT sa.table_x_scripts.*
       FROM sa.TABLE_X_SCRIPTS
      WHERE sa.table_x_scripts.x_script_type = c_script_type
    AND sa.table_x_scripts.x_script_id       = c_script_id
    AND sa.table_x_scripts.x_language        = c_language
    AND NOT EXISTS (SELECT 1  FROM sa.MTM_PART_CLASS6_X_SCRIPTS1 where sa.MTM_PART_CLASS6_X_SCRIPTS1.SCRIPT2PART_CLASS = sa.TABLE_X_SCRIPTS.OBJID)
 AND (sa.table_x_scripts.x_sourcesystem = decode(c_sourcesystem, 'WAP','WEB',c_sourcesystem)    -- PMistry CR15166 07/01/2010 WAP Redemption.
 --CR21961 VAS_APP                      -- SMEGANATHAN CR35913 Removed 'APP' from the above decode stmnt. for MY account phase2
  OR sa.table_x_scripts.x_sourcesystem   = 'ALL')
  AND sa.table_x_scripts.SCRIPT2BUS_ORG IS NULL
 ORDER BY sa.table_x_scripts.x_sourcesystem desc, sa.table_x_scripts.x_published_date DESC;

  script_rec sa.table_x_scripts%rowtype;
  v_sourcesystem VARCHAR2(20);
  v_language     VARCHAR2(20);
  trace          VARCHAR2(200);
  script_temp    VARCHAR2(10000);
  class_name     VARCHAR2(100);

BEGIN
  v_sourcesystem         := NVL(ip_sourcesystem,'ALL');
  v_language             := upper(NVL(ip_language,'ENGLISH'));

  class_name:= ip_part_class;

  open part_class_cur (ip_part_class);
  fetch part_Class_cur into part_class_rec1;
  if part_class_cur%notfound then
     open pn_pc_cur(ip_part_class);
     fetch pn_pc_cur into part_class_rec2;
     if pn_pc_cur%found then
         class_name:= part_class_rec2.name;
     end if;
     close pn_pc_cur;
  end if;
  close part_class_cur;


  IF ip_script_id is null THEN -- Requesting Part Script
    OPEN part_script_cur(ip_script_type,class_name,ip_language);
    FETCH part_script_cur INTO part_script_rec;
    IF part_script_cur%found THEN
      script_temp    := part_script_rec.x_script_text;
      op_objid       :='N/A';
      op_description :='PART_SCRIPT';
      op_script_text := script_temp;
      op_publish_by  := 'N/A';
      op_publish_date:= to_date('1-jan-1753');
      op_sm_link  := null;
    ELSE
      op_objid       :='N/A';
      op_description :='PART_SCRIPT';
      op_script_text := 'SCRIPT MISSING: '||NVL(ip_script_type,'')||' '||NVL(class_name,'')||' '||NVL(ip_language,'');
      op_publish_by  := 'N/A';
      op_publish_date:= to_date('1-jan-1753');
      op_sm_link  := null;
    END IF;
    CLOSE part_script_cur;
  ELSE
    IF ip_carrier_id IS NOT NULL THEN -- looking by carrier
      OPEN carrier_script_cur (to_number(ip_carrier_id), v_sourcesystem, ip_script_type, ip_script_id, v_language);
      FETCH carrier_script_cur INTO script_rec;
      IF carrier_script_cur%found THEN
        op_objid       :=script_rec.objid;
        op_description :=script_rec.x_description;
        op_script_text :=script_rec.x_script_text;
        op_publish_by  := script_rec.x_published_by;
        op_publish_date:= script_rec.x_published_date;
        op_sm_link  := script_rec.x_script_manager_link;
      ELSE
        OPEN generic_script_cur (v_sourcesystem, ip_script_type, ip_script_id, v_language);
        FETCH generic_script_cur INTO script_rec;
        IF generic_script_cur%found THEN
          op_objid       :=script_rec.objid;
          op_description :=script_rec.x_description;
          op_script_text :=script_rec.x_script_text;
          op_publish_by  := script_rec.x_published_by;
          op_publish_date:= script_rec.x_published_date;
          op_sm_link  := script_rec.x_script_manager_link;
        ELSE
          op_objid       :='N/A';
          op_description :='N/A';
          op_script_text := 'SCRIPT MISSING: '||NVL(ip_script_type,'')||'_'||NVL(ip_script_id,'')||' CARR:'||NVL(ip_carrier_id,'')||' '||NVL(ip_language,'')||' '||v_sourcesystem;
          op_publish_by  := 'N/A';
          op_publish_date:= to_date('1-jan-1753');
          op_sm_link  := null;
        END IF;
        CLOSE generic_script_cur;
      END IF;
      CLOSE carrier_script_cur;
    ELSE                                -- not looking by carrier
      IF class_name IS NOT NULL THEN -- looking by model
        OPEN part_class_script_cur (class_name, v_sourcesystem, ip_script_type, ip_script_id, v_language);
        FETCH part_class_script_cur INTO script_rec;
        IF part_class_script_cur%found THEN
          op_objid       :=script_rec.objid;
          op_description :=script_rec.x_description;
          op_script_text :=script_rec.x_script_text;
          op_publish_by  := script_rec.x_published_by;
          op_publish_date:= script_rec.x_published_date;
          op_sm_link  := script_rec.x_script_manager_link;
        ELSE
          OPEN generic_script_cur (v_sourcesystem, ip_script_type, ip_script_id, v_language);
          FETCH generic_script_cur INTO script_rec;
          IF generic_script_cur%found THEN
            op_objid       :=script_rec.objid;
            op_description :=script_rec.x_description;
            op_script_text :=script_rec.x_script_text;
            op_publish_by  := script_rec.x_published_by;
            op_publish_date:= script_rec.x_published_date;
            op_sm_link  := script_rec.x_script_manager_link;
          ELSE
            op_objid       :='N/A';
            op_description :='N/A';
            op_script_text := 'SCRIPT MISSING: '||NVL(ip_script_type,'')||'_'||NVL(ip_script_id,'')||' '||NVL(class_name,'')||' '||NVL(ip_language,'')||' '||v_sourcesystem;
            op_publish_by  := 'N/A';
            op_publish_date:= to_date('1-jan-1753');
            op_sm_link  := null;
          END IF;
          CLOSE generic_script_cur;
        END IF ;
        CLOSE part_class_script_cur;
      ELSE -- looking by generic
        OPEN generic_script_cur (v_sourcesystem, ip_script_type, ip_script_id, v_language);
        FETCH generic_script_cur INTO script_rec;
        IF generic_script_cur%found THEN
          op_objid       :=script_rec.objid;
          op_description :=script_rec.x_description;
          op_script_text :=script_rec.x_script_text;
          op_publish_by  := script_rec.x_published_by;
          op_publish_date:= script_rec.x_published_date;
          op_sm_link  := script_rec.x_script_manager_link;
        ELSE
          op_objid       :='N/A';
          op_description :='N/A';
          op_script_text := 'SCRIPT MISSING: '||NVL(ip_script_type,'')||'_'||NVL(ip_script_id,'')||' '||NVL(ip_language,'')||' '||v_sourcesystem;
          op_publish_by  := 'N/A';
          op_publish_date:= to_date('1-jan-1753');
          op_sm_link  := null;
        END IF;
        CLOSE generic_script_cur;
      END IF;
    END IF;
  END IF;
END;


PROCEDURE get_script_prc
  (
    ip_sourcesystem IN VARCHAR2, --WEB,WEBCSR,ALL
    ip_brand_name   IN VARCHAR2 default 'GENERIC', --TRACFONE,NET10,STRAIGHT_TALK
    ip_script_type  IN VARCHAR2, --required
    ip_script_id    IN VARCHAR2, -- if null it is assume to be part script
    ip_language     IN VARCHAR2 default 'ENGLISH', -- required
    ip_carrier_id   IN VARCHAR2, -- objid carrier null carrier ==> look by part_class
    ip_part_class   IN VARCHAR2, -- null part class ==> look generic
    op_objid        OUT VARCHAR2,
    op_description  OUT VARCHAR2,
    op_script_text  OUT VARCHAR2,
    op_publish_by   OUT VARCHAR2,
    op_publish_date OUT DATE,
    op_sm_link      OUT VARCHAR2) IS

script_rec sa.table_x_scripts%rowtype;
  CURSOR part_script_cur is
    SELECT x_script_text
    FROM table_x_part_script sc,
         table_part_num pn           ,
         table_part_class pc
    WHERE sc.x_type = ip_script_type
    AND sc.part_script2part_num = pn.objid
    AND pn.part_num2part_class  = pc.objid
    AND pc.name                 = ip_part_class
    AND upper(sc.x_language)    = upper(nvl(ip_language,'ENGLISH'))
    AND ROWNUM                  < 2;
    part_script_rec part_script_cur%rowtype;

  CURSOR carrier_script_cur is
     SELECT xs.*
       FROM sa.table_x_scripts xs,
      sa.MTM_X_CARRIER34_X_SCRIPTS0 mtm,
      sa.table_x_carrier xc
      WHERE mtm.carrier2script= xc.objid
    AND mtm.script2carrier    = xs.objid
    AND xc.objid              = to_number(ip_carrier_id)
    AND xs.x_script_type      = ip_script_type
    AND xs.x_script_id        = ip_script_id
    AND XS.X_LANGUAGE         = NVL(IP_LANGUAGE,'ENGLISH')
    AND (xs.x_sourcesystem    = decode(ip_sourcesystem, 'WAP','WEB',ip_sourcesystem)    -- PMistry CR15166 07/01/2010 WAP Redemption.
    -- CR21961 VAS_APP        -- SMEGANATHAN CR35913 Removed 'APP' from the above decode stmnt. for MY account phase2
    OR xs.x_sourcesystem      = 'ALL')
    AND xs.SCRIPT2BUS_ORG IS not NULL
   ORDER BY xs.x_sourcesystem desc, xs.x_published_date DESC;


   CURSOR part_class_script_cur is
     SELECT xs.*
       FROM sa.TABLE_X_SCRIPTS xs,
      sa.MTM_PART_CLASS6_X_SCRIPTS1 mtm,
      sa.table_part_class pc
      WHERE MTM.PART_CLASS2SCRIPT=pc.objid
    AND MTM.SCRIPT2PART_CLASS    = xs.objid
    AND xs.x_script_type         = ip_script_type
    AND xs.x_script_id           = ip_script_id
    AND xs.x_language            = nvl(ip_language,'ENGLISH')
    AND pc.name                  = ip_part_class
    AND (xs.x_sourcesystem       = decode(ip_sourcesystem, 'WAP','WEB',ip_sourcesystem)    -- PMistry CR15166 07/01/2010 WAP Redemption.
    -- CR21961 VAS_APP           -- SMEGANATHAN CR35913 Removed 'APP' from the above decode stmnt. for MY account phase2
    OR xs.x_sourcesystem         = 'ALL')
    AND xs.SCRIPT2BUS_ORG IS not NULL
   ORDER BY xs.x_sourcesystem desc, xs.x_published_date DESC;




procedure populate_script_notfound is
BEGIN
      op_objid       :='N/A';
      op_description :='N/A';
      op_description :='PART_SCRIPT';
      op_publish_by  := 'N/A';
      op_publish_date:= to_date('1-jan-1753');
      op_sm_link  := null;
      op_script_text := 'SCRIPT MISSING: '||NVL(ip_script_type,'')||
                        '_'||NVL(ip_script_id,'')||' CARR:'||
                        NVL(ip_carrier_id,'')||' '||NVL(ip_language,'')||
                        ' '||ip_sourcesystem;

END;
FUNCTION get_generic_script(ip_brand_name in varchar2) RETURN boolean is
 CURSOR generic_script_cur IS
    SELECT xs.*
    FROM sa.TABLE_X_SCRIPTS xs,
         sa.TABLE_BUS_ORG bo
    WHERE xs.x_script_type = ip_script_type
    AND xs.x_script_id     = ip_script_id
    AND xs.x_language      = nvl(ip_language,'ENGLISH')
    AND xs.SCRIPT2BUS_ORG  = bo.objid
    AND bo.name            = ip_brand_name
    AND (xs.x_sourcesystem = decode(ip_sourcesystem, 'WAP','WEB',ip_sourcesystem)    -- PMistry CR15166 07/01/2010 WAP Redemption.
    -- CR21961 VAS_APP      -- SMEGANATHAN CR35913 Removed 'APP' from the above decode stmnt. for MY account phase2
      OR xs.x_sourcesystem   = 'ALL')
    AND NOT EXISTS (SELECT 1  FROM sa.MTM_PART_CLASS6_X_SCRIPTS1 mtm
                    WHERE mtm.SCRIPT2PART_CLASS = xs.OBJID)
    ORDER BY xs.x_sourcesystem desc, xs.x_published_date DESC;


begin
     OPEN generic_script_cur;
     FETCH generic_script_cur INTO script_rec;
     IF generic_script_cur%found THEN
          op_objid       :=script_rec.objid;
          op_description :=script_rec.x_description;
          op_script_text :=script_rec.x_script_text;
          op_publish_by  := script_rec.x_published_by;
          op_publish_date:= script_rec.x_published_date;
          op_sm_link     := script_rec.x_script_manager_link;
          CLOSE generic_script_cur;
     ELSIF  ip_brand_name <> 'GENERIC' then
        CLOSE generic_script_cur;
        return(get_generic_script('GENERIC'));
     ELSE
        CLOSE generic_script_cur;
        return false;
     END IF;
  return true;
end;


begin

IF ip_script_id is null THEN  -- looking by Part Script
    OPEN part_script_cur;
    FETCH part_script_cur INTO part_script_rec;
    IF part_script_cur%FOUND THEN
      op_objid       :='N/A';
      op_description :='PART_SCRIPT';
      op_script_text := part_script_rec.x_script_text;
      op_publish_by  := 'N/A';
      op_publish_date:= to_date('1-jan-1753');
      op_sm_link  := null;
    ELSE
      populate_script_notfound;
    END IF;
    CLOSE part_script_cur;
ELSIF ip_carrier_id IS NOT NULL THEN -- looking by carrier
      OPEN carrier_script_cur ;
      FETCH carrier_script_cur INTO script_rec;
      IF carrier_script_cur%FOUND THEN
        op_objid       :=script_rec.objid;
        op_description :=script_rec.x_description;
        op_script_text :=script_rec.x_script_text;
        op_publish_by  := script_rec.x_published_by;
        op_publish_date:= script_rec.x_published_date;
        op_sm_link  := script_rec.x_script_manager_link;
      ELSE
        IF not get_generic_script(ip_brand_name) then
           populate_script_notfound;
        END IF;
      END IF;
      CLOSE carrier_script_cur ;

ELSIF ip_part_class IS NOT NULL THEN -- looking by model
    OPEN part_class_script_cur ;
    FETCH part_class_script_cur INTO script_rec;
    IF part_class_script_cur%found THEN
          op_objid       :=script_rec.objid;
          op_description :=script_rec.x_description;
          op_script_text :=script_rec.x_script_text;
          op_publish_by  := script_rec.x_published_by;
          op_publish_date:= script_rec.x_published_date;
          op_sm_link  := script_rec.x_script_manager_link;
    ELSE
        if (not get_generic_script(ip_brand_name)) then
           populate_script_notfound;
        end if;
    END IF;
    CLOSE part_class_script_cur ;

ELSE -- looking by generic
   if (not get_generic_script(ip_brand_name)) then
       populate_script_notfound;
   end if;
END IF;
END;
procedure sp_error_code2script(error_code varchar2,
                               func varchar2,
                               flow varchar2,
                               script_name in out varchar2,
                               script_text in varchar2,
                               prefix in varchar2 ) is
   print_debug boolean := true;
   save_ec varchar2(30);
   save_func varchar2(100);
   save_flow varchar2(100);
   v_ec varchar2(30):= nvl(upper(error_code),'ALL');
   v_func varchar2(100):= nvl(upper(func),'ALL');
   v_flow varchar2(100):= nvl(upper(flow),'ALL');
   v_script_name varchar2(30) := nvl(upper(script_name),'ALL');
   v_ret varchar2(40);
   v_ins boolean := false;
--   upd_stmt varchar2(300);
   iter number := 0;
   ins_stmt varchar2(400):= 'insert into sa.x_rqst_mapping( objid';
   ins_val varchar2(400) := 'values ( sa.rqst_mapping_seq.nextval';
function scriptExists(p_script in varchar2) return boolean is
  var  varchar2(100):= '-1';
begin
   select p_script
   into var
   from sa.table_x_scripts
   where x_script_type  = substr(p_script,1,instr(p_script,'_')-1)
   and   x_script_id = substr(p_script,instr(p_script,'_')+1)
   and rownum <2;

   return true;
exception
   when others then
     return false;
end;
begin
<<repeat>>
  begin
     if print_debug then
        dbms_output.put_line ( '============================');
        if v_ins then
          dbms_output.put_line ( iter||' Iteration'||' Ins=true ');
        else
          dbms_output.put_line ( iter||' Iteration'||' Ins=FALSE ');
        end if;
        dbms_output.put_line ( 'v_func='||v_func);
        dbms_output.put_line ( 'v_flow='||v_flow);
        dbms_output.put_line ( 'v_ec='||v_ec);
        dbms_output.put_line ( 'v_script_name='||v_script_name);
        --dbms_output.put_line ( 'v_script_name='||v_script_name||chr(10));
     end if;


   select b.x_script_name
   into v_ret
   from sa.x_mapping_tbl b,
        sa.x_flows c,
        sa.x_error_codes d,
        sa.x_functions e
   where b.x_script_name = decode(v_script_name,'ALL',b.x_script_name,v_script_name)
   and   b.x_flow_objid  = c.x_flow_objid(+)
   and   b.x_error_objid = d.x_error_objid(+)
   and   b.x_func_objid  = e.x_func_objid(+)
   and   d.x_error_code in (v_ec,upper(error_code))
   and   e.x_func_name in ( v_func,upper(func))
   and   c.x_flow_name in (v_flow,upper(flow))
   and rownum < 2;
   dbms_output.put_line ( 'Iter '||iter||' ret='||v_ret);

   if (iter <> 0 and iter < 4 ) and v_ins = true then
        raise no_data_found;
   end if;

  exception
     when no_data_found then
      v_ins := true;
      if iter = 0 then
          ins_stmt := ins_stmt||',x_func_name';
          ins_val := ins_val||','''||v_func||'''';
          v_func := 'ALL';
          iter := iter +1;
          goto repeat;
      elsif iter = 1 then
          ins_stmt := ins_stmt||',x_flow_name';
          ins_val := ins_val||','''||v_flow||'''';
          iter := iter +1;
          v_flow := 'ALL';
          goto repeat;
      elsif iter = 2 then
          ins_stmt := ins_stmt||',x_error_code';
          ins_val := ins_val||','''||v_ec||'''';
          iter := iter +1;
          v_ec := 'ALL';
          goto repeat;
      elsif iter = 3 then
          if (v_script_name <> 'ALL') then
               ins_stmt := ins_stmt||',x_script_name';
               ins_val := ins_val||','''||script_name||'''';
               iter := iter +1;
               goto repeat;
          end if;
      end if;
  end;
  if v_ins then
       begin
         if print_debug = true then
            dbms_output.put_line(ins_stmt||',x_script_text)'||
                             ins_val||','''||script_text||''')');
         end if;
         execute immediate ins_stmt||',x_script_text)'||ins_val||','''||script_text||''')';
       exception
         when dup_val_on_index then
            null;
         when others then
            if (print_debug) then
                dbms_output.put_line('Inserting - '||sqlerrm);
            end if;
       end;
  end if;
        dbms_output.put_line ( 'v_ret='||v_ret);
  if ( v_ret is not null ) then
      if ( v_func = 'ALL' or v_flow = 'ALL' or v_ec = 'ALL' ) then
             script_name := prefix||v_ret;
      else
             script_name := v_ret;
      end if;

  elsif (not scriptExists(v_script_name)) then
      script_name := null;
  end if;
end sp_error_code2script;


procedure sp_error_code2script(error_code varchar2,
                               func varchar2,
                               flow varchar2,
                               script_name in out varchar2,
                               script_text in varchar2) is
   print_debug boolean := true;
   save_ec varchar2(30);
   save_func varchar2(100);
   save_flow varchar2(100);
   v_ec varchar2(30):= nvl(upper(error_code),'ALL');
   v_func varchar2(100):= nvl(upper(func),'ALL');
   v_flow varchar2(100):= nvl(upper(flow),'ALL');
   v_script_name varchar2(30) := nvl(upper(script_name),'ALL');
   v_ret varchar2(40);
   v_ins boolean := false;
--   upd_stmt varchar2(300);
   iter number := 0;
   ins_stmt varchar2(400):= 'insert into sa.x_rqst_mapping( objid';
   ins_val varchar2(400) := 'values ( sa.rqst_mapping_seq.nextval';
function scriptExists(p_script in varchar2) return boolean is
  var  varchar2(100):= '-1';
begin
   select p_script
   into var
   from sa.table_x_scripts
   where x_script_type  = substr(p_script,1,instr(p_script,'_')-1)
   and   x_script_id = substr(p_script,instr(p_script,'_')+1)
   and rownum <2;

   return true;
exception
   when others then
     return false;
end;
begin
<<repeat>>
  begin
     if print_debug then
        dbms_output.put_line ( '============================');
        if v_ins then
          dbms_output.put_line ( iter||' Iteration'||' Ins=true ');
        else
          dbms_output.put_line ( iter||' Iteration'||' Ins=FALSE ');
        end if;
        dbms_output.put_line ( 'v_func='||v_func);
        dbms_output.put_line ( 'v_flow='||v_flow);
        dbms_output.put_line ( 'v_ec='||v_ec);
        dbms_output.put_line ( 'v_script_name='||v_script_name);
        --dbms_output.put_line ( 'v_script_name='||v_script_name||chr(10));
     end if;


   select b.x_script_name
   into v_ret
   from sa.x_mapping_tbl b,
        sa.x_flows c,
        sa.x_error_codes d,
        sa.x_functions e
   where b.x_script_name = decode(v_script_name,'ALL',b.x_script_name,v_script_name)
   and   b.x_flow_objid  = c.x_flow_objid(+)
   and   b.x_error_objid = d.x_error_objid(+)
   and   b.x_func_objid  = e.x_func_objid(+)
   and   d.x_error_code in (v_ec,upper(error_code))
   and   e.x_func_name in ( v_func,upper(func))
   and   c.x_flow_name in (v_flow,upper(flow))
   and rownum < 2;
   dbms_output.put_line ( 'Iter '||iter||' ret='||v_ret);

   if (iter <> 0 and iter < 4 ) and v_ins = true then
        raise no_data_found;
   end if;

  exception
     when no_data_found then
      v_ins := true;
      if iter = 0 then
          ins_stmt := ins_stmt||',x_func_name';
          ins_val := ins_val||','''||v_func||'''';
          v_func := 'ALL';
          iter := iter +1;
          goto repeat;
      elsif iter = 1 then
          ins_stmt := ins_stmt||',x_flow_name';
          ins_val := ins_val||','''||v_flow||'''';
          iter := iter +1;
          v_flow := 'ALL';
          goto repeat;
      elsif iter = 2 then
          ins_stmt := ins_stmt||',x_error_code';
          ins_val := ins_val||','''||v_ec||'''';
          iter := iter +1;
          v_ec := 'ALL';
          goto repeat;
      elsif iter = 3 then
          if (v_script_name <> 'ALL') then
               ins_stmt := ins_stmt||',x_script_name';
               ins_val := ins_val||','''||script_name||'''';
               iter := iter +1;
               goto repeat;
          end if;
      end if;
  end;
  if v_ins then
       begin
         if print_debug = true then
            dbms_output.put_line(ins_stmt||',x_script_text)'||
                             ins_val||','''||script_text||''')');
         end if;
         execute immediate ins_stmt||',x_script_text)'||ins_val||','''||script_text||''')';
       exception
         when dup_val_on_index then
            null;
         when others then
            if (print_debug) then
                dbms_output.put_line('Inserting - '||sqlerrm);
            end if;
       end;
  end if;
        dbms_output.put_line ( 'v_ret='||v_ret);
  if ( v_ret is not null ) then
     script_name := v_ret;

  elsif (not scriptExists(v_script_name)) then
      script_name := null;
  end if;
end sp_error_code2script;

  procedure get_error_map_script (ip_func_name varchar2, -- USE THE METHOD NAME
                                  ip_flow_name varchar2, -- USE THE PERMISSION NAME
                                  ip_error_code varchar2, -- USE W/E NUMBER
                                  ip_default_msg varchar2, -- DEFAULT ERROR MESSAGE
                                  ip_default_script_id varchar2, -- OPTIONAL
                                  ip_brand varchar2, -- TRACFONE,NET10,STRAIGHT_TALK (TO OBTAIN SCRIPT)
                                  ip_language varchar2, -- ENGLISH,SPANISH
                                  ip_source_system varchar2, --
                                  ip_part_class varchar2, -- OPTIONAL FOR PART CLASS ERROR SCRIPT
                                  ip_replace_tokens varchar2, -- Y OR N - FLAG TO REPLACE VARIABLES EXAMPLE [COMPANY_NAME]
                                  op_script_text out varchar2)
  as
    v_prefix varchar2(30);
    v_suffix varchar2(30);
    v_map_text varchar2(200);
    v_default_script_id varchar2(30) := ip_default_script_id;
    v_default_msg_in_table sa.x_rqst_mapping.x_script_text%type;
    v_error_code  sa.x_rqst_mapping.x_error_code%type := ip_error_code;
    op_objid varchar2(200);
    op_description varchar2(200);
    op_publish_by varchar2(200);
    op_publish_date date;
    op_sm_link varchar2(200);
  begin
  	-- ADDRESSING ISSUE FROM DEFECT BRANCH.Branch_2015 - Defect #3334 - CR36345
  	-- WHICH GAVE ISSUES IN SIT1 ON 7/9/2015
  	-- ISSUE CAME WHEN A DUPLICATE ERROR+FUNC+FLOW IS EXECUTED WITH A DIFFERENT MESSAGE
  	-- IN THE CASE OF THE DEFECT THERE ARE TWO DIFFERENT MESSAGES IN THE SOA SERVICE
  	-- THAT HAVE THE SAME KEY
  	-- TO SOLVE THIS UNCOMMON ISSUE, WE COMPARE THE MESSAGE COMING IN TO WHAT'S IN
  	-- THE DATABASE AND IF A MATCH IS NOT FOUND, WE CREATE A NEW ENTRY BASED OF THE
  	-- ERROR NUMBER + LENGTH OF THE MESSAGE PROVIDED

    select substr(x_script_name,0,instr(x_script_name,'_')-1) prefix,
           substr(x_script_name,instr(x_script_name,'_')+1) suffix,
           nvl(x_script_text,'MISSING SCRIPT - FLOW: '||x_flow_name||' - FUNC: '||x_func_name||' - ERROR: '||x_error_code) mapping_text,
           x_script_text
    into   v_prefix,v_suffix,v_map_text,v_default_msg_in_table
    from   x_rqst_mapping a
    where 1=1
    and x_error_code = ip_error_code
    and x_func_name  = ip_func_name
    and x_flow_name  = ip_flow_name
    and rownum <2;

    if v_default_msg_in_table != ip_default_msg then
      v_error_code := ip_error_code+length(ip_default_msg);
      select substr(x_script_name,0,instr(x_script_name,'_')-1) prefix,
             substr(x_script_name,instr(x_script_name,'_')+1) suffix,
             nvl(x_script_text,'MISSING SCRIPT - FLOW: '||x_flow_name||' - FUNC: '||x_func_name||' - ERROR: '||x_error_code) mapping_text,
             x_script_text
      into   v_prefix,v_suffix,v_map_text,V_default_msg_in_table
      from   x_rqst_mapping a
      where 1=1
      and x_error_code = v_error_code
      and x_func_name  = ip_func_name
      and x_flow_name  = ip_flow_name
      and rownum <2;
    end if;

    if v_prefix is not null then
      dbms_output.put_line('FOUND SCRIPT ID = ' || v_prefix||'_'||v_suffix);
      scripts_pkg.get_script_prc (ip_sourcesystem => ip_source_system,
                                  ip_brand_name => ip_brand,
                                  ip_script_type => v_prefix,
                                  ip_script_id => v_suffix,
                                  ip_language => ip_language,
                                  ip_carrier_id => null,
                                  ip_part_class => ip_part_class,
                                  op_objid => op_objid,
                                  op_description => op_description,
                                  op_script_text => op_script_text,
                                  op_publish_by => op_publish_by,
                                  op_publish_date => op_publish_date,
                                  op_sm_link => op_sm_link);
    else
      -- dbms_output.put_line('NO SCRIPT ID DEFAULT TEXT = ' || v_map_text);
      op_script_text := v_map_text;
    end if;

    if ip_replace_tokens = 'Y' then
      op_script_text := replace_script_token_variables (ip_script_text => op_script_text,
                                        ip_bus_org => ip_brand,
                                        ip_language => ip_language);
    end if;

  --  dbms_output.put_line('OP_OBJID = ' || op_objid);
  --  dbms_output.put_line('OP_DESCRIPTION = ' || op_description);
  --  dbms_output.put_line('OP_SCRIPT_TEXT = ' || op_script_text);
  --  dbms_output.put_line('OP_PUBLISH_BY = ' || op_publish_by);
  --  dbms_output.put_line('OP_PUBLISH_DATE = ' || op_publish_date);
  --  dbms_output.put_line('OP_SM_LINK = ' || op_sm_link);

  exception
    when others then
      -- this should happen primarily when no data found
      scripts_pkg.sp_error_code2script(error_code => v_error_code,
                                       func => ip_func_name,
                                       flow => ip_flow_name,
                                       script_name => v_default_script_id,
                                       script_text => ip_default_msg);
      --Retrieve default message April 2014
	  op_script_text := ip_default_msg;
  end get_error_map_script;

  /*=============== PROCEDURE GET_SCRIPT_DETAILS ===============*/
PROCEDURE GET_SCRIPT_DETAILS( IP_SCRIPT_VALUES	IN VARCHAR2,
                              IP_LANGUAGE 		IN VARCHAR2,
                              IP_SOURCESYSTEM 	IN VARCHAR2,
                              OP_RESULT_SET		OUT SYS_REFCURSOR,
                              OP_ERRORNUM	 		OUT VARCHAR2,
                              OP_ERRORMSG	 		OUT VARCHAR2) IS
BEGIN
  OP_ERRORNUM := '0';
  OP_ERRORMSG := '';

  OPEN OP_RESULT_SET FOR
    SELECT DISTINCT SCRIPT_TYPE || '_' || SCRIPT_ID || ',' || X_SCRIPT_TEXT SCRIPT_RESULT
      FROM (SELECT substr(SCRIPT_VALUES,1,instr(s.SCRIPT_VALUES,'_')-1) SCRIPT_TYPE,
                   substr(SCRIPT_VALUES,instr(s.SCRIPT_VALUES,'_')+1) SCRIPT_ID,
                    ip_language LANGUAGE,
                    ip_sourcesystem SOURCESYSTEM
              FROM (SELECT regexp_substr(ip_script_values,'[^,]+', 1, level) SCRIPT_VALUES,
                           ip_language LANGUAGE,
                           ip_sourcesystem SOURCESYSTEM
                      from dual
                   connect by regexp_substr(ip_script_values, '[^,]+', 1, level) is not null) s) s,
           TABLE_X_SCRIPTS t
     WHERE s.SCRIPT_ID = t.X_SCRIPT_ID
       AND s.SCRIPT_TYPE = t.X_SCRIPT_TYPE
       AND s.LANGUAGE = t.X_LANGUAGE
       AND s.SOURCESYSTEM= t.X_SOURCESYSTEM;

EXCEPTION WHEN OTHERS THEN
  OP_ERRORNUM := SQLCODE;
  OP_ERRORMSG := SQLCODE || SUBSTR (SQLERRM, 1, 100);
  INSERT INTO sa.X_PROGRAM_ERROR_LOG
	(X_SOURCE,
	X_ERROR_CODE,
	X_ERROR_MSG,
	X_DATE,
	X_DESCRIPTION,
	X_SEVERITY)
	VALUES
	('SCRIPTS_PKG.GET_SCRIPT_DETAILS',
	OP_ERRORNUM,
	OP_ERRORMSG,
	SYSDATE,
	'SCRIPTS_PKG.GET_SCRIPT_DETAILS',
	2 -- MEDIUM
	);
END;
--
-- CR35913 changes starts..
-- Added the below procedure to get the script text from table_x_scripts, in addition to the functionality of sp_error_code2script
PROCEDURE p_get_error_script_text( ip_brand         IN      VARCHAR2,
                                   ip_source_system IN      VARCHAR2,
                                   ip_language      IN      VARCHAR2 default 'ENGLISH',  --CR44680 - Getting Language as Input param
                                   ip_error_code    IN      VARCHAR2,
                                   ip_func          IN      VARCHAR2,
                                   ip_flow          IN      VARCHAR2,
                                   io_script_name   IN OUT  VARCHAR2,
                                   ip_script_type   IN      VARCHAR2,
                                   io_script_text   IN OUT  VARCHAR2)
IS
--
CURSOR script_text_cur(in_brand VARCHAR2, in_source_system VARCHAR2, in_script_id VARCHAR2, in_script_type VARCHAR2) IS
  SELECT x_script_text
    FROM
    (
      SELECT sr.x_script_text,
             row_number() OVER (ORDER BY sr.x_published_date, sr.objid DESC) rn
        FROM table_bus_org  bo,
             table_x_scripts sr
       WHERE sr.script2bus_org  = bo.objid
         AND bo.NAME            = in_brand
         AND sr.x_sourcesystem  = in_source_system
         AND sr.x_script_type   = in_script_type
         AND sr.x_script_id     = in_script_id
         AND sr.x_language      = ip_language  --CR44680
    )
  WHERE rn = 1;
  --
  l_script_id    table_x_scripts.x_script_id%TYPE;
  l_script_type  table_x_scripts.x_script_type%TYPE;
  l_script_text  table_x_scripts.x_script_text%TYPE;
BEGIN
  -- Get the Script Name
  sp_error_code2script(error_code 	=> ip_error_code,
                       func         => ip_func,
                       flow         => ip_flow,
                       script_name 	=> io_script_name,
                       script_text 	=> io_script_text);
  --
  IF io_script_name IS NOT NULL THEN
    --SELECT substr(io_script_name, 1, instr( io_script_name,'_')-1) INTO l_script_type  FROM dual;
    SELECT substr(io_script_name, instr( io_script_name,'_') +1, 100) INTO l_script_id FROM dual;
    -- Get the Script text for the given Brand and Source System (Combination 1).
    -- If the script can not be found then get it using other Brand and Source System combinations (2,3 and 4)
    -- 1. Brand         : GIVEN BRAND
    --    Source System : GIVEN SOURCE SYSTEM
    --
    -- 2. Brand         : 'GENERIC'
    --    Source System : GIVEN SOURCE SYSTEM
    --
    -- 3. Brand         : GIVEN BRAND
    --    Source System : 'ALL'
    --
    -- 4. Brand         : 'GENERIC'
    --    Source System : 'ALL'
    --
    -- Get the Scirpt text for the combination 1
    OPEN script_text_cur(ip_brand,ip_source_system,l_script_id,ip_script_type);
    FETCH script_text_cur INTO l_script_text;
    CLOSE script_text_cur;
    -- If the record is not found then
    -- Get the Scirpt text for the combination 2
    IF l_script_text IS NOT NULL THEN
      io_script_text := l_script_text;
    ELSE
      OPEN script_text_cur('GENERIC',ip_source_system,l_script_id,ip_script_type);
      FETCH script_text_cur INTO l_script_text;
      CLOSE script_text_cur;
      -- If the record is not found then
      -- Get the Scirpt text for the combination 3
      IF l_script_text IS NOT NULL THEN
        io_script_text := l_script_text;
      ELSE
        OPEN script_text_cur(ip_brand,'ALL',l_script_id,ip_script_type);
        FETCH script_text_cur INTO l_script_text;
        CLOSE script_text_cur;
        -- If the record is not found then
        -- Get the Scirpt text for the combination 4
        IF l_script_text IS NOT NULL THEN
          io_script_text := l_script_text;
        ELSE
          OPEN script_text_cur('GENERIC','ALL',l_script_id,ip_script_type);
          FETCH script_text_cur INTO l_script_text;
          CLOSE script_text_cur;
          --
          IF l_script_text IS NOT NULL THEN
            io_script_text := l_script_text;
          ELSE
            dbms_output.put_line('Script Text is not found.');
          END IF;
        END IF;
      END IF;
    END IF;
  ELSE
    dbms_output.put_line('Script Name is not found');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
  dbms_output.put_line('Error Code: '||SQLCODE);
  dbms_output.put_line('Error Message: '||SQLERRM);
END p_get_error_script_text;
--
-- CR35913 changes Ends
  procedure get_carrier_tech_script(ip_pc varchar2,
                                    ip_script_id varchar2,
                                    ip_carrier_id varchar2,
                                    ip_language varchar2,
                                    ip_sourcesystem VARCHAR2,
                                    op_objid out varchar2,
                                    op_description out varchar2,
                                    op_script_text out varchar2,
                                    op_publish_by out varchar2,
                                    op_publish_date out varchar2,
                                    op_sm_link out varchar2)
  is
    -- OBTAIN SCRIPT
    -- BY CARRIER AND TECH
    -- BY CARRIER -- ip_pc is null
    -- BY TECH -- ip_carrier_id is null
    v_script_type sa.table_x_scripts.x_script_type%TYPE := substr(ip_script_id,0,instr(ip_script_id,'_')-1);
    v_script_id   sa.table_x_scripts.x_script_id%TYPE := substr(ip_script_id,instr(ip_script_id,'_')+1);
    v_tech        sa.table_x_scripts.x_technology%TYPE;
    v_base_tech   sa.table_x_scripts.x_technology%TYPE;

    -- GET SCRIPT BY CARRIER AND TECHNOLOGY (NOT CARRIER AND BUSORG)
    cursor scpt_carrier_cur(sr_ci varchar2,
                            sr_tech varchar2,
                            sr_st varchar2,
                            sr_si varchar2,
                            sr_lang varchar2,
                            sr_ss varchar2)
    is
    SELECT xs.*
    FROM  sa.table_x_scripts xs,
          sa.MTM_X_CARRIER34_X_SCRIPTS0 mtm,
          sa.table_x_carrier xc
    WHERE mtm.carrier2script= xc.objid
    AND mtm.script2carrier    = xs.objid
    AND xc.x_carrier_id       = sr_ci
    AND xs.x_technology       = nvl(sr_tech,'ALL')
    AND xs.x_script_type      = sr_st
    AND xs.x_script_id        = sr_si
    AND XS.X_LANGUAGE         = sr_lang
    and (xs.X_SOURCESYSTEM     = sr_ss
    or xs.X_SOURCESYSTEM     = 'ALL');

    -- GET SCRIPT BY CARRIER PARENT AND TECHNOLOGY (NOT CARRIER AND BUSORG)
    cursor scpt_parent_cur (sr_ci varchar2,
                            sr_tech varchar2,
                            sr_st varchar2,
                            sr_si varchar2,
                            sr_lang varchar2,
                            sr_ss varchar2)
    is
    SELECT xs.*
    FROM   sa.table_x_scripts xs,
           sa.MTM_X_PARENT_TO_X_SCRIPTS mtm,
          (select p.objid
           from  TABLE_X_PARENT P,
                 TABLE_X_CARRIER_GROUP CG,
                 TABLE_X_CARRIER C
           WHERE c.x_carrier_id = sr_ci
           AND C.CARRIER2CARRIER_GROUP      = CG.OBJID
           AND CG.X_CARRIER_GROUP2X_PARENT  = P.OBJID) xc
    WHERE mtm.carrier_parent_objid= xc.objid
    AND mtm.script_objid      = xs.objid
    AND xs.x_technology       = nvl(sr_tech,'ALL')
    AND xs.x_script_type      = sr_st
    AND xs.x_script_id        = sr_si
    AND XS.X_LANGUAGE         = sr_lang
    and (xs.X_SOURCESYSTEM    = sr_ss
    or xs.X_SOURCESYSTEM      = 'ALL');

    cursor scpt_tech_cur (sr_tech varchar2,
                          sr_st varchar2,
                          sr_si varchar2,
                          sr_lang varchar2,
                          sr_ss varchar2)
    is
    SELECT xs.* -- CHECKING FOR BASE TECH AND TECH
    FROM   sa.table_x_scripts xs
    WHERE 1=1
    AND xs.x_technology       = sr_tech
    AND xs.x_script_type      = sr_st
    AND xs.x_script_id        = sr_si
    AND XS.X_LANGUAGE         = sr_lang
    and (xs.X_SOURCESYSTEM    = sr_ss
    or xs.X_SOURCESYSTEM      = 'ALL')
    and not exists (select 1 from sa.mtm_x_parent_to_x_scripts mtm
                    where mtm.script_objid = xs.objid);

    cursor tech_cur(tr_pc varchar2)
    is
    select a.part_class,a.param_value||decode(b.param_value,'BYOP','','BYOD','','','','_'||b.param_value) tech
    from  (
            select *
            from pc_params_view
            where param_name in ('TECHNOLOGY')
           ) a,
          (
            select *
            from pc_params_view
            where param_name in ('PHONE_GEN')
          ) b
    where a.pc_objid = b.pc_objid(+)
    and a.part_class = tr_pc;

  begin
    if ip_pc is null and ip_carrier_id is null then
      op_script_text := 'PART CLASS AND/OR CARRIER ID IS REQUIRED';
      return;
    end if;
    if ip_pc is null and ip_carrier_id is not null then
      dbms_output.put_line('DOING A CARRIER ID SCRIPT');
    end if;
    if ip_pc is not null and ip_carrier_id is not null then
      dbms_output.put_line('DOING A CARRIER/TECH ID SCRIPT');
    end if;
    if ip_pc is not null and ip_carrier_id is null then
      dbms_output.put_line('DOING A TECH ID SCRIPT');
    end if;

--    if ip_pc is null then
--      op_script_text := 'PART CLASS IS REQUIRED';
--      return;
--    end if;
--    if ip_carrier_id is null then
--      op_script_text := 'CARRIER ID IS REQUIRED';
--      return;
--    end if;
    if ip_script_id is null then
      op_script_text := 'SCRIPT ID IS REQUIRED';
      return;
    end if;
    if ip_language is null then
      op_script_text := 'LANGUAGE IS REQUIRED';
      return;
    end if;

    if ip_pc is not null then
      for tech_rec in tech_cur(ip_pc)
      loop
        v_tech := tech_rec.tech;
        v_base_tech := substr(tech_rec.tech,0,instr(tech_rec.tech,'_')-1);
      end loop;
    end if;

    if v_tech is null and v_tech is null then
      dbms_output.put_line('NOT ABLE TO DETERMINE THE TECHNOLOGY WILL TRY FOR CARRIER SCRIPT');
    else
      dbms_output.put_line('TECHNOLOGY      ==>'||v_tech);
      dbms_output.put_line('TECHNOLOGY BASE ==>'||v_base_tech);
    end if;

    -- GET TECHNOLOGY SCRIPT
    if ip_pc is not null and ip_carrier_id is null then
      for scpt_rec in scpt_tech_cur(sr_tech => v_tech,
                                    sr_st => v_script_type,
                                    sr_si => v_script_id,
                                    sr_lang =>ip_language,
                                    sr_ss =>ip_sourcesystem)
      loop
        op_objid        := scpt_rec.objid;
        op_description  := scpt_rec.x_description;
        op_script_text  := scpt_rec.x_script_text;
        op_publish_by   := scpt_rec.x_published_by;
        op_publish_date := scpt_rec.x_published_date;
        op_sm_link      := scpt_rec.x_script_manager_link;
      end loop;
    end if;

    -- GET CARRIER OR CARRIER/TECHNOLOGY SCRIPT
    if ip_carrier_id is not null then
      for scpt_rec in scpt_parent_cur(sr_ci => ip_carrier_id,
                                      sr_tech => v_tech,
                                      sr_st => v_script_type,
                                      sr_si => v_script_id,
                                      sr_lang =>ip_language,
                                      sr_ss =>ip_sourcesystem)
      loop
        op_objid        := scpt_rec.objid;
        op_description  := scpt_rec.x_description;
        op_script_text  := scpt_rec.x_script_text;
        op_publish_by   := scpt_rec.x_published_by;
        op_publish_date := scpt_rec.x_published_date;
        op_sm_link      := scpt_rec.x_script_manager_link;
      end loop;

      -- GET CARRIER OR CARRIER/TECHNOLOGY(BASE) SCRIPT
      -- FOR EXAMPLE CDMA_4G (TECH) => CDMA (BASE TECH)
      if op_script_text is null and (v_base_tech != v_tech) then
        for scpt_rec in scpt_parent_cur(sr_ci => ip_carrier_id,
                                        sr_tech => v_base_tech,
                                        sr_st => v_script_type,
                                        sr_si => v_script_id,
                                        sr_lang =>ip_language,
                                        sr_ss =>ip_sourcesystem)
        loop
          op_objid        := scpt_rec.objid;
          op_description  := scpt_rec.x_description;
          op_script_text  := scpt_rec.x_script_text;
          op_publish_by   := scpt_rec.x_published_by;
          op_publish_date := scpt_rec.x_published_date;
          op_sm_link      := scpt_rec.x_script_manager_link;
        end loop;
      end if;
    end if;

    if op_script_text is null then
      op_script_text := 'MISSING SCRIPT -  '||ip_script_id||' TECH - '||v_tech||' CARRIER - '||ip_carrier_id||' LANG - '||ip_language||' CHANNEL - '||ip_sourcesystem;
    end if;

    dbms_output.put_line('ip_pc           ==>'||ip_pc);
    dbms_output.put_line('v_script_type   ==>'||v_script_type);
    dbms_output.put_line('v_script_id     ==>'||v_script_id);
    dbms_output.put_line('ip_carrier_id   ==>'||ip_carrier_id);
    dbms_output.put_line('v_tech          ==>'||v_tech);
    dbms_output.put_line('ip_language     ==>'||ip_language);
    dbms_output.put_line('ip_sourcesystem ==>'||ip_sourcesystem);

  exception
    when others then
      op_script_text := 'MISSING SCRIPT -  '||ip_script_id||'';
  end get_carrier_tech_script;
--------------------------------------------------------------------------------
  procedure get_err_map_carrier_tech_scpt(ip_func_name varchar2, -- USE THE METHOD NAME
                                          ip_flow_name varchar2, -- USE THE PERMISSION NAME
                                          ip_error_code varchar2, -- USE W/E NUMBER
                                          ip_default_msg varchar2, -- DEFAULT ERROR MESSAGE
                                          ip_default_script_id varchar2, -- OPTIONAL
                                          ip_carrier varchar2, -- TABLE_X_CARRIER.X_CARRIER_ID - NEW MANDATORY
                                          ip_language varchar2, -- ENGLISH,SPANISH
                                          ip_part_class varchar2, -- MANDATORY
                                          ip_source_system varchar2, --
                                          ip_replace_tokens varchar2, -- Y OR N - FLAG TO REPLACE VARIABLES EXAMPLE [COMPANY_NAME]
                                          op_script_text out varchar2)
  as
    v_brand varchar2(30);
    v_script_type varchar2(30);
    v_prefix varchar2(30);
    v_suffix varchar2(30);
    v_map_text varchar2(200);
    v_default_script_id varchar2(30) := ip_default_script_id;
    v_default_msg_in_table sa.x_rqst_mapping.x_script_text%type;
    v_error_code  sa.x_rqst_mapping.x_error_code%type := ip_error_code;
    op_objid varchar2(200);
    op_description varchar2(200);
    op_publish_by varchar2(200);
    op_publish_date date;
    op_sm_link varchar2(200);
  begin
    v_brand := GET_PARAM_BY_NAME_FUN(ip_part_class,'BUS_ORG');

    select x_script_name,
           substr(x_script_name,0,instr(x_script_name,'_')-1) prefix,
           substr(x_script_name,instr(x_script_name,'_')+1) suffix,
           nvl(x_script_text,'MISSING SCRIPT - FLOW: '||x_flow_name||' - FUNC: '||x_func_name||' - ERROR: '||x_error_code) mapping_text,
           x_script_text
    into   v_script_type,v_prefix,v_suffix,v_map_text,v_default_msg_in_table
    from   x_rqst_mapping a
    where 1=1
    and x_error_code = ip_error_code
    and x_func_name  = ip_func_name
    and x_flow_name  = ip_flow_name
    and rownum <2;

    if v_default_msg_in_table != ip_default_msg then
      v_error_code := ip_error_code+length(ip_default_msg);
      select x_script_name,
             substr(x_script_name,0,instr(x_script_name,'_')-1) prefix,
             substr(x_script_name,instr(x_script_name,'_')+1) suffix,
             nvl(x_script_text,'MISSING SCRIPT - FLOW: '||x_flow_name||' - FUNC: '||x_func_name||' - ERROR: '||x_error_code) mapping_text,
             x_script_text
      into   v_script_type,v_prefix,v_suffix,v_map_text,V_default_msg_in_table
      from   x_rqst_mapping a
      where 1=1
      and x_error_code = v_error_code
      and x_func_name  = ip_func_name
      and x_flow_name  = ip_flow_name
      and rownum <2;
    end if;

    if v_prefix is not null then
      dbms_output.put_line('FOUND SCRIPT ID = ' || v_prefix||'_'||v_suffix);
      scripts_pkg.get_carrier_tech_script (ip_pc =>ip_part_class,
                                           ip_script_id =>v_script_type,
                                           ip_carrier_id =>ip_carrier,
                                           ip_language =>ip_language,
                                           ip_sourcesystem =>ip_source_system,
                                           op_objid => op_objid,
                                           op_description => op_description,
                                           op_script_text => op_script_text,
                                           op_publish_by => op_publish_by,
                                           op_publish_date => op_publish_date,
                                           op_sm_link => op_sm_link);
    else
      -- dbms_output.put_line('NO SCRIPT ID DEFAULT TEXT = ' || v_map_text);
      op_script_text := v_map_text;
    end if;

    if ip_replace_tokens = 'Y' then
      op_script_text := scripts_pkg.replace_script_token_variables (ip_script_text => op_script_text,
                                                                    ip_bus_org => v_brand,
                                                                    ip_language => ip_language);
    end if;

    dbms_output.put_line('OP_OBJID = ' || op_objid);
    dbms_output.put_line('OP_DESCRIPTION = ' || op_description);
    dbms_output.put_line('OP_SCRIPT_TEXT = ' || op_script_text);
    dbms_output.put_line('OP_PUBLISH_BY = ' || op_publish_by);
    dbms_output.put_line('OP_PUBLISH_DATE = ' || op_publish_date);
    dbms_output.put_line('OP_SM_LINK = ' || op_sm_link);

  exception
    when others then
      -- this should happen primarily when no data found
      scripts_pkg.sp_error_code2script(error_code => v_error_code,
                                       func => ip_func_name,
                                       flow => ip_flow_name,
                                       script_name => v_default_script_id,
                                       script_text => ip_default_msg);
      --Retrieve default message April 2014
	  op_script_text := ip_default_msg;
  end get_err_map_carrier_tech_scpt;
--------------------------------------------------------------------------------
end scripts_pkg;
/