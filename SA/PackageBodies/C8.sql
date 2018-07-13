CREATE OR REPLACE PACKAGE BODY sa."C8"
AS
/******************************************************************************/
/*    Copyright ) 2001 Tracfone  Wireless Inc. All rights reserved            */
/*                                                                            */
/* NAME:         SPRINT2.sql                                                  */
/* PURPOSE:                                                                   */
/* FREQUENCY:                                                                 */
/* PLATFORMS:    Oracle 8.1.7.4 AND newer versions.                           */
/* REVISIONS:                                                                 */
/* VERSION  DATE        WHO               PURPOSE                             */
/* -------  ----------  -------------  -------------------------------------- */
/* 1.0                                 	Initial Revision                      */
/* 1.1      3/12/2003   MNazir      	Number of rows limited to 2000	      */
/*                                      for get_deleted_lines procedure       */
/*									      */
/******************************************************************************/


  Function P_From_Varchar2 (p_varchar2 varchar2, p_width number) return varchar2 ;
  Function P_From_Number (p_number number, p_width number) return varchar2 ;
  Function Fill_From_Varchar2 (p_char varchar2, p_width number) return varchar2 ;
--
--

--     Constant fields pertaining to Header record ONLY
  c_ba_header		CONSTANT VARCHAR2(3) := 'HDR';
--     Constant fields pertaining to Trailer record ONLY
  c_ba_trailer		CONSTANT VARCHAR2(3) := 'TLR';
--     Constant fields pertaining to Header and Trailer record ONLY
  c_filler_a36		CONSTANT VARCHAR2(36) :=  Fill_from_Varchar2('A',36);
  c_filler_a44		CONSTANT VARCHAR2(44) :=  Fill_from_Varchar2('A',44);
  c_filler_a5		CONSTANT VARCHAR2(5) := 'AAAAA';
  c_filler_a9		CONSTANT VARCHAR2(9) := 'AAAAAAAAA';
--     Constant fields pertaining to Detail record ONLY
  c_ba_sub_loc 		CONSTANT VARCHAR2(4) := '1000';
  c_ba_ani_term_id 	CONSTANT VARCHAR2(4) := '    ';
  c_ba_order_flag	CONSTANT VARCHAR2(2) := 'SS';
  c_ba_end_cust_name	CONSTANT VARCHAR2(30) := P_From_Varchar2('TRACFONE',30);
  c_ba_btn_cust_code	CONSTANT VARCHAR2(3) := '000';
  c_ba_sds_indicator	CONSTANT VARCHAR2(2) := '  ';
  c_ba_reserved3	CONSTANT VARCHAR2(3) := '   ';
  c_ba_code_type	CONSTANT VARCHAR2(1) := ' ';
  c_ba_code_digits	CONSTANT VARCHAR2(1) := ' ';
  c_ba_reserved4	CONSTANT VARCHAR2(4) := '    ';
  c_ba_cust_type	CONSTANT VARCHAR2(1) := 'R';
  c_ba_jurisdiction	CONSTANT VARCHAR2(4) := 'E   ';
--     Constant fields pertaining to Header, Detail and Trailer records
  c_ba_mkt_grp		CONSTANT VARCHAR2(3) := 'DBG';
  c_ba_prgm_no		CONSTANT VARCHAR2(10) := '0861641010';
  c_cr 			CONSTANT VARCHAR2(1) := CHR(13);
--
--
  Function Get_Header (p_seq number, p_date varchar2) return varchar2 ;
  Function Get_Trailer (p_seq number, p_rec_count number,
                            p_date varchar2) return varchar2 ;
  Function Get_Detail (p_account varchar2, p_min varchar2, p_seq number,
                       p_rec_count number, p_date varchar2 ) return varchar2 ;
  Procedure output_line(p_filename UTL_FILE.FILE_TYPE, p_line varchar2);

--
/*****************  get_new_lines (Proc 1)  		***************/
/*                                                            */
/* Objective  : To obtain the List of lines deleted.		  */
/*                                                            */
/**************************************************************/
  procedure get_new_lines is
