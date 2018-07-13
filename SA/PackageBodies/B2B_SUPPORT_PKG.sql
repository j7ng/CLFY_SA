CREATE OR REPLACE PACKAGE BODY sa."B2B_SUPPORT_PKG" AS
/*****************************************************************
  * Package Name: B2B_SUPPORT_PKG
  * Purpose     : Support DB Updates for the B2B App.
  *
  * Platform    : Oracle 8.0.6 and newer versions.
  * Created by  : Natalio Guada
  * Date        : 04/23/2009
  *
  * Frequency   : All weekdays
  * History
  * REVISIONS    VERSION  DATE          WHO            PURPOSE
  * -------------------------------------------------------------
  *              1.0      04/23/2009    Nguada     Initial Revision
  *              1.5      08/20/2010    Nguada     CR13581
  *              1.6      09/15/2010    Nguada     Primary ESN Fix
  *              1.7      09/21/2010    Nguada     Primary ESN Fix
  *              1.8      10/20/2010    Nguada     CR14676
  *              1.9      11/01/2010    Akhan      CR14676 added procedure to update pricing description.
  *              1.10-11  11/15/2010    Nguada     CR14676 lookup part number modified.
  *              1.12     11/19/2010    Nguada     CR14676 Port case notification
  *              1.13     03/10/2011    Nguada     CR14678
  *              1.14     03/24/2011    Nguada     CR14678
  *              1.16     04/11/2011    YMillan    CR11553 Tax Collection Mod Proj
  *              1.17     04/13/2011    Nguada     CR11553 Tax Collection Mod Proj
  *              1.18     04/18/2011    Nguada     CR11553 Tax Collection Mod Proj
  *              1.19     04/18/2011    Nguada     CR11553 Tax Collection Mod Proj
  *              1.20     04/18/2011    Nguada     CR11553 Tax Collection Mod Proj
  *              1.19     04/18/2011    Nguada     CR11553 Tax Collection Mod Proj
  *              1.20     04/22/2011    Nguada     CR11553 Tax Collection - Order Number Removed
  *              1.21-22  05/11/2011    Nguada     CR16387 B2B Split
  *              1.23-24  06/26/2012    Icanavan   CR20451 | CR20854: Add TELCEL Brand
************************************************************************/

Procedure port_case_notification is
-- emails case information of pending port activations

cursor emails_cur is
select x_param_value
from table_x_parameters
where x_param_name = 'B2B_PORT_NOTIFICATION';

emails_rec emails_cur%rowtype;

cursor ports_closed_cur is
select x_sales_orders.order_id b2b_order_id, order_status, part_serial_no, id_number port_case_id,oper_system port_status, trunc(( sysdate-queue_time) * 24) hours_since_close
from x_sales_order_services, table_case, table_condition, x_sales_orders
where port_case_id  is not null
and x_sales_order_services.order_id = x_sales_orders.order_id
and port_case_id = id_number
and case_state2condition = table_condition.objid
and (condition = 4 or oper_system = 'Port Successful')
and creation_time >= sysdate - 30
and order_status in ('Pending ESNs','Pending Enrollment','Pending Activations');

ports_closed_rec ports_closed_cur%rowtype;

email_dtl VARCHAR2(4000);
result varchar2(200);

begin


    email_dtl:= '<table width="40%" border="1" cellspacing="0" cellpadding="0"><tr><td>Order Id</td><td>Order Status</td><td>Part Serial Number</td><td>Port Id</td><td>Port Status</td><td>Age</td></tr>';
    for ports_closed_rec in ports_closed_cur loop

       email_dtl:=email_dtl||'<tr>';
       email_dtl:=email_dtl||'<td>';
       email_dtl:=email_dtl||trim(ports_closed_rec.B2B_ORDER_ID);
       email_dtl:=email_dtl||'</td>';
       email_dtl:=email_dtl||'<td>';
       email_dtl:=email_dtl||trim(ports_closed_rec.order_status);
       email_dtl:=email_dtl||'</td>';
       email_dtl:=email_dtl||'<td>';
       email_dtl:=email_dtl||trim(ports_closed_rec.PART_SERIAL_NO);
       email_dtl:=email_dtl||'</td>';
       email_dtl:=email_dtl||'<td>';
       email_dtl:=email_dtl||trim(ports_closed_rec.port_case_id);
       email_dtl:=email_dtl||'</td>';
       email_dtl:=email_dtl||'<td>';
       email_dtl:=email_dtl||trim(ports_closed_rec.port_status);
       email_dtl:=email_dtl||'</td>';
       email_dtl:=email_dtl||'<td>';
       email_dtl:=email_dtl||trim(to_char(ports_closed_rec.HOURS_SINCE_CLOSE));
       email_dtl:=email_dtl||'</td>';
       email_dtl:=email_dtl||'</tr>';

    end loop;

    email_dtl:=email_dtl || '</table>';

    for emails_rec in emails_cur loop

    send_mail(
      subject_txt => 'B2B Port Cases Ready for Activation',
      msg_from => 'noreply@tracfone.com',
      SEND_TO => emails_rec.x_param_value,
      MESSAGE_TXT => email_dtl,
      result => result
    );

    end loop;

end;


Procedure Account_Primary_Esn_Fix (ip_account_id in number) IS

   Cursor Tf_Nt_Cur  Is
   Select X_Program_Enrolled.*
   From X_Program_Enrolled,X_Business_Accounts,X_Program_Parameters, Table_Web_User
   Where Account_Id = Ip_Account_Id
   and Pgm_Enroll2web_User = Table_Web_User.Objid
   and Web_User2contact = BUS_PRIMARY2CONTACT
   And Pgm_Enroll2pgm_Parameter = X_Program_Parameters.Objid
   And X_Enrollment_Status = 'ENROLLED'
   And Prog_Param2bus_Org In (Select Objid From Table_Bus_Org Where Org_Id In ('TRACFONE','NET10'))
   order by x_next_charge_date asc;

   Tf_Nt_Rec Tf_Nt_Cur%Rowtype;

