CREATE OR REPLACE PACKAGE sa."PROCESS_MANAGER" AS
--
PROCEDURE checkactivationattrval (
    focus_type               IN NUMBER,    -- Owning object db type
    focus_lowid              IN NUMBER,    -- Owning object objid
    attr_name                IN VARCHAR2,  -- Attribute Name
    rqst_inst_objid          IN NUMBER,    -- The request instance being processed
    empl_objid               IN NUMBER,    -- The employee objid
    com_tmplte_title         IN VARCHAR2,  -- Title of com_tmplte for time bomb
    ora_date_format          IN VARCHAR2,  -- The Oracle date format to convert returned value to string
    cached_time_bomb_id      IN NUMBER,    -- Cached time_bomb objid for reuse as needed
    cached_rqst_pending_id   IN NUMBER,    -- Cached rqst_pending objid for possible reuse
    new_time_bomb_id         OUT NUMBER,   -- New time_bomb objid for use next time
    new_rqst_pending_id      OUT NUMBER,   -- New rqst_pending objid for use next time
    attr_value               OUT VARCHAR2, -- The attr value (if its there!)
    return_status            OUT NUMBER    -- 1=time elapsed,2=time not elapsed,0=error
);
--
PROCEDURE checkdependentattrval (
    focus_type               IN NUMBER,   -- Owning object db type
    focus_lowid              IN NUMBER,
    attr_name                IN VARCHAR2,
    rqst_inst_objid          IN NUMBER,   -- The request instance being processed
    dependency_value         IN VARCHAR2, -- Dependency on a particular value
    ora_date_format          IN VARCHAR2, -- The Oracle date format to convert returned value to string
    cached_rqst_pending_id   IN NUMBER,   -- Cached rqst_pending objid for possible reuse
    new_rqst_pending_id      OUT NUMBER,  -- New rqst_pending objid for use next time
    attr_value               OUT VARCHAR2,-- The attr value (if its there!)
    attr_status              OUT NUMBER   -- 0 = OK,1 = Request(s) pending for dependent field,2 = Requests pending for activation
);
--
PROCEDURE lockrqstinst (
    rqst_inst_objid        IN NUMBER,   -- Objid of the x_rqst_inst
    call_string            IN VARCHAR2, -- Call string from execute_return only
    queue_objid            IN NUMBER,   -- Optional Parameter for queued rqst
    cached_rqst_queue_id   IN NUMBER,   -- Cached rqst_queue objid for possible reuse
    new_rqst_queue_id      OUT NUMBER,  -- New rqst_queue objid for use next time
    busy_flag              OUT NUMBER,  -- The busy flag: 0=free,1=busy
    used_rqst_queue_id     OUT NUMBER
);
--
PROCEDURE unlockrqstinst (
    rqst_inst_objid    IN NUMBER,   -- Objid of the x_rqst_inst
    rqst_queue_objid   OUT NUMBER,  -- Optional queue objid
    call_string        OUT VARCHAR2 -- Call string if return request
);
--
PROCEDURE updateparentgroupinst (
    parent_objid   IN NUMBER,   -- parent group insance
    delta_change   IN NUMBER,   -- change in count
    new_count      OUT NUMBER   -- new value returned
);
--
PROCEDURE setattrval (
    focus_type        IN NUMBER,   -- Owning object db type
    focus_lowid       IN NUMBER,   -- Focus objid of owning object instance
    attr_name         IN VARCHAR2,
    attr_value        IN VARCHAR2, -- The value to set
    ora_date_format   IN VARCHAR2, -- The Oracle date format to convert values to dates
    attr_status       OUT NUMBER   -- 0 = OK,1 = Request(s) pending for dependent field,2 = Requests pending for activation
);
--
END process_manager;
/