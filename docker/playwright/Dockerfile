FROM mcr.microsoft.com/playwright:v1.60.0-noble

RUN npm install -g corepack@0.35.0 && corepack enable

WORKDIR /app

COPY frontend/package.json frontend/pnpm-lock.yaml frontend/pnpm-workspace.yaml ./

RUN pnpm install --frozen-lockfile

COPY frontend/ ./