--     Script variables
    v_error_found	BOOLEAN := FALSE;
    v_file_name		VARCHAR2(100);
    v_output_file	UTL_FILE.FILE_TYPE;
    v_err_file		UTL_FILE.FILE_TYPE;
    v_exception_file	UTL_FILE.FILE_TYPE;

--     Script Constants
    c_ba_create_date	CONSTANT VARCHAR2(6) := to_char(sysdate,'YYMMDD');
    c_rundate		CONSTANT VARCHAR2(10) := to_char(sysdate,'YYMMDDHH24MI');
    c_max_rec		CONSTANT NUMBER := 999;        --max rec per file/commit
    c_acct_size		CONSTANT NUMBER := 9;          --acct no len
    c_path		CONSTANT VARCHAR2(100) := '/f01/invfile';
    c_file_name		CONSTANT VARCHAR2(20) := 'nl' || c_rundate;
    c_ext		CONSTANT VARCHAR2(4) :='.txt';
    c_err_file_name	CONSTANT VARCHAR2(20) := 'nlerr' || c_rundate || c_ext;
    c_exc_file_name 	CONSTANT VARCHAR2(20) := 'nlexc' || c_rundate || '.log';
--     Variable fields pertaining to Header, Detail and Trailer records
    v_ba_batch_seq_num	NUMBER(3) := 1; --starts at 001 through 999
    v_ba_rec_count	NUMBER(4) := 0; --starts at  1 through 1000
--
    cursor c_lines is
      select pi.part_serial_no,
	        ca.x_ld_account
	  from table_part_inst        pi,
	       table_x_carrier        ca
	 where (pi.x_ld_processed is null OR pi.x_ld_processed = 'DELETED')
           and pi.x_part_inst_status||'' in  ('11','12','13','15','16','37','38','39')
	   and ca.objid          = pi.part_inst2carrier_mkt
	   and ca.x_ld_provider  = 'Sprint'
	   order by ca.x_ld_account, pi.part_serial_no;
    begin
--       dbms_output.enable(1000000);
              dbms_output.put_line('A.......');

       for r_lines in c_lines loop
              dbms_output.put_line('B.......');

         if (length(ltrim(rtrim(r_lines.x_ld_account))) = c_acct_size) then   --valid account?
             if (v_ba_rec_count = 0) then                                  --create new file?
                v_file_name :=  c_file_name || P_From_Number (v_ba_batch_seq_num,3) || c_ext;
                v_output_file := utl_file.fopen(c_path,v_file_name,'w');
                output_line(v_output_file, Get_Header (v_ba_batch_seq_num, c_ba_create_date));
              dbms_output.put_line('1.......');

             end if;
--
             v_ba_rec_count := v_ba_rec_count + 1;
             output_line(v_output_file, Get_Detail( r_lines.x_ld_account,
                   r_lines.part_Serial_no,v_ba_batch_seq_num, v_ba_rec_count,c_ba_create_date ));
--
              dbms_output.put_line('2..');

            update table_part_inst
               set x_ld_processed = 'INSERTED'
                 where x_domain = 'LINES'
                       and part_serial_no = r_lines.part_serial_no;
--
              dbms_output.put_line('3..');
            if (v_ba_rec_count >= c_max_rec) then                          --reached max rec
               output_line(v_output_file, Get_Trailer (v_ba_batch_seq_num, v_ba_rec_count,
                           c_ba_create_date ));
              dbms_output.put_line('4..');
               utl_file.fclose(v_output_file);
               commit;
               v_ba_rec_count := 0;
               v_ba_batch_seq_num := v_ba_batch_seq_num + 1;
            end if;
         else                                                --error found in account number
            if not (v_error_found) then
               v_error_found := TRUE;
              dbms_output.put_line('5..');
               v_err_file := utl_file.fopen(c_path,c_err_file_name,'w');
            end if;
            output_line(v_err_file, r_lines.part_Serial_no || '  ' || r_lines.x_ld_account ||
                    '    Bad LD account number' );
         end if;
       end loop;
