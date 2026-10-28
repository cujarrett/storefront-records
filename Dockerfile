FROM node:26-slim@sha256:36793bcbb160a6a16cede1e62b93f84e26b78a972a8a4c0b879c1c12f22761ec AS build
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci
COPY . .
RUN npm run build
# The runtime image has no npm, so dev dependencies are dropped here.
RUN npm prune --omit=dev

# Keep this Node major equal to the build stage. Renovate bumps only the build stage.
FROM gcr.io/distroless/nodejs26-debian13:nonroot@sha256:96455baef11b178fc135b32206e3922c515dbed2400676c94f907f8f84e6abf6
WORKDIR /app
ENV NODE_ENV=production
ENV SCHEMA_PATH=/schema.graphql
ENV PORT=8080
COPY --from=build /app/package.json ./
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY schema.graphql /schema.graphql
EXPOSE 8080
CMD ["dist/index.js"]
