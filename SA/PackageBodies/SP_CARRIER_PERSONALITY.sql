CREATE OR REPLACE PACKAGE BODY sa."SP_CARRIER_PERSONALITY"
AS
/******************************************************************************
* Package Body: SP_CARRIER_PERSONALITY
* Description: This Package is designed to perform carrier personality updates/
*              create including updating personality flag for each related
*              lines.
*              Basically, the package is called by clarify form 1150
*
*   Digital TDMA updates:
*
*     If a change is made to any of the TDMA digital fields and only the
*     TDMA digital fields, Part_inst2x_new_pers is flagged with the objid of
*     the new personality record for TDMA only
*     Part_inst2x _pers is set equal to the objid of the new personality
*     record for CDMA and Analog and part_inst2x_new_pers is left as NULL
*
*   Digital TDMA and Analog  updates:
*
*    If a change is made to any of the TDMA digital fields and the analog fields
*    Part_inst2x_new_pers is flagged with the objid of the new personality
*    record for all cases except for CDMA.
*    Part_inst2x _pers is set equal to the objid of the new personality record
*    for CDMA and part_inst2x_new_pers is left as NULL
*
*   Digital CDMA updates:
*     Not available
* Created by: SL
* Date:  06/14/2000
*
* History             Author             Reason
* -------------------------------------------------------------
* 1 06/14/01          SL                 Initail version
* 2 04/10/02          SL                 Fix "Fetch out of sequence" problem
  3 01/10/03          SU                 Added New Parameters for DMO and modified personality updates for
                                          CDMA and TDMA phones.
  4 04/10/03          SL                 Clarify Upgrade - sequence
  5 06/23/04          Chandra            Commented out Master SID Insert code, since this will be done
                                         now in CB code (Form 1150)
*********************************************************************************/

 type mytab is table of varchar2(50) index by binary_integer;

 procedure next_pid 	(p_next_pid OUT number) ;
 procedure sid2band    ( p_sid varchar2,
                        p_band OUT varchar2 );
 procedure string2tab  ( p_string varchar2,
                        p_seperator varchar2,
                        p_tab OUT mytab);
 procedure get_technology (p_min varchar2,
                           p_technology OUT varchar2,
                           p_dll OUT number);

 procedure save(p_old_pers_objid number,
              p_carrier_id  number,
			  p_country_code number,
              p_soc_id varchar2,
              p_analog_change varchar2,
   		      p_digital_change varchar2,
			  p_restrict_ld number,
			  p_restrict_callop number,
			  p_restrict_intl number,
			  p_restrict_roam number,
			  p_restrict_inbound number,
			  p_restrict_outbound number,
			  p_inoutchange_flag varchar2,
			  p_master_sid varchar2,
			  p_master_type varchar2,
			  p_lsid_string varchar2,
			  p_lac_string varchar2,
			  p_freenum1 varchar2,
			  p_freenum2 varchar2,
			  p_freenum3 varchar2,
              		  p_favored  varchar2,
              		  p_neutral  varchar2,
              		  p_partner  varchar2,
			  p_status OUT varchar2,
			  p_msg OUT varchar2) is
 v_carrier_objid number;
 v_next_pid number;
 v_country_code number;
 v_sep varchar2(1) := '~';
 v_lac_tab mytab;
 v_lsid_tab mytab;
 v_msid_tab mytab;
 v_msid_type_tab mytab;
 v_msid_band_tab mytab;

 v_new_pers_objid number;
 v_band varchar2(1);
 v_old_pers_objid number;
 cursor get_carr_line  is
   select pi.objid, pi.part_serial_no x_min,
          pi.x_part_inst_status,pi.part_inst2x_pers,
          pi.part_inst2x_new_pers,
          pi.rowid
   from table_part_inst pi
   where pi.x_domain||'' = 'LINES'
   and pi.part_inst2carrier_mkt = v_carrier_objid
   -- 04/10/02
   --for update of part_inst2x_pers,part_inst2x_new_pers nowait
   ;

 v_line_rec get_carr_line%rowtype;
 v_technology varchar2(20);
 v_sid_objid number;
 v_soc_objid number;
 v_num_line_changed number := 0;
 v_dll number ;