--
       if (v_ba_rec_count <> 0) then                          --file exist. need to close up
           output_line(v_output_file, Get_Trailer (v_ba_batch_seq_num, v_ba_rec_count,
                        c_ba_create_date ));
              dbms_output.put_line('6..');
           utl_file.fclose(v_output_file);
           commit;
       end if;
--
       if (v_error_found) then                          --error file exist. need to close up
           utl_file.fclose(v_err_file);
              dbms_output.put_line('7..');
       end if;

    EXCEPTION
      when others then
        v_exception_file := utl_file.fopen(c_path,c_exc_file_name,'w');
        output_line(v_exception_file, 'ERROR: ' || sqlerrm || ' ' || sqlcode);
        utl_file.fclose(v_exception_file);
        utl_file.fclose(v_output_file);
        if (v_error_found) then                 --error file exist. need to close up
           utl_file.fclose(v_err_file);
        end if;

    end get_new_lines;
-----------------------------------------------------
/*****************  get_deleted_lines (Proc 2)		***************/
/*                                                            */
/* Objective  : To obtain the List of lines deleted.		  */
/*                                                            */
/**************************************************************/

procedure get_deleted_lines is
--     Script variables
    v_output_file	UTL_FILE.FILE_TYPE;
    v_exception_file	UTL_FILE.FILE_TYPE;
    v_have_data		BOOLEAN := FALSE;
    v_data   		VARCHAR2(2000);
    v_cnt      		number :=1;

--     Script Constants
    c_rundate		CONSTANT VARCHAR2(10) := to_char(sysdate,'YYMMDDHH24MI');
    c_max_commit	CONSTANT NUMBER := 1000;        --max rec per commit
    c_acct_size		CONSTANT NUMBER := 9;          --acct no len
    c_path		CONSTANT VARCHAR2(100) := '/f01/invfile';
    c_file_name		CONSTANT VARCHAR2(20) := 'dl' || c_rundate || '.txt';
    c_exc_file_name 	CONSTANT VARCHAR2(20) := 'dlexc' || c_rundate || '.log';


    c_order_code        CONSTANT VARCHAR2(3) := 'BLK';
    c_ba_prgm_no_del    CONSTANT VARCHAR2(9) := substr(c_ba_prgm_no,2,9);
    c_space 		CONSTANT VARCHAR2(134) := Fill_from_Varchar2(' ',134);

    cursor c_lines is
     select pi.part_serial_no,
	    ca.x_ld_account
	  from table_part_inst        pi,
	       table_x_carrier        ca
	 where pi.x_ld_processed = 'INSERTED'
       and pi.x_part_inst_status||'' in ('17','18','33','35','36')
	   and ca.objid          = pi.part_inst2carrier_mkt
	   and ca.x_ld_provider  = 'Sprint' and rownum < 2001;
     c_lines_rec c_lines%rowtype;
    begin

       open c_lines;
         fetch c_lines into c_lines_rec;
         if c_lines%found then
           close c_lines;
           dbms_output.enable(1000000);
           v_have_data := TRUE;
           v_output_file := utl_file.fopen(c_path, c_file_name,'w');

           for r_lines in c_lines loop
             if mod(v_cnt,c_max_commit) = 0 then
               commit;
             end if;
             v_data := r_lines.part_Serial_no || r_lines.x_ld_account || c_ba_prgm_no_del;


