drop table proceso_rsc cascade constraints;

create table pevisa.proceso_rsc (
  id_proceso  number(8),
  periodo_ano number(4)   not null,
  periodo_mes number(2)   not null,
  id_moneda   varchar2(2) not null,
  id_estado   number(2)   not null,
  create_user varchar2(30),
  create_date date,
  update_user varchar2(30),
  update_date date
)
  tablespace pevisad;


create unique index pevisa.idx_proceso_rsc
  on pevisa.proceso_rsc(id_proceso)
  tablespace pevisax;


create index pevisa.idx_procesorsc_estado
  on pevisa.proceso_rsc(id_estado)
  tablespace pevisax;

create or replace public synonym proceso_rsc for pevisa.proceso_rsc;


alter table pevisa.proceso_rsc
  add (
    constraint pk_proceso_rsc
      primary key (id_proceso)
        using index pevisa.idx_proceso_rsc
        enable validate
    , constraint fk_procesorsc_estado
      foreign key (id_estado)
        references estado_proceso(id_estado)
    , constraint fk_procesorsc_moneda
      foreign key (id_moneda)
        references moneda(id_moneda)
    );

alter table proceso_rsc
  add constraint uq_procesorsc_periodo
    unique (periodo_ano, periodo_mes);

grant delete, insert, select, update on pevisa.proceso_rsc to sig_roles_invitado;

