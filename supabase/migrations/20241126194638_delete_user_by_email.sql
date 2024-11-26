-- Eliminar la función existente si existe
DROP FUNCTION IF EXISTS delete_user_by_email(text);

-- Crear la nueva función con el parámetro renombrado y permisos adecuados
create or replace function delete_user_by_email(p_email text) 
returns void as $$
begin
  -- Establecer el rol de ejecución
  set role service_role;

  -- Eliminar al usuario con el email proporcionado
  delete from auth.users where email = p_email;
end;
$$ language plpgsql;
