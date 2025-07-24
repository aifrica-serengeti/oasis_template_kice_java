FROM gradle:7.5.1-jdk17 AS builder

# 컨테이너 내 작업 디렉토리 설정
WORKDIR /app

# Gradle Wrapper 및 빌드 스크립트 복사 (캐시 활용을 위해 먼저)
# 이는 Gradle Wrapper를 사용한다고 가정합니다.
COPY gradlew .
COPY gradle gradle

# build.gradle, settings.gradle, gradle.properties 등 Gradle 관련 파일 복사
COPY build.gradle settings.gradle gradle.properties ./
COPY src ./src

# 의존성 다운로드 및 빌드 실행
# 'test' 태스크는 이미 CI에서 SonarQube 분석 시 실행되거나,
# Docker 이미지 빌드 자체에서는 불필요할 수 있으므로 '-x test'로 제외.
# 필요에 따라 이 라인을 조정하여 테스트를 포함할 수 있습니다.
RUN gradle clean build -x test

# Stage 2: 런타임 스테이지
# 애플리케이션 실행에 필요한 JRE만 포함된 가벼운 이미지를 사용합니다.
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

COPY --from=builder /app/build/libs/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
