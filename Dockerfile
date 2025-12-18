FROM golang:1.25.5-alpine AS builder

RUN apk add --no-cache git

WORKDIR /app

COPY go.mod go.sum ./

# Скачиваем зависимости
RUN go mod download

# Копируем исходный код
COPY . .

# Собираем бинарный файл
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# Финальный образ
FROM alpine:latest

# Устанавливаем зависимости времени выполнения
RUN apk --no-cache add ca-certificates

# Рабочая директория
WORKDIR /root/

# Копируем бинарный файл
COPY --from=builder /app/main .
COPY --from=builder /app/.env .

# Экспонируем порт
EXPOSE 8080

# Команда запуска
CMD ["./main"]