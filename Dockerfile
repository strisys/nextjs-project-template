# Stage 1: Dependencies
FROM node:20-alpine AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

# Copy package files
COPY package.json package-lock.json* ./

# Install dependencies based on the preferred package manager
RUN if [ -f package-lock.json ]; then npm ci; \
    else echo "Lockfile not found." && exit 1; \
    fi

# ------------------------------------------------------
# Stage 2: Builder
# ------------------------------------------------------
FROM node:20-alpine AS builder
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production

RUN npm run build

# ------------------------------------------------------
# Stage 3: Production Runner
# ------------------------------------------------------
FROM node:20-alpine AS runner-prod
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

RUN chown -R nextjs:nodejs /app

USER nextjs

EXPOSE 3000

ENV PORT=3000

CMD ["node", "server.js"]

# ------------------------------------------------------
# Stage 4: Development Runner
# ------------------------------------------------------
FROM node:20-slim AS runner-dev
WORKDIR /app

ENV NODE_ENV=development
ENV NEXT_TELEMETRY_DISABLED=1

RUN apt-get update && apt-get install -y \
    git \
    curl \
    bash \
    build-essential \
    inotify-tools \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --system --gid 1001 nodejs && \
    useradd --system --uid 1001 nextjs

# Copy built application
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

# Copy source files for development
COPY --from=builder /app/src ./src
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/package-lock.json ./package-lock.json
COPY --from=builder /app/next.config.ts ./next.config.ts
COPY --from=builder /app/tsconfig.json ./tsconfig.json

RUN chown -R nextjs:nodejs /app

RUN npm install

USER nextjs

EXPOSE 3000
EXPOSE 5679

RUN mkdir -p .next && \
    chown -R nextjs:nodejs .next

EXPOSE 3000
EXPOSE 5679

ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Turbopack specific settings
ENV NEXT_HMR_POLLING_INTERVAL=2000

CMD ["npm", "run", "dev"]