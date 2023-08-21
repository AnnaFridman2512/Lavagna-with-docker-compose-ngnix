# Start from the maven image as instructed
FROM maven:3.8-jdk-8 as builder

# Copy current directory (which should contain the Lavagna source code) into the container
COPY . /app

# Switch to the app directory
WORKDIR /app

# Build the Lavagna project using Maven
RUN mvn clean install

# Now, for the final stage, we will use the lightweight Java 8 runtime, as in the demo Dockerfile
FROM openjdk:8-jre-alpine

# Expose the port 8080 for Lavagna
EXPOSE 8080

# Set the environment variables just like the demo Dockerfile
ENV DB_DIALECT HSQLDB
ENV DB_URL jdbc:hsqldb:file:lavagna
ENV DB_USER sa
ENV DB_PASS ""
ENV SPRING_PROFILE dev

# Copy certificates (important if you want to make HTTPS connections)
RUN apk update && apk add ca-certificates && update-ca-certificates && apk add openssl

# Copy the built .war file from the builder stage
COPY --from=builder /app/target/lavagna-jetty-console.war /target/lavagna-jetty-console.war

# Add the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the entry point for the Docker container
ENTRYPOINT ["/entrypoint.sh"]
