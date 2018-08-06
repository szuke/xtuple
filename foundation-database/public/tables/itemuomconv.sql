SELECT xt.create_table('itemuomconv', 'public');

ALTER TABLE public.itemuomconv DISABLE TRIGGER ALL;

SELECT
  xt.add_column('itemuomconv', 'itemuomconv_id',                 'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('itemuomconv', 'itemuomconv_item_id',           'INTEGER', 'NOT NULL', 'public'),
  xt.add_column('itemuomconv', 'itemuomconv_from_uom_id',       'INTEGER', 'NOT NULL', 'public'),
  xt.add_column('itemuomconv', 'itemuomconv_from_value', 'NUMERIC(20,10)', 'NOT NULL', 'public'),
  xt.add_column('itemuomconv', 'itemuomconv_to_uom_id',         'INTEGER', 'NOT NULL', 'public'),
  xt.add_column('itemuomconv', 'itemuomconv_to_value',   'NUMERIC(20,10)', 'NOT NULL', 'public'),
  xt.add_column('itemuomconv', 'itemuomconv_fractional',        'BOOLEAN', 'NOT NULL DEFAULT FALSE', 'public'),
  xt.add_column('itemuomconv', 'itemuomconv_active',            'BOOLEAN', 'NOT NULL DEFAULT TRUE',  'public');

SELECT
  xt.add_constraint('itemuomconv', 'itemuomconv_pkey', 'PRIMARY KEY (itemuomconv_id)', 'public'),
  xt.add_constraint('itemuomconv', 'itemuomconv_uom',
                    'CHECK (itemuomconv_from_uom_id <> itemuomconv_to_uom_id)',        'public'),
  xt.add_constraint('itemuomconv', 'itemuomconv_itemuomconv_from_uom_id_fkey',
                    'FOREIGN KEY (itemuomconv_from_uom_id) REFERENCES uom(uom_id)',    'public'),
  xt.add_constraint('itemuomconv', 'itemuomconv_itemuomconv_item_id_fkey',
                    'FOREIGN KEY (itemuomconv_item_id) REFERENCES item(item_id)',      'public'),
  xt.add_constraint('itemuomconv', 'itemuomconv_itemuomconv_to_uom_id_fkey',
                    'FOREIGN KEY (itemuomconv_to_uom_id) REFERENCES uom(uom_id)',      'public');

ALTER TABLE public.itemuomconv ENABLE TRIGGER ALL;

COMMENT ON TABLE itemuomconv IS 'UOM conversion information. From Unit to To Unit with a value per.';

COMMENT ON COLUMN itemuomconv.itemuomconv_active IS 'Item UOM conversion active/inactive';