BEGIN

 --
 -- create new personality
 --
 select objid,x_country_code into v_carrier_objid, v_country_code
 from table_x_carrier where x_carrier_id = p_carrier_id;

 -- 04/10/03 select SEQ_X_CARR_PERSONALITY.nextval+power(2,28)
 select seq('x_carr_personality')
 into v_new_pers_objid
 from dual;

 next_pid(v_next_pid);
 IF p_old_pers_objid <> 0 THEN
  BEGIN
   select objid
   into v_soc_objid
   from table_x_soc
   where x_soc_id = p_soc_id;
  EXCEPTION
    WHEN others THEN
     v_soc_objid := null;
  END;
 END IF;
 insert into table_x_carr_personality
 (OBJID      ,
  X_FREENUM1 ,
  X_FREENUM2 ,
  X_FREENUM3 ,
  X_PID,
  X_RESTRICT_LD,
  X_RESTRICT_CALLOP ,
  X_RESTRICT_INTL ,
  X_RESTRICT_ROAM ,
  X_CARR_PERSONALITY2X_SOC,
  X_FAVORED  ,
  X_NEUTRAL ,
  X_PARTNER,
  X_SOC_ID,
  X_RESTRICT_INBOUND,
  X_RESTRICT_OUTBOUND
 ) values
 (v_new_pers_objid,
  p_freenum1,
  p_freenum2,
  p_freenum3,
  v_next_pid,
  abs(p_restrict_ld),
  abs(p_restrict_callop),
  abs(p_restrict_intl),
  abs(p_restrict_roam),
  v_soc_objid,
  p_favored,
  p_neutral,
  p_partner,
  p_soc_id,
  abs(p_restrict_inbound),
  abs(p_restrict_outbound)
  );
  commit;

  IF v_country_code <> p_country_code THEN
    update table_x_carrier
    set x_country_code = p_country_code,
        carrier2personality  = v_new_pers_objid
    where x_carrier_id = p_carrier_id;
  ELSE
    update table_x_carrier
    set carrier2personality  = v_new_pers_objid
    where x_carrier_id = p_carrier_id;
  END IF;

  string2tab(p_lac_string,v_sep,v_lac_tab);
  string2tab(p_lsid_string,v_sep,v_lsid_tab);
  string2tab(p_master_sid,v_sep,v_msid_tab);
  string2tab(p_master_type,v_sep,v_msid_type_tab);

  -- Create LAC for personality
  FOR i in 0..v_lac_tab.count -1 LOOP
    insert into table_x_lac values
    (-- 04/10/03 SEQ_X_LAC.nextval + power(2,28),
     seq('x_lac'),
     v_new_pers_objid,
     v_lac_tab(i) );
  END LOOP;

  -- Create Master sid for personality
    FOR i IN 0..v_msid_tab.count-1 LOOP

    IF v_msid_tab(i) is not null and v_msid_type_tab(i) is not null THEN

     sid2band(v_msid_tab(i),v_band);

     insert into table_x_sids values
     (seq('x_sids'),
      v_new_pers_objid,
      v_band,
      v_msid_tab(i),
      v_msid_type_tab(i),
      1);
      END IF;
      v_band := null;

  END LOOP;

  -- Create Local sid for personality
  FOR i IN 0..v_lsid_tab.count-1 LOOP

    IF v_lsid_tab(i) is not null THEN
     sid2band(v_lsid_tab(i),v_band);

     insert into table_x_sids values
     (-- 04/10/03 SEQ_X_SIDS.nextval + power(2,28),
      seq('x_sids'),
      v_new_pers_objid,
      v_band,
      v_lsid_tab(i),
      'LOCAL',
      i + 1);
      END IF;
      v_band := null;
  END LOOP;

  IF p_old_pers_objid = 0 THEN
    -- *** OLD PERS NOT EXIST ***
    FOR get_carr_line_rec in get_carr_line LOOP
      -- Process each line for this carrier
      IF get_carr_line_rec.x_part_inst_status in ('13','34') THEN
       -- update personality for active lines
       update table_part_inst
       set part_inst2x_new_pers = v_new_pers_objid
       where rowid = get_carr_line_rec.rowid;
       --where current of get_carr_line;
      ELSE
       -- update personality for non-active lines
       update table_part_inst
       set part_inst2x_pers = v_new_pers_objid,
           part_inst2x_new_pers  = null
       where rowid = get_carr_line_rec.rowid;
       --where current of get_carr_line;
      END IF;
      IF MOD(v_num_line_changed,2000) = 0 then
       commit;
      END IF;
    END LOOP;

  ELSE
    -- OLD PERS EXIST
    FOR get_carr_line_rec in get_carr_line LOOP
       get_technology(get_carr_line_rec.x_min,v_technology,v_dll);

       IF get_carr_line_rec.x_part_inst_status in ('13','34') THEN
        -- All the line are either 'Active' or 'Pending AC change'

       -- If the changes to the personality were digital only fields,
       -- then only update the digital activated lines to the new
       -- personality and flag as new. Otherwise, just link to a new
       -- personality

       IF p_digital_change = '1' AND p_analog_change = '0' THEN


        /*

	          IF v_technology = 'TDMA' THEN
	            update table_part_inst
	            set part_inst2x_new_pers = v_new_pers_objid
	            where rowid = get_carr_line_rec.rowid;
	            -- 04/10/02 where current of get_carr_line;
	            v_num_line_changed := v_num_line_changed + 1;
	          ELSE
	            update table_part_inst
	            set part_inst2x_pers = v_new_pers_objid,
	                part_inst2x_new_pers  = null
	            where rowid = get_carr_line_rec.rowid;
	            -- 04/10/02  where current of get_carr_line;
	            v_num_line_changed := v_num_line_changed + 1;
          END IF;

         */

		 -- modified by Suganthi  DMO 01/10/2003

       IF v_technology = 'TDMA' THEN

	         If    p_inoutchange_flag = 'TRUE' Then
			 		     If v_dll >= 10  then
		     		  	 		   update table_part_inst
								    set part_inst2x_new_pers = v_new_pers_objid
									where rowid = get_carr_line_rec.rowid;
									 v_num_line_changed := v_num_line_changed + 1;
             		    else

									update table_part_inst
									 set part_inst2x_pers = v_new_pers_objid,
									 part_inst2x_new_pers  = null
									 where rowid = get_carr_line_rec.rowid;
									 v_num_line_changed := v_num_line_changed + 1;
			   		     end if;

       		 Else

	                  update table_part_inst
	    	          set part_inst2x_new_pers = v_new_pers_objid
	                  where rowid = get_carr_line_rec.rowid;
	        	     v_num_line_changed := v_num_line_changed + 1;

              End if;


	     ELSE
		  	  	  IF v_technology = 'CDMA' THEN
		   		  	 		  If    p_inoutchange_flag = 'TRUE' Then
			 		    		   If v_dll >= 10  then
		     		  	 		   	   	update table_part_inst
								   	    set part_inst2x_new_pers = v_new_pers_objid
										where rowid = get_carr_line_rec.rowid;
									    v_num_line_changed := v_num_line_changed + 1;
             		   			   else

									update table_part_inst
									 set part_inst2x_pers = v_new_pers_objid,
									 part_inst2x_new_pers  = null
									 where rowid = get_carr_line_rec.rowid;
									 v_num_line_changed := v_num_line_changed + 1;

								   end if;

       		 				 Else

	                  		 	    update table_part_inst
							   		set part_inst2x_pers = v_new_pers_objid,
							   		part_inst2x_new_pers  = null
                              		where rowid = get_carr_line_rec.rowid;
                            		v_num_line_changed := v_num_line_changed + 1;


             			    End if;

		    	  Else
	             	  		  update table_part_inst
							   set part_inst2x_pers = v_new_pers_objid,
							   part_inst2x_new_pers  = null
                              where rowid = get_carr_line_rec.rowid;
                            v_num_line_changed := v_num_line_changed + 1;

		     	  End if ;


          END IF;



       END IF;

		 -- END modified by Suganthi  DMO 01/10/2003


        -- If analog change then update all records to the new personality
        IF (p_analog_change = '1'
           OR get_carr_line_rec.part_inst2x_new_pers is not null) THEN
            update table_part_inst
            set part_inst2x_new_pers = v_new_pers_objid
           where rowid = get_carr_line_rec.rowid;
           --04/10/02 where current of get_carr_line;
           v_num_line_changed := v_num_line_changed + 1;
        END IF;
    ELSE
    -- Inactive Line
      update table_part_inst
      set part_inst2x_pers = v_new_pers_objid,
          part_inst2x_new_pers  = null
      where rowid = get_carr_line_rec.rowid;
      --04/10/02 where current of get_carr_line;
      v_num_line_changed := v_num_line_changed + 1;
    END IF;

    IF MOD(v_num_line_changed,200) = 0 then
     commit;
    end if;
    END LOOP;

  END IF;
  commit;

  p_status := 'S';
  IF p_msg is not null THEN
   p_msg := p_msg||' Completed. '||v_num_line_changed||' lines updated.';
  ELSE
   p_msg := 'Completed. '||v_num_line_changed||' lines updated.';
  END IF;
