create or replace package enum_moneda as
  subtype t_moneda is varchar2(2);

  soles constant t_moneda := 'S';
  dolares constant t_moneda := 'D';
end enum_moneda;