-- Note: the following lines comment out until sprint decides how to handle blocks. We
--are processing blocks as before, sending to Troy. When sprint changes, we need to
--modify the above v_data line with whatever change sprint makes (possibly lines below).
--
--             v_data := c_order_code ||  r_lines.part_Serial_no || r_lines.part_Serial_no ||
--                       c_ba_prgm_no_del || c_space;

             output_line(v_output_file, v_data);

             update table_part_inst
                set x_ld_processed = 'DELETED'
              where x_domain = 'LINES'
                and part_serial_no = r_lines.part_serial_no;
             v_cnt := v_cnt +1;
           end loop;
           commit;
           utl_file.fclose(v_output_file );
        else
          close c_lines;
        end if;
     EXCEPTION
       when others then
         v_exception_file := utl_file.fopen(c_path,c_exc_file_name,'w');
         output_line(v_exception_file, 'ERROR: ' || sqlerrm || ' ' || sqlcode);
         utl_file.fclose(v_exception_file);
         if (v_have_data) then
           utl_file.fclose(v_output_file);
         end if;

    end get_deleted_lines;
--
-----------------------------------------------------
--
  Procedure output_line(p_filename UTL_FILE.FILE_TYPE, p_line varchar2)
    is
  begin
      utl_file.put_line(p_filename, p_line || c_cr);
  end output_line;
--
--
  Function P_From_Varchar2 (p_varchar2 varchar2, p_width number)
    return varchar2 Is
    v_text Varchar2(2000);
  begin
    v_text := rpad(nvl(ltrim(rtrim(p_varchar2)),' '),p_width,' ');
    return(v_text);
  end P_From_Varchar2;
--
--
  Function P_From_Number (p_number number, p_width number)
    return varchar2 Is
    v_text Varchar2(2000);
  begin
    v_text := lpad(nvl(to_char(p_number),' '),p_width,'0');
    return(v_text);
  end P_From_Number;
--
--
  Function Fill_From_Varchar2 (p_char varchar2, p_width number)
    return varchar2 Is
    v_text Varchar2(2000);
  begin
    if (length(p_char) <> 1) then
	  v_text := p_char;
    else
	  v_text := rpad(p_char,p_width,p_char);
    end if;
    return(v_text);
  end Fill_from_Varchar2;
--
--
  Function Get_Header (p_seq number, p_date varchar2)
    return varchar2 Is
    v_text Varchar2(2000);
    v_seq_no Varchar2(3) := P_From_Number(p_seq, 3);
  begin
    v_text := c_ba_mkt_grp || c_ba_header || c_filler_a36 || p_date ||
              c_ba_prgm_no || c_filler_a44 || v_seq_no || c_filler_a9;
    return(v_text);
  end Get_Header;
--
--
  Function Get_Trailer (p_seq number, p_rec_count number, p_date varchar2)
    return varchar2 Is
    v_text Varchar2(2000);
    v_seq_no Varchar2(3) := P_From_Number(p_seq, 3);
    v_rec_count Varchar2(4) := P_From_Number(p_rec_count, 4);
  begin
    v_text := c_ba_mkt_grp || c_ba_trailer || c_filler_a36 || p_date ||
              c_ba_prgm_no || c_filler_a44 || v_seq_no || v_rec_count || c_filler_a5;
    return(v_text);
  end Get_Trailer;
--
--
  Function Get_Detail (p_account varchar2, p_min varchar2, p_seq number, p_rec_count number,
                            p_date varchar2 )
    return varchar2 Is
    v_text Varchar2(2000);
    v_acct Varchar2(9) := P_From_Varchar2(p_account, 9);
    v_min Varchar2(10) := P_From_Varchar2(p_min, 10);
    v_seq_no Varchar2(3) := P_From_Number(p_seq, 3);
    v_rec_count Varchar2(4) := P_From_Number(p_rec_count, 4);
  begin
    v_text := c_ba_mkt_grp || v_acct || c_ba_sub_loc || v_min || v_min || c_ba_ani_term_id ||
              c_ba_order_flag || p_date || c_ba_prgm_no || c_ba_end_cust_name ||
              c_ba_btn_cust_code || c_ba_sds_indicator || c_ba_reserved3 || c_ba_code_type ||
              c_ba_code_digits || c_ba_reserved4 || v_seq_no || v_rec_count ||
              c_ba_cust_type || c_ba_jurisdiction;
    return(v_text);
  end Get_Detail;
END ;
/