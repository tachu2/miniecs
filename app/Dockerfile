# Build stage
FROM golang:1.24-alpine AS builder

WORKDIR /app

COPY go.mod ./
# COPY go.sum ./ # Not needed yet as no dependencies

RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# Run stage
FROM scratch

COPY --from=builder /app/main /main

EXPOSE 8080

CMD ["/main"]
