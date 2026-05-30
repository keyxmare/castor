ARG NODE_VERSION=26.2.0-alpine3.23

FROM node:${NODE_VERSION} AS base

RUN npm install -g corepack@0.35.0 && corepack enable

WORKDIR /app

FROM base AS dev

FROM base AS build

COPY frontend/ ./

RUN pnpm install --frozen-lockfile \
    && pnpm build

FROM node:${NODE_VERSION} AS prod

ENV NODE_ENV=production

WORKDIR /app

COPY --from=build /app/.output ./.output

USER node

EXPOSE 3000

CMD ["node", ".output/server/index.mjs"]
