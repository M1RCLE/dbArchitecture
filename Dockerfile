FROM postgres:latest

RUN apt-get update && \
    apt-get install -y python3-pip && \
    apt-get install -y python3-venv && \
    apt-get install -y postgresql-plpython3-16 && \
    apt-get install -y postgresql-server-dev-16 && \
    apt-get install -y pgxnclient && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN /opt/venv/bin/pip install faker

RUN pgxn install postgresql_faker

RUN crontab -l | { cat; echo "* ${BACKUPS_TIMEOUT:?1} * * * bash /root/backuper/backup.sh"; } | crontab -