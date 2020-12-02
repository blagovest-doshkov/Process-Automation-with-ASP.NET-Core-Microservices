# Base image
FROM node:12.2.0 as build

# Working directory
WORKDIR /app

# Add something to $PATH
ENV PATH /app/node_modules/.bin:$PATH

# Install app dependencies
COPY package.json /app/package.json
RUN npm install
RUN npm install -g @angular/cli@10.1.2

# Add app
COPY . /app

# Arguments and build command
ARG configuration=production
RUN ng build --output-path=dist --configuration=$configuration




# Base image
FROM nginx:1.16.0-alpine

# Remove default Nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy Nginx configuration
COPY ./nginx.conf /etc/nginx/nginx.conf

# Copy app/dist from "Build" img to /usr/share/nginx/html
COPY --from=build /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Run nginx
CMD ["nginx", "-g", "daemon off;"]