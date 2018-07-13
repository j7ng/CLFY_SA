CREATE OR REPLACE PROCEDURE sa.SP_REFUND_CALC
                 (p_act_date        in varchar2,
                  p_deact_date      in varchar2,
                  p_refund_pct      out varchar2,
                  p_msg             out varchar2
                  )
--
--
-- Author:    Stahl Technology Services, Inc., Copyright 2002
--
-- Date:      4/02/02
--
--
-- History:
--
-- -----------------------------------------------------------------------
-- 04/02/02   STS                      Initial Version
--
IS

    v_refund_pct    number;
    v_act_date      date;
    v_deact_date    date;

BEGIN

    p_msg := '0';

    v_act_date := TO_DATE(p_act_date);
    v_deact_date := TO_DATE(p_deact_date);

    If v_act_date > v_deact_date Then
        p_msg := 'The activation date is later than the deactivation date.  Please try again.';
    End If;

    -- get refund percent
    If (v_deact_date - v_act_date) <= 30 Then
        p_refund_pct := '100';
    Else
        v_refund_pct := ((12-CEIL(months_between(last_day(v_deact_date),v_act_date )))* (1/12)) * 100;
        p_refund_pct := TO_CHAR(v_refund_pct);
    End If;

EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20001,
      'Unexpected error detected. Please contact your system administrator. '||sqlerrm);
END;
/