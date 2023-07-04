create package enum_estado_proceso as
  subtype t_opcion is binary_integer range 0..99;

  generado constant t_opcion := 0;
  enviado constant t_opcion := 10;
  cerrado constant t_opcion := 80;
  anulado constant t_opcion := 99;
end;

create public synonym enum_estado_proceso for pevisa.enum_estado_proceso;