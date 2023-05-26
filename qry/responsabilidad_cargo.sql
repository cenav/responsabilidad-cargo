-- rsc
select r.id_cargo, p.desc_cargo, p.c_codigo, p.desc_encargado, p.nombre, p.turno
     , case p.turno
         when 1 then r.bono_dia
         when 2 then r.bono_tarde
         when 3 then r.bono_noche
         else 0
       end as bono
  from vw_personal p
       join responsabilidad_cargo r on p.c_cargo = r.id_cargo
 where p.situacion not in (
   select codigo
     from planilla10.t_situacion_cesado
   )
 order by desc_cargo, desc_encargado, nombre;

select * from responsabilidad_cargo order by id_cargo;

select * from planilla10.t_cargo where c_cargo = 'OM';