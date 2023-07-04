create or replace package pevisa.api_proceso_rsc is
  type aat is table of proceso_rsc%rowtype index by pls_integer;
  type ntt is table of proceso_rsc%rowtype;

  procedure ins(
    p_rec in proceso_rsc%rowtype
  );

  procedure ins(
    p_coll aat
  );

  procedure upd(
    p_rec in proceso_rsc%rowtype
  );

  procedure upd(
    p_coll aat
  );

  procedure del(
    p_id_proceso in proceso_rsc.id_proceso%type
  );

  function onerow(
    p_id_proceso in proceso_rsc.id_proceso%type
  ) return proceso_rsc%rowtype result_cache;

  function allrows return aat;

  function exist(
    p_id_proceso in proceso_rsc.id_proceso%type
  ) return boolean;

  function next_key return proceso_rsc.id_proceso%type result_cache;
end api_proceso_rsc;


create or replace package body pevisa.api_proceso_rsc is
  forall_err exception;
  pragma exception_init (forall_err, -24381);

  procedure ins(
    p_rec in proceso_rsc%rowtype
  ) is
  begin
    insert into proceso_rsc
    values p_rec;
  end;

  procedure ins(
    p_coll in aat
  ) is
  begin
    forall i in 1 .. p_coll.count save exceptions
      insert into proceso_rsc values p_coll(i);
  exception
    when forall_err then
      for i in 1 .. sql%bulk_exceptions.COUNT loop
        logger.log('PK: ' || p_coll(sql%bulk_exceptions(i).error_index).id_proceso ||
                   ' Err: ' || sqlerrm(sql%bulk_exceptions(i).error_code * -1));
      end loop;
      raise;
  end;

  procedure upd(
    p_rec in proceso_rsc%rowtype
  ) is
  begin
    update proceso_rsc t
       set row = p_rec
     where t.id_proceso = p_rec.id_proceso;
  end;

  procedure upd(
    p_coll in aat
  ) is
  begin
    forall i in 1 .. p_coll.count save exceptions
      update proceso_rsc
         set row = p_coll(i)
       where id_proceso = p_coll(i).id_proceso;
  exception
    when forall_err then
      for i in 1 .. sql%bulk_exceptions.COUNT loop
        logger.log('PK: ' || p_coll(sql%bulk_exceptions(i).error_index).id_proceso ||
                   ' Err: ' || sqlerrm(sql%bulk_exceptions(i).error_code * -1));
      end loop;
      raise;
  end;

  procedure del(
    p_id_proceso in proceso_rsc.id_proceso%type
  ) is
  begin
    delete
      from proceso_rsc t
     where t.id_proceso = p_id_proceso;
  end;

  function onerow(
    p_id_proceso in proceso_rsc.id_proceso%type
  ) return proceso_rsc%rowtype result_cache is
    rec proceso_rsc%rowtype;
  begin
    select *
      into rec
      from proceso_rsc t
     where t.id_proceso = p_id_proceso;

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
      from proceso_rsc;

    return p_coll;
  end;

  function exist(
    p_id_proceso in proceso_rsc.id_proceso%type
  ) return boolean is
    dummy pls_integer;
  begin
    select 1
      into dummy
      from proceso_rsc t
     where t.id_proceso = p_id_proceso;

    return true;
  exception
    when no_data_found then
      return false;
    when too_many_rows then
      return true;
  end;

  function next_key return proceso_rsc.id_proceso%type result_cache is
    l_nro proceso_rsc.id_proceso%type;
  begin
    select nvl(max(id_proceso), 0)
      into l_nro
      from proceso_rsc;

    return l_nro + 1;
  end;

end api_proceso_rsc;
/

create or replace public synonym api_proceso_rsc for pevisa.api_proceso_rsc;
