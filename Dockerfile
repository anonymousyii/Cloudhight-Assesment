# Step 1: Build the application
FROM maven:3.6.3-jdk-11 as build
WORKDIR /app

# Copy the source code
COPY src /app/src
# Copy the Maven configuration file
COPY pom.xml /app

# Package the application
RUN mvn clean package -DskipTests

# Step 2: Create the Docker container
FROM openjdk:11-jre-slim
WORKDIR /app

# Copy the packaged WAR file from the build stage to the container
COPY --from=build /app/target/spring-petclinic-*.war /app/app.war

# Expose the port the application listens on
EXPOSE 8080

# Run the application
CMD ["java", "-jar", "app.war"]
