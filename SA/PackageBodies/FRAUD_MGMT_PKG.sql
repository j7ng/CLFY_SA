CREATE OR REPLACE PACKAGE BODY sa.Fraud_Mgmt_Pkg AS
PROCEDURE getfraudattributes(
        in_entityid     IN        VARCHAR2,
        io_key_tbl      IN OUT    KEYS_TBL,
        out_err_num     OUT       NUMBER,
        out_err_msg     OUT       VARCHAR2)
  IS
        v_key_tbl       keys_tbl := keys_tbl();
        l_key_name      x_fraud_keys.x_key_name%type;
        CURSOR cur_key_values
         IS
          SELECT  fkv.x_key_value
             FROM x_fraud_key_values fkv,
                  x_fraud_keys fk,
                  x_fraud_entity fe
             WHERE                         1 = 1
               AND upper(fe.x_entity_name)   = upper(in_entityid)
               AND upper(fe.x_entity_status) = 'ACTIVE'
               AND upper(fk.x_key_name)      = upper(l_key_name)
               AND upper(fk.x_key_status)    = 'ACTIVE'
               AND fk.objid                  = fkv.value2key
               AND fe.objid                  = fkv.value2entity
               AND upper(fkv.x_value_status) = 'ACTIVE';
        key_values_rec    cur_key_values%rowtype;
        entity_exists      NUMBER;
        kvpair_exists      NUMBER;
  BEGIN
          --> Validation 1: Is entity null
        IF in_entityid IS NULL THEN
          out_err_num := -1;
          out_err_msg := 'Entity ID must be provided.';
          RETURN;
        END IF;
          --> Validation 2: Does entity exist
        SELECT COUNT(*)
          INTO entity_exists
          FROM x_fraud_entity
          WHERE                    1 = 1
          AND upper(x_entity_name)   = upper(in_entityid)
          AND upper(x_entity_status) = 'ACTIVE' ;
        IF entity_exists = 0 THEN
          out_err_num := -1;
          out_err_msg := 'Entity does not exist.';
          RETURN;
        END IF;
        v_key_tbl         := io_key_tbl;
          --> Validation 3: Are any keys provided
        IF (v_key_tbl.count > 0) THEN  --> K-V pairs for only those keys will be returned.
                FOR i IN 1..v_key_tbl.COUNT
                  LOOP
                    l_key_name := v_key_tbl(i).key_type;
                    OPEN cur_key_values;
                    FETCH cur_key_values INTO key_values_rec;
                    v_key_tbl(i).key_value := key_values_rec.x_key_value;
                    CLOSE cur_key_values;
                    SELECT NVL2( v_key_tbl(i).key_value ,'Success','Failed')
                      INTO v_key_tbl(i).result_value
                        FROM dual;
                  END LOOP;
                  io_key_tbl := v_key_tbl;
        ELSE                          --> All K-V pairs for the entity will be returned.
                  SELECT keys_obj(fk.x_key_name, fkv.x_key_value, null)
                    BULK COLLECT INTO v_key_tbl
                      FROM x_fraud_keys fk,
                           x_fraud_key_values fkv,
                           x_fraud_entity fe
                     /*
                     WHERE 1 = 1
                       AND upper(fe.x_entity_name)  = upper(in_entityid)
                       AND fk.objid                 = fkv.value2key
                       AND fe.objid                 = fkv.value2entity;
                    */
                    WHERE                         1 = 1
                       AND upper(fe.x_entity_name)   = upper(in_entityid)
                       AND upper(fe.x_entity_status) = 'ACTIVE'
                       AND fk.objid                  = fkv.value2key
                       AND upper(fk.x_key_status)    = 'ACTIVE'
                       AND fe.objid                  = fkv.value2entity
                       AND upper(fkv.x_value_status) = 'ACTIVE';

                  FOR i IN 1..v_key_tbl.COUNT
                  LOOP
                  SELECT NVL2( v_key_tbl(i).key_value ,'Success','Failed')
                    INTO v_key_tbl(i).result_value
                      FROM dual;
                  END LOOP;
                  io_key_tbl := v_key_tbl;
        END IF;
        --> Validation 4: Do any K-V pairs exist for the entity.
        IF Io_Key_Tbl.COUNT = 0 THEN
           out_err_num := -1;
           out_err_msg := 'No key-value pairs exist for the entity.';
        END IF;
        IF out_err_num IS NULL THEN
          out_err_num := 0;
          out_err_msg := 'Success';
        END IF;
  EXCEPTION
        WHEN OTHERS THEN
          out_err_num := SQLCODE;
          out_err_msg := substr(SQLERRM, 1, 300);
          sa.util_pkg.insert_error_tab_proc(
                                        ip_action       => 'Fetching K-V pairs for fraud entity.',
                                        ip_key          => to_char(in_entityid),
                                        ip_program_name => 'SA.Fraud_Mgmt_Pkg.getFraudAttributes',
                                        ip_error_text   => out_err_msg
                                          );
  END;
