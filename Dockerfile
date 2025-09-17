# Stage 1: build
FROM node:20-alpine AS builder
WORKDIR /app

# Copy the package.json and package-lock.json files
COPY package.json package-lock.json ./

# Install all dependencies, including devDependencies for building
RUN npm install

# Copy the rest of the application code
COPY . .

# Build the Next.js app
RUN npm run build

# Stage 2: production
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

# Pass environment variables for Supabase (if necessary)
ENV NEXT_PUBLIC_SUPABASE_URL=$NEXT_PUBLIC_SUPABASE_URL
ENV NEXT_PUBLIC_SUPABASE_ANON_KEY=$NEXT_PUBLIC_SUPABASE_ANON_KEY

# Copy the build artifacts from the builder stage
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/node_modules ./node_modules

# Expose the port for the frontend
EXPOSE 3000

# Command to run the production build
CMD ["npm", "start"]
