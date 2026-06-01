# Quartz Scheduler Configuration - PostgreSQL

## Problem

Pentaho Server CE 9.4 por padrão vem configurado para usar **HSQLDB** (H2 database) para o Quartz Scheduler. Isso causa falha ao inicializar em ambiente Docker com PostgreSQL.

## Error Message

```
One or more system listeners failed. These are set in the systemListeners.xml.
org.pentaho.platform.api.engine.PentahoSystemException: PentahoSystem.ERROR_0014 - 
Error while trying to execute startup sequence for 
org.pentaho.platform.scheduler2.quartz.EmbeddedQuartzSystemListener
```

## Root Cause

O arquivo `tomcat/webapps/pentaho/META-INF/context.xml` contém configuração padrão:

```xml
<Resource name="jdbc/Quartz" 
          driverClassName="org.hsqldb.jdbcDriver" 
          url="jdbc:hsqldb:hsql://localhost/quartz"
          .../>
```

Mas o Quartz precisa conectar ao **PostgreSQL** neste deployment.

## Solution

Substituir `context.xml` com configuração PostgreSQL durante build.

### 1. Arquivo: `docker/overrides/context.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Context>
    <!-- Quartz Scheduler Database -->
    <Resource name="jdbc/Quartz" 
              auth="Container" 
              type="javax.sql.DataSource"
              factory="org.apache.tomcat.jdbc.pool.DataSourceFactory"
              maxActive="20" 
              minIdle="0"
              maxIdle="5" 
              initialSize="0"
              maxWait="10000"
              username="pentaho_user" 
              password="password"
              driverClassName="org.postgresql.Driver"
              url="jdbc:postgresql://repository:5432/quartz"
              testOnBorrow="true"
              validationQuery="SELECT 1"/>

    <!-- JackRabbit Content Repository Database -->
    <Resource name="jdbc/jackrabbit" 
              auth="Container" 
              type="javax.sql.DataSource"
              factory="org.apache.tomcat.jdbc.pool.DataSourceFactory"
              maxActive="20" 
              minIdle="0"
              maxIdle="5" 
              initialSize="0"
              maxWait="10000"
              username="jcr_user" 
              password="password"
              driverClassName="org.postgresql.Driver"
              url="jdbc:postgresql://repository:5432/jackrabbit"
              testOnBorrow="true"
              validationQuery="SELECT 1"/>

    <!-- Hibernate Repository Database -->
    <Resource name="jdbc/Hibernate" 
              auth="Container" 
              type="javax.sql.DataSource"
              factory="org.apache.tomcat.jdbc.pool.DataSourceFactory"
              maxActive="20" 
              minIdle="0"
              maxIdle="5" 
              initialSize="0"
              maxWait="10000"
              username="hibuser" 
              password="password"
              driverClassName="org.postgresql.Driver"
              url="jdbc:postgresql://repository:5432/hibernate"
              testOnBorrow="true"
              validationQuery="SELECT 1"/>
</Context>
```

### 2. Dockerfile - Copy Override

```dockerfile
# Copy PostgreSQL datasource configuration
COPY overrides/context.xml ${PENTAHO_HOME}/tomcat/webapps/pentaho/META-INF/context.xml
RUN chown ${PENTAHO_USER}:${PENTAHO_USER} ${PENTAHO_HOME}/tomcat/webapps/pentaho/META-INF/context.xml
```

## Configuration Details

### Datasource: `jdbc/Quartz`
- **Database:** `quartz`
- **User:** `pentaho_user`
- **Tables:** 11 Quartz scheduler tables (qrtz_*)
- **Purpose:** Job scheduling, cron triggers, etc.

### Datasource: `jdbc/jackrabbit`
- **Database:** `jackrabbit`
- **User:** `jcr_user`
- **Purpose:** JCR (Java Content Repository) - file storage, versioning

### Datasource: `jdbc/Hibernate`
- **Database:** `hibernate`
- **User:** `hibuser`
- **Purpose:** Pentaho repository metadata

## Verification

### 1. Check Quartz Properties

```bash
docker exec pentaho-server cat /opt/pentaho/pentaho-server/pentaho-solutions/system/quartz/quartz.properties | grep dataSource
```

Should show:
```properties
org.quartz.jobStore.dataSource = myDS
org.quartz.dataSource.myDS.jndiURL = Quartz
```

### 2. Check Context.xml

```bash
docker exec pentaho-server cat /opt/pentaho/pentaho-server/tomcat/webapps/pentaho/META-INF/context.xml | grep -A 5 'jdbc/Quartz'
```

Should show PostgreSQL driver and URL.

### 3. Test Database Connection

```bash
# From inside container
docker exec pentaho-server psql -h repository -U pentaho_user -d quartz -c '\dt'
```

Should list 11 Quartz tables.

## Common Mistakes

❌ **Wrong Driver Class:**
```xml
driverClassName="org.hsqldb.jdbcDriver"  <!-- WRONG -->
```

✅ **Correct Driver Class:**
```xml
driverClassName="org.postgresql.Driver"  <!-- CORRECT -->
```

❌ **Wrong URL:**
```xml
url="jdbc:hsqldb:hsql://localhost/quartz"  <!-- WRONG -->
```

✅ **Correct URL:**
```xml
url="jdbc:postgresql://repository:5432/quartz"  <!-- CORRECT -->
```

❌ **Wrong Factory (using Pentaho DecryptingDataSourceFactory):**
```xml
factory="org.pentaho.di.core.database.util.DecryptingDataSourceFactory"  <!-- WRONG for PostgreSQL -->
```

✅ **Correct Factory:**
```xml
factory="org.apache.tomcat.jdbc.pool.DataSourceFactory"  <!-- CORRECT -->
```

## Related Files

- **Quartz Config:** `pentaho-solutions/system/quartz/quartz.properties`
- **Datasource Config:** `tomcat/webapps/pentaho/META-INF/context.xml`
- **JDBC Driver:** `tomcat/lib/postgresql-42.7.4.jar`

## Testing After Fix

```bash
# Rebuild image
docker compose build --no-cache pentaho-server

# Start containers
docker compose up -d

# Wait for initialization (5-10 minutes)
docker logs pentaho-server -f

# Should see successful Quartz initialization:
# "Scheduler meta-data: Quartz Scheduler (v2.x.x) ... - JobStoreTX"
```

## References

- Pentaho Documentation: Database Configuration
- Quartz Scheduler Documentation: JDBC JobStore
- Tomcat JNDI Resources: DataSource Configuration
