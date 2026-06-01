-- =============================================================================
-- Pentaho Quartz Scheduler Database Creation Script
-- Database: quartz
-- Purpose: Scheduler for Pentaho Server jobs and schedules
-- =============================================================================

-- Create database
CREATE DATABASE quartz
    WITH OWNER = postgres
    ENCODING = 'UTF8'
    TABLESPACE = pg_default
    LC_COLLATE = 'en_US.utf8'
    LC_CTYPE = 'en_US.utf8'
    CONNECTION LIMIT = -1;

-- Create user
CREATE USER pentaho_user WITH PASSWORD 'password';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE quartz TO pentaho_user;

-- Connect to quartz database
\c quartz;

-- Grant schema privileges
GRANT ALL ON SCHEMA public TO pentaho_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO pentaho_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO pentaho_user;

-- Set default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO pentaho_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO pentaho_user;

-- Create Quartz tables with QRTZ5_ prefix (required by Pentaho 9.4)
CREATE TABLE QRTZ5_JOB_DETAILS (
    sched_name VARCHAR(120) NOT NULL,
    job_name VARCHAR(200) NOT NULL,
    job_group VARCHAR(200) NOT NULL,
    description VARCHAR(250),
    job_class_name VARCHAR(250) NOT NULL,
    is_durable BOOLEAN NOT NULL,
    is_nonconcurrent BOOLEAN NOT NULL,
    is_update_data BOOLEAN NOT NULL,
    requests_recovery BOOLEAN NOT NULL,
    job_data BYTEA,
    PRIMARY KEY (sched_name, job_name, job_group)
);

CREATE TABLE QRTZ5_TRIGGERS (
    sched_name VARCHAR(120) NOT NULL,
    trigger_name VARCHAR(200) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    job_name VARCHAR(200) NOT NULL,
    job_group VARCHAR(200) NOT NULL,
    description VARCHAR(250),
    next_fire_time BIGINT,
    prev_fire_time BIGINT,
    priority INTEGER,
    trigger_state VARCHAR(16) NOT NULL,
    trigger_type VARCHAR(8) NOT NULL,
    start_time BIGINT NOT NULL,
    end_time BIGINT,
    calendar_name VARCHAR(200),
    misfire_instr SMALLINT,
    job_data BYTEA,
    PRIMARY KEY (sched_name, trigger_name, trigger_group),
    FOREIGN KEY (sched_name, job_name, job_group) 
        REFERENCES QRTZ5_JOB_DETAILS(sched_name, job_name, job_group)
);

CREATE TABLE QRTZ5_SIMPLE_TRIGGERS (
    sched_name VARCHAR(120) NOT NULL,
    trigger_name VARCHAR(200) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    repeat_count BIGINT NOT NULL,
    repeat_interval BIGINT NOT NULL,
    times_triggered BIGINT NOT NULL,
    PRIMARY KEY (sched_name, trigger_name, trigger_group),
    FOREIGN KEY (sched_name, trigger_name, trigger_group) 
        REFERENCES QRTZ5_TRIGGERS(sched_name, trigger_name, trigger_group)
);

CREATE TABLE QRTZ5_CRON_TRIGGERS (
    sched_name VARCHAR(120) NOT NULL,
    trigger_name VARCHAR(200) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    cron_expression VARCHAR(120) NOT NULL,
    time_zone_id VARCHAR(80),
    PRIMARY KEY (sched_name, trigger_name, trigger_group),
    FOREIGN KEY (sched_name, trigger_name, trigger_group) 
        REFERENCES QRTZ5_TRIGGERS(sched_name, trigger_name, trigger_group)
);

CREATE TABLE QRTZ5_SIMPROP_TRIGGERS (
    sched_name VARCHAR(120) NOT NULL,
    trigger_name VARCHAR(200) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    str_prop_1 VARCHAR(512),
    str_prop_2 VARCHAR(512),
    str_prop_3 VARCHAR(512),
    int_prop_1 INTEGER,
    int_prop_2 INTEGER,
    long_prop_1 BIGINT,
    long_prop_2 BIGINT,
    dec_prop_1 NUMERIC(13,4),
    dec_prop_2 NUMERIC(13,4),
    bool_prop_1 BOOLEAN,
    bool_prop_2 BOOLEAN,
    PRIMARY KEY (sched_name, trigger_name, trigger_group),
    FOREIGN KEY (sched_name, trigger_name, trigger_group) 
        REFERENCES QRTZ5_TRIGGERS(sched_name, trigger_name, trigger_group)
);

CREATE TABLE QRTZ5_BLOB_TRIGGERS (
    sched_name VARCHAR(120) NOT NULL,
    trigger_name VARCHAR(200) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    blob_data BYTEA,
    PRIMARY KEY (sched_name, trigger_name, trigger_group),
    FOREIGN KEY (sched_name, trigger_name, trigger_group)
        REFERENCES QRTZ5_TRIGGERS(sched_name, trigger_name, trigger_group)
);

