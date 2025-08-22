# backend-api

Express API backing the Flutter app. Supports:
- List/search videos
- Fetch video details and comments
- Upload video to Google Cloud Storage
- Logging endpoints

## Setup

1) Install deps
```
npm install
```

2) Configure environment
Create a `.env` file with (see `.env.example`):
```
PORT=8080
MONGO_URI=mongodb+srv://<user>:<pass>@cluster.mongodb.net/yourdb?retryWrites=true&w=majority
AWS_REGION=us-east-1
S3_BUCKET=your-s3-bucket
JWT_SECRET=super-secret
```

Storage now uses AWS S3.

## Run locally
```
npm run dev
```

## Deploy to EC2 (Nginx + PM2)
1) Copy Nginx conf
```
sudo cp deploy/nginx/backend-api.conf /etc/nginx/sites-available/backend-api.conf
sudo ln -s /etc/nginx/sites-available/backend-api.conf /etc/nginx/sites-enabled/backend-api.conf
sudo nginx -t && sudo systemctl reload nginx
```

2) Place `.env` in `backend-api/.env` on server with PORT, MONGO_URI, AWS_REGION, S3_BUCKET, JWT_SECRET

3) Use PM2 with `ecosystem.config.js`:
```
pm2 startOrReload ecosystem.config.js --env production
pm2 save
```

4) CI/CD: set GitHub secrets `EC2_HOST`, `EC2_USER`, `EC2_SSH_KEY`, `EC2_PATH`, push to main.
