drop view vw_bono_rsc_d;

create or replace view vw_bono_rsc_d as
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

select * from vw_bono_rsc_d;

