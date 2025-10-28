FROM node:20 AS build

RUN corepack enable

WORKDIR /usr/src/app

COPY package.json yarn.lock ./
COPY .yarn ./.yarn
COPY .yarnrc.yml ./

RUN yarn install --immutable

COPY . .

RUN yarn run build
RUN yarn workspaces focus --production && yarn cache clean

FROM node:20-alpine3.20 AS production

RUN corepack enable

WORKDIR /usr/src/app

COPY --from=build /usr/src/app/package.json ./package.json
COPY --from=build /usr/src/app/dist ./dist
COPY --from=build /usr/src/app/node_modules ./node_modules

EXPOSE 3000

CMD ["yarn", "run", "start:prod"]