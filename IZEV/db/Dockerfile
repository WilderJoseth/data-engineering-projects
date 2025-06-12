FROM rapidfort/microsoft-sql-server-2019-ib:latest
WORKDIR /db

# Copy files from host to container
COPY . .

EXPOSE 1433

# Run command using interpreter Bash-specific
CMD ["/bin/bash", "run.sh"]