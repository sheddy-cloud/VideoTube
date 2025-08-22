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

## Deploy (Cloud Run)
Deploy (example with Docker): build and push to ECR, deploy to ECS/Fargate or run on EC2/Elastic Beanstalk. Ensure instance/task role has S3 putObject permissions.
