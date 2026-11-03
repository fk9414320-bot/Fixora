FROM node:22-alpine
WORKDIR /app
COPY package.json server.js ./
COPY public ./public
ENV NODE_ENV=production TRUST_PROXY=1 DATA_DIR=/data
VOLUME /data
EXPOSE 3000
CMD ["node", "server.js"]
