begin
  rsc.elimina(2024, 1);
  commit;
end;

begin
  rsc.procesa(2024, 2);
  commit;
end;

begin
  rsc.correo(2024, 2);
end;