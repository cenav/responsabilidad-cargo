create or replace package rsc as

  procedure procesa(
    p_ano simple_integer
  , p_mes simple_integer
  );

  procedure elimina(
    p_id_proceso proceso_rsc.id_proceso%type
  );

  procedure elimina(
    p_ano simple_integer
  , p_mes simple_integer
  );

  procedure cierra(
    p_id_proceso  proceso_rsc.id_proceso%type
  );

end rsc;
