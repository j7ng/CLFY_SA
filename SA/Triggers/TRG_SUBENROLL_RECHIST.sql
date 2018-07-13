CREATE OR REPLACE TRIGGER sa."TRG_SUBENROLL_RECHIST"
before insert or update
on sa.x_subscriber_enrollments
for each row
declare
--------------------------------------------------------------------------------------------
--$RCSfile: trg_subenroll_rechist.sql,v $
--$Revision: 1.5 $
--$Author: akhan $
--$Date: 2016/06/24 14:59:29 $
-- Asim version 1.1
--$ $Log: trg_subenroll_rechist.sql,v $
--$ Revision 1.5  2016/06/24 14:59:29  akhan
--$ bug fixes
--$
--$ Revision 1.4  2016/06/17 16:21:11  akhan
--$ Changing the triggers for adjusting address field to come from table address intead of table_contact
--$
--$ Revision 1.3  2016/06/14 19:30:32  akhan
--$ fixed a bug
--$
--$ Revision 1.2  2016/06/14 17:28:23  aganesan
--$ CR43511
--$
--$ Revision 1.1  2016/05/04 22:15:59  aganesan
--$ CR41846
--$
--------------------------------------------------------------------------------------------
begin
        insert into x_subscriber_enrollments_hist(
                SUB_ENR_OBJID,
                PGM_ENROLLED_OBJID,
                X_ESN,
                ENROLLMENT_TYPE,
                ENROLLED_STATUS,
                ENROLLED_PROGRAM,
                ENROLL_RQST_CHANNEL,
                ENR_INCEPTION_PROMO,
                ENR_RECURRING_PROMO,
                PAY_SRC_OBJID,
                WU_OBJID,
                CUST_NAME,
                CUST_ADDRESS,
                CUST_EMAIL,
                CUST_CCEXPD,
                ENROLL_START_DATE,
                NEXT_CHARGE_DATE,
                BILL_ACCT_NUM,
                BILL_GRP_NUM,
                UPDATED_BY,
                CHANGE_DATE)
        values (
                :new.OBJID,
                :new.PGM_ENROLLED_OBJID,
                :new.X_ESN,
                :new.ENROLLMENT_TYPE,
                :new.ENROLLED_STATUS,
                :new.ENROLLED_PROGRAM,
                :new.ENROLL_RQST_CHANNEL,
                :new.ENR_INCEPTION_PROMO,
                :new.ENR_RECURRING_PROMO,
                :new.PAY_SRC_OBJID,
                :new.WU_OBJID,
                :new.CUST_NAME,
                :new.CUST_ADDRESS,
                :new.CUST_EMAIL,
                :new.CUST_CCEXPD,
                :new.ENROLL_START_DATE,
                :new.NEXT_CHARGE_DATE,
                :new.BILL_ACCT_NUM,
                :new.BILL_GRP_NUM,
                :new.UPDATED_BY,
                SYSDATE);
end;
/