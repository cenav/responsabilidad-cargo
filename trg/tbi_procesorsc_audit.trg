create or replace trigger tbi_procesorsc_audit
  before insert
  on proceso_rsc
  for each row
begin
  :new.create_user := user;
  :new.create_date := sysdate;
end;

