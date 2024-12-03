FROM node:20-slim

WORKDIR /frontend

COPY . .

RUN npm i

RUN npm run build

CMD ["npm", "run", "start"]
