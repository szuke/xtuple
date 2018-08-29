SELECT xt.add_column('checkitem', 'checkitem_currdate', 'DATE', 'NULL', 'public',
                     'This date is the date the stored curr_rate is for, NOT checkitem_docdate');
