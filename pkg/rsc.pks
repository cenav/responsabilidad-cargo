create or replace package rsc as
  procedure procesa(
    p_ano simple_integer
  , p_mes simple_integer
  );

  procedure elimina(
    p_ano simple_integer
  , p_mes simple_integer
  );
end rsc;
