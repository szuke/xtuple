select xt.create_table('classcodetax', 'public');

select xt.add_column('classcodetax','classcodetax_id', 'serial', 'primary key', 'public');
select xt.add_column('classcodetax','classcodetax_classcode_id', 'integer', 'NOT NULL', 'public') ;
select xt.add_column('classcodetax','classcodetax_taxtype_id', 'integer', 'NOT NULL', 'public');
select xt.add_column('classcodetax','classcodetax_taxzone_id', 'integer', null, 'public');


ALTER TABLE public.classcodetax DROP CONSTRAINT IF EXISTS classcodetax_classcodetax_classcode_id_fkey;

select xt.add_constraint('classcodetax', 'classcodetax_classcodetax_classcode_id_fkey',
                                       'FOREIGN KEY (classcodetax_classcode_id)
                                        REFERENCES classcode (classcode_id) MATCH SIMPLE
                                        ON UPDATE NO ACTION ON DELETE CASCADE', 'public');
select xt.add_constraint('classcodetax', 'classcodetax_classcodetax_taxtype_id_fkey',
                                       'FOREIGN KEY (classcodetax_taxtype_id)
                                        REFERENCES taxtype (taxtype_id) MATCH SIMPLE
                                        ON UPDATE NO ACTION ON DELETE NO ACTION', 'public');
select xt.add_constraint('classcodetax', 'classcodetax_classcodetax_taxzone_id_fkey',
                                       'FOREIGN KEY (classcodetax_taxzone_id)
                                        REFERENCES taxzone (taxzone_id) MATCH SIMPLE
                                        ON UPDATE NO ACTION ON DELETE NO ACTION', 'public');

comment on table public.classcodetax is 'Class Code Default Item Tax table';