exception
 when others then
  rollback;
  p_status := 'F';
  p_msg := ' Unexpected error: '||substr(sqlerrm,1,150);
end;

/*************************
* procedure next_pid (p_next_pid number)
**************************/
procedure next_pid (p_next_pid OUT number)
IS
BEGIN
  select max(x_pid)+ 1 into p_next_pid
  from table_x_carr_personality;

EXCEPTION
  WHEN others THEN
   p_next_pid := null;
END next_pid;

/*************************************
* Procedure string2tab
*           Convert String into array
**************************************/
procedure string2tab ( p_string varchar2,
                        p_seperator varchar2,
                        p_tab OUT mytab)
IS
 v_substr varchar2(2000);
 v_sep_loc number;
 v_tab_idx integer := 0;

BEGIN
 IF length(p_seperator) <> 1 THEN
   return;
 END IF;
 v_substr := p_string;
 IF substr(v_substr,length(v_substr)) <> p_seperator THEN
   v_substr := v_substr || p_seperator;
 END IF;

 v_sep_loc := instr(v_substr,p_seperator);
 WHILE (v_sep_loc > 0) LOOP
  p_tab(v_tab_idx) := substr(v_substr,1,v_sep_loc -1);
  v_tab_idx := v_tab_idx + 1;
  v_substr := substr(v_substr,v_sep_loc+1);
  v_sep_loc := instr(v_substr,p_seperator);
 END LOOP;
