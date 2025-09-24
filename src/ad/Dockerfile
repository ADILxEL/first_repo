FROM eclipse-temurin:21-jdk AS builder 

WORKDIR /usr/src/app/ 


COPY . .

COPY ./pb ./proto

RUN chmod +x gradlew 

RUN ./gradlew installDist -PprotoSourceDir=./proto


FROM eclipse-temurin:21-jre  
###################################################
WORKDIR /usr/src/app/

COPY --from=builder /usr/src/app/build ./build

EXPOSE 8080

ENV AD_PORT=8080
ENV Feature_flag=50053

ENTRYPOINT ["./build/install/opentelemetry-demo-ad/bin/Ad"]
