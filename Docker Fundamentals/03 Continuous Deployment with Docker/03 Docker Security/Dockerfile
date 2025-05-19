# Dockerfile for a Node.js app with security best practices
FROM node:18

# Create a non-root user
RUN useradd -m appuser

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

EXPOSE 3000

CMD ["node", "app.js"]