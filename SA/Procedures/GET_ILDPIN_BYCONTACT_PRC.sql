CREATE OR REPLACE PROCEDURE sa.get_ildpin_bycontact_prc(p_contact_objid IN NUMBER, p_ild_pin OUT VARCHAR2,p_partserial_no OUT VARCHAR2)
as

/******************************************************************************************/
/*    Copyright   2002 Tracfone  Wireless Inc. All rights reserved               	  */
/*                                                                               	  */
/* NAME:         get_ildpin_bycontact_prc                                          	  */
/* PURPOSE:      To retrieve the cards associated with the contact objid                  */
/*		 from table_x_ild_inst						          */
/* FREQUENCY:                                                                    	  */
/* PLATFORMS:    Oracle 8.0.6 AND newer versions.                                	  */
/*                                                                                        */
/* REVISIONS:                                                                    	  */
/* VERSION  DATE        WHO              PURPOSE                                          */
/* -------  ---------- -----  		 ---------------------------------------------    */
/*  1.0     07/25/03   Suganthi Uthaman  Initial  Revision                                */
/******************************************************************************************/

	Cursor all_red_cur (contact_objid IN VARCHAR2)is
	Select x_red_code , x_part_serial_no from
 	TABLE_X_ILD_INST
 	where ILD_INST2CONTACT = contact_objid ;

  	pin_count NUMBER;
  	n NUMBER :=0;

 	TYPE ild_pin_rec IS RECORD ( red_code varchar2(30),
 				     part_serial_no varchar2(30)
                                   );
 	TYPE ILD_PIN_T  IS  TABLE OF ILD_pin_rec
  	INDEX BY BINARY_INTEGER;
        ILD_PIN ILD_PIN_T    ;

BEGIN
 FOR i in all_red_cur(p_contact_objid) LOOP

 ILD_PIN(n).red_code:= system.decrpt_ild_fun(i.x_red_code , i.x_part_serial_no);
 ILD_PIN(n).part_serial_no := i.x_part_serial_no;
 n := n+1;

 END LOOP;
 pin_count := n;
 p_ild_pin := '';
 p_partserial_no:='';

 FOR j in  0..pin_count-1 LOOP

  p_ild_pin := ILD_PIN(j).red_code||'^'||p_ild_pin;
  p_ild_pin := TRIM(p_ild_pin);

  p_partserial_no := ILD_PIN(j).part_serial_no||'^'||p_partserial_no;
  p_partserial_no := TRIM(p_partserial_no);

  --dbms_output.put_line('p_ild_pin is :'||p_ild_pin);

 END LOOP;

END   get_ildpin_bycontact_prc;


/