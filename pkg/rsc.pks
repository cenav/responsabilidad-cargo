create or replace package rsc as
  procedure procesa_bono(
    p_ano pls_integer
  , p_mes pls_integer
  );
end rsc;
