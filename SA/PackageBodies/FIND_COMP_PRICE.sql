CREATE OR REPLACE PACKAGE BODY sa.FIND_COMP_PRICE 
AS

procedure SP_get_price(testname varchar2, testch varchar2)is
     vname varchar2(25) ;
     vch  varchar2(25):=null;
 
       cursor is_pn is
       select part_number 
       from table_part_num where 
       part_number= vname;
 
    pnrec  is_pn%rowtype;
  
      cursor is_pc is
        select 1 
          from table_part_class where
          name =vname;
          pcrec  is_pc%rowtype;
begin
      
        vname :=upper(testname);
       vch :=testch;
                 open is_pc;
                     fetch is_pc into pcrec;
                    if  is_pc%found then 
                       dbms_output.put_line('Call  only PC');
                        pc_prTest(vname, vch);                    
                  close is_pc;
              else    
                open is_pn;
                    fetch is_pn into pnrec;
                      if is_pn%found then 
                         vname :=pnrec.part_number;
                              insert_pr_rtrp(vname,vch );       
                            ---  dbms_output.put_line('RTRP Results');
                               insert_pr_dev(vname,vch );
                                -- dbms_output.put_line('DEV Results');                               
                      else
                    dbms_output.put_line('Need pn or pc');   
                 end if;   
                close is_pn;  
          end if;                
    
end; 

 procedure insert_pr_dev(testname varchar2, testch varchar2) is
  
  lv_pn_objid   NUMBER;
  lv_pn_name    VARCHAR2(50) ; 
  ch_clause     VARCHAR2(1000);
  sqlstmt       VARCHAR2(3000);
  lv_channel    VARCHAR2(30) :=null;
  dbname varchar2(25) ;

  TYPE ty_price IS TABLE OF table_x_pricing%ROWTYPE;
  tbl_price ty_price;

