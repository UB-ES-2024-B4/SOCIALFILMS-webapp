CREATE OR REPLACE FUNCTION public.handle_user_update()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.profiles (id, username, email)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data ->> 'username',
    NEW.email
  )
  ON CONFLICT (id) -- Si el usuario ya existe en profiles, actualiza sus datos
  DO UPDATE 
    SET username = EXCLUDED.username,
        email = EXCLUDED.email;

  RETURN NEW;
END;
$$;

-- Trigger the function every time a user is updated
CREATE TRIGGER on_auth_user_updated
  AFTER UPDATE ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_user_update();


CREATE OR REPLACE FUNCTION change_password(
  current_plain_password text, 
  new_plain_password text, 
  current_id uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  encpass auth.users.encrypted_password%type;
BEGIN
  -- Verifica que la nueva contraseña cumple con los requisitos
  IF NOT new_plain_password ~ '^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[\W_]).{6,}$' THEN
    RAISE EXCEPTION 'La contraseña debe tener al menos 6 caracteres, una mayúscula, una minúscula, un número y un símbolo.' 
    USING ERRCODE = 'P0003';
  END IF;

  -- Verificar si la contraseña actual coincide
  SELECT encrypted_password
  INTO encpass
  FROM auth.users
  WHERE id = current_id AND encrypted_password = crypt(current_plain_password, encrypted_password);

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Incorrect current password'
    USING ERRCODE = 'P0001';
  END IF;

  -- Cambiar la contraseña
  UPDATE auth.users
  SET encrypted_password = crypt(new_plain_password, gen_salt('bf'))
  WHERE id = current_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Failed to update password'
    USING ERRCODE = 'P0002';
  END IF;
END;
$$;
