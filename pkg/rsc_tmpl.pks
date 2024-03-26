create or replace package rsc_tmpl as

  -- template html para el envío de correo
  function html_proceso return clob;

end rsc_tmpl;
