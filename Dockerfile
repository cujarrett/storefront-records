FROM node:24-slim@sha256:55fb5f5a527ea2c5c4a95f963e48ef90aa38c7b346054fdc8ee9957a2b55d205 AS build
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:24-slim@sha256:55fb5f5a527ea2c5c4a95f963e48ef90aa38c7b346054fdc8ee9957a2b55d205
WORKDIR /app
ENV NODE_ENV=production
ENV SCHEMA_PATH=/schema.graphql
ENV PORT=8080
COPY package.json package-lock.json* ./
# npm is only needed to install. Its bundled packages carry CVEs the app never runs.
RUN npm ci --omit=dev && rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx
COPY --from=build /app/dist ./dist
COPY schema.graphql /schema.graphql
USER node
EXPOSE 8080
CMD ["node", "dist/index.js"]
