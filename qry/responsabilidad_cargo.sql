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
 order by dsc_cargo;

select *
  from responsabilidad_cargo
 where id_cargo = '697A';

select *
  from planilla10.t_cargo
 where c_cargo = 'AXPLT';

select *
  from planilla10.t_cargo
 where descripcion like '%MADERA%';

select *
  from planilla10.personal
 where c_cargo = 'CHM';

select *
  from planilla10.personal
 where c_codigo = 'E42917';

select * from estado_proceso;

select id_proceso, periodo_ano, periodo_mes, id_moneda, id_estado, create_user, create_date
     , to_date(periodo_ano || periodo_mes, 'yyyymm') as ini
     , last_day(to_date(periodo_ano || periodo_mes, 'yyyymm')) as fin
  from proceso_rsc;

select * from proceso_rsc;

select *
  from proceso_rsc_d
 where id_empleado = 'E42576';

select * from proceso_rsc_excluye where exclusion = 1;

select *
  from proceso_rsc_excluye
 where id_excluye = 'TAR'
   and acumulado > 0;

select m.id_excluye, m.dsc_excluye, e.medida, e.cantidad, m.id_concepto_tecflex, m.regla
  from motivo_excluye m
       join exclusiones e on m.id_excluye = e.id_excluye
 where e.id_bono = 1 --> bono he trimestral
   and e.estado = 1; --> activo

select * from bono;

select * from motivo_excluye;

select * from exclusiones;

select * from estado_proceso;

select * from color;

select * from vw_bono_rsc;

select id_proceso, id_empleado, p.id_excluye, m.dsc_excluye, medida, fijado, acumulado, fechas
     , exclusion
  from proceso_rsc_excluye p
       left join motivo_excluye m on p.id_excluye = m.id_excluye;

select *
  from proceso_rsc_excluye
 where id_proceso = 1
   and id_empleado = 'E42506';

  with excluye as (
    select e.id_proceso, e.id_empleado, sum(exclusion) as es_excluido
      from proceso_rsc_excluye e
     group by e.id_proceso, e.id_empleado
    )
select d.id_proceso, d.id_empleado, nom_empleado, id_cargo, dsc_cargo, id_encargado, nom_encargado
     , id_turno, dsc_turno, bono_bruto, bono_neto
     , case when es_excluido >= 1 then 'SI' when es_excluido = 0 then 'NO' end as exclusion
  from proceso_rsc_d d
       left join excluye e on d.id_proceso = e.id_proceso and d.id_empleado = e.id_empleado;

-- merge into proceso_rsc_d d
-- using (
--   select e.id_proceso, e.id_empleado, sum(exclusion) as es_excluido
--     from proceso_rsc_excluye e
--    group by e.id_proceso, e.id_empleado
--   ) e
-- on (d.id_proceso = e.id_proceso and d.id_empleado = e.id_empleado)
-- when matched then
--   update set bono_neto = case when es_excluido >= 1 then 0 else bono_neto end;

select *
  from vw_vacaciones
 where encargado = 'KAREN CASTILLO';

select id_empleado
  from proceso_rsc_d
 where nom_encargado = 'KAREN CASTILLO';

select *
  from vw_vacaciones
 where id_personal in (
                       'E41903', 'E42195', 'E42910', 'E43065', 'E42941', 'E42133', 'E42375',
                       'E42780', 'E42558', 'E42505', 'E42576', 'E42947', 'E42358', 'E42931',
                       'E42629', 'E41844', 'E42445', 'E41316', 'E4376', 'E42643', 'E42376',
                       'E42468', 'E41311', 'E4785', 'E43006', 'E42373', 'E41892', 'E43030',
                       'E42595', 'E43094', 'E43043', 'E43024', 'E42811', 'E42647', 'E42030',
                       'E43133', 'E42807', 'E42989'
   )
   and to_char(f_inivac, 'yyyymm') = '202401'
 order by f_inivac desc;

select sum(dias) as dias
     , listagg('del ' || f_inivac || ' al ' || f_finvac, ' | ')
               within group ( order by f_inivac) as fechas
  from vw_vacaciones v
 where v.id_personal = 'E42030X'
   and v.estado = '8'
   and v.dias > 7
   and extract(year from v.fch_pago) = 2024
   and extract(month from v.fch_pago) = 1
 group by id_personal;

select * from modulo;

select *
  from usuario_modulo
 where modulo = 'BONO_RSC';

select id_proceso, id_empleado, nom_empleado, id_cargo, dsc_cargo, id_encargado, nom_encargado
     , id_turno, dsc_turno, bono_bruto, bono_neto
  from proceso_rsc_d;

select * from bono_obrero_excluye;

select dsc_bono, id_bono from bono order by id_bono;

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
   and not exists (
   select id_personal
     from bono_obrero_excluye
    where periodo_ano = 2024
      and periodo_mes = 2
      and id_personal = p.c_codigo
   )
 order by desc_cargo, desc_encargado, nombre;

select g.cod_bono, b.descripcion as dsc_bono, p.c_cargo, c.descripcion as dsc_cargo
     , p.c_codigo, p.apellido_paterno, p.nombres
     , trunc(months_between(sysdate, f_ingreso)) as meses_antiguedad
  from planilla10.personal p
       left join planilla10.hr_personal h on p.c_codigo = h.c_codigo
       join planilla10.t_cargo c on p.c_cargo = c.c_cargo
       join bono_oa_puesto g
            on p.c_cargo = g.cod_puesto
              and (h.local = g.cod_sede or g.cod_sede is null)
       join bono_oa b on g.cod_bono = b.cod_bono
       join param_bono_obrero a on a.id = 1
 where trunc(months_between(sysdate, f_ingreso)) > a.meses_antiguedad
   and p.situacion not in (
   select codigo
     from planilla10.t_situacion_cesado
   )
   and b.estado = 1
   and not exists (
   select id_personal
     from bono_obrero_excluye
    where periodo_ano = extract(year from to_date('31/01/2024', 'dd/mm/yyyy'))
      and periodo_mes = 1
      and id_personal = p.c_codigo
   )
 order by cod_bono, g.orden_reporte, p.c_cargo, p.apellido_paterno;

select *
  from proceso_bono_oa
 order by periodo_ini desc;

begin
  select descripcion
    from planilla10.t_cargo
   where c_cargo = 'MLS';
exception
  when others then null;
end;

select c_cargo, descripcion
  from planilla10.t_cargo
 order by c_cargo;

select c_cargo, descripcion
  from planilla10.t_cargo
 where perfil = 'SI'
   and nvl(status, '0') != '9'
 order by c_cargo;

select * from bono;

select * from bono_obrero_excluye_modulo;

select id_personal
  from bono_obrero_excluye e
       join bono_obrero_excluye_modulo m on e.id_excluye = m.id_excluye
 where periodo_ano = 2024
   and periodo_mes = 1
   and id_personal = 'E4923'
   and id_bono = 2;
