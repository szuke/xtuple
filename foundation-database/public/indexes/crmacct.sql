select xt.add_index('crmacct', 'crmacct_cust_id',       'crmacct_crmacct_cust_id_idx',       'btree', 'public'),
       xt.add_index('crmacct', 'crmacct_prospect_id',   'crmacct_crmacct_prospect_id_idx',   'btree', 'public');

-- Consider these:
-- SELECT
--     xt.add_index('crmacct', 'crmacct_vend_id',       'crmacct_vend_id_idx',               'btree', 'public'),
--     xt.add_index('crmacct', 'crmacct_emp_id',        'crmacct_crmacct_emp_id_idx',        'btree', 'public'),
--     xt.add_index('crmacct', 'crmacct_partner_id',    'crmacct_crmacct_partner_id_idx',    'btree', 'public'),
--     xt.add_index('crmacct', 'crmacct_salesrep_id',   'crmacct_crmacct_salesrep_id_idx',   'btree', 'public'),
--     xt.add_index('crmacct', 'crmacct_taxauth_id',    'crmacct_crmacct_taxauth_id_idx',    'btree', 'public'),
--     xt.add_index('crmacct', 'crmacct_competitor_id', 'crmacct_crmacct_competitor_id_idx', 'btree', 'public'),
--     xt.add_index('crmacct', 'crmacct_cntct_id_1',    'crmacct_crmacct_cntct_id_1_idx',    'btree', 'public'),
--     xt.add_index('crmacct', 'crmacct_cntct_id_2',    'crmacct_crmacct_cntct_id_2_idx',    'btree', 'public');
