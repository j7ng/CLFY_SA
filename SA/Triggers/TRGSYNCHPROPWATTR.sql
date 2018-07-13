CREATE OR REPLACE TRIGGER sa."TRGSYNCHPROPWATTR"
 BEFORE INSERT OR UPDATE ON sa.table_n_properties
 FOR EACH ROW

DECLARE

-- General Variables
   v_type_id             NUMBER;
   v_lic_type            VARCHAR2(30);
   v_site_id             NUMBER;
   v_default_date        DATE;
   v_objid               NUMBER;
   v_obj_num             NUMBER;
   v_update_needed       VARCHAR2(20);
   v_found               BOOLEAN;

-- N_Attribute table variables
   attr_type             NUMBER;
   attr_effectivedate    DATE;
   attr_expirationdate   date;
   attr_objid            NUMBER;

-- N_Property table variables
   prop_name             VARCHAR2(50);
   prop_type             NUMBER;
   prop_effectivedate    DATE;
   prop_expirationdate   DATE;
   prop_itemid           NUMBER;
   prop_itemtypeid       NUMBER;
   prop_tmpl_itemtypeid  NUMBER;

-- Exception variables
   incorrect_data        EXCEPTION;
   n_type_error          EXCEPTION;
   invalid_typeid_error  EXCEPTION;
   adp_tbl_oid_error     EXCEPTION;
   adp_db_header_error   EXCEPTION;
   flex_attribute        EXCEPTION;

  CURSOR c_adp_tbl_oid IS
      SELECT obj_num
        FROM sa.adp_tbl_oid
       WHERE type_id = v_type_id;

   CURSOR c_adp_db_header IS
      SELECT site_id
        FROM sa.adp_db_header;

   CURSOR c_n_attribute IS
      SELECT objid,
             n_type,
             n_expirationdate,
             n_effectivedate
        FROM sa.table_n_attribute
       WHERE n_name = prop_name;

   CURSOR c_lic_count IS
      SELECT lic_type
        FROM sa.table_lic_count
       WHERE lic_type = 'UNIV_FLEX';

   CURSOR c_n_template IS
      SELECT n_itemtypeid
        FROM sa.table_n_templates
       WHERE objid = prop_itemid;

BEGIN

   v_type_id := 5468;
   v_default_date := TO_DATE('01-01-1753','DD-MM-YYYY');
   prop_name := :NEW.n_name;

   open c_lic_count;
   FETCH c_lic_count INTO v_lic_type;
	v_found := c_lic_count%FOUND;
	close c_lic_count;

   IF v_found THEN     -- Check for FLEX License

     if (:NEW.n_name IS NULL) OR (:NEW.n_type IS NULL) OR (:NEW.objid IS NULL) OR
         (:New.n_effectivedate IS NULL) OR (:New.n_expirationdate IS NULL) THEN
              RAISE incorrect_data;
     end IF;

     prop_name := :NEW.n_name;
     prop_type := :NEW.n_type;

     prop_itemtypeid := :NEW.n_itemtypeid;
     prop_itemid     := :NEW.n_itemid;

     if prop_itemtypeid = 5420 then  -- Property is associated with a template
        open c_n_template;
        fetch c_n_template into prop_tmpl_itemtypeid;
        if c_n_template%FOUND Then
           if prop_tmpl_itemtypeid = 5470 THEN  -- Template is associated with attribute definition
              RAISE flex_attribute;  -- Cannot modify properties defined using flexible attributes forms
           end if;
        end if;
        close c_n_template;
     end if;

     open c_n_attribute;
     fetch c_n_attribute INTO attr_objid, attr_type, attr_expirationdate, attr_effectivedate;
     v_found := c_n_attribute%FOUND;
     close c_n_attribute;

     IF v_found THEN  --  N_Attribute entry already exists
          IF attr_type = prop_type THEN

             prop_effectivedate := attr_effectivedate;
             prop_expirationdate := attr_expirationdate;
             v_update_needed := 'False';

             IF :NEW.n_effectivedate IS NOT NULL AND
                TO_CHAR(:NEW.n_effectivedate,'DD-MM-YYYY') != TO_CHAR(v_default_date,'DD-MM-YYYY') AND
                :NEW.n_effectivedate < NVL(attr_effectivedate, :NEW.n_effectivedate + 1) THEN

                     prop_effectivedate := :NEW.n_effectivedate;
                     v_update_needed := 'True';

             END IF;

             IF :NEW.n_expirationdate IS NOT NULL AND
                 TO_CHAR(:NEW.n_expirationdate,'DD-MM-YYYY') != TO_CHAR(v_default_date,'DD-MM-YYYY') AND
                 :NEW.n_expirationdate > NVL(attr_expirationdate, :NEW.n_expirationdate -1) THEN

                      prop_expirationdate := :NEW.n_expirationdate;
                      v_update_needed := 'True';
             END IF;

             IF v_update_needed = 'True' THEN   -- Update on N_Attribute required

                  UPDATE sa.table_n_attribute
                    SET n_expirationdate = prop_expirationdate,
                        n_effectivedate = prop_effectivedate,
                        n_modificationdate = SYSDATE
                  WHERE n_name = prop_name;

             END IF;

          ELSE       -- N_Type differs from N_Attribute.N_Type
                RAISE n_type_error;

          END IF;

      ELSE    -- N_Attrbiute entry doesn't exist

          OPEN c_adp_db_header;
          FETCH c_adp_db_header INTO v_site_id;
          v_found := c_adp_db_header%FOUND;
          close c_adp_db_header;

          IF v_found AND v_site_id IS NOT NULL THEN

               UPDATE sa.adp_tbl_oid
                  SET obj_num = obj_num + 1
                WHERE type_id = v_type_id;

                IF SQL%NOTFOUND THEN
                     RAISE invalid_typeid_error;
                ELSE
                    OPEN c_adp_tbl_oid;
                    FETCH c_adp_tbl_oid INTO v_obj_num;
                       v_objid := (POWER(2,28) * v_site_id) + MOD (v_obj_num, POWER(2,28) ); -- generate NA.objid
                    CLOSE c_adp_tbl_oid;
               END IF;

           ELSE
               RAISE adp_db_header_error;
           END IF;

           INSERT INTO sa.table_n_attribute
            (objid,
             n_name,
             n_type,
             n_effectivedate,
             n_expirationdate,
             n_modificationdate)
           VALUES
             (v_objid,
             :NEW.n_name,
             :NEW.n_type,
             :NEW.n_effectivedate,
             :NEW.n_expirationdate,
             :NEW.n_modificationdate);

            :NEW.n_propts2n_attribute := v_objid;     -- Populate the relation

      END IF;
   END IF;

EXCEPTION
   WHEN invalid_typeid_error THEN
      RAISE_APPLICATION_ERROR(-20001, 'Invalid TypeId');
   WHEN adp_tbl_oid_error THEN
      RAISE_APPLICATION_ERROR(-20002, 'adp_tbl_oid missing entry for N_Attribute Table');
   WHEN adp_db_header_error THEN
      RAISE_APPLICATION_ERROR(-20003, 'adp_db_header corrupted');
   WHEN incorrect_data THEN
      RAISE_APPLICATION_ERROR(-20001, 'Data you entered is incorrect');
   WHEN n_type_error THEN
      RAISE_APPLICATION_ERROR(-20002, 'N_TYPE is invalid');
   WHEN flex_attribute THEN
      close c_n_template;
   WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20005, SQLCODE || '   '|| SQLERRM);

END;
/