------------------------------------------------------------------------------------
PROCEDURE setfraudattributes(
    in_entityid IN VARCHAR2,
    io_key_tbl  IN keys_tbl,
    out_err_num OUT NUMBER,
    out_err_msg OUT VARCHAR2 )
  is
    v_key_tbl               KEYS_TBL := keys_tbl();
    active_entity_exists    NUMBER;
    deleted_entity_exists   NUMBER;
    l_value2key             NUMBER;
    l_value2entity          NUMBER;
    l_key_type              x_fraud_keys.x_key_name%type;
    CURSOR cur_find_key
        IS SELECT objid
        from x_fraud_keys
        WHERE 1 = 1
        AND upper(x_key_name) = upper(l_key_type)
        AND upper(x_key_status) = 'ACTIVE';
    l_entity_objid          NUMBER; -- x_fraud_entity.objid%type;
    l_key_objid             NUMBER; --cur_find_key%rowtype;
    CURSOR cur_find_key_value
        IS SELECT objid
        FROM x_fraud_key_values
        WHERE 1 = 1
        AND value2entity = l_entity_objid
        and value2key = l_key_objid
        AND upper(x_value_status) = 'ACTIVE';
    l_key_value_objid       cur_find_key_value%rowtype;
  BEGIN
      --> Validation 1: Is entity null
        IF in_entityid IS NULL THEN
          out_err_num := -1;
          out_err_msg := 'Entity must be provided.';
          RETURN;
        END IF;
