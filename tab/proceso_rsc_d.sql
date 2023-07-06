drop table proceso_rsc_d cascade constraints;

create table pevisa.proceso_rsc_d (
  id_proceso    number(8),
  id_item       number(3),
  id_cargo      varchar2(6),
  dsc_cargo     varchar2(50),
  id_empleado   varchar2(8),
  nom_empleado  varchar2(50),
  id_encargado  varchar2(4),
  nom_encargado varchar2(50),
  id_turno      number(1),
  dsc_turno     varchar2(50),
  bono_bruto    number(8, 2),
  bono_neto     number(8, 2)
)
  tablespace pevisad;


create unique index pevisa.idx_proceso_rsc_d
  on pevisa.proceso_rsc_d(id_proceso, id_item)
  tablespace pevisax;


create or replace public synonym proceso_rsc_d for pevisa.proceso_rsc_d;


alter table pevisa.proceso_rsc_d
  add (
    constraint pk_proceso_rsc_d
      primary key (id_proceso, id_item)
        using index pevisa.idx_proceso_rsc_d
        enable validate,
    constraint fk_proceso_rsc_d
      foreign key (id_proceso)
        references proceso_rsc(id_proceso)
          on delete cascade
    );


grant delete, insert, select, update on pevisa.proceso_rsc_d to sig_roles_invitado;
