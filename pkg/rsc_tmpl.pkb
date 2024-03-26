create or replace package body rsc_tmpl as
  function html_proceso return clob is
  begin
    return q'[<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
            "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta name="viewport" content="width=device-width"/>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <title>Pevisa Auto Parts</title>
        <style type="text/css">
            body {
                margin: 0;
                padding: 0;
                min-width: 100%;
                font-family: sans-serif;
                background-color: #FFFFFF;
            }

            table {
                margin: 0 0 10px 0;
                padding: 0;
                width: 100%;
            }

            div {
                margin: 0;
                padding: 0;
            }

            .header {
                height: 40px;
                text-align: center;
                font-size: 20px;
                font-weight: bold;
                color: #808080;
                text-decoration: underline;
            }

            .content {
                height: 100px;
                font-size: 16px;
                line-height: 30px;
            }

            .footer {
                height: 40px;
                text-align: center;
                font-size: 12px;
                color: #999999;
            }

            .footer a {
                color: #000000;
                text-decoration: none;
                font-style: normal;
            }

            .logo {
                text-align: center;
                font-style: italic;
                color: #999999;
            }

            .myTable {
                background-color: #eee;
                border-collapse: collapse;
                margin: 5px 0;
            }

            .myTable th {
                background-color: #004899;
                color: white;
                font-weight: bold;
            }

            .myTable td, .myTable th {
                padding: 5px;
                border: 1px solid #b3b3b3;
            }

            .etiqueta {
                font-weight: bold;
            }

            strong {
                color: #85A8BA;
            }
        </style>
    </head>
    <body bgcolor="#FFFFFF">
    <div>
        <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr>
                <td align="center" style="padding: 0 80px;">
                    <div style="background-color: #eee;">
                        <img src="https://drive.google.com/uc?id=1MBaDH_v72vVoaI-o9Ghbk18foq9wTQpt"
                             alt="logo pevisa">
                    </div>
                </td>
            </tr>
            <tr class="header">
                <td style="padding: 1px 0 0 0;">
                    <h2>Bono RSC</h2>
                </td>
            </tr>
            <tr>
                <td style="padding: 20px 80px 0 80px;">
                    <b>${encargado_nom}</b>, se env&iacute;a el bono RSC
                    del periodo <%= pkg_ano.get_nombre_mes(${mes}) %> ${ano}:
                </td>
            </tr>
            <tr class="content">
                <td style="padding: 20px 80px;">
                    <table class="myTable">
                        <tr>
                            <th>C&oacute;digo</th>
                            <th>Nombre</th>
                            <th>Cargo</th>
                            <th>Turno</th>
                            <th>Bono</th>
                            <th>Exclusi&oacute;n</th>
                        </tr>
                        <%
                        for r in (
                        with excluye as (
                        select e.id_proceso, e.id_empleado, sum(exclusion) as es_excluido
                        from proceso_rsc_excluye e
                        group by e.id_proceso, e.id_empleado
                        )
                        select d.id_proceso, d.id_empleado, nom_empleado, id_cargo, dsc_cargo,
                        id_encargado
                        , nom_encargado, id_turno, dsc_turno, bono_bruto, bono_neto
                        , case when es_excluido >= 1 then 'SI'
                        when es_excluido = 0 then 'NO'
                        end as exclusion
                        from proceso_rsc p
                        join proceso_rsc_d d on p.id_proceso = d.id_proceso
                        left join excluye e on d.id_proceso = e.id_proceso and d.id_empleado =
                        e.id_empleado
                        where p.periodo_ano = ${ano}
                        and p.periodo_mes = ${mes}
                        and d.id_encargado = '${encargado_id}'
                        order by d.nom_encargado, d.nom_empleado
                        ) loop
                        %>
                        <tr>
                            <td><%= r.id_empleado %></td>
                            <td><%= r.nom_empleado %></td>
                            <td><%= r.dsc_cargo %></td>
                            <td><%= r.dsc_turno %></td>
                            <td><%= r.bono_neto %></td>
                            <td><%= r.exclusion %></td>
                        </tr>
                        <%
                        end loop;
                        %>
                    </table>
                </td>
            </tr>
            <tr class="footer">
                <td style="padding: 40px;">
                    <p>Usuario: ${usuario}</p>
                    Envio de Correo Automático<br>
                    Area de Sistemas
                </td>
            </tr>
        </table>
    </div>
    </body>
    </html>]';
  end;

end rsc_tmpl;