/*
      --> Validation 2: Does the entity already exist in deleted state
       SELECT COUNT(*)
          INTO deleted_entity_exists
          FROM x_fraud_entity
          where 1=1
          and upper(x_entity_name) = upper(in_entityid)
          AND upper(x_entity_status) = 'DELETED';

       IF deleted_entity_exists > 0 THEN
          out_err_num := -1;
          out_err_msg := 'This entity was previously deleted. Enter a unique entity ID.';
          RETURN;
        END IF;
*/
      --> Validation 3: Is at least one K-V pair provided
        IF (io_key_tbl.COUNT = 0) THEN
          out_err_num := -1;
          out_err_msg := 'Atleast one key-value pair must be provided.';
          RETURN;
        END IF;

       SELECT COUNT(*)
          INTO active_entity_exists
          FROM x_fraud_entity
          WHERE 1=1
          AND upper(x_entity_name) = upper(in_entityid)
          AND x_entity_status = 'ACTIVE';

        IF active_entity_exists = 0 THEN    ------------------------> create new entity and its K-V pairs
          l_entity_objid := sa.sequ_fraud_entity.nextval;
          INSERT INTO x_fraud_entity(
                                  objid,
                                  x_entity_name,
                                  x_entity_description,
                                  x_entity_status
                                  )
                              VALUES(
                                  l_entity_objid,
                                  in_entityid,
                                  upper(in_entityid),
                                  'ACTIVE'
                                  );
                    v_key_tbl         := io_key_tbl;
                    FOR i IN v_key_tbl.FIRST..v_key_tbl.LAST
                          LOOP
                                  l_key_type := v_key_tbl(i).key_type;
                                  OPEN cur_find_key;
                                  FETCH cur_find_key INTO l_key_objid;
                                  IF cur_find_key%found THEN
                                    INSERT INTO x_fraud_key_values (
                                                                    objid,
                                                                    x_key_value,
                                                                    x_value_status,
                                                                    value2entity,
                                                                    value2key
                                                                    )
                                      VALUES
                                                                    (
                                                                    sa.sequ_fraud_entity.nextval,
                                                                    v_key_tbl(i).key_value,
                                                                    'ACTIVE',
                                                                    l_entity_objid,
                                                                    l_key_objid
                                                                    );
                                  ELSE
                                      l_key_objid := sa.sequ_fraud_keys.nextval;
                                      INSERT INTO x_fraud_keys      (
                                                                    objid,
                                                                    x_key_name,
                                                                    x_key_description,
                                                                    x_key_status
                                                                    )
                                      VALUES
                                                                    (
                                                                    l_key_objid,
                                                                    upper(v_key_tbl(i).key_type),
                                                                    upper(v_key_tbl(i).key_type),
                                                                    'ACTIVE'
                                                                    );

                                      INSERT INTO x_fraud_key_values (
                                                                    objid,
                                                                    x_key_value,
                                                                    x_value_status,
                                                                    value2entity,
                                                                    value2key
                                                                    )
                                      VALUES
                                                                    (
                                                                    sa.sequ_fraud_entity.nextval,
                                                                    v_key_tbl(i).key_value,
                                                                    'ACTIVE',
                                                                    l_entity_objid,
                                                                    l_key_objid
                                                                    );
                                  END IF;
                                  CLOSE cur_find_key;
                          SELECT 'Success'INTO v_key_tbl(i).result_value FROM dual;
                          end LOOP;
        ELSE -----------------> in the case where the entity DOES exist in an ACTIVE state
           v_key_tbl         := io_key_tbl;
           SELECT objid INTO l_entity_objid FROM x_fraud_entity WHERE x_entity_name = in_entityid AND x_entity_status = 'ACTIVE';
           FOR i IN v_key_tbl.FIRST..v_key_tbl.LAST
                          LOOP
                                  l_key_type := v_key_tbl(i).key_type;
                                  OPEN cur_find_key;
                                  FETCH cur_find_key INTO l_key_objid;
                                  IF cur_find_key%found THEN
                                        OPEN cur_find_key_value;
                                        FETCH cur_find_key_value INTO l_key_value_objid;
                                        IF cur_find_key_value%found THEN
                                            UPDATE x_fraud_key_values
                                              SET x_key_value = v_key_tbl(i).key_value
                                              WHERE 1 = 1
                                              AND value2entity = l_entity_objid
                                              AND value2key = l_key_objid;
                                        ELSE
                                            INSERT INTO x_fraud_key_values (
                                                                    objid,
                                                                    x_key_value,
                                                                    x_value_status,
                                                                    value2entity,
                                                                    value2key
                                                                    )
                                            VALUES
                                                                    (
                                                                    sa.sequ_fraud_entity.nextval,
                                                                    v_key_tbl(i).key_value,
                                                                    'ACTIVE',
                                                                    l_entity_objid,
                                                                    l_key_objid
                                                                    );
                                        END IF;
                                        CLOSE cur_find_key_value;
                                  ELSE ------------------> the key must be created, and also its value
                                      l_key_objid := sa.sequ_fraud_keys.nextval;
                                      INSERT INTO x_fraud_keys      (
                                                                    objid,
                                                                    x_key_name,
                                                                    x_key_description,
                                                                    x_key_status
                                                                    )
                                      VALUES
                                                                    (
                                                                    l_key_objid,
                                                                    upper(v_key_tbl(i).key_type),
                                                                    upper(v_key_tbl(i).key_type),
                                                                    'ACTIVE'
                                                                    );

                                      INSERT INTO x_fraud_key_values (
                                                                    objid,
                                                                    x_key_value,
                                                                    x_value_status,
                                                                    value2entity,
                                                                    value2key
                                                                    )
                                      VALUES
                                                                    (
                                                                    sa.sequ_fraud_entity.nextval,
                                                                    v_key_tbl(i).key_value,
                                                                    'ACTIVE',
                                                                    l_entity_objid,
                                                                    l_key_objid
                                                                    );
                                  END IF;
            SELECT 'Success'INTO v_key_tbl(i).result_value FROM dual;
            CLOSE cur_find_key;
            END LOOP;
        END IF;
        IF out_err_num IS NULL THEN
          out_err_num := 0;
          out_err_msg := 'Success';
        END IF;
  EXCEPTION
        WHEN OTHERS THEN
          out_err_num := SQLCODE;
          out_err_msg := substr(SQLERRM, 1, 300);
          sa.util_pkg.insert_error_tab_proc(
                                        ip_action       => 'Setting attributes for fraud entity.',
                                        ip_key          => to_char(in_entityid),
                                        ip_program_name => 'SA.Fraud_Mgmt_Pkg.setFraudAttributes',
                                        ip_error_text   => out_err_msg
                                          );
  END;
