create or replace package body rsc as
  /*************************************************************************************************
  Autor: Cesar Navarro
  Fecha Creacion: 26/06/2023
  Empresa: Pevisa Auto Parts
  Descripcion: Bonos segun el riesgo del puesto del trabajador

  Historial Modificacion
  --------------------------------------------------------------------------------------------------
  Fecha       Autor                Comentarios
  ----------  -------------------  -----------------------------------------------------------------

  *************************************************************************************************/
  c_bono_rsc constant bono.id_bono%type := 2;

  cursor empleados_cr(p_ano simple_integer, p_mes simple_integer) is
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
         from bono_obrero_excluye e
              join bono_obrero_excluye_modulo m on e.id_excluye = m.id_excluye
        where periodo_ano = p_ano
          and periodo_mes = p_mes
          and id_personal = p.c_codigo
          and id_bono = 2
       )
     order by desc_cargo, desc_encargado, nombre;

--::::::::::::::::::::::::::::--
--      Private Routines      --
--::::::::::::::::::::::::::::--
  procedure registra_exclusion(
    p_idproceso  number
  , p_idempleado varchar2
  , p_idexcluye  varchar2
  , p_medida     varchar2
  , p_fijado     number
  , p_acumulado  number
  , p_fechas     varchar2
  , p_exclusion  signtype
  ) is
  begin
    insert into proceso_rsc_excluye( id_proceso, id_empleado, id_excluye, medida
                                   , fijado, acumulado, fechas, exclusion)
    values ( p_idproceso, p_idempleado, p_idexcluye, p_medida
           , p_fijado, p_acumulado, p_fechas, p_exclusion);
  end;

  function es_excluido(
    p_regla     varchar2
  , p_fijado    number
  , p_acumulado number
  ) return signtype is
  begin
    return case p_regla
             when '+' then
               case when p_acumulado > p_fijado then 1 else 0 end
             when '-' then
               case when p_acumulado < p_fijado then 1 else 0 end
             else 0
           end;
  end;

  function calc_proceso(
    p_ano simple_integer
  , p_mes simple_integer
  ) return proceso_rsc%rowtype is
    l_proceso proceso_rsc%rowtype;
  begin
    l_proceso.id_proceso := api_proceso_rsc.next_key();
    l_proceso.periodo_ano := p_ano;
    l_proceso.periodo_mes := p_mes;
    l_proceso.id_moneda := enum_moneda.soles;
    l_proceso.id_estado := enum_estado_proceso.generado;
    api_proceso_rsc.ins(l_proceso);

    return l_proceso;
  end;

  procedure calc_empleados(
    p_empleado empleados_cr%rowtype
  , p_proceso  proceso_rsc%rowtype
  ) is
    l_detalle proceso_rsc_d%rowtype;
  begin
    l_detalle.id_proceso := p_proceso.id_proceso;
    l_detalle.id_empleado := p_empleado.c_codigo;
    l_detalle.nom_empleado := p_empleado.nombre;
    l_detalle.id_cargo := p_empleado.id_cargo;
    l_detalle.dsc_cargo := p_empleado.desc_cargo;
    l_detalle.id_encargado := p_empleado.c_encargado;
    l_detalle.nom_encargado := p_empleado.desc_encargado;
    l_detalle.id_turno := p_empleado.turno;
    l_detalle.dsc_turno := p_empleado.dsc_turno;
    l_detalle.bono_bruto := p_empleado.bono;
    l_detalle.bono_neto := p_empleado.bono;
    api_proceso_rsc_d.ins(l_detalle);
  end;


  procedure calc_exclusiones(
    p_empleado empleados_cr%rowtype
  , p_proceso  proceso_rsc%rowtype
  ) is
    l_concepto  exclusion.t_veces_concepto;
    l_exclusion signtype := 0;
  begin
    for r in (
      select m.id_excluye, m.dsc_excluye, e.medida, e.cantidad, m.id_concepto_tecflex, m.regla
        from motivo_excluye m
             join exclusiones e on m.id_excluye = e.id_excluye
       where e.id_bono = c_bono_rsc
         and e.estado = 1 --> activo
      )
    loop
      case r.id_excluye
        when 'FAL' then
          l_concepto := exclusion.veces_concepto_asistencia(
              p_concepto => r.id_concepto_tecflex
            , p_empleado => p_empleado.c_codigo
            , p_fch_ini => to_date(p_proceso.periodo_ano || p_proceso.periodo_mes, 'yyyymm')
            , p_fch_fin => last_day(to_date(
                  p_proceso.periodo_ano || p_proceso.periodo_mes
                , 'yyyymm')));
          l_exclusion := es_excluido(r.regla, r.cantidad, l_concepto.veces);
          registra_exclusion(p_proceso.id_proceso, p_empleado.c_codigo, r.id_excluye, r.medida,
                             r.cantidad, l_concepto.veces, l_concepto.fechas, l_exclusion);
        when 'TAR' then
          l_concepto := exclusion.veces_concepto_asistencia(
              p_concepto => r.id_concepto_tecflex
            , p_empleado => p_empleado.c_codigo
            , p_fch_ini => to_date(p_proceso.periodo_ano || p_proceso.periodo_mes, 'yyyymm')
            , p_fch_fin => last_day(to_date(
                  p_proceso.periodo_ano || p_proceso.periodo_mes
                , 'yyyymm')));
          l_exclusion := es_excluido(r.regla, r.cantidad, l_concepto.veces);
          registra_exclusion(p_proceso.id_proceso, p_empleado.c_codigo, r.id_excluye, r.medida,
                             r.cantidad, l_concepto.veces, l_concepto.fechas, l_exclusion);
        when 'VAC' then
          l_concepto := exclusion.dias_vacaciones(
              p_empleado => p_empleado.c_codigo
            , p_ano => p_proceso.periodo_ano
            , p_mes => p_proceso.periodo_mes);
          l_exclusion := es_excluido(r.regla, r.cantidad, l_concepto.veces);
          registra_exclusion(p_proceso.id_proceso, p_empleado.c_codigo, r.id_excluye, r.medida,
                             r.cantidad, l_concepto.veces, l_concepto.fechas, l_exclusion);
      end case;
    end loop;
  end;

  procedure calc_neto(
    p_proceso proceso_rsc%rowtype
  ) is
  begin
    merge into proceso_rsc_d d
    using (
      select e.id_proceso, e.id_empleado, sum(exclusion) as es_excluido
        from proceso_rsc_excluye e
       group by e.id_proceso, e.id_empleado
      ) e
    on (d.id_proceso = e.id_proceso and d.id_empleado = e.id_empleado)
    when matched then
      update
         set bono_neto = case when es_excluido >= 1 then 0 else bono_neto end
       where id_proceso = p_proceso.id_proceso;
  end;

  procedure enviar(
    p_periodo_ano    simple_integer
  , p_periodo_mes    simple_integer
  , p_encargado_id   varchar2
  , p_encargado_nom  varchar2
  , p_encargado_mail varchar2
  ) is
    l_html clob;
    l_vars teplsql.t_assoc_array;
  begin
    l_html := rsc_tmpl.html_proceso();

    l_vars('ano') := p_periodo_ano;
    l_vars('mes') := p_periodo_mes;
    l_vars('encargado_id') := p_encargado_id;
    l_vars('encargado_nom') := p_encargado_nom;
    l_vars('usuario') := user;

    l_html := teplsql.render(l_vars, l_html);

    mail.send_html(
        p_to => p_encargado_mail || '; icatalan@pevisa.com.pe',
        p_cc => 'jcabezas@pevisa.com.pe',
        p_bcc => 'cnavarro@pevisa.com.pe',
        p_from => 'avisos_bienestar@pevisa.com.pe',
        p_subject => 'BONO RSC ' || p_periodo_ano || ' - ' || p_periodo_mes,
        p_html_msg => l_html
    );

    --     mail.send_html(
--         p_to => 'cnavarro@pevisa.com.pe',
--         p_from => 'avisos_bienestar@pevisa.com.pe',
--         p_subject => 'BONO RSC ' || p_periodo_ano || ' - ' || p_periodo_mes,
--         p_html_msg => l_html
--     );
  end;

