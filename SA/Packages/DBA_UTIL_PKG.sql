CREATE OR REPLACE PACKAGE sa.DBA_UTIL_PKG  AS
Procedure Delete_PartClass( pcname in varchar2);
procedure Insert_Part_class_hist(pcname in varchar2);
Procedure Delete_PartNum(p_num in varchar2);
procedure Insert_Part_num_hist(p_num in varchar2);
Procedure Delete_Site(v_dealer in varchar2);
Procedure Delete_Billing_Prog(pgname in varchar2);
procedure insert_program_hist( pgname in varchar2);
Procedure Add_New_site(vname in varchar2);
Procedure Add_contact_site(pname in varchar2);
Procedure Add_Part_Class( PClass in varchar2);
Procedure Add_Part_num(vnum in varchar2);
Procedure Add_Billing_Prog(pgname in varchar2);
Procedure get_site_name(siteobj in number);
Procedure Add_Billing_Part_Nums(pgname varchar2) ;
procedure Delete_pricing(pnobj number);
procedure ADD_PRICING(pn in  varchar2);
PROCEDURE Check_Script(scid in varchar2, sctp in varchar2, plang in varchar2 , ptech in varchar2,Brand_nm  in varchar2,
psrcsys varchar2) ;
procedure INSERT_MISSING_SCRIPTS ;
Procedure Create_User_db(P_Uname in varchar2, OP_MESSAGE out varchar2);
Procedure Reset_User_db (P_Uname In Varchar2,OP_MESSAGE out varchar2);
Procedure Create_User_Tas (Ip_Priviledge_Class In Varchar2,Ip_Sec_Grp_Name  In  varchar2,Ip_Login_Name  In  Varchar2,
Ip_First_Name  In Varchar2,Ip_Last_Name  In Varchar2,Ip_Employee_Id  In  Varchar2,Ip_Email In Varchar2,OP_MESSAGE out varchar2);
PROCEDURE RESET_USER_TAS (v_login varchar2);
Procedure  update_Priv_class(ip_Priv_class in varchar2,Ip_Login_Name  In  Varchar2);
Procedure update_sec_grp(Ip_Sec_Grp_Name  In  varchar2,Ip_Login_Name  In  Varchar2);

Procedure Create_user_B2C_b2b(Ip_Priviledge_Class In Varchar2,Ip_Sec_Grp_Name  In  varchar2,Ip_Login_Name  In  Varchar2,
                            Ip_First_Name  In Varchar2,Ip_Last_Name  In Varchar2,Ip_Employee_Id  In  Varchar2,
                            ip_role  in varchar2,Ip_Email In Varchar2,OP_MESSAGE out varchar2);
Procedure create_user_apex (Ip_Priviledge_Class In Varchar2,Ip_Sec_Grp_Name  In  varchar2,Ip_Login_Name  In  Varchar2,
Ip_First_Name  In Varchar2,Ip_Last_Name  In Varchar2,Ip_Employee_Id  In  Varchar2,Ip_Email In Varchar2, OP_MESSAGE out varchar2);
PROCEDURE RESET_USER_APEX (v_login varchar2);
Procedure Create_User_udp(P_Fname In Varchar2,p_lastname in varchar2,p_email in varchar2,p_role in varchar2,OP_MESSAGE out varchar2);
Procedure Void_batch;
Procedure Void_batch_Ndays(numday number);
Procedure Delete_Promo(prom_obj number);
Procedure Add_Promo(v_promo_code varchar2);

end;
/