SELECT xt.create_table('imageass', 'public');

ALTER TABLE public.imageass DISABLE TRIGGER ALL;

SELECT
  xt.add_column('imageass', 'imageass_id',         'INTEGER', $$NOT NULL DEFAULT nextval('docass_docass_id_seq'::regclass)$$, 'public'),
  xt.add_column('imageass', 'imageass_source_id',  'INTEGER', 'NOT NULL', 'public'),
  xt.add_column('imageass', 'imageass_source',     'TEXT',    'NOT NULL', 'public'),
  xt.add_column('imageass', 'imageass_image_id',   'INTEGER', 'NOT NULL', 'public'),
  xt.add_column('imageass', 'imageass_purpose',    'character(1)', 'NOT NULL', 'public');

SELECT
  xt.add_constraint('imageass', 'imageass_pkey', 'PRIMARY KEY (imageass_id)', 'public'),
  xt.add_constraint('imageass', 'imageass_imageass_purpose_check', $$CHECK (imageass_purpose IN ('I','E','M','P','A','C','D','S')$$, 'public');


DELETE FROM imageass
WHERE NOT EXISTS(SELECT 1
                   FROM image
                  WHERE image_id = imageass_image_id);

SELECT
  xt.add_constraint('imageass', 'imageass_image_id_fk', 'FOREIGN KEY (imageass_image_id)
                                                         REFERENCES image (image_id) MATCH SIMPLE
                                                         ON UPDATE NO ACTION ON DELETE CASCADE', 'public');
