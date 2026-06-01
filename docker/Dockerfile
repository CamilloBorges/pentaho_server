# Pentaho Server Community Edition Docker Image  
# Base: Debian Bullseye Slim with OpenJDK 11 JRE (compatible with Pentaho 9.4)

FROM debian:bullseye-slim

# Build arguments
ARG PENTAHO_VERSION=9.4.0.0-343
ARG PENTAHO_USER=pentaho
ARG PENTAHO_UID=5000
ARG PENTAHO_GID=5000

# Labels
LABEL maintainer="Your Organization"
LABEL version="${PENTAHO_VERSION}"
LABEL description="Pentaho Server Community Edition with PostgreSQL and Java 11"

# Environment variables
ENV PENTAHO_HOME=/opt/pentaho/pentaho-server
ENV PENTAHO_VERSION=${PENTAHO_VERSION}
ENV CATALINA_HOME=${PENTAHO_HOME}/tomcat
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=${JAVA_HOME}/bin:${PENTAHO_HOME}:${PATH}

# Install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openjdk-11-jre-headless \
        wget \
        curl \
        unzip \
        netcat-traditional \
        postgresql-client \
        ca-certificates \
        tzdata \
        fontconfig \
        libfreetype6 \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create pentaho user and group
RUN groupadd -g ${PENTAHO_GID} ${PENTAHO_USER} && \
    useradd -u ${PENTAHO_UID} -g ${PENTAHO_GID} -m -s /bin/bash ${PENTAHO_USER}

# Create directories
RUN mkdir -p ${PENTAHO_HOME} && \
    chown -R ${PENTAHO_USER}:${PENTAHO_USER} /opt/pentaho

# Copy staged artifacts (Pentaho Server CE package must be placed here)
COPY stagedArtifacts/pentaho-server-ce-${PENTAHO_VERSION}.zip /tmp/

# Extract Pentaho Server
RUN cd /tmp && \
    unzip -q pentaho-server-ce-${PENTAHO_VERSION}.zip && \
    mv pentaho-server/* ${PENTAHO_HOME}/ && \
    rm -rf /tmp/pentaho-server* && \
    chown -R ${PENTAHO_USER}:${PENTAHO_USER} ${PENTAHO_HOME}

# Download and install PostgreSQL JDBC driver (latest version)
RUN wget -q https://jdbc.postgresql.org/download/postgresql-42.7.4.jar \
    -O ${PENTAHO_HOME}/tomcat/lib/postgresql-42.7.4.jar && \
    chown ${PENTAHO_USER}:${PENTAHO_USER} ${PENTAHO_HOME}/tomcat/lib/postgresql-42.7.4.jar

# Note: Java 17 is LTS and compatible with Pentaho 9.4
# No additional fixes needed

# Copy entrypoint script
COPY entrypoint/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh && \
    chown ${PENTAHO_USER}:${PENTAHO_USER} /usr/local/bin/docker-entrypoint.sh

# Switch to pentaho user
USER ${PENTAHO_USER}
WORKDIR ${PENTAHO_HOME}

# Expose ports
EXPOSE 8080 8443

# Health check
# Increased start-period to 300s (5min) for initial startup
# Using /pentaho/ root instead of /Login to avoid auth issues
HEALTHCHECK --interval=30s --timeout=10s --start-period=300s --retries=5 \
    CMD curl -f http://localhost:8080/pentaho/ || exit 1

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["run"]
