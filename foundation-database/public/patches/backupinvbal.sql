DO $$
BEGIN

  IF NOT EXISTS (SELECT 1
                   FROM pg_class
                  WHERE pg_class.relname='oldinvbal') THEN
    CREATE TABLE oldinvbal AS
    SELECT invbal_id, invbal_period_id, invbal_itemsite_id,
           invbal_qoh_beginning, invbal_qoh_ending, invbal_qty_in, invbal_qty_out,
           invbal_value_beginning, invbal_value_ending, invbal_value_in, invbal_value_out,
           invbal_nn_beginning, invbal_nn_ending, invbal_nn_in, invbal_nn_out,
           invbal_nnval_beginning, invbal_nnval_ending, invbal_nnval_in, invbal_nnval_out,
           invbal_dirty
      FROM invbal;
  END IF;

END;
$$ LANGUAGE plpgsql;
