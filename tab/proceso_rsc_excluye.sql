drop table proceso_rsc_excluye cascade constraints;

create table pevisa.proceso_rsc_excluye (
  id_proceso  number(8),
  id_empleado varchar2(8),
  id_excluye  varchar2(3)         not null,
  medida      varchar2(30)        not null,
  fijado      number(5)           not null,
  acumulado   number(5)           not null,
  fechas      varchar2(4000),
  exclusion   number(1) default 0 not null
)
  tablespace pevisad;


create unique index pevisa.idx_proceso_rsc_excluye
  on pevisa.proceso_rsc_excluye(id_proceso, id_empleado, id_excluye)
  tablespace pevisax;


create or replace public synonym proceso_rsc_excluye for pevisa.proceso_rsc_excluye;


alter table pevisa.proceso_rsc_excluye
  add (
    constraint pk_proceso_rsc_excluye
      primary key (id_proceso, id_empleado, id_excluye)
        using index pevisa.idx_proceso_rsc_excluye
        enable validate,
    constraint fk_proceso_rsc_excluye
      foreign key (id_proceso, id_empleado)
        references proceso_rsc_d(id_proceso, id_empleado)
          on delete cascade
          enable validate,
    constraint fk_proceso_rsc_motivo
      foreign key (id_excluye)
        references motivo_excluye(id_excluye)
          enable validate,
    constraint chk_proceso_rsc_exclusion
      check ( exclusion in (0, 1) )
    );


grant delete, insert, select, update on pevisa.proceso_rsc_excluye to sig_roles_invitado;
