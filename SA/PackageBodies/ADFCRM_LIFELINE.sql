CREATE OR REPLACE package body sa.ADFCRM_LIFELINE
AS
  FUNCTION get_lid (i_esn VARCHAR2,
                    i_min VARCHAR2)
  RETURN  VARCHAR2
  IS
    n_lid   VARCHAR2(200);
  BEGIN
    SELECT lid
    INTO   n_lid
    FROM   sa.ll_subscribers
    WHERE  current_esn = nvl( i_esn , current_esn)
	AND    current_min = i_min ;

    RETURN n_lid;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END get_lid;

  FUNCTION get_ll_enrollment_details ( i_esn        IN    VARCHAR2,
                                       i_min        IN    VARCHAR2,
                                       i_lid        IN    VARCHAR2,
                                       i_language   IN    VARCHAR2
                                     )
  RETURN get_ll_enrollment_details_tab pipelined
  is
    get_ll_enrollment_details_rslt get_ll_enrollment_details_rec;
    ll_refcursor   SYS_REFCURSOR;
  BEGIN
	IF i_esn IS NULL AND i_min IS NULL AND i_lid IS NULL
	THEN
		RETURN;
	END IF;

    get_ll_enrollment_details_rslt.objid                    := null;
    get_ll_enrollment_details_rslt.x_program_name           := null;
    get_ll_enrollment_details_rslt.x_program_desc           := null;
    get_ll_enrollment_details_rslt.x_enrollment_status      := null;
    get_ll_enrollment_details_rslt.allow_de_enroll          := null;

    FOR rec IN  (SELECT ll_sub.objid,
                        lp.plan_description x_program_name,
                        lp.plan_description x_program_desc,
                        ll_sub.enrollment_status x_enrollment_status,
                        (CASE
                          WHEN ll_sub.enrollment_status = 'ENROLLED'
                          THEN 'true'
                          ELSE 'false'
                         END) de_enroll
                 FROM   sa.ll_subscribers ll_sub,
                        sa.ll_plans lp
                 WHERE  ll_sub.lid                                            = NVL (i_lid, ll_sub.lid)
                 AND    ll_sub.current_esn                                    = NVL (i_esn, ll_sub.current_esn)
                 AND    ll_sub.current_min                                    = NVL (i_min, ll_sub.current_min)
                 AND    ll_sub.enrollment_status                              = 'ENROLLED'
                 AND    TRUNC(NVL(ll_sub.projected_deenrollment, SYSDATE+1)) >= TRUNC (SYSDATE)
                 AND    ll_sub.current_ll_plan_id                             = lp.plan_id
                 ORDER BY ll_sub.objid DESC
                )
    LOOP
      get_ll_enrollment_details_rslt.objid                    := rec.objid;
      get_ll_enrollment_details_rslt.x_program_name           := rec.x_program_name;
      get_ll_enrollment_details_rslt.x_program_desc           := rec.x_program_desc;
      get_ll_enrollment_details_rslt.x_enrollment_status      := rec.x_enrollment_status;
      get_ll_enrollment_details_rslt.allow_de_enroll          := rec.de_enroll;

      pipe row (get_ll_enrollment_details_rslt);
    END LOOP;

    -- If no ENROLLED records then display the most recent DEENROLLED record.
    IF get_ll_enrollment_details_rslt.objid IS NULL
    THEN
      OPEN ll_refcursor FOR SELECT ll_sub.objid,
                                   lp.plan_description x_program_name,
                                   lp.plan_description x_program_desc,
                                   ll_sub.enrollment_status x_enrollment_status,
                                   (CASE
                                     WHEN ll_sub.enrollment_status = 'ENROLLED'
                                     THEN 'true'
                                     ELSE 'false'
                                   END) de_enroll
                            FROM   sa.ll_subscribers ll_sub,
                                   sa.ll_plans lp
                            WHERE  ll_sub.lid                                            = NVL (i_lid, ll_sub.lid)
                            AND    ll_sub.current_esn                                    = NVL (i_esn, ll_sub.current_esn)
                            AND    ll_sub.current_min                                    = NVL (i_min, ll_sub.current_min)
                            AND    ll_sub.enrollment_status                              = 'DEENROLLED'
                            AND    TRUNC(NVL(ll_sub.projected_deenrollment, SYSDATE-1)) <= TRUNC (SYSDATE)
                            AND    ll_sub.current_ll_plan_id                             = lp.plan_id
                            ORDER BY ll_sub.objid DESC;

      FETCH ll_refcursor INTO get_ll_enrollment_details_rslt.objid,
                              get_ll_enrollment_details_rslt.x_program_name,
                              get_ll_enrollment_details_rslt.x_program_desc,
                              get_ll_enrollment_details_rslt.x_enrollment_status,
                              get_ll_enrollment_details_rslt.allow_de_enroll;

                              pipe row (get_ll_enrollment_details_rslt);
      CLOSE ll_refcursor;
    END IF;
    RETURN;
  END get_ll_enrollment_details;

END ADFCRM_LIFELINE;
/