EXCEPTION
 WHEN others THEN
  p_tab.delete;
END string2tab;

/*************************************
* Procedure sid2band
*           Convert SID to band
**************************************/
procedure sid2band   ( p_sid varchar2,
                        p_band OUT varchar2)
IS
BEGIN
  IF mod(to_number(p_sid),2) = 0 THEN
    p_band := 'B';
  ELSE
    p_band := 'A';
  END IF;
EXCEPTION
  WHEN others THEN
    p_band := null;
END sid2band;

/*************************************
* Procedure get_technology
*           get technology for lines
**************************************/
procedure get_technology (p_min varchar2, p_technology OUT varchar2 ,p_dll OUT number)
is
v_default varchar2(20) := 'Analog';
v_dll  number := 0;
BEGIN
/*
 select  state_value
 into p_technology
 from table_site_part
 where x_min = p_min
 and part_status ||'' = 'Active';

 */

  SELECT sp.state_value ,  pn.x_dll
  into p_technology , p_dll
    FROM table_part_inst pi, table_mod_level ml,
       table_part_num pn , table_site_part sp
  WHERE  sp.x_min = p_min
  AND    sp.part_status||'' ='Active'
  AND   pi.x_part_inst2site_part = sp.objid
  AND   pi.n_part_inst2part_mod = ml.objid
  AND   pi.x_domain = 'PHONES'
  AND   ml.part_info2part_num = pn.objid
  AND   pn.domain = 'PHONES';



 IF p_technology is null THEN
  p_technology := v_default;
 END IF;

 IF p_dll is null THEN
  p_dll := v_dll;
 END IF;



EXCEPTION

 WHEN others THEN
  p_technology := v_default;
END get_technology ;

END SP_CARRIER_PERSONALITY;
/