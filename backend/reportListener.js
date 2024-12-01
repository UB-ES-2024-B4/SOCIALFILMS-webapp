import { createClient } from '@supabase/supabase-js';
import nodemailer from 'nodemailer';
import dotenv from 'dotenv';

// Carga las variables de entorno desde .env
dotenv.config();

const client = createClient('https://jxbspkcbkgmtnrvylrqa.supabase.co', process.env.SUPABASE_KEY);

// Configura nodemailer
const transporter = nodemailer.createTransport({
    host: 'smtp.sendgrid.net',
    port: 465,
    secure: false,
    auth: {
        user: 'apikey',
        pass: process.env.SENDGRID_API_KEY
    }
});


// Suscríbete a los eventos de la tabla 'Report' en la base de datos online de Supabase
client
  .channel('new_report')
  .on('postgres_changes', { event: 'INSERT', schema: 'public', table: '"Report"' }, async (payload) => {
      console.log('Evento recibido:', payload);  // Log de los datos recibidos
    const report = payload.new;
    try {
      // Enviar correo
      const info = await transporter.sendMail({
        from: 'soportesfilms@gmail.com',
        to: 'soportefilmsv2@gmail.com',
        subject: 'Nuevo Reporte Creado',
        text: `Se ha creado un nuevo reporte:\n\nUsuario: ${report.user_id}\nMotivo: ${report.reason}\nDescripción: ${report.other_reason || 'N/A'}`,
        html: `<p>Se ha creado un nuevo reporte:</p>
               <ul>
                 <li><b>Usuario:</b> ${report.user_id}</li>
                 <li><b>Motivo:</b> ${report.reason}</li>
                 <li><b>Descripción:</b> ${report.other_reason || 'N/A'}</li>
                 <li><b>Review ID:</b> ${report.review_id}</li>
               </ul>`
      });

      console.log('Correo enviado:', info.messageId);
    } catch (err) {
      console.error('Error al enviar el correo:', err);
    }
  })
  .subscribe();