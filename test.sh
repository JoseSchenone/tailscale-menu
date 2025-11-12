# 1. Detener Tailscale
sudo systemctl stop tailscaled

# 2. Borrar estado local y socket
sudo rm -rf /var/lib/tailscale/*
sudo rm -f /run/tailscale/tailscaled.sock

# 3. Establecer DNS temporal para evitar bucles
sudo bash -c 'echo -e "nameserver 1.1.1.1\nnameserver 1.0.0.1" > /etc/resolv.conf'

# 4. Iniciar el demonio
sudo systemctl start tailscaled

# 5. Conectar de nuevo (abrirá el navegador)
sudo tailscale up --reset

