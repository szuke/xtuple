do $$
declare
  _b    boolean;
  _i    integer := 1;
  _ins  text;
  _pair text[] = array[ /* should be 2D array */
    'C',       'char_customers',
    'CT',      'char_customers',
    'I',       'char_items',
    'CNTCT',   'char_contacts',
    'ADDR',    'char_addresses',
    'CRMACCT', 'char_crmaccounts',
    'LS',      'char_lotserial',
    'LSR',     'char_lotserial',
    'OPP',     'char_opportunity',
    'EMP',     'char_employees',
    'INCDT',   'char_incidents',
    'PROJ',    'char_projects',
    'TASK',    'char_tasks',
    'QU',      'char_quotes',
    'SO',      'char_salesorders',
    'INV',     'char_invoices',
    'V',       'char_vendors',
    'PO',      'char_purchaseorders',
    'VCH',     'char_vouchers'
  ];

  begin
    update public.charuse
       set charuse_target_type = 'CRMACCT'
     where charuse_target_type = 'CRMA';

    for _i in 1..array_length(_pair, 1) by 2 loop
      _ins := format($f$insert into public.charuse (
                         charuse_char_id, charuse_target_type
                       ) select char_id, '%s' from "char"
                          where %I
                            and not exists(select 1 from charuse
                                            where charuse_char_id = char_id
                                              and charuse_target_type = '%s');$f$,
                     _pair[_i], _pair[_i + 1], _pair[_i]);
      execute _ins;
    end loop;

    -- bug 29827 - patch demo database:
    IF fetchMetricText('remitto_address2') = '12100 Playland Way' AND
       fetchMetricText('DatabaseName')     = 'Practice Database' THEN
      INSERT INTO public.charuse (
        charuse_char_id, charuse_target_type
      ) SELECT charuse_char_id, tgttype
          FROM charuse couter,
               (SELECT unnest AS tgttype
                  FROM unnest(ARRAY['INVI', 'PI', 'RI',
                                    'QI', 'SI', 'TI', 'WI'])) AS types
         WHERE NOT EXISTS(SELECT 1 FROM charuse cinner
                           WHERE cinner.charuse_char_id = couter.charuse_char_id
                             AND cinner.charuse_target_type = tgttype)
           AND EXISTS(SELECT 1 FROM source WHERE source_charass = tgttype)
           AND couter.charuse_target_type = 'I';
    END IF;
    -- }
    -- bug 30700: {
    INSERT INTO charuse (charuse_char_id, charuse_target_type)
      SELECT DISTINCT bomitem_char_id, 'SI'
        FROM bomitem
       WHERE bomitem_char_id IS NOT NULL
         AND bomitem_char_id NOT IN (SELECT charuse_char_id
                                       FROM charuse
                                      WHERE charuse_target_type = 'SI');
    -- }

  end
$$ language plpgsql;

