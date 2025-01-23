FROM maven:3.8.7 AS build
WORKDIR /app
COPY . .
RUN mvn -B clean package -Dmaven.test.skip=true
RUN ls -lh /app/target

FROM openjdk:17-slim
RUN apt-get update && apt-get install -y curl && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=build /app/target/*.jar /app/registerData.jar

EXPOSE 8088

ENTRYPOINT ["java", "-jar", "/app/registerData.jar"]