# Router Linux

Un "router Linux" es un enrutador de red que utiliza una distribución de Linux como base para su sistema operativo.

Ubuntu Server, al igual que otros sistemas operativos basados en Linux, se puede utilizar como un enrutador Linux para cumplir varias funciones, dependiendo de tus necesidades y configuración. Algunos de los usos más comunes incluyen:

1. **Enrutamiento**: Ubuntu Server puede funcionar como un enrutador para dirigir el tráfico de red entre diferentes redes o subredes. Puede utilizar herramientas como iptables o nftables para configurar reglas de enrutamiento y filtrado de paquetes.

2. **Firewall**: Puedes utilizar Ubuntu Server como un firewall para proteger tu red. Herramientas como iptables o nftables te permiten configurar reglas para permitir o denegar el tráfico de red según tus necesidades.

3. **NAT (Network Address Translation)**: Puedes configurar Ubuntu Server para realizar NAT, lo que permite que múltiples dispositivos en una red interna compartan una única dirección IP pública para acceder a Internet.

4. **Proxy**: Puedes configurar un servidor proxy en Ubuntu Server para actuar como intermediario entre los dispositivos de tu red interna y los recursos en Internet. Esto puede ayudar a mejorar la seguridad y el rendimiento de la red.

5. **VPN (Virtual Private Network)**: Ubuntu Server puede ser configurado como un servidor VPN para permitir a los usuarios o dispositivos remotos acceder a tu red de forma segura a través de una conexión cifrada.

6. **Balanceo de carga**: Si tienes múltiples conexiones de Internet o servidores, puedes configurar Ubuntu Server como un enrutador de balanceo de carga para distribuir el tráfico de manera equitativa entre las diferentes conexiones o servidores.

7. **Monitoreo y registro de tráfico**: Puedes utilizar herramientas de monitoreo y registro de tráfico, como Wireshark o tcpdump, para analizar y registrar el tráfico de red en tiempo real.

8. **QoS (Quality of Service)**: Ubuntu Server te permite configurar la calidad de servicio para priorizar ciertos tipos de tráfico de red sobre otros, lo que puede ser útil en entornos donde es importante garantizar un rendimiento óptimo para aplicaciones críticas.

En resumen, Ubuntu Server puede desempeñar varias funciones como enrutador Linux, dependiendo de tus necesidades y la configuración que elijas. Puedes utilizarlo para gestionar el tráfico de red, mejorar la seguridad, optimizar el rendimiento y realizar muchas otras tareas relacionadas con la administración de redes.

### Configuración

Para configurar ubuntu server 20 como router linux debes tener dos interfaces de red con la siguiebte configuracion


sudo nano /etc/netplan/00-installer-config.yaml

```yaml
network:
  ethernets:
    enp0s3:
      dhcp4: true
    enp0s8:
       addresses: [10.10.10.1/24]
       #gateway4: 192.168.1.1
       nameservers:
         addresses: [8.8.8.8, 8.8.4.4]
```

Luego vamos a clonar el repositorio

```
git clone https://github.com/SebastianZhunaula/Router-Linux.git

sudo chmod +x config.py

sudo python3 config.py
```