--   CR20451 | CR20854: Add TELCEL Brand  modify this corsor
--   Cursor St_Cur Is
--   Select X_Program_Enrolled.*
--   From X_Program_Enrolled,X_Business_Accounts,X_Program_Parameters, Table_Web_User
--   Where Account_Id = Ip_Account_Id
--   and Pgm_Enroll2web_User = Table_Web_User.Objid
--   and Web_User2contact = BUS_PRIMARY2CONTACT
--   And Pgm_Enroll2pgm_Parameter = X_Program_Parameters.Objid
--   And X_Enrollment_Status = 'ENROLLED'
--   And Prog_Param2bus_Org In (Select Objid From Table_Bus_Org Where Org_Id In ('STRAIGHT_TALK'))
--   order by x_next_charge_date asc;

   Cursor St_Cur Is
   Select X_Program_Enrolled.*
   From X_Program_Enrolled,X_Business_Accounts,X_Program_Parameters, Table_Web_User
   Where Account_Id = Ip_Account_Id
   and Pgm_Enroll2web_User = Table_Web_User.Objid
   and Web_User2contact = BUS_PRIMARY2CONTACT
   And Pgm_Enroll2pgm_Parameter = X_Program_Parameters.Objid
   And X_Enrollment_Status = 'ENROLLED'
   And Prog_Param2bus_Org In (Select Objid From Table_Bus_Org Where Org_flow In ('3'))
   order by x_next_charge_date asc;

   St_Rec St_Cur%Rowtype;

   Cursor Tf_Nt_Cur_2  Is
   Select X_Program_Enrolled.*
   From X_Program_Enrolled,X_Business_Accounts,X_Program_Parameters, Table_Web_User
   Where Account_Id = Ip_Account_Id
   and Pgm_Enroll2web_User = Table_Web_User.Objid
   and Web_User2contact = BUS_PRIMARY2CONTACT
   And Pgm_Enroll2pgm_Parameter = X_Program_Parameters.Objid
   And X_Enrollment_Status = 'ENROLLMENTSCHEDULED'
   And Prog_Param2bus_Org In (Select Objid From Table_Bus_Org Where Org_Id In ('TRACFONE','NET10'))
   order by x_enrolled_date asc;

   Tf_Nt_Rec_2 Tf_Nt_Cur_2%Rowtype;

   -- Cursor St_Cur_2 Is
   --Select X_Program_Enrolled.*
   --From X_Program_Enrolled,X_Business_Accounts,X_Program_Parameters, Table_Web_User
   --Where Account_Id = Ip_Account_Id
   --and Pgm_Enroll2web_User = Table_Web_User.Objid
   --and Web_User2contact = BUS_PRIMARY2CONTACT
   --And Pgm_Enroll2pgm_Parameter = X_Program_Parameters.Objid
   --And X_Enrollment_Status = 'ENROLLMENTSCHEDULED'
   --and prog_param2bus_org in (select objid from table_bus_org where org_id in ('STRAIGHT_TALK'))
   --order by x_enrolled_date asc;

  Cursor St_Cur_2 Is
  Select X_Program_Enrolled.*
    From X_Program_Enrolled,X_Business_Accounts,X_Program_Parameters, Table_Web_User
   Where Account_Id = Ip_Account_Id
   and Pgm_Enroll2web_User = Table_Web_User.Objid
   and Web_User2contact = BUS_PRIMARY2CONTACT
   And Pgm_Enroll2pgm_Parameter = X_Program_Parameters.Objid
   And X_Enrollment_Status = 'ENROLLMENTSCHEDULED'
   and prog_param2bus_org in (select objid from table_bus_org where org_flow in ('3'))
   order by x_enrolled_date asc;

   St_Rec_2 St_Cur_2%Rowtype;

   Tf_Nt_Next_date Date;
   Tf_Nt_Primary Number;

   St_Next_Date Date;
   St_Primary Number;

BEGIN

   --
   -- Selecting first enrolled nt or tf as primary,
   -- updating all others tf or nt to pointing to primary and match same date
   --

   Open Tf_Nt_Cur;
   fetch tf_nt_cur into tf_nt_rec;

   If Tf_Nt_Cur%Found Then
      Tf_Nt_Next_Date :=  Tf_Nt_Rec.X_Next_Charge_Date;
      Tf_Nt_Primary := Tf_Nt_Rec.Objid;

      Update X_Program_Enrolled
      set x_is_grp_primary = 1,
          pgm_enroll2pgm_group = null
      Where Objid = Tf_Nt_Primary;

      Update X_Program_Enrolled
      Set X_Is_Grp_Primary = 0,
          x_next_charge_date = decode(x_enrollment_status,'ENROLLED',tf_nt_next_date,null),
          x_enrolled_date = decode(X_Enrollment_Status,'ENROLLMENTSCHEDULED',Tf_Nt_Rec.X_Next_charge_Date,x_enrolled_date),
          PGM_ENROLL2PGM_GROUP =Tf_Nt_Primary
      Where Pgm_Enroll2web_User In (Select Objid From Table_Web_User
                                    Where Web_User2contact In (Select Bus_Primary2contact
                                                               From X_Business_Accounts
                                                               where account_id = ip_account_id))
      and X_Enrollment_Status in ('ENROLLED','ENROLLMENTSCHEDULED')
      And Objid <> Tf_Nt_Primary
      And Pgm_Enroll2pgm_Parameter In (Select Objid From X_Program_Parameters
                                       Where Prog_Param2bus_Org In (Select Objid From Table_Bus_Org
                                                                    where org_id in ('TRACFONE','NET10')));
   else

   --
   -- Not enrolled found, looking for enrollmentschedule nt or tf as primary,
   -- updating all others tf or nt to pointing to primary and match same date
   --
      open tf_nt_cur_2;
      fetch tf_nt_cur_2 into tf_nt_rec_2;
      If Tf_Nt_Cur_2%Found Then

         tf_nt_next_date :=  tf_nt_rec_2.x_enrolled_date;
         tf_nt_primary := tf_nt_rec_2.objid;

         update x_program_enrolled
         set x_is_grp_primary = 1,
             pgm_enroll2pgm_group = null
         where objid = tf_nt_primary;

         update x_program_enrolled
         set x_is_grp_primary = 0,
             x_next_charge_date = null,
             x_enrolled_date = tf_nt_next_date,
             pgm_enroll2pgm_group =tf_nt_primary
         Where Pgm_Enroll2web_User In (Select Objid From Table_Web_User
                                    Where Web_User2contact In (Select Bus_Primary2contact
                                                               From X_Business_Accounts
                                                               where account_id = ip_account_id))
         and X_Enrollment_Status = 'ENROLLMENTSCHEDULED'
         and objid <> tf_nt_primary
         And Pgm_Enroll2pgm_Parameter In (Select Objid From X_Program_Parameters
                                       where prog_param2bus_org in (select objid from table_bus_org
                                                                    where org_id in ('TRACFONE','NET10')));
      end if;
      close tf_nt_cur_2;
   End If;
   close Tf_Nt_Cur;

   --
   -- Selecting first enrolled st as primary,
   -- updating all others st to pointing to primary and match same date
   --
   Open St_Cur;
   Fetch St_Cur Into St_Rec;
   If St_Cur%Found Then
      St_Next_Date :=  st_Rec.X_Next_Charge_Date;
      st_Primary := st_Rec.Objid;

      update x_program_enrolled
      set x_is_grp_primary = 1,
          pgm_enroll2pgm_group = null
      Where Objid = st_Primary;

      Update X_Program_Enrolled
      Set X_Is_Grp_Primary = 0,
          x_next_charge_date = decode(x_enrollment_status,'ENROLLED',st_next_date,null),
          x_enrolled_date = decode(X_Enrollment_Status,'ENROLLMENTSCHEDULED',st_Rec.X_Next_charge_Date,x_enrolled_date),
          PGM_ENROLL2PGM_GROUP =st_Primary
      Where Pgm_Enroll2web_User In (Select Objid From Table_Web_User
                                    Where Web_User2contact In (Select Bus_Primary2contact
                                                               From X_Business_Accounts
                                                               Where Account_Id = Ip_Account_Id))
      and objid <> tf_nt_primary
      and X_Enrollment_Status in ('ENROLLED','ENROLLMENTSCHEDULED')
      And Pgm_Enroll2pgm_Parameter In (Select Objid From X_Program_Parameters
                                       Where Prog_Param2bus_Org In (Select Objid From Table_Bus_Org
                                       --CR20451 | CR20854: Add TELCEL Brand
                                       -- Where Org_Id In ('STRAIGHT_TALK')));
                                       Where Org_flow In ('3')));


   else

   --
   -- Not enrolled found, looking for enrollmentschedule st as primary,
   -- updating all others st to pointing to primary and match same date
   --
      open st_cur_2;
      fetch st_cur_2 into st_rec_2;
      If St_Cur_2%Found Then

         st_next_date :=  st_rec_2.x_enrolled_date;
         st_primary := st_rec_2.objid;

         Update X_Program_Enrolled
         set x_is_grp_primary = 1,
             pgm_enroll2pgm_group = null
         where objid = st_primary;

         update x_program_enrolled
         set x_is_grp_primary = 0,
             x_next_charge_date = null,
             x_enrolled_date = st_next_date,
             pgm_enroll2pgm_group =st_primary
         Where Pgm_Enroll2web_User In (Select Objid From Table_Web_User
                                    Where Web_User2contact In (Select Bus_Primary2contact
                                                               From X_Business_Accounts
                                                               where account_id = ip_account_id))
         and X_Enrollment_Status = 'ENROLLMENTSCHEDULED'
         and objid <> st_primary
         And Pgm_Enroll2pgm_Parameter In (Select Objid From X_Program_Parameters
                                       where prog_param2bus_org in (select objid from table_bus_org
                                       --CR20451 | CR20854: Add TELCEL Brand
                                       -- Where Org_Id In ('STRAIGHT_TALK')));
                                       Where Org_flow In ('3')));

      end if;
      close st_cur_2;

   End If;
   Close st_Cur;

   commit;

