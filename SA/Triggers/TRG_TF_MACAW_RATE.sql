CREATE OR REPLACE TRIGGER sa.TRG_TF_MACAW_RATE
BEFORE INSERT OR UPDATE
ON sa.TF_MACAW_COUNTRY_RATE REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
declare
	new_objid number;
	unique_key_constrain exception;
 	Cursor c1 is
    	   SELECT M_COUNTRY_NAME,COUNTRY_ID,M_COUNTRY_RATE, m_start_date,m_end_date
		   FROM sa.TF_MACAW_COUNTRY_RATE
    	   WHERE M_COUNTRY_NAME  = :NEW.M_COUNTRY_NAME
		   AND COUNTRY_ID = :NEW.COUNTRY_ID;

    c1_rec c1%rowtype;

BEGIN
	 open c1;
	 fetch c1 into c1_rec;
	 IF c1%NOTFOUND then

	 	insert into sa.TF_MACAW_COUNTRY_RATE_HIST
  		(OBJID, COUNTRY_ID, M_COUNTRY_NAME, M_COUNTRY_RATE, M_START_DATE, M_END_DATE,UPDATE_STAMP)
		 values ( :NEW.objid, :NEW.COUNTRY_ID, :NEW.M_COUNTRY_NAME,:NEW.M_COUNTRY_RATE,
		     	 :NEW.M_START_DATE, :NEW.M_END_DATE, sysdate);

	 ELSE
	 	if (c1_rec.m_country_name = :new.m_country_name
		    and c1_rec.country_id = :new.country_id) then
			raise unique_key_constrain;
		end if;
	 END IF;

	 close c1;

EXCEPTION
		 WHEN unique_key_constrain then
		 if (c1_rec.m_country_rate <> :new.m_country_rate
		 	or c1_rec.m_start_date <> :new.m_start_date) then


			select max(objid) into new_objid
			from sa.TF_MACAW_COUNTRY_RATE_HIST;

			insert into sa.TF_MACAW_COUNTRY_RATE_HIST
  		    (OBJID, COUNTRY_ID, M_COUNTRY_NAME, M_COUNTRY_RATE, M_START_DATE, M_END_DATE,UPDATE_STAMP)
		     values ( new_objid +1, c1_rec.COUNTRY_ID, c1_rec.M_COUNTRY_NAME,:new.M_COUNTRY_RATE,
		  		  :new.M_START_DATE, :new.M_END_DATE, sysdate);

			delete from sa.TF_MACAW_COUNTRY_RATE
		    where COUNTRY_ID = :NEW.COUNTRY_ID
		    and M_COUNTRY_NAME = :NEW.M_COUNTRY_NAME;
		 else
		 	delete from sa.TF_MACAW_COUNTRY_RATE
		    where COUNTRY_ID = :NEW.COUNTRY_ID
		    and M_COUNTRY_NAME = :NEW.M_COUNTRY_NAME;
		 end if;

END;
/