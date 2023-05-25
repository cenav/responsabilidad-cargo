select r.id_cargo, p.desc_cargo, p.c_codigo, p.desc_encargado, p.nombre, p.turno
  from vw_personal p
       join responsabilidad_cargo r on p.c_cargo = r.id_cargo
 where p.situacion not in (
   select codigo
     from planilla10.t_situacion_cesado
   )
 order by desc_cargo, desc_encargado, nombre;

select * from responsabilidad_cargo;