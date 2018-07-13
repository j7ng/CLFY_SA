CREATE OR REPLACE PROCEDURE sa."SP_RESERVE_ILD_CARD" ( p_reserve_id number,
						 p_partnums   varchar2,
						 p_partcount  varchar2,
                                                 p_domain     varchar2,
                                                 p_status     OUT varchar2,
                                                 p_msg        OUT varchar2) is


/******************************************************************************************/
/*    Copyright   2002 Tracfone  Wireless Inc. All rights reserved               	  */
/*                                                                               	  */
/* NAME:         sp_reserve_ild_card                                          	          */
/* PURPOSE:      Reserves the card for purchase by  ILD Customer                          */
/*		 in table_x_cc_inv						          */
/* FREQUENCY:                                                                    	  */
/* PLATFORMS:    Oracle 8.0.6 AND newer versions.                                	  */
/*                                                                                        */
/* REVISIONS:                                                                    	  */
/* VERSION  DATE        WHO              PURPOSE                                          */
/* -------  ---------- -----  		 ---------------------------------------------    */
/*  1.0     07/25/03   Suganthi Uthaman  Initial  Revision                                */
/******************************************************************************************/


  v_found varchar2(1) := 'N';
  hold_rec varchar2(100);
  hold_rec2 varchar2(100);
  cards_found number := 0;
  loop_cnt number := 0;
  total_cards number :=0;
  m number;
  n number;
  len number;
  i number;
  occ number;
  num_partnum_occ number;
  num_count_occ number;


 TYPE ild_rec IS RECORD (
                             partnum varchar2(15),
                             partcount Number
                            );

 TYPE ILD_CARD_T  IS  TABLE OF ILD_REC
  INDEX BY BINARY_INTEGER;

  ILD_CARD ILD_CARD_T ;

BEGIN
     -----------------------------------------------------------------------

  --This block will extract the partnumbers seperated by the '^'
       BEGIN
 	   m :=1;
 	   n :=1 ;
          len := LENGTH(p_partnums);
          i:=2;
    	LOOP
	   	occ := INSTR(p_partnums ,'^',m,i-1);

	IF (occ = 0)
    	THEN

    	ILD_CARD(i-1).PARTNUM := SUBSTR( p_partnums ,n,len-n+1) ;
	num_partnum_occ := i-1;

	--dbms_output.put_line (i||' : '||part_num(i-1 ));
    	--dbms_output.put_line ('occ is'||occ);
	EXIT;
	END IF;

	ILD_CARD(i-1).PARTNUM  := SUBSTR( p_partnums ,n,occ-n) ;

	--dbms_output.put_line (i||' : '||part_num(i-1 ));
	--dbms_output.put_line ('occ is'||occ);

   	n := occ + 1;
        i := i + 1   ;

    	END LOOP;
       END;

----------------------------------------------------------------------

----------------------------------------------------------------------

       --This block will extract the count of partnumbers seperated by the '^'
        BEGIN
 	   m :=1;
 	   n :=1 ;
          len := LENGTH(p_partcount);
          i:=2;
    	LOOP
	   	occ := INSTR(p_partcount ,'^',m,i-1);
	IF (occ = 0)
    	THEN

    	ILD_CARD(i-1).PARTCOUNT:= to_number(SUBSTR( p_partcount ,n,len-n+1)) ;
	num_count_occ := i-1;
	--dbms_output.put_line (i||' : '||ILD_CARD(i-1).PARTCOUNT);
    	--dbms_output.put_line ('occ is'||occ);

	EXIT;
	END IF;

	    ILD_CARD(i-1).PARTCOUNT := to_number(SUBSTR( p_partcount ,n,occ-n)) ;

	--dbms_output.put_line (i||' : '||ILD_CARD(i-1).PARTCOUNT);
	--dbms_output.put_line ('occ is'||occ);

   	n := occ + 1;
        i := i + 1   ;

    	END LOOP;
        END;

----------------------------------------------------------------------

      FOR i in 1 .. num_count_occ LOOP
                 total_cards := total_cards + ILD_CARD(i).PARTCOUNT;
      END LOOP;


     IF (num_partnum_occ = num_count_occ) THEN
	FOR i in 1.. num_partnum_occ LOOP
       FOR j in 1..ILD_CARD(i).PARTCOUNT LOOP

       BEGIN
-----------------------------------------------------------------------
       select ild.rowid, ild.x_red_code
        into hold_rec,hold_rec2
        from table_x_cc_ILD_inv ild ,table_mod_level ml , table_part_num pn
       where ild.x_reserved_flag = 0
         and ild.x_domain = nvl(p_domain,'ILD')
         and ild.CC_ILD_INV2MOD_LEVEL =ml.objid
         and ml.part_info2part_num = pn.objid
         and pn.part_number =ILD_CARD(i).PARTNUM
         and rownum < 2
         for update nowait;

----------------------------------------------------------------------
      update table_x_cc_ild_inv
         set x_reserved_flag = 1,
             x_reserved_stmp = sysdate,
             x_reserved_id = p_reserve_id
       where rowid = hold_rec ;

     -- dbms_output.put_line('X_RED_CARD_NUMBER:'||hold_rec2);
----------------------------------------------------------------------
      commit;
----------------------------------------------------------------------

      cards_found := cards_found + 1;
     -- dbms_output.put_line('cards_found:'||cards_found);


      if cards_found = total_cards then
        v_found := 'Y';
      --  dbms_output.put_line('finished v_found := Y');
        exit;
      end if;


      if loop_cnt > 199 then
        update table_x_cc_ild_inv
           set x_reserved_flag = 0,
               x_reserved_stmp = null,
               x_reserved_id =null
         where x_reserved_id = p_reserve_id;
        commit;
       -- dbms_output.put_line('loop count 200 without reserving all cards');
        exit;
      end if;
----------------------------------------------------------------------
    exception when others then
      loop_cnt := loop_cnt + 1;
      null;
    END;
   -- dbms_output.put_line('skip and go to next card:'||loop_cnt);
    END LOOP;
    END LOOP;
    END IF;
   -- dbms_output.put_line('v_found :'||v_found);
  if v_found = 'Y' then
    p_msg := 'Completed';
    p_status := 'Y';
  else
    p_msg := 'No reserve card in the invertory.';
    p_status := 'N';
  end if;
END sp_reserve_ild_card;
/