--::::::::::::::::::::::::::::--
--      Public Routines       --
--::::::::::::::::::::::::::::--
  procedure procesa(
    p_ano simple_integer
  , p_mes simple_integer
  ) is
    l_proceso proceso_rsc%rowtype;
  begin
    l_proceso := calc_proceso(p_ano, p_mes);
    for empleado in empleados_cr(p_ano, p_mes) loop
      calc_empleados(empleado, l_proceso);
      calc_exclusiones(empleado, l_proceso);
    end loop;
    calc_neto(l_proceso);
  exception
    when others then
      /* Use the standard error logging mechanism. */
      if sqlcode not between -20999 and -20000 then
        logger.log_error('Informacion del error aqui');
      end if;

      rollback;
      raise;
  end;

  procedure elimina(
    p_id_proceso proceso_rsc.id_proceso%type
  ) is
  begin
    delete from proceso_rsc where id_proceso = p_id_proceso;
  end;

  procedure elimina(
    p_ano simple_integer
  , p_mes simple_integer
  ) is
  begin
    delete from proceso_rsc where periodo_ano = p_ano and periodo_mes = p_mes;
  end;

  procedure cierra(
    p_id_proceso proceso_rsc.id_proceso%type
  ) is
  begin
    update proceso_rsc
       set id_estado = enum_estado_proceso.cerrado
     where id_proceso = p_id_proceso;
  end cierra;

  procedure correo(
    p_ano simple_integer
  , p_mes simple_integer
  ) is
  begin
    for r in (
      select d.id_proceso, id_encargado, nom_encargado, e.ecorreo
        from proceso_rsc p
             join proceso_rsc_d d on p.id_proceso = d.id_proceso
             join planilla10.tar_encarga e on d.id_encargado = e.codigo
       where p.id_proceso = d.id_proceso
         and p.periodo_ano = p_ano
         and p.periodo_mes = p_mes
       group by id_encargado, nom_encargado, d.id_proceso, e.ecorreo
       order by nom_encargado
      )
    loop
      enviar(
          p_periodo_ano => p_ano
        , p_periodo_mes => p_mes
        , p_encargado_id => r.id_encargado
        , p_encargado_nom => r.nom_encargado
        , p_encargado_mail => r.ecorreo
      );
    end loop;
  end;

  procedure tarea(
    p_ano simple_integer default extract(year from add_months(sysdate, -1))
  , p_mes simple_integer default extract(month from add_months(sysdate, -1))
  ) is
  begin
    rsc.procesa(p_ano, p_mes);
    commit;
  end;

end rsc;
