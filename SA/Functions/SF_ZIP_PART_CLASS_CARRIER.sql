CREATE OR REPLACE FUNCTION sa."SF_ZIP_PART_CLASS_CARRIER" (
    p_zip        IN VARCHAR2,
    p_part_class IN VARCHAR2)
  RETURN parent_name_object
IS
  cursor part_num_curs is
    select part_number
      from table_part_class pc,
           table_part_num pn
     where pc.name = p_part_class
       and part_num2part_class = pc.objid
     order by part_number desc; --CR43079 -fix issue with telcel part numbers attached to ST part class;
  part_num_rec part_num_curs%rowtype;
  CURSOR act_parent_curs
  IS
    SELECT parent_name_type(x_parent_name,x_parent_id)
    FROM table_x_parent
    WHERE upper(x_status) = 'ACTIVE'
    ORDER BY x_parent_name;
  parent_tab parent_name_object  := parent_name_object();
  parent_tab2 parent_name_object := parent_name_object();
  hold      VARCHAR2(30);
  cnt       NUMBER := 0;
  rec_found BOOLEAN;
BEGIN
  open part_num_curs;
    fetch part_num_curs into part_num_rec;
    if part_num_curs%found then
      nap_service_pkg.get_list(p_zip, NULL, part_num_rec.part_number, NULL, NULL, NULL);
      IF nap_service_pkg.big_tab.count >0 THEN
        FOR i IN nap_service_pkg.big_tab.first..nap_service_pkg.big_tab.last LOOP
          parent_tab.extend;
          parent_tab(parent_tab.last) := parent_name_type(nap_service_pkg.big_tab(i).carrier_info.x_parent_name, nap_service_pkg.big_tab(i).carrier_info.x_parent_id );
        END LOOP;
      END IF;
    end if;
  close part_num_curs;
  FOR c1_rec IN ( SELECT * FROM TABLE(parent_tab)  )  LOOP
    select count(*)
      into hold
      from table(parent_tab2)
     where x_parent_name = c1_rec.x_parent_name;
      dbms_output.put_line('hold;'||hold);
    if hold = 0 then
      parent_tab2.extend;
      parent_tab2(parent_tab2.count) := parent_name_type(c1_rec.x_parent_name,c1_rec.x_parent_id);
      dbms_output.put_line('c1_rec.x_parent_name:'||c1_rec.x_parent_name);
    end if;
  END LOOP;
  RETURN parent_tab2;
END;
/