CREATE TABLE QRTZ5_CALENDARS (
    sched_name VARCHAR(120) NOT NULL,
    calendar_name VARCHAR(200) NOT NULL,
    calendar BYTEA NOT NULL,
    PRIMARY KEY (sched_name, calendar_name)
);

CREATE TABLE QRTZ5_PAUSED_TRIGGER_GRPS (
    sched_name VARCHAR(120) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    PRIMARY KEY (sched_name, trigger_group)
);

CREATE TABLE QRTZ5_FIRED_TRIGGERS (
    sched_name VARCHAR(120) NOT NULL,
    entry_id VARCHAR(95) NOT NULL,
    trigger_name VARCHAR(200) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    instance_name VARCHAR(200) NOT NULL,
    fired_time BIGINT NOT NULL,
    sched_time BIGINT NOT NULL,
    priority INTEGER NOT NULL,
    state VARCHAR(16) NOT NULL,
    job_name VARCHAR(200),
    job_group VARCHAR(200),
    is_nonconcurrent BOOLEAN,
    requests_recovery BOOLEAN,
    PRIMARY KEY (sched_name, entry_id)
);

CREATE TABLE QRTZ5_SCHEDULER_STATE (
    sched_name VARCHAR(120) NOT NULL,
    instance_name VARCHAR(200) NOT NULL,
    last_checkin_time BIGINT NOT NULL,
    checkin_interval BIGINT NOT NULL,
    PRIMARY KEY (sched_name, instance_name)
);

CREATE TABLE QRTZ5_LOCKS (
    sched_name VARCHAR(120) NOT NULL,
    lock_name VARCHAR(40) NOT NULL,
    PRIMARY KEY (sched_name, lock_name)
);

-- Create indexes
CREATE INDEX idx_qrtz5_j_req_recovery ON QRTZ5_JOB_DETAILS(sched_name, requests_recovery);
CREATE INDEX idx_qrtz5_j_grp ON QRTZ5_JOB_DETAILS(sched_name, job_group);

CREATE INDEX idx_qrtz5_t_j ON QRTZ5_TRIGGERS(sched_name, job_name, job_group);
CREATE INDEX idx_qrtz5_t_jg ON QRTZ5_TRIGGERS(sched_name, job_group);
CREATE INDEX idx_qrtz5_t_c ON QRTZ5_TRIGGERS(sched_name, calendar_name);
CREATE INDEX idx_qrtz5_t_g ON QRTZ5_TRIGGERS(sched_name, trigger_group);
CREATE INDEX idx_qrtz5_t_state ON QRTZ5_TRIGGERS(sched_name, trigger_state);
CREATE INDEX idx_qrtz5_t_n_state ON QRTZ5_TRIGGERS(sched_name, trigger_name, trigger_group, trigger_state);
CREATE INDEX idx_qrtz5_t_n_g_state ON QRTZ5_TRIGGERS(sched_name, trigger_group, trigger_state);
CREATE INDEX idx_qrtz5_t_next_fire_time ON QRTZ5_TRIGGERS(sched_name, next_fire_time);
CREATE INDEX idx_qrtz5_t_nft_st ON QRTZ5_TRIGGERS(sched_name, trigger_state, next_fire_time);
CREATE INDEX idx_qrtz5_t_nft_misfire ON QRTZ5_TRIGGERS(sched_name, misfire_instr, next_fire_time);
CREATE INDEX idx_qrtz5_t_nft_st_misfire ON QRTZ5_TRIGGERS(sched_name, misfire_instr, next_fire_time, trigger_state);
CREATE INDEX idx_qrtz5_t_nft_st_misfire_grp ON QRTZ5_TRIGGERS(sched_name, misfire_instr, next_fire_time, trigger_group, trigger_state);

CREATE INDEX idx_qrtz5_ft_trig_inst_name ON QRTZ5_FIRED_TRIGGERS(sched_name, instance_name);
CREATE INDEX idx_qrtz5_ft_inst_job_req_rcvry ON QRTZ5_FIRED_TRIGGERS(sched_name, instance_name, requests_recovery);
CREATE INDEX idx_qrtz5_ft_j_g ON QRTZ5_FIRED_TRIGGERS(sched_name, job_name, job_group);
CREATE INDEX idx_qrtz5_ft_jg ON QRTZ5_FIRED_TRIGGERS(sched_name, job_group);
CREATE INDEX idx_qrtz5_ft_t_g ON QRTZ5_FIRED_TRIGGERS(sched_name, trigger_name, trigger_group);
CREATE INDEX idx_qrtz5_ft_tg ON QRTZ5_FIRED_TRIGGERS(sched_name, trigger_group);

-- Grant table privileges
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO pentaho_user;

-- Display confirmation
SELECT 'Quartz database and tables created successfully' AS status;
