create or replace view vw_bono_rsc as
  with total as (
    select id_proceso, sum(bono_bruto) as bono_bruto, sum(bono_neto) as bono_neto
         , sum(case id_turno when 1 then bono_neto else 0 end) as neto_dia
         , sum(case id_turno when 2 then bono_neto else 0 end) as neto_tarde
         , sum(case id_turno when 3 then bono_neto else 0 end) as neto_noche
      from proceso_rsc_d
     group by id_proceso
    )
select p.id_proceso, periodo_ano, periodo_mes, p.id_moneda, m.descripcion as dsc_moneda, m.simbolo
     , p.id_estado, e.dsc_estado, create_user, create_date, update_user, update_date, bono_bruto
     , bono_neto, neto_dia, neto_tarde, neto_noche, e.id_color, c.nom_color, c.colorindex
  from proceso_rsc p
       left join total t on p.id_proceso = t.id_proceso
       left join estado_proceso e on p.id_estado = e.id_estado
       left join moneda m on p.id_moneda = m.id_moneda
       left join color c on e.id_color = c.id_color