create or replace package pevisa.api_estado_proceso is
  type aat is table of estado_proceso%rowtype index by pls_integer;
  type ntt is table of estado_proceso%rowtype;

  procedure ins(
    p_rec in estado_proceso%rowtype
  );

  procedure ins(
    p_coll aat
  );

  procedure upd(
    p_rec in estado_proceso%rowtype
  );

  procedure upd(
    p_coll aat
  );

  procedure del(
    p_id_estado in estado_proceso.id_estado%type
  );

  function onerow(
    p_id_estado in estado_proceso.id_estado%type
  ) return estado_proceso%rowtype result_cache;

  function allrows return aat;

  function exist(
    p_id_estado in estado_proceso.id_estado%type
  ) return boolean;

end api_estado_proceso;


create or replace package body pevisa.api_estado_proceso is
  forall_err exception;
  pragma exception_init (forall_err, -24381);

  procedure ins(
    p_rec in estado_proceso%rowtype
  ) is
  begin
    insert into estado_proceso
    values p_rec;
  end;

  procedure ins(
    p_coll in aat
  ) is
  begin
    forall i in 1 .. p_coll.count save exceptions
      insert into estado_proceso values p_coll(i);
  exception
    when forall_err then
      for i in 1 .. sql%bulk_exceptions.COUNT loop
        logger.log('PK: ' || p_coll(sql%bulk_exceptions(i).error_index).id_estado ||
                   ' Err: ' || sqlerrm(sql%bulk_exceptions(i).error_code * -1));
      end loop;
      raise;
  end;

  procedure upd(
    p_rec in estado_proceso%rowtype
  ) is
  begin
    update estado_proceso t
       set row = p_rec
     where t.id_estado = p_rec.id_estado;
  end;

  procedure upd(
    p_coll in aat
  ) is
  begin
    forall i in 1 .. p_coll.count save exceptions
      update estado_proceso
         set row = p_coll(i)
       where id_estado = p_coll(i).id_estado;
  exception
    when forall_err then
      for i in 1 .. sql%bulk_exceptions.COUNT loop
        logger.log('PK: ' || p_coll(sql%bulk_exceptions(i).error_index).id_estado ||
                   ' Err: ' || sqlerrm(sql%bulk_exceptions(i).error_code * -1));
      end loop;
      raise;
  end;

  procedure del(
    p_id_estado in estado_proceso.id_estado%type
  ) is
  begin
    delete
      from estado_proceso t
     where t.id_estado = p_id_estado;
  end;

  function onerow(
    p_id_estado in estado_proceso.id_estado%type
  ) return estado_proceso%rowtype result_cache is
    rec estado_proceso%rowtype;
  begin
    select *
      into rec
      from estado_proceso t
     where t.id_estado = p_id_estado;

    return rec;
  exception
    when no_data_found then
      return null;
    when too_many_rows then
      raise;
  end;

  function allrows return aat is
    p_coll aat;
  begin
    select * bulk collect
      into p_coll
      from estado_proceso;

    return p_coll;
  end;

  function exist(
    p_id_estado in estado_proceso.id_estado%type
  ) return boolean is
    dummy pls_integer;
  begin
    select 1
      into dummy
      from estado_proceso t
     where t.id_estado = p_id_estado;

    return true;
  exception
    when no_data_found then
      return false;
    when too_many_rows then
      return true;
  end;

end api_estado_proceso;
/

create or replace public synonym api_estado_proceso for pevisa.api_estado_proceso;