------------------------------------------------------------------------------------
PROCEDURE deletefraudattributes(
    in_entityid IN VARCHAR2,
    io_key_tbl  IN keys_tbl,
    out_err_num OUT NUMBER,
    out_err_msg OUT VARCHAR2 )
IS
    l_entity_objid number;
    l_key_objid number;
BEGIN
    if IN_ENTITYID is null then
        out_err_num := -1;
        out_err_msg := 'Entity ID Required';
        return;
    end if;

                 begin
                  select objid into l_entity_objid
                    from  x_fraud_entity
                    where upper(X_ENTITY_NAME) = upper(in_entityid)
                    and X_ENTITY_STATUS = 'ACTIVE';
                  exception
                  when NO_DATA_found THEN
                    out_err_num := -1;
                    out_err_msg := 'Entity does not exist.';
                    return;
                  when others then
                    out_err_num := -1;
                    out_err_msg := 'Multiple Entities Exist.';
                    return;
                  end;
    if io_key_tbl.count = 0 then
                  begin
                   update sa.x_fraud_entity
                       set x_entity_status = 'DELETED'
                       where upper(X_ENTITY_NAME) = upper(in_entityid)
                       and objid = l_entity_objid;
                       exception
                        when others then
                         out_err_num := -1;
                         out_err_msg := 'Entity cannot be deleted';
                        return;
                  end;
                  begin
                   update sa.x_fraud_key_values
                       set x_value_status = 'DELETED'
                       where VALUE2ENTITY    = l_entity_objid;
                       exception
                        when others then
                         out_err_num := -1;
                         out_err_msg := 'Key Values cannot be deleted';
                        return;
                  end;
    else
      for i in  io_key_tbl.first..io_key_tbl.last loop
                  begin
                     select objid into l_key_objid
                     from x_fraud_keys
                     where x_key_name = io_key_tbl(i).Key_Type;
                     exception
                     when NO_DATA_found then
                       out_err_num := -1;
                       out_err_msg := 'Key: ' || io_key_tbl(i).Key_Type || 'does not exist.';
                     when others then
                       out_err_num := -1;
                       out_err_msg := 'Multiple Keys Exist';
                      return;
                  end ;
                  begin
                    update sa.x_fraud_key_values
                       set x_value_status = 'DELETED'
                       where VALUE2ENTITY = l_entity_objid
                       and value2key      = l_key_objid;
                       exception
                       when others then
                       out_err_num := -1;
                       out_err_msg := ('Key value cannot be deleted for key' || io_key_tbl(i).Key_Type);
                      return;
                  end;
      end loop;
    end if;
     if out_err_num is null then
        out_err_num := 0;
        out_err_msg := 'Success';
    end if;
