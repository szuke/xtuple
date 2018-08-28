SELECT xt.create_table('poreject', 'public');

ALTER TABLE public.poreject DISABLE TRIGGER ALL;

SELECT
  xt.add_column('poreject', 'poreject_id',              'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('poreject', 'poreject_date', 'TIMESTAMP WITH TIME ZONE', NULL, 'public'),
  xt.add_column('poreject', 'poreject_ponumber',          'TEXT', NULL, 'public'),
  xt.add_column('poreject', 'poreject_itemsite_id',    'INTEGER', NULL, 'public'),
  xt.add_column('poreject', 'poreject_vend_id',        'INTEGER', NULL, 'public'),
  xt.add_column('poreject', 'poreject_vend_item_number',  'TEXT', NULL, 'public'),
  xt.add_column('poreject', 'poreject_vend_item_descrip', 'TEXT', NULL, 'public'),
  xt.add_column('poreject', 'poreject_vend_uom',          'TEXT', NULL, 'public'),
  xt.add_column('poreject', 'poreject_qty',      'NUMERIC(18,6)', NULL, 'public'),
  xt.add_column('poreject', 'poreject_posted',         'BOOLEAN', NULL, 'public'),
  xt.add_column('poreject', 'poreject_rjctcode_id',    'INTEGER', NULL, 'public'),
  xt.add_column('poreject', 'poreject_poitem_id',      'INTEGER', NULL, 'public'),
  xt.add_column('poreject', 'poreject_invoiced',       'BOOLEAN', NULL, 'public'),
  xt.add_column('poreject', 'poreject_vohead_id',      'INTEGER', NULL, 'public'),
  xt.add_column('poreject', 'poreject_agent_username',    'TEXT', NULL, 'public'),
  xt.add_column('poreject', 'poreject_voitem_id',      'INTEGER', NULL, 'public'),
  xt.add_column('poreject', 'poreject_value',    'NUMERIC(18,6)', NULL, 'public'),
  xt.add_column('poreject', 'poreject_trans_username',    'TEXT', NULL, 'public'),
  xt.add_column('poreject', 'poreject_recv_id',        'INTEGER', NULL, 'public'),
  xt.add_column('poreject', 'poreject_rma',               'TEXT', NULL, 'public');

SELECT
  xt.add_constraint('poreject', 'poreject_pkey', 'PRIMARY KEY (poreject_id)', 'public'),
  xt.add_constraint('poreject', 'poreject_poreject_recv_id_fkey',
                   'FOREIGN KEY (poreject_recv_id) REFERENCES recv(recv_id)', 'public'),
  xt.add_constraint('poreject', 'poreject_poreject_vend_id_fkey',
                   'FOREIGN KEY (poreject_vend_id) REFERENCES vendinfo(vend_id)', 'public');

ALTER TABLE public.poreject ENABLE TRIGGER ALL;

COMMENT ON TABLE poreject IS 'The poreject table describes Purchase Order Items that were returned to Vendors.';

COMMENT ON COLUMN poreject.poreject_id IS 'This is the internal id of this poreject record';
COMMENT ON COLUMN poreject.poreject_date IS 'This is the date and time the return was entered into the database';
COMMENT ON COLUMN poreject.poreject_ponumber IS 'This is the number of the original Purchase Order of this item';
COMMENT ON COLUMN poreject.poreject_itemsite_id IS 'This is the Item Site into which the item had been received';
COMMENT ON COLUMN poreject.poreject_vend_id IS 'This is the Vendor from which the item had been purchased';
COMMENT ON COLUMN poreject.poreject_vend_item_number IS 'This is the Vendor''s item number for this item';
COMMENT ON COLUMN poreject.poreject_vend_item_descrip IS 'This is the Vendor''s description of this item';
COMMENT ON COLUMN poreject.poreject_vend_uom IS 'This is the Unit of Measure in which the Vendor sold this item';
COMMENT ON COLUMN poreject.poreject_qty IS 'This is the quantity of the item that was returned';
COMMENT ON COLUMN poreject.poreject_posted IS 'This indicates whether or not the return has been recorded in the General Ledger, Inventory History, and Purchase Order Item';
COMMENT ON COLUMN poreject.poreject_rjctcode_id IS 'This indicates the reason for the return';
COMMENT ON COLUMN poreject.poreject_poitem_id IS 'This is the internal id of the original Purchase Order Item';
COMMENT ON COLUMN poreject.poreject_invoiced IS 'This indicates whether the Credit Memo associated with the return has been posted';
COMMENT ON COLUMN poreject.poreject_vohead_id IS 'This is the Voucher associated with the Purchase Order Item';
COMMENT ON COLUMN poreject.poreject_agent_username IS 'This is the Purchase Order Agent responsible for the original Purchase Order';
COMMENT ON COLUMN poreject.poreject_voitem_id IS 'This is the Voucher Item associated with the Purchase Order Item';
COMMENT ON COLUMN poreject.poreject_value IS 'This is the value (in base currency) of the return at the time it was posted to the General Ledger';
COMMENT ON COLUMN poreject.poreject_trans_username IS 'This is the user who recorded the return';
