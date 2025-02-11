FROM node:20 AS build

WORKDIR /app

ENV NODE_VERSION=20.0.0

COPY package*.json /app/

COPY yarn.lock /app/

RUN yarn install

COPY . .

RUN yarn build

FROM node:20-alpine 

WORKDIR /app

COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/ ./

ENV BROWSER=none
EXPOSE 3000

CMD [ "yarn", "start" ]