# One image for the whole app: the NestJS backend serves the API (/api), the photos (/uploads)
# and the React frontend (every other page). So the app has a single link.

# 1) Build the frontend
FROM node:22-bookworm-slim AS frontend
WORKDIR /front
COPY Crowd-Sense-Frontend/package*.json ./
RUN npm ci
COPY Crowd-Sense-Frontend/ ./
# "/" = call the API on the same address the page comes from
ENV VITE_API_URL=/
RUN npm run build

# 2) Build the backend
FROM node:22-bookworm-slim AS backend
WORKDIR /app
COPY Crowd-Sense-Backend/package*.json ./
RUN npm ci
COPY Crowd-Sense-Backend/ ./
RUN npm run build

# 3) Run it
FROM node:22-bookworm-slim
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3000
COPY Crowd-Sense-Backend/package*.json ./
RUN npm ci --omit=dev && npm cache clean --force
COPY --from=backend /app/dist ./dist
COPY --from=frontend /front/dist ./public
RUN mkdir -p /app/uploads
EXPOSE 3000
CMD ["node", "dist/main"]
