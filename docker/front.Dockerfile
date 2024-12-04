FROM node:20-slim

WORKDIR /frontend

COPY ../farseer/frontend .

RUN npm i

RUN npm run build

CMD ["npm", "run", "start"]
