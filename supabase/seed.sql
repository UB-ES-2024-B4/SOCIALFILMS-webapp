INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at)
VALUES 
  ('00000000-0000-0000-0000-000000000000', '5899f99d-a449-4bfa-8769-19c097aaf1f5', 'authenticated', 'authenticated', 'admin@email.com', '$2a$10$7HloIuRU8136LMux12Vceu8x57OuqrRDpUsIlHLjM4I85LwzUiHRm', '2022-10-04 03:41:27.39308+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"provider": "email", "providers": ["email"]}', '{ "sub": "5899f99d-a449-4bfa-8769-19c097aaf1f5",  "email": "admin@email.com", "username": "Seed user", "email_verified": false,"phone_verified": false }', NULL, '2022-10-04 03:41:27.391146+00', '2022-10-04 03:41:27.39308+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL);

INSERT INTO auth.identities (id,provider_id,user_id,identity_data,provider,last_sign_in_at,created_at,updated_at)
VALUES 
  ('5899f99d-a449-4bfa-8769-19c097aaf1f5', '123e4567-e89b-12d3-a456-426614174000', '5899f99d-a449-4bfa-8769-19c097aaf1f5'::uuid, '{ "sub": "5899f99d-a449-4bfa-8769-19c097aaf1f5",  "email": "admin@email.com", "username": "Seed user", "email_verified": false,"phone_verified": false }', 'email', '2022-10-04 04:45:00.000+00', '2022-10-04 03:41:27.391146+00', '2022-10-04 03:41:27.39308+00');