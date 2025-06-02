# Build stage
FROM node:20-alpine AS build

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application files
COPY . .

# Production stage
FROM node:20-alpine

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000

# Set working directory
WORKDIR /app

# Create a non-root user for better security
RUN addgroup -g 1001 -S nodejs \
    && adduser -S nodejs -u 1001 -G nodejs

# Copy only the necessary files from the build stage
COPY --from=build --chown=nodejs:nodejs /app/node_modules /app/node_modules
COPY --from=build --chown=nodejs:nodejs /app/index.js /app/index.js
COPY --from=build --chown=nodejs:nodejs /app/package.json /app/package.json

# Change to non-root user
USER nodejs

# Expose the port the app runs on
EXPOSE 3000

# Set healthcheck to make sure container is responsive
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/healthz || exit 1

# Command to run the application
CMD ["node", "index.js"]