exception

   when others then null;

END;

-----CR13581
PROCEDURE refund_pre_processing IS

CURSOR RETURNED_ESN_CUR IS --Returned ESNs
Select  C.Product_Code_1,d.order_id,e.order2purch_hdr,b.item_code_1,ba.bus_primary2contact
FROM tf.tf_asni_header@ofsprd a
     ,Tf.Tf_Asni_Detail@ofsprd B
     ,Tf.Tf_Asni_Serial_Number@Ofsprd C
     ,X_BUS_ACC_ESN D
     ,X_SALES_ORDERS E
     , X_BUSINESS_ACCOUNTS BA
WHERE 1=1
AND a.tp_location_code           = b.tp_location_code
AND a.shipment_num                  = b.shipment_num
AND b.tp_location_code           = c.tp_location_code
AND b.shipment_num                  = c.shipment_num
AND b.shipment_line_num       = c.shipment_line_num
And Asn_Type_Code = 'RET'
And A.Creation_Date >= Trunc(Sysdate) -3
And D.Esn = C.Product_Code_1
And Nvl(D.Returned,0) = 0
And Nvl(D.Refunded,0) = 0
AND D.ORDER_ID = E.ORDER_ID
and ba.account_id = e.account_id
and e.creation_date >= sysdate - 30;
/* CR11553
Cursor Sales_Tax_Cur (Ip_Esn Varchar2, Ip_Order_Id Varchar2) Is
Select st.X_COMBSTAX
From X_Sales_Orders So,
     X_Business_Accounts Ba,
     Table_X_Sales_Tax St
Where So.Bill_Zipcode = St.X_Zipcode
And  So.Order_Id = Ip_Order_Id
AND  So.Account_Id = Ba.Account_Id
And  Ba.Tax_Exempt = 'false';

Sales_Tax_Rec Sales_Tax_Cur%Rowtype; */ --CR11553

Cursor Part_Num_Cur (Ip_Esn Varchar2) Is
SELECT part_number,domain
FROM table_part_num
WHERE objid IN (SELECT part_info2part_num FROM table_mod_level
Where Objid In (Select N_Part_Inst2part_Mod From Table_Part_Inst
Where Part_Serial_No = Ip_Esn));

part_num_rec part_num_cur%rowtype;

Cursor Price_Cur (Ip_Part_Num Varchar2, Ip_Order_Id Varchar2) Is
Select Unit_Price
From X_Sales_Order_Items
Where Order_Id = Ip_Order_Id
And Part_Number = Ip_Part_Num
and rownum < 2;

price_rec price_cur%rowtype;

Cursor Price_Cur_2 (Ip_Part_Num Varchar2, Ip_Order_Id Varchar2) Is
Select Unit_Price
From X_Sales_Order_Items
where order_id = ip_order_id
and part_number in (select pn1.part_number from table_part_num pn1, table_part_num pn2
                    where pn1.part_num2part_class = pn2.part_num2part_class
                    and pn2.part_number = Ip_Part_Num)
and rownum < 2;

price_rec_2 price_cur_2%rowtype;


Cursor missmatched_phone_cur (Ip_Order_Id Number) Is
Select Rowid,X_Bus_Acc_Esn.* From X_Bus_Acc_Esn
Where X_Bus_Acc_Esn.Order_Id = Ip_Order_Id
and X_Bus_Acc_Esn.Combo = -1;

missmatched_phone_rec missmatched_phone_cur%rowtype;

Cursor Missmatched_Card_Cur (Ip_Order_Id Number,Ip_Combo_Part_Number Varchar2) Is
Select rowid,X_Bus_Acc_Esn.* From X_Bus_Acc_Esn
Where Order_Id = Ip_Order_Id
and combo_part_number = ip_combo_part_number
and Combo = -2;

Missmatched_card_Rec Missmatched_card_cur%Rowtype;


CURSOR PENDING_REFUND_CUR IS
Select ORDER_ID, sum(nvl(Price,0)+nvl(Tax,0)) amount
FROM X_Bus_Acc_Esn
WHERE nvl(Returned,0)=1
AND nvl(REFUNDED,0) = 0
AND NVL(REFUND_CASE_ID,'0')='0'
AND nvl(COMBO,0) IN ( 0,1)  -- (0 = not combo, 1 = matched combo/phone record)
GROUP BY ORDER_ID;

pending_refund_rec pending_refund_cur%rowtype;


CURSOR ACCOUNT_ORDER_CUR (V_ORDER_ID NUMBER) IS
SELECT X_SALES_ORDERS.*,X_BUSINESS_ACCOUNTS.BUS_PRIMARY2CONTACT
FROM X_BUSINESS_ACCOUNTS,X_SALES_ORDERS
WHERE X_BUSINESS_ACCOUNTS.ACCOUNT_ID = X_SALES_ORDERS.ACCOUNT_ID
and x_sales_orders.order_id = v_order_id;