EXCEPTION
        WHEN OTHERS THEN
          out_err_num := SQLCODE;
          out_err_msg := substr(SQLERRM, 1, 300);
          sa.util_pkg.insert_error_tab_proc(
                                        ip_action       => 'Deleting entity/attributes for fraud mgmt.',
                                        ip_key          => to_char(in_entityid),
                                        ip_program_name => 'SA.Fraud_Mgmt_Pkg.deletefraudattributes',
                                        ip_error_text   => out_err_msg
                                          );
END deletefraudattributes;
------------------------------------------------------------------------------------
PROCEDURE searchfraudentity(
    in_entityid IN VARCHAR2,
    in_max_rec  in number default 300,
    io_key_tbl OUT keys_tbl,
    out_err_num OUT NUMBER,
    out_err_msg OUT VARCHAR2 )
IS
BEGIN
  if IN_ENTITYID is null then
    out_err_num := -1;
    out_err_msg := 'Entity ID Required';
    return;
  end if;
   select Keys_obj(null,
                  null,
                  x_entity_name )
     BULK COLLECT INTO io_key_tbl
     from x_fraud_entity
     where upper(X_ENTITY_NAME) like upper('%'||in_entityid||'%')
     and  rownum   <= NVL(in_max_rec, 300);

  if io_key_tbl.count>0 then
      out_err_num := 0;
      out_err_msg := 'Success';
  else
      out_err_num := -1;
      out_err_msg := 'Entity IDs Are Not Availble';
  end if;
EXCEPTION
        WHEN OTHERS THEN
          out_err_num := SQLCODE;
          out_err_msg := substr(SQLERRM, 1, 300);
          sa.util_pkg.insert_error_tab_proc(
                                        ip_action       => 'Searching for fraud entity.',
                                        ip_key          => to_char(in_entityid),
                                        ip_program_name => 'SA.Fraud_Mgmt_Pkg.searchfraudentity',
                                        ip_error_text   => out_err_msg
                                          );