BEGIN   
      lv_pn_name := testname ;
      lv_channel := testch ;   
      
    select instance_name into dbname 
    from v$instance; 
     
   SELECT objid 
    INTO lv_pn_objid
    FROM table_part_num  
    WHERE part_number = lv_pn_name;
     
  ch_clause := ' AND x_channel = ''' || lv_channel || '''';
  sqlstmt   :='SELECT *
                 FROM table_x_pricing 
                WHERE x_end_date > SYSDATE
                  AND x_pricing2part_num = ' || lv_pn_objid;

      IF lv_channel IS NULL THEN
        sqlstmt := sqlstmt;       
      ELSE                  
         sqlstmt := sqlstmt || ch_clause;
  END IF;
  
  EXECUTE IMMEDIATE sqlstmt BULK COLLECT INTO tbl_price;
  IF TBL_PRICE.COUNT =0 THEN 
      DBMS_OUTPUT.PUT_LINE('NO Pricing for  :  '|| lv_pn_name ||'IN '|| dbname);
   else  
     DBMS_OUTPUT.PUT_LINE('                 ');   
     DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------');
     DBMS_OUTPUT.PUT_LINE('RESULTS FROM ' ||dbname);
     DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------');
     DBMS_OUTPUT.PUT_LINE(' PART_NUM    '||'PRICE    '||'      CHANNEL  ' ||'    VALID_FROM      ' ||'         VALID_TILL ');
     DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------');
     DBMS_OUTPUT.PUT_LINE('                 ');
     --DBMS_OUTPUT.PUT_LINE(' Part_num  '||'PRICE  '||'    CHANNEL  ' ||' VALID_TILL ');
  
     FOR i IN 1..tbl_price.COUNT 
     LOOP
               --DBMS_OUTPUT.PUT_LINE(tbl_price(i).x_retail_price ||' '|| tbl_price(i).X_CHANNEL);
           DBMS_OUTPUT.PUT_LINE( lv_pn_name ||'    '||tbl_price(i).x_retail_price ||'    '|| tbl_price(i).X_CHANNEL||'    ' ||tbl_price(i).x_end_date||'       '||tbl_price(i).x_start_date);     
        INSERT INTO sa.comp_pricing_smoke
               (dbenv, part_num, x_retail_price, valid_till, brand, x_channel, date_updated,start_date) 
         VALUES (dbname,  lv_pn_name, tbl_price(i).x_retail_price, tbl_price(i).x_end_date, tbl_price(i).x_brand_name, tbl_price(i).X_CHANNEL, SYSDATE,tbl_price(i).x_start_date);
       COMMIT;
    END LOOP;
 end if;   
END;

 procedure insert_pr_rtrp(testname varchar2, testch varchar2) is 
   lv_pn_objid   NUMBER;
   lv_pn_name    VARCHAR2(50);  
  ch_clause     VARCHAR2(1000);
  sqlstmt       VARCHAR2(3000);
  lv_channel    VARCHAR2(30) :=null;

  

  TYPE ty_price IS TABLE OF sa.table_x_pricing%ROWTYPE;
  tbl_price ty_price;

BEGIN   
    lv_pn_name  :=  testname;
    lv_channel  :=testch;
  SELECT objid 
    INTO lv_pn_objid
    FROM sa.table_part_num@READ_RTRP 
   WHERE part_number = lv_pn_name;
     
  ch_clause := ' AND x_channel = ''' || lv_channel || '''';
  sqlstmt   :='SELECT *
                 FROM sa.table_x_pricing@READ_RTRP 
                WHERE x_end_date > SYSDATE
                  AND x_pricing2part_num = ' || lv_pn_objid;

  IF lv_channel IS NULL THEN
    sqlstmt := sqlstmt;       
  ELSE                  
    sqlstmt := sqlstmt || ch_clause;
  END IF;
  
  EXECUTE IMMEDIATE sqlstmt BULK COLLECT INTO tbl_price;
  
    IF TBL_PRICE.COUNT =0 THEN 
      DBMS_OUTPUT.PUT_LINE('NO Pricing for  :  '|| lv_pn_name ||'  IN RTRP');
    ELSE   
    -- DBMS_OUTPUT.PUT_LINE('PRICE  '||'    CHANNEL');
     DBMS_OUTPUT.PUT_LINE('                 ');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------');
     DBMS_OUTPUT.PUT_LINE('RESULTS FROM RTRP ');
     DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------');
     DBMS_OUTPUT.PUT_LINE(' PART_NUM    '||'PRICE    '||'      CHANNEL  ' ||'      VALID_FROM      ' ||'     VALID_TILL');
     DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------');
     DBMS_OUTPUT.PUT_LINE('                 ');
  FOR i IN 1..tbl_price.COUNT 
  LOOP
    -- DBMS_OUTPUT.PUT_LINE(tbl_price(i).x_retail_price ||' '|| tbl_price(i).X_CHANNEL);
    DBMS_OUTPUT.PUT_LINE( lv_pn_name ||'      '||tbl_price(i).x_retail_price ||'       '|| tbl_price(i).X_CHANNEL||'       ' ||tbl_price(i).x_end_date||'         '||tbl_price(i).x_start_date);
    INSERT INTO sa.comp_pricing_smoke
               (dbenv, part_num, x_retail_price, valid_till, brand, x_channel, date_updated,start_date) 
         VALUES ('RTRP',  lv_pn_name, tbl_price(i).x_retail_price, tbl_price(i).x_end_date, tbl_price(i).x_brand_name, tbl_price(i).X_CHANNEL, SYSDATE,tbl_price(i).x_start_date);
  
        COMMIT;
    END LOOP;
  END IF; 
END;

 
 procedure pc_prTest(testname varchar2, testch varchar2) is

vname  varchar2(30);
vch  varchar2(30) :=null;
cursor c is
   select part_number
   from sa.table_part_num pn, sa.table_part_class pc
   where pn.part_num2part_class=pc.objid
   and pc.name=vname;
begin
      vname := testname;
      vch := testch;
    for crec in c loop      
       insert_pr_dev(crec.part_number,vch );           
       insert_pr_rtrp(crec.part_number,vch );   
     end loop;
end pc_prTest;     
 end FIND_COMP_PRICE ;
/