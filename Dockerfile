# Multi-stage build: Build stage
FROM alpine as builder
RUN apk --no-cache add curl
WORKDIR /app
RUN curl -o index.html https://raw.githubusercontent.com/yourusername/yourrepository/yourbranch/index.html

# Final stage: Copy the file into Nginx
FROM nginx:alpine
COPY --from=builder /app/index.html /usr/share/nginx/html/index.html
