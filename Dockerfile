FROM openjdk:11 AS BUILD_IMAGE
RUN apt update && apt install maven -y
COPY . .
RUN mvn install

FROM tomcat:latest
RUN rm -rf /usr/locat/tomcat/webapps/*
COPY --from=BUILD_IMAGE demo-cd-pipeline/target/demo-v2.war /usr/local/tomcat/webapps/deploy.war
EXPOSE 8080
CMD ["catalina.sh", "run"]