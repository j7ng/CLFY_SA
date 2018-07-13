CREATE OR REPLACE TRIGGER sa.X_RAF_REPLIES_B_U
BEFORE UPDATE OF CARD_OBJID_CUSTOMER,  CARD_OBJID_FRIEND
ON sa.X_RAF_REPLIES REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE

  l_cust_part_inst_no table_part_inst.part_serial_no%TYPE;
  l_friend_part_inst_no table_part_inst.part_serial_no%TYPE;

BEGIN

  IF ( NVL(:new.card_objid_customer,0)  <> 0 ) THEN

       SELECT part_serial_no
       INTO l_cust_part_inst_no
       FROM table_part_inst
       WHERE objid = :new.card_objid_customer;

       :new.card_smp_customer :=  l_cust_part_inst_no;
  END IF;

  IF ( NVL(:new.card_objid_friend,0) <> 0 )  THEN

       SELECT part_serial_no
       INTO l_friend_part_inst_no
       FROM table_part_inst
       WHERE objid = :new.card_objid_friend;

       :new.card_smp_friend := l_friend_part_inst_no;
  END IF;

END;
/