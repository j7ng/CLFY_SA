CREATE OR REPLACE PACKAGE sa.FIND_COMP_PRICE 
as
 procedure SP_get_price(testname varchar2, testch varchar2) ;
 procedure insert_pr_dev(testname varchar2, testch varchar2) ;
 procedure insert_pr_rtrp(testname varchar2, testch varchar2) ;
 procedure pc_prTest(testname varchar2, testch varchar2); 
END  FIND_COMP_PRICE;
/