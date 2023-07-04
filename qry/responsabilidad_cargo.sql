-- rsc
select r.id_cargo, p.desc_cargo, p.c_codigo, p.nombre, p.c_encargado, p.desc_encargado, p.turno
     , case p.turno
         when 1 then 'DIA'
         when 2 then 'TARDE'
         when 3 then 'NOCHE'
       end as dsc_turno
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

-- tabla rsc
select r.id_cargo, c.descripcion as dsc_cargo, r.bono_dia, r.bono_tarde, r.bono_noche
  from responsabilidad_cargo r
       join planilla10.t_cargo c on r.id_cargo = c.c_cargo
 order by r.id_cargo;

select *
  from planilla10.t_cargo
 where c_cargo = 'CHM';

select *
  from planilla10.personal
 where c_cargo = 'CHM';

select *
  from planilla10.personal
 where c_codigo = 'E42917';

select * from estado_proceso;

select * from proceso_rsc;

select * from estado_proceso;

select * from moneda;