END searchfraudentity;
------------------------------------------------------------------------------------
procedure tasupdatefraudparams(p_x_entity_name sa.x_fraud_entity.x_entity_name%type,
                                 p_x_key_name sa.x_fraud_keys.x_key_name%type,
                                 p_x_key_value sa.x_fraud_key_values.x_key_value%type,
                                 p_x_value_status sa.x_fraud_key_values.x_value_status%type,
                                 op_out_num out number,
                                 op_out_msg out varchar2)
  is
    v_status varchar2(30) := 'ACTIVE';
    V_ENTITY_NAME sa.X_FRAUD_ENTITY.X_ENTITY_NAME%type := P_X_ENTITY_NAME; -- NEW
    v_key_name sa.x_fraud_keys.x_key_name%type := upper(p_x_key_name);
    p_value2entity number;
    p_value2key number;
    n_entity_exists number;
  begin

    op_out_num := 0;
    op_out_msg := 'Success';

    if v_entity_name is null then
      op_out_num := '-100';
      op_out_msg := 'Entity Name is required.';
      return;
    end if;
    if p_x_value_status is null or
       p_x_value_status not in ('ACTIVE','DELETED')
    then
      op_out_num := '-101';
      op_out_msg := 'A Correct Status is required.';
      return;
    end if;

    if p_x_value_status = 'ACTIVE' then

      -- VALIDATE THE ENTITY NAME DOESN'T ALREADY EXIST
      select count(*)
      into   n_entity_exists
      from   x_fraud_entity
      where  X_ENTITY_DESCRIPTION = upper(v_entity_name) -- NEW
      and   x_entity_status = 'DELETED';

      if n_entity_exists > 0 then
        op_out_num := '-102';
        op_out_msg := 'This entity name already exists, please choose another.';
        return;
      end if;

      -- FIND AND CREATE IF NEED THE ENTITY
      begin
        select objid
        into p_value2entity
        from x_fraud_entity
        where X_ENTITY_DESCRIPTION = upper(v_entity_name) -- NEW
        and   x_entity_status = 'ACTIVE';
      exception
        when others then
         p_value2entity := sa.sequ_fraud_entity.nextval;
         merge into sa.x_fraud_entity
         using (select 1 from dual)
         on   (x_entity_status = p_x_value_status
         and   X_ENTITY_DESCRIPTION = upper(v_entity_name))
         when not matched then
         insert (objid,
                 x_entity_name,
                 x_entity_description,
                 x_entity_status)
         values (p_value2entity,
                 v_entity_name,
                 UPPER(v_entity_name), -- NEW
                 p_x_value_status);
      end;

      if v_key_name is not null then
        -- FIND AND CREATE IF NEED THE ATTRIBUTE
        begin
          select objid
          into p_value2key
          from X_FRAUD_KEYS
          where upper(x_key_name) = v_key_name
          and   x_key_status = 'ACTIVE';
        exception
          when others then
           p_value2key := sa.sequ_fraud_keys.nextval;
           merge into sa.x_fraud_keys
           using (select 1 from dual)
           on   (x_key_status = p_x_value_status
           and   x_key_name   = v_key_name)
           when not matched then
           insert (objid,
                   X_KEY_NAME,
                   x_key_description,
                   X_KEY_STATUS)
           values (p_value2key,
                   p_x_key_name,
                   v_key_name,
                   p_x_value_status);
        end;

         -- ENTER THE VALUE FOR THE ENTITY'S ATTRIBUTE
         merge into sa.x_fraud_key_values
         using (select 1 from dual)
         on   (x_value_status = p_x_value_status
         and   value2entity   = p_value2entity
         and   value2key      = p_value2key)
         when matched then
         update set x_key_value = p_x_key_value
         when not matched then
         insert (objid,
                 x_key_value,
                 x_value_status,
                 value2entity,
                 value2key)
         values (sa.sequ_fraud_entity.nextval,
                 p_x_key_value,
                 p_x_value_status,
                 p_value2entity,
                 p_value2key);
      end if;

    elsif p_x_value_status = 'DELETED' then
      if v_entity_name is not null and
         v_key_name is not null then
        -- DELETE THE ATTRIBUTE FOR THE ENTITY
        update x_fraud_key_values
        set x_value_status = p_x_value_status
        where value2entity in  (select objid
                                from x_fraud_entity
                                where X_ENTITY_DESCRIPTION = upper(v_entity_name)) --NEW
        and   value2key in (select objid
                            from x_fraud_keys
                            where x_key_name = v_key_name);

      end if;
      if v_entity_name is not null and
         v_key_name is null then
        -- DELETE ALL RELATED ATTRIBUTES AND THE ENTITY
        update x_fraud_key_values
        set x_value_status = p_x_value_status
        where value2entity in  (select objid
                                from x_fraud_entity
                                where X_ENTITY_DESCRIPTION = upper(v_entity_name)) -- NEW
        and x_value_status = 'ACTIVE';

        if sql%rowcount > 0 then
          op_out_msg := 'Entity values deleted ('||sql%rowcount||')';
        end if;

        update x_fraud_entity
        set  x_entity_status = p_x_value_status
        where X_ENTITY_DESCRIPTION = upper(v_entity_name) -- NEW
        and x_entity_status = 'ACTIVE';

        if sql%rowcount > 0 then
          op_out_msg := 'Entity deleted ('||sql%rowcount||') ' ||op_out_msg;
        end if;

        if op_out_msg = 'Success' then
          op_out_msg := 'Nothing to delete.';
        end if;

      end if;
    end if;
  exception
    when others then
      op_out_num := '-103';
      op_out_msg := 'SQL ERROR: '||sqlerrm;
  end tasupdatefraudparams;
--------------------------------------------------------------------------------------------------------------------------------------------------------------
END FRAUD_MGMT_PKG;
/