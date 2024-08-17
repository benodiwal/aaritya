FROM golang:1.22.2-alpine

RUN apk g++ && apk add make

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN make build

EXPOSE 8000
ENV PORT=8000

CMD ["make", "run"]
