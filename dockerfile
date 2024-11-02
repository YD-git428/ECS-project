FROM node:alpine3.20

WORKDIR /app

COPY package*.json /app/

COPY yarn.lock /app/

RUN yarn install

COPY public/index.html /app/public/

RUN yarn global add ts-node

COPY . .

EXPOSE 3000

CMD [ "yarn", "start" ]