FROM openjdk:17-jdk-slim
WORKDIR /opt/app
COPY target/wezvatech-demo-9739110917.jar app.jar
ENTRYPOINT ["java","-jar","app.jar"]