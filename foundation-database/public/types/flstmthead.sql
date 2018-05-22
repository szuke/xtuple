DROP TYPE IF EXISTS flstmthead CASCADE;
CREATE TYPE flstmthead AS (
        flstmthead_flhead_id integer,
        flstmthead_flcol_id integer,
        flstmthead_period_id integer,
        flstmthead_username text,
        flstmthead_typedescrip1 text,
        flstmthead_typedescrip2 text,
        flstmthead_flhead_name text,
        flstmthead_flcol_name text,
        flstmthead_month text,
        flstmthead_qtr text,
        flstmthead_year text,
        flstmthead_prmonth text,
        flstmthead_prqtr text,
        flstmthead_pryear text
);
