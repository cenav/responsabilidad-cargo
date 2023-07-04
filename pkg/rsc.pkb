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
  g_item number(3) := 1;

  cursor empleados_cr is
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


  function calc_proceso(
    p_ano pls_integer
  , p_mes pls_integer
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
    l_detalle.id_item := g_item;
    l_detalle.id_cargo := p_empleado.id_cargo;
    l_detalle.dsc_cargo := p_empleado.desc_cargo;
    l_detalle.id_empleado := p_empleado.c_codigo;
    l_detalle.nom_empleado := p_empleado.nombre;
    l_detalle.id_encargado := p_empleado.c_encargado;
    l_detalle.nom_encargado := p_empleado.desc_encargado;
    l_detalle.id_turno := p_empleado.turno;
    l_detalle.dsc_turno := p_empleado.dsc_turno;
    l_detalle.bono_bruto := p_empleado.bono;
    l_detalle.bono_neto := p_empleado.bono;
    g_item := g_item + 1;
  end;


  procedure calc_exclusiones(
    p_empleado empleados_cr%rowtype
  , p_proceso  proceso_rsc%rowtype
  ) is
  begin
    null;
  end;


  procedure procesa_bono(
    p_ano pls_integer
  , p_mes pls_integer
  ) is
    l_proceso proceso_rsc%rowtype;
  begin
    l_proceso := calc_proceso(p_ano, p_mes);
    for empleado in empleados_cr loop
      calc_empleados(empleado, l_proceso);
      calc_exclusiones(empleado, l_proceso);
    end loop;
  exception
    when others then
      /* Use the standard error logging mechanism. */
      if sqlcode not between -20999 and -20000 then
        logger.log_error('Informacion del error aqui');
      end if;

      rollback;
      raise;
  end;
end rsc;
