CREATE OR REPLACE Trigger sa.TRG_sales_Order_Services
   AFTER UPDATE OF PART_SERIAL_NO
   ON sa.X_Sales_Order_Services    FOR EACH ROW

DECLARE

   Cursor C1 Is
   Select so.*
   From sa.X_Sales_Orders So
   Where So.Order_Id = :New.Order_Id;

   Cursor C2 (Acc_Id Number)  Is
   Select *
   from sa.X_BUS_ACC_ESN
   Where Esn = :New.Part_Serial_No
   And Account_Id = acc_id;

   r2 c2%rowtype;

BEGIN

  if :New.Part_Serial_No is not null then

   For R1 In C1 Loop

      Open C2 (R1.Account_Id);
      Fetch C2 Into R2;
      if c2%notfound then

         Insert Into sa.X_Bus_Acc_Esn (Account_Id,Case_Id, Esn, Order_Id)
         Values (R1.Account_Id,r1.case_id_services,:New.Part_Serial_No,:New.Order_Id);

      End If;
      Close C2;
   end loop;

  end if;

END TRG_sales_Order_Services;
/