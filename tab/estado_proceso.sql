create table pevisa.estado_proceso (
  id_estado  number(2),
  dsc_estado varchar2(50) not null
)
  tablespace pevisad;


create unique index pevisa.idx_estado_proceso
  on pevisa.estado_proceso(id_estado)
  tablespace pevisax;


create or replace public synonym estado_proceso for pevisa.estado_proceso;


alter table pevisa.estado_proceso
  add (
    constraint pk_estado_proceso
      primary key (id_estado)
        using index pevisa.idx_estado_proceso
        enable validate
    );


grant delete, insert, select, update on pevisa.estado_proceso to sig_roles_invitado;