ACCOUNT_ORDER_REC ACCOUNT_ORDER_CUR%ROWTYPE;

Cursor Bus_Acc_Cur Is
SELECT ACCOUNT_Id FROM X_BUSINESS_ACCOUNTS;

bus_ACC_REC BUS_ACC_CUR%ROWTYPE;

Tax_Rate Number;
TAX_911 Number; --CR11553
TAX_USF Number; --CR11553
TAX_CRF Number; --CR11553
TAX_SUB NUmber; --CR11553
V_Price Number;
V_Part_Number Varchar2(30);
V_Combo Number:=0;
v_combo_part_number varchar2(30);
  P_TITLE VARCHAR2(200);
  P_CASE_TYPE VARCHAR2(200);
  P_STATUS VARCHAR2(200);
  P_PRIORITY VARCHAR2(200);
  P_ISSUE VARCHAR2(200);
  P_SOURCE VARCHAR2(200);
  P_POINT_CONTACT VARCHAR2(200);
  P_CREATION_TIME DATE;
  P_TASK_OBJID NUMBER;
  P_CONTACT_OBJID NUMBER;
  P_USER_OBJID NUMBER;
  P_ESN VARCHAR2(200);
  P_PHONE_NUM VARCHAR2(200);
  P_FIRST_NAME VARCHAR2(200);
  P_LAST_NAME VARCHAR2(200);
  P_E_MAIL VARCHAR2(200);
  P_DELIVERY_TYPE VARCHAR2(200);
  P_ADDRESS VARCHAR2(200);
  P_CITY VARCHAR2(200);
  P_STATE VARCHAR2(200);
  P_ZIPCODE VARCHAR2(200);
  P_REPL_UNITS NUMBER;
  P_FRAUD_OBJID NUMBER;
  P_CASE_DETAIL VARCHAR2(200);
  P_PART_REQUEST VARCHAR2(400);
  P_ID_NUMBER VARCHAR2(200);
  P_CASE_OBJID NUMBER;
  P_ERROR_NO VARCHAR2(200);
  P_ERROR_STR VARCHAR2(200);
  P_QUEUE_NAME VARCHAR2(200);
--CR11553
  P_b2bCombStaxAmt    NUMBER;
  P_b2bE911Amt   NUMBER;
  P_b2bUsfAmt     NUMBER;
  P_b2bRcrfAmt   NUMBER;
  P_b2bSubTotalAmount  NUMBER;
  P_b2bTotalTaxAmount    NUMBER;
  P_b2bTotalCharges   NUMBER;
  P_b2bE911Note    VARCHAR2(400);
  P_result        NUMBER;
  P_Msg   VARCHAR2(200);
begin


   For returned_esn_rec In returned_esn_cur Loop



      v_combo:=0;
      --Determine Tax Rate for the Order
   /* comm CR11553
      Open Sales_Tax_Cur (returned_esn_rec.Product_Code_1,returned_esn_rec.Order_Id);
      --Fetch Sales_Tax_Cur Into Sales_Tax_Rec;
      If Sales_Tax_Cur%Found Then
        Tax_Rate := Nvl(Sales_Tax_Rec.X_COMBSTAX,0);
      Else
        Tax_Rate := 0;
      End If;
      Close Sales_Tax_Cur; CR11553 */
           SP_TAXES.taxrate_b2b(returned_esn_rec.Order_Id,TAX_RATE,TAX_911,TAX_USF,TAX_CRF,TAX_SUB); --CR11553

      --Determine The Part Number
      Open Part_Num_Cur (Returned_Esn_Rec.Product_Code_1);
      Fetch part_num_cur Into part_num_rec;
      If Part_Num_Cur%Found Then
         v_Part_Number := part_num_rec.part_number;
      Else
         v_Part_Number := Returned_Esn_Rec.Item_Code_1;
      end if;
      close Part_Num_Cur;


      --Determine Price
      Open Price_Cur(v_Part_Number,Returned_Esn_Rec.Order_Id);
      Fetch Price_Cur Into Price_Rec;
      If Price_Cur%Found Then
         V_Price := Price_Rec.Unit_Price;
      else
         open price_cur_2(v_part_number,returned_esn_rec.order_id);
         fetch price_cur_2 into price_rec_2;
         if price_cur_2%found then
            v_price := price_rec.unit_price;
         else
            v_price := 0;
         end if;
         close price_cur_2;
      end if;
      CLOSE Price_cur;


      Update X_Sales_Order_Services
      Set Status = 'Returned'
      Where Part_Serial_No = Returned_Esn_Rec.Product_Code_1
      and order_id = Returned_Esn_Rec.Order_Id;

      Update X_Bus_Acc_Esn
      Set Returned = 1,
          price = v_price,
          TAX = V_price * TAX_RATE,
          PURCH_HDR_OBJID = RETURNED_ESN_REC.ORDER2PURCH_HDR,
          CONTACT_OBJID = RETURNED_ESN_REC.bus_primary2contact,
          combo = 0
      Where Order_Id = Returned_Esn_rec.Order_Id
      And Esn = Returned_Esn_rec.Product_Code_1;

      commit;



   end loop;



   FOR PENDING_REFUND_REC IN PENDING_REFUND_CUR LOOP

      OPEN ACCOUNT_ORDER_CUR(PENDING_REFUND_REC.ORDER_ID);
      FETCH ACCOUNT_ORDER_CUR INTO ACCOUNT_ORDER_REC;
      IF ACCOUNT_ORDER_CUR%FOUND THEN

        P_TITLE := 'Refund';
        P_CASE_TYPE := 'Refund';
        P_STATUS := 'Pending';
        P_PRIORITY := 'Low';
        P_ISSUE := 'B2B REFUND';
        P_SOURCE := 'BATCH';
        P_POINT_CONTACT := 'BATCH';
        P_CREATION_TIME := sysdate;
        P_TASK_OBJID := NULL;
        P_CONTACT_OBJID := ACCOUNT_ORDER_rec.BUS_PRIMARY2CONTACT;
        P_USER_OBJID := 268435556;
        P_ESN := NULL;
        P_PHONE_NUM := NULL;
        P_FIRST_NAME := NULL;
        P_LAST_NAME := NULL;
        P_E_MAIL := NULL;
        P_DELIVERY_TYPE := NULL;
        P_ADDRESS := NULL;
        P_CITY := NULL;
        P_STATE := NULL;
        P_ZIPCODE := NULL;
        P_REPL_UNITS := NULL;
        P_FRAUD_OBJID := NULL;
        P_PART_REQUEST := NULL;

        P_CASE_DETAIL := 'AMOUNT||'||TO_CHAR(PENDING_REFUND_REC.AMOUNT);
        P_CASE_DETAIL := P_CASE_DETAIL||'||ACOUNT_ID||'||TO_CHAR(ACCOUNT_ORDER_REC.ACCOUNT_ID);
        P_CASE_DETAIL := P_CASE_DETAIL||'||ORDER_ID||'||TO_CHAR(ACCOUNT_ORDER_REC.ORDER_ID);

        CLARIFY_CASE_PKG.CREATE_CASE(
          P_TITLE => P_TITLE,
          P_CASE_TYPE => P_CASE_TYPE,
          P_STATUS => P_STATUS,
          P_PRIORITY => P_PRIORITY,
          P_ISSUE => P_ISSUE,
          P_SOURCE => P_SOURCE,
          P_POINT_CONTACT => P_POINT_CONTACT,
          P_CREATION_TIME => P_CREATION_TIME,
          P_TASK_OBJID => P_TASK_OBJID,
          P_CONTACT_OBJID => P_CONTACT_OBJID,
          P_USER_OBJID => P_USER_OBJID,
          P_ESN => P_ESN,
          P_PHONE_NUM => P_PHONE_NUM,
          P_FIRST_NAME => P_FIRST_NAME,
          P_LAST_NAME => P_LAST_NAME,
          P_E_MAIL => P_E_MAIL,
          P_DELIVERY_TYPE => P_DELIVERY_TYPE,
          P_ADDRESS => P_ADDRESS,
          P_CITY => P_CITY,
          P_STATE => P_STATE,
          P_ZIPCODE => P_ZIPCODE,
          P_REPL_UNITS => P_REPL_UNITS,
          P_FRAUD_OBJID => P_FRAUD_OBJID,
          P_CASE_DETAIL => P_CASE_DETAIL,
          P_PART_REQUEST => P_PART_REQUEST,
          P_ID_NUMBER => P_ID_NUMBER,
          P_CASE_OBJID => P_CASE_OBJID,
          P_ERROR_NO => P_ERROR_NO,
          P_ERROR_STR => P_ERROR_STR
        );

          CLARIFY_CASE_PKG.DISPATCH_CASE(
            P_CASE_OBJID => P_CASE_OBJID,
            P_USER_OBJID => P_USER_OBJID,
            P_QUEUE_NAME => P_QUEUE_NAME,
            P_ERROR_NO => P_ERROR_NO,
            P_ERROR_STR => P_ERROR_STR
          );

          UPDATE X_BUS_ACC_ESN
          SET REFUND_CASE_ID = P_ID_NUMBER
          WHERE RETURNED=1
          AND REFUNDED = 0
          AND NVL(REFUND_CASE_ID,'0')=0
          AND COMBO IN ( 0,1)
          and ORDER_Id = PENDING_REFUND_REC.ORDER_ID;

          COMMIT;

       END IF;
       CLOSE ACCOUNT_ORDER_CUR;

   end loop;

   -- Review Account Primary /  Piggyback on Dayly Job for Refund Pre-Processing.
   For Bus_Acc_Rec In Bus_Acc_Cur Loop

      Account_Primary_Esn_Fix(Bus_Acc_REC.account_id);

   END LOOP;

