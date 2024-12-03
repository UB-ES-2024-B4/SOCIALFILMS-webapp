import { serve } from "https://deno.land/std/http/server.ts";

serve(async (req) => {
  const { user_id, review_id, motivo, motivo_ad } = await req.json();

  // Configurar el cuerpo del mensaje para la API de SendGrid
  const msg = {
    personalizations: [
      {
        to: [{ email: 'soportefilmsv2@gmail.com' }],
        subject: 'Nuevo reporte recibido',
      },
    ],
    from: { email: 'soportesfilms@gmail.com' },  // Remitente
    content: [
      {
        type: 'text/plain',
        value: `El usuario ${user_id} ha reportado la review ${review_id} por el siguiente motivo: ${motivo}/${motivo_ad}`,
      },
    ],
  };

  try {
    // Hacer la solicitud POST a la API de SendGrid
    const response = await fetch('https://api.sendgrid.com/v3/mail/send', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${Deno.env.get("SMTP_PASSWORD")}`,  // Obtén la API Key de SendGrid desde las variables de entorno
      },
      body: JSON.stringify(msg),
    });

    if (response.ok) {
      return new Response("Correo enviado correctamente", { status: 200 });
    } else {
      return new Response(`Error enviando el correo: ${response.statusText}`, { status: response.status });
    }
  } catch (error) {
    console.error("Error en la función:", error);
    return new Response("Error enviando el correo: " + error.message, { status: 500 });
  }
});

