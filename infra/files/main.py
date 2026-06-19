import os
import base64
import json
import smtplib
from email.message import EmailMessage

def send_email_notification(event, context):
    pubsub_message = base64.b64decode(event['data']).decode('utf-8')
    data = json.loads(pubsub_message)
    
    email_user = os.environ.get('EMAIL_USER')
    email_pass = os.environ.get('EMAIL_PASSWORD')
    target_email = os.environ.get('NOTIFICATION_EMAIL')
    
    msg = EmailMessage()
    msg['Subject'] = '🚨 ALERTA: Falha no Martech Toolkit v9'
    msg['From'] = email_user
    msg['To'] = target_email
    
    corpo = f"""
    Ocorreu um erro no pipeline Dataform.
    
    -------------------------------------------
    PROJETO: {data.get('project', 'N/A')}
    ERRO: {data.get('message', 'Sem detalhes')}
    -------------------------------------------
    
    Verifique o console do Google Cloud para mais detalhes.
    """
    msg.set_content(corpo)

    try:
        with smtplib.SMTP("smtp.gmail.com", 587) as server:
            server.starttls()
            server.login(email_user, email_pass)
            server.send_message(msg)
            print(f"✅ E-mail de alerta enviado com sucesso para {target_email}")
    except Exception as e:
        print(f"❌ Falha critica no envio via SMTP: {str(e)}")