END refund_pre_processing;    -----CR13581


PROCEDURE get_esn_by_bus_acc(ip_acc_id in varchar2,
                             esn_list out SYS_REFCURSOR) IS

BEGIN

Open Esn_List For
Select Account_Id,Order_Id,Case_Id,Esn,table_part_num.Part_Number,X_Code_Name Status,Tab1.X_Program_Name Plan
From X_Bus_Acc_Esn,(Select X_Program_Name,X_Esn
from x_program_enrolled,x_program_parameters
where x_program_enrolled.pgm_enroll2pgm_parameter = x_program_parameters.objid) tab1,
table_part_inst, table_x_code_table, table_mod_level, table_part_num
where tab1.x_esn (+)= x_bus_acc_esn.esn
and table_part_inst.part_serial_no= x_bus_acc_esn.esn
and table_part_inst.x_domain = 'PHONES'
and table_x_code_table.x_code_number = table_part_inst.x_part_inst_status
and table_part_inst.n_part_inst2part_mod= table_mod_level.objid
and table_mod_level.part_info2part_num = table_part_num.objid
and account_id = ip_acc_id
order by order_id desc;        -----CR13581

END;

PROCEDURE get_price_list(bus_org in varchar2,
                         zip_code in varchar2,
                         ip_domain in varchar2,
                         price_list out SYS_REFCURSOR) IS

begin

if ip_domain = 'PHONES' then

open price_list for
select * from x_b2b_phone_view
where org_id = bus_org
and domain = 'PHONES'
and X_RETAIL_PRICE>0          -----CR13581
and x_technology|| simprofile
in (
SELECT DISTINCT b.CDMA_TECH || 'NA' modelprofile
   FROM npanxx2carrierzones b, (
            SELECT DISTINCT a.ZONE,
               a.st,
               s.sim_profile,----------CR13581
               a.county
            From Carrierzones A, Carriersimpref S  ----CR13581
            WHERE a.zip = zip_code
            and a.CARRIER_NAME=s.CARRIER_NAME
            order by s.rank asc) tab1, table_x_carrier ca, table_x_carrier_group grp
      , table_x_parent pa, carrierpref pref
   WHERE b.ZONE = tab1.ZONE
   AND b.state = tab1.st
   AND ca.X_CARRIER_ID = b.carrier_id
   AND grp.OBJID = ca.CARRIER2CARRIER_GROUP
   AND pa.OBJID = grp.X_CARRIER_GROUP2X_PARENT
   AND pref.carrier_id = ca.x_carrier_id
   AND pref.st = b.state
   AND pref.county = tab1.county
   and b.CDMA_TECH = 'CDMA'
   union
   SELECT DISTINCT b.GSM_TECH  || substr(sim_profile,length(sim_profile),1) modelprofile
   FROM npanxx2carrierzones b, (
            SELECT DISTINCT a.ZONE,
               a.st,
               s.sim_profile,
               a.county
            From Carrierzones A, Carriersimpref S
            WHERE a.zip = zip_code
            and a.CARRIER_NAME=s.CARRIER_NAME
            order by s.rank asc) tab1, table_x_carrier ca, table_x_carrier_group grp
      , table_x_parent pa, carrierpref pref
   WHERE b.ZONE = tab1.ZONE
   AND b.state = tab1.st
   AND ca.X_CARRIER_ID = b.carrier_id
   AND grp.OBJID = ca.CARRIER2CARRIER_GROUP
   AND pa.OBJID = grp.X_CARRIER_GROUP2X_PARENT
   AND pref.carrier_id = ca.x_carrier_id
   AND pref.st = b.state
   And Pref.County = Tab1.County
   And B.Gsm_Tech = 'GSM')
   order by x_retail_price asc,inventory desc;  -----CR13581
   --and sim_profile in (select pref_sim_profile from x_b2b_sim_profile_view where pref_zip = zip_code and rownum < 2)); --CR13581


