FROM node:14.15.4-alpine3.10
RUN apk --no-cache --update --available upgrade
RUN apk add --no-cache make git bash

COPY . .

RUN yarn
RUN yarn compile