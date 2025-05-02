FROM openjdk:21-jdk-slim-buster
WORKDIR /app
COPY target/*.jar teste.jar
CMD ["java", "-jar", "teste.jar"]