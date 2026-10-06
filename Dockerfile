---- 构建阶段：用 Maven 把 Spring Boot + Unidbg 打成 fat jar ----
注意：Render 免费档构建有 20 分钟超时、CPU/内存有限，unidbg 依赖较多，
若构建超时/失败，请改为本地 mvnw package 后用一个「仅 JRE」的 Dockerfile（见末尾说明）。
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /build
COPY . .
RUN chmod +x mvnw && ./mvnw -q -T4 package -DskipTests

---- 运行阶段：只留 JRE，尽量瘦身 ----
FROM eclipse-temurin:17-jre AS runtime
WORKDIR /app
COPY --from=build /build/target/unidbg-boot-server-*.jar /app/app.jar

512MB 极限调优：小堆 + 串行 GC + 关闭分层编译以省内存
若仍被 OOMKilled，说明 512MB 不够，必须换 Oracle（2C/12G）
ENV JAVA_OPTS="-Xms96m -Xmx360m -XX:+UseSerialGC -XX:+TieredCompilation -XX:TieredStopAtLevel=1 -noverify"

EXPOSE 8099

Render 会注入 PORT 环境变量，Spring Boot 必须监听它且绑定 0.0.0.0
CMD exec java.JAVAOPTS−Dserver.port=JAVAO​PTS−Dserver.port={PORT:-8099} -jar /app/app.jar
