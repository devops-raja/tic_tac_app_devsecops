# --- Stage 1: Build Stage ---
# Use an official Node.js runtime as the parent image
FROM node:18-alpine AS build

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json to leverage Docker cache
COPY package*.json ./

# Install project dependencies
RUN npm install

# Copy the rest of the application source code
COPY . .

# Run the build script to generate the static files
RUN npm run build

# --- Stage 2: Final Stage ---
# Use a lightweight Nginx image to serve the application
FROM nginx:alpine

# Remove the default Nginx index file
RUN rm -rf /usr/share/nginx/html/*

# Copy the build artifacts from the build stage to the Nginx html directory
#for this app build artifacts are stored in /dist
COPY --from=build /app/dist /usr/share/nginx/html

# Copy a custom Nginx configuration file to handle SPA routing
# (See the explanation below to create this file)
#COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80 to the outside world
EXPOSE 80

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]