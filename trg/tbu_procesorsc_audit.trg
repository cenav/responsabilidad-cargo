create or replace trigger tbu_procesorsc_audit
  before update
  on proceso_rsc
  for each row
begin
  :new.update_user := user;
  :new.update_date := sysdate;
end;