else

   if ip_domain = 'REDEMPTION CARDS' then
     open price_list for
     select * from x_b2b_phone_view
     WHERE DOMAIN = IP_DOMAIN
     and X_RETAIL_PRICE>0    ------CR13581
     and org_id = bus_org;

   else
     open price_list for
     select * from x_b2b_phone_view
     WHERE DOMAIN = IP_DOMAIN
     and X_RETAIL_PRICE>0; ------CR13581

   end if;

end if;

END get_price_list;

PROCEDURE insert_business_account (
IP_NAME               IN   VARCHAR2,
IP_TAX_EXEMPT 	      IN   VARCHAR2,
IP_BUS_ORG            IN   VARCHAR2,
IP_BUSINESS_DESC      IN   VARCHAR2,
IP_WEB_SITE           IN   VARCHAR2,
IP_COMMENTS           IN   VARCHAR2,
IP_ACC_STATUS         IN   VARCHAR2,
IP_FED_TAX_ID         IN   VARCHAR2,
IP_SALES_TAX_ID       IN   VARCHAR2,
IP_DEFAULT_ACT_ZIPCODE IN   VARCHAR2,
IP_BUS_PRIMARY2CONTACT IN  NUMBER,
IP_CREATED_BY          IN  VARCHAR2 ,
OP_ACCOUNT_ID  OUT    NUMBER,
OP_ERROR_NO    OUT    VARCHAR2,
OP_ERROR_STR   OUT    VARCHAR2) IS

  ID_NUMBER NUMBER;

BEGIN

   SELECT sa.X_BUS_ACCOUNTS_SEQ.NEXTVAL
     INTO ID_NUMBER
     FROM DUAL;

  OP_ERROR_NO := '0';
  OP_ERROR_STR := '';

 INSERT
   INTO sa.X_BUSINESS_ACCOUNTS
  (
    ACCOUNT_ID         ,
    NAME               ,
    TAX_EXEMPT         ,
    BUS_ORG            ,
    BUSINESS_DESC      ,
    WEB_SITE           ,
    COMMENTS           ,
    ACC_STATUS         ,
    FED_TAX_ID         ,
    SALES_TAX_ID       ,
    DEFAULT_ACT_ZIPCODE,
    BUS_PRIMARY2CONTACT,
    CREATED_BY         ,
    CREATION_DATE      ,
    LAST_UPDATED_BY    ,
    LAST_UPDATE_DATE
  )
  VALUES
  (
    ID_NUMBER         ,
    IP_NAME               ,
    IP_TAX_EXEMPT         ,
    IP_BUS_ORG            ,
    IP_BUSINESS_DESC      ,
    IP_WEB_SITE           ,
    IP_COMMENTS           ,
    IP_ACC_STATUS         ,
    IP_FED_TAX_ID         ,
    IP_SALES_TAX_ID       ,
    IP_DEFAULT_ACT_ZIPCODE,
    IP_BUS_PRIMARY2CONTACT,
    IP_CREATED_BY         ,
    SYSDATE      ,
    IP_CREATED_BY    ,
    SYSDATE
  );

---CR13581
   UPDATE TABLE_X_CONTACT_ADD_INFO
   SET X_PRERECORDED_CONSENT=0
   where add_info2contact = nvl(IP_BUS_PRIMARY2CONTACT,0);  ----CR13581

  COMMIT;


      declare

        cursor c1 is
        select objid bus_org_objid
        from  table_bus_org
        where objid in (268438257,268438258,536876745);


        cursor c2 (contact_objid number, bus_org_objid number) is
        select *
        from table_x_contact_add_info
        where add_info2contact = contact_objid
        and add_info2bus_org = bus_org_objid;
        r2 c2%rowtype;

        cursor c3 (contact_objid number) is
        select * from table_web_user
        where web_user2contact = contact_objid
        and rownum < 2;
        r3 c3%rowtype;

        cursor c4 (contact_objid number, bus_org_objid number) is
        select * from table_web_user
        where web_user2contact = contact_objid
        and web_user2bus_org = bus_org_objid;
        r4 c4%rowtype;

      --
      -- Start Block to complete missing account data
      --
      begin

         open c3 (ip_bus_primary2contact);
         fetch c3 into r3;

         for r1 in c1 loop

            open c2 (IP_BUS_PRIMARY2CONTACT,r1.bus_org_objid);
            fetch c2 into r2;
            if c2%notfound then

            insert into table_x_contact_add_info
            (objid,x_do_not_email,x_do_not_phone,x_do_not_sms,x_do_not_mail,add_info2contact,add_info2user,
             x_last_update_date,add_info2bus_org,x_dateofbirth,x_pin,x_remind_flag,x_info_request,x_prerecorded_consent)
             values (sa.seq('x_contact_add_info'),0,0,0,0,IP_BUS_PRIMARY2CONTACT,268494203,
             to_timestamp(sysdate,'DD-MON-RR HH.MI.SSXFF AM'),r1.bus_org_objid,
             to_timestamp(sysdate,'DD-MON-RR HH.MI.SSXFF AM'),null,null,null,0);

            end if;
            close c2;

            open c4 (ip_bus_primary2contact,r1.bus_org_objid);
            fetch c4 into r4;
            if c4%notfound and c3%found then

              insert into table_web_user (objid,login_name,s_login_name,password,user_key,status,
              passwd_chg,dev,ship_via,x_secret_questn,s_x_secret_questn,x_secret_ans,
              s_x_secret_ans,web_user2user,web_user2contact,web_user2lead,web_user2bus_org,x_last_update_date)
              values (sa.seq('web_user'),r3.login_name,r3.s_login_name,r3.password,r3.user_key,r3.status,
              r3.passwd_chg,r3.dev,r3.ship_via,r3.x_secret_questn,r3.s_x_secret_questn,r3.x_secret_ans,
              r3.s_x_secret_ans,r3.web_user2user,r3.web_user2contact,r3.web_user2lead,r1.bus_org_objid,r3.x_last_update_date);

            end if;
            close c4;

         end loop;
         close c3;
         commit;
      exception
         when others then null;
      end;
      --
      -- End Block to complete missing account data
      --

  OP_ACCOUNT_ID := ID_NUMBER;

/*
      EXCEPTION
      WHEN OTHERS
      THEN
         OP_ACCOUNT_ID := NULL;
         OP_ERROR_NO := '100';
         OP_ERROR_STR := SQLERRM;
*/
END;

PROCEDURE insert_sales_order(
	IP_ACCOUNT_ID IN NUMBER,
  IP_SHIP_ADDRESS IN VARCHAR2,
	IP_SHIP_ADDRESS_2 IN VARCHAR2,
	IP_SHIP_CITY  IN VARCHAR2,
	IP_SHIP_STATE IN VARCHAR2,
	IP_SHIP_ZIPCODE IN VARCHAR2,
  IP_BILL_ADDRESS IN VARCHAR2,
	IP_BILL_ADDRESS_2 IN VARCHAR2,
	IP_BILL_CITY IN VARCHAR2,
	IP_BILL_STATE IN VARCHAR2,
	IP_BILL_ZIPCODE IN VARCHAR2,
	IP_ORDER2PAYMENT_SOURCE IN NUMBER,
  IP_ORDER2PURCH_HDR IN  NUMBER,
  IP_TERMS_AND_COND_CHECK IN  NUMBER,
  IP_SUB_TOTAL_ITEMS IN  NUMBER,
  IP_SUB_TOTAL_AIR IN NUMBER,
  IP_ITEMS_TAX IN NUMBER,
  IP_AIR_TAX IN NUMBER,
  IP_E911_FEE IN NUMBER,
  IP_SHIPPING_OPTION IN VARCHAR2,
  IP_SHIPPING_COST IN NUMBER,
	IP_ORDER_TOTAL IN NUMBER,
  IP_ORDER_STATUS IN VARCHAR2,
  IP_ENROLL_STATUS IN VARCHAR2,
	IP_CREATED_BY IN VARCHAR2,
  IP_NOTES IN VARCHAR2,
  OP_ORDER_DATE OUT DATE,
  OP_ORDER_ID    OUT NUMBER,
  OP_ERROR_NO    OUT    VARCHAR2,
  OP_ERROR_STR   OUT    VARCHAR2) IS

  ID_NUMBER NUMBER;

BEGIN

  OP_ERROR_NO := '0';
  OP_ERROR_STR := '';

  SELECT sa.get_next_sales_order_id
  INTO ID_NUMBER
  FROM DUAL;

  insert into sa.X_SALES_ORDERS
   (ORDER_ID,
    ORDER_DATE,
	  ACCOUNT_ID,
	  SHIP_ADDRESS,
	  SHIP_ADDRESS_2,
	  SHIP_CITY,
	  SHIP_STATE,
	  SHIP_ZIPCODE,
	  BILL_ADDRESS,
	  BILL_ADDRESS_2,
	  BILL_CITY,
	  BILL_STATE,
	  BILL_ZIPCODE,
	  ORDER2PAYMENT_SOURCE,
	  ORDER2PURCH_HDR,
	  TERMS_AND_COND_CHECK,
    SUB_TOTAL_ITEMS,
	  SUB_TOTAL_AIR,
	  ITEMS_TAX,
	  AIR_TAX,
	  E911_FEE,
	  SHIPPING_OPTION,
	  SHIPPING_COST,
	  ORDER_TOTAL,
	  ORDER_STATUS,
	  ENROLL_STATUS,
	  CREATED_BY,
    NOTES,
	  CREATION_DATE,
	  LAST_UPDATED_BY,
	  LAST_UPDATE_DATE) values
       (ID_NUMBER,
    SYSDATE,
	  IP_ACCOUNT_ID,
	  IP_SHIP_ADDRESS,
	  IP_SHIP_ADDRESS_2,
	  IP_SHIP_CITY,
	  IP_SHIP_STATE,
	  IP_SHIP_ZIPCODE,
	  IP_BILL_ADDRESS,
	  IP_BILL_ADDRESS_2,
	  IP_BILL_CITY,
	  IP_BILL_STATE,
	  IP_BILL_ZIPCODE,
	  IP_ORDER2PAYMENT_SOURCE,
	  IP_ORDER2PURCH_HDR,
	  IP_TERMS_AND_COND_CHECK,
    IP_SUB_TOTAL_ITEMS,
	  IP_SUB_TOTAL_AIR,
	  IP_ITEMS_TAX,
    IP_AIR_TAX,
	  IP_E911_FEE,
	  IP_SHIPPING_OPTION,
	  IP_SHIPPING_COST,
	  IP_ORDER_TOTAL,
	  IP_ORDER_STATUS,
	  IP_ENROLL_STATUS,
	  IP_CREATED_BY,
    IP_NOTES,
	  SYSDATE,
	  IP_CREATED_BY,
	  SYSDATE);

    COMMIT;

    OP_ORDER_DATE := sysdate;
    OP_ORDER_ID := ID_NUMBER;

/*CR13581
        EXCEPTION
      WHEN OTHERS
      THEN
         OP_ORDER_ID := NULL;
         OP_ERROR_NO := '10';
         OP_ERROR_STR := SQLERRM;
*/
END;

PROCEDURE insert_sale_order_item(
  IP_ORDER_ID IN NUMBER,
  IP_LINE_TYPE IN  VARCHAR2,
  IP_ZIP_CODE IN VARCHAR2,
	IP_PART_NUMBER IN VARCHAR2,
  IP_AIRTIME_PLAN IN VARCHAR2,
	IP_QUANTITY IN NUMBER,
	IP_UNIT_PRICE IN NUMBER,
  IP_PLAN_PRICE IN NUMBER,
	IP_CREATED_BY IN VARCHAR2,
	OP_LINE_ITEM_ID OUT NUMBER,
  OP_ERROR_NO    OUT    VARCHAR2,
  OP_ERROR_STR   OUT    VARCHAR2) IS

  ID_NUMBER NUMBER;

  BEGIN

  OP_ERROR_NO := '0';
  OP_ERROR_STR := '';

     SELECT sa.X_SALES_ORDER_ITEM_SEQ.NEXTVAL
     INTO ID_NUMBER
     FROM DUAL;

  INSERT INTO sa.X_SALES_ORDER_ITEMS (
  ORDER_ID,
LINE_ITEM_ID,
LINE_TYPE,
ZIP_CODE,
PART_NUMBER,
AIRTIME_PLAN,
QUANTITY,
UNIT_PRICE,
PLAN_PRICE,
CREATED_BY,
CREATION_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_DATE,
ORIGINAL_QTY) VALUES (
IP_ORDER_ID,
ID_NUMBER,
IP_LINE_TYPE,
IP_ZIP_CODE,
IP_PART_NUMBER,
IP_AIRTIME_PLAN,
IP_QUANTITY,
IP_UNIT_PRICE,
IP_PLAN_PRICE,
IP_CREATED_BY,
SYSDATE,
IP_CREATED_BY,
SYSDATE,
IP_QUANTITY);

COMMIT;

 op_line_item_id := id_number;
/*  CR13581
  EXCEPTION
      WHEN OTHERS
      THEN
         OP_LINE_ITEM_Id := NULL;
         OP_ERROR_NO := '10';
         OP_ERROR_STR := SQLERRM;
*/
  END;

PROCEDURE insert_sales_order_service(
  IP_ORDER_ID NUMBER,
  IP_LINE_ITEM_ID NUMBER,
  IP_SERVICE_TYPE IN VARCHAR2,
  IP_ACT_ZIP_CODE IN VARCHAR2,
	IP_PART_NUMBER IN VARCHAR2,
  IP_PART_SERIAL_NO IN VARCHAR2,
  IP_SIM_SERIAL_NO IN VARCHAR2,
  IP_AIRTIME_PLAN IN VARCHAR2,
  IP_FIRST_NAME IN VARCHAR2,
  IP_LAST_NAME  IN VARCHAR2,
  IP_BUSINESS_NAME IN VARCHAR2,
  IP_TAX_ID_NUMBER IN VARCHAR2,
  IP_CONTACT_FIRST_NAME IN VARCHAR2,
  IP_CONTACT_LAST_NAME IN VARCHAR2,
  IP_ADDRESS IN VARCHAR2,
	IP_ADDRESS_2 IN VARCHAR2,
	IP_CITY IN VARCHAR2,
	IP_STATE IN VARCHAR2,
	IP_ZIP_CODE IN VARCHAR2,
  IP_NUMBER_TO_PORT IN VARCHAR2,
  IP_SSN_LAST_4 IN VARCHAR2,
  IP_PROVIDER IN VARCHAR2,
  IP_PROV_ACC_NUMBER IN VARCHAR2,
  IP_PROV_PASS_PIN IN VARCHAR2,
  IP_PORT_REQ_STATUS IN VARCHAR2,
  IP_PORT_CASE_ID IN VARCHAR2,
	IP_CREATED_BY  IN VARCHAR2,
	IP_CREATION_DATE  IN DATE,
	IP_LAST_UPDATED_BY IN VARCHAR2,
	IP_LAST_UPDATE_DATE  IN DATE,
  OP_LINE_SERV_ID OUT   NUMBER,
  OP_ERROR_NO    OUT    VARCHAR2,
  OP_ERROR_STR   OUT    VARCHAR2) IS

  ID_NUMBER NUMBER;

  BEGIN
  OP_ERROR_NO := '0';
  OP_ERROR_STR := '';

     SELECT sa.X_SALES_ORDER_SERVICES_SEQ.NEXTVAL
     INTO ID_NUMBER
     FROM DUAL;

  INSERT INTO sa.X_SALES_ORDER_SERVICES
  (ORDER_ID,
LINE_SERV_ID,
LINE_ITEM_ID,
SERVICE_TYPE,
ACT_ZIP_CODE,
PART_NUMBER,
PART_SERIAL_NO,
SIM_SERIAL_NO,
AIRTIME_PLAN,
FIRST_NAME,
LAST_NAME,
BUSINESS_NAME,
TAX_ID_NUMBER,
CONTACT_FIRST_NAME,
CONTACT_LAST_NAME,
ADDRESS,
ADDRESS_2,
CITY,
STATE,
ZIP_CODE,
NUMBER_TO_PORT,
SSN_LAST_4,
PROVIDER,
PROV_ACC_NUMBER,
PROV_PASS_PIN,
PORT_REQ_STATUS,
PORT_CASE_ID,
CREATED_BY,
CREATION_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_DATE) VALUES (
IP_ORDER_ID,
ID_NUMBER,
IP_LINE_ITEM_ID,
IP_SERVICE_TYPE,
IP_ACT_ZIP_CODE,
IP_PART_NUMBER,
IP_PART_SERIAL_NO,
IP_SIM_SERIAL_NO,
IP_AIRTIME_PLAN,
IP_FIRST_NAME,
IP_LAST_NAME,
IP_BUSINESS_NAME,
IP_TAX_ID_NUMBER,
IP_CONTACT_FIRST_NAME,
IP_CONTACT_LAST_NAME,
IP_ADDRESS,
IP_ADDRESS_2,
IP_CITY,
IP_STATE,
IP_ZIP_CODE,
IP_NUMBER_TO_PORT,
IP_SSN_LAST_4,
IP_PROVIDER,
IP_PROV_ACC_NUMBER,
IP_PROV_PASS_PIN,
IP_PORT_REQ_STATUS,
IP_PORT_CASE_ID,
IP_CREATED_BY,
SYSDATE,
IP_CREATED_BY,
SYSDATE);

COMMIT;

 OP_LINE_SERV_ID:= ID_NUMBER;

/* CR13581
  EXCEPTION
      WHEN OTHERS
      THEN
         OP_LINE_SERV_ID := NULL;
         OP_ERROR_NO := '10';
         OP_ERROR_STR := SQLERRM;
*/
  END;

PROCEDURE insert_sales_order_refund(
  IP_LINE_ITEM_ID IN NUMBER,
  IP_QTY IN NUMBER,
  IP_CREATED_BY IN VARCHAR2,
  OP_REFUND_ITEM_ID OUT NUMBER,
  OP_ERROR_NO    OUT    VARCHAR2,
  OP_ERROR_STR   OUT    VARCHAR2) IS

  ID_NUMBER NUMBER;

  cursor order_item_cur is
  select * from sa.x_sales_order_items
  where line_item_id = IP_LINE_ITEM_ID;

  order_item_rec order_item_cur%rowtype;

  BEGIN

  OP_ERROR_NO := '0';
  OP_ERROR_STR := '';

  open order_item_cur;
  fetch order_item_cur into order_item_rec;
  if order_item_cur%notfound then
     close order_item_cur;
     op_error_no := '100';
     op_error_str := 'Line Item Not Found';
     return;
  end if;
  close order_item_cur;

  SELECT sa.X_SALES_ORDER_ITEM_SEQ.NEXTVAL
  INTO ID_NUMBER
  FROM DUAL;


  INSERT INTO sa.X_SALES_ORDER_ITEMS (
  ORDER_ID,
  LINE_ITEM_ID,
  LINE_TYPE,
  ZIP_CODE,
  PART_NUMBER,
  AIRTIME_PLAN,
  QUANTITY,
  UNIT_PRICE,
  PLAN_PRICE,
  CREATED_BY,
  CREATION_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_DATE,
  ORIGINAL_QTY,
  ITEM_STATUS,
  REFUND_ITEM2PURCH_HDR,
  REFUND_ITEM2ORDER_ITEM) VALUES (
  order_item_rec.order_id,
  ID_NUMBER,
  'Refund',
  order_item_rec.zip_code,
  order_item_rec.part_number,
  order_item_rec.airtime_plan,
  IP_QTY,
  order_item_rec.unit_price,
  order_item_rec.plan_price,
  IP_CREATED_BY,
  SYSDATE,
  IP_CREATED_BY,
  SYSDATE,
  0,
  'Pending',
  null,
  IP_LINE_ITEM_ID);

COMMIT;

 OP_REFUND_ITEM_ID := ID_NUMBER;
--CR13581
 /* EXCEPTION
      WHEN OTHERS
      THEN
         OP_REFUND_ITEM_ID := NULL;
         OP_ERROR_NO := '10';
         OP_ERROR_STR := SQLERRM;
*/
  End;

PROCEDURE update_x_pricing_desc (ip_desc in varchar2,
                                 ip_type  in varchar2,
                                 ip_price_objid in number,
                                 op_result out number) is
begin
         update table_x_pricing
         set x_web_description = ip_desc,
             x_special_type =  ip_type
         where objid = ip_price_objid;
         op_result := 0;
exception
   when others then
      op_result := sqlcode;
end;

END B2B_SUPPORT_PKG;
/