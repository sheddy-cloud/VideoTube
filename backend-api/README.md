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
Create a `.env` file with:
```
PORT=8080
MONGO_URI=mongodb+srv://<user>:<pass>@cluster.mongodb.net/yourdb?retryWrites=true&w=majority
GCS_BUCKET=your-gcs-bucket-name
GCP_PROJECT_ID=your-gcp-project-id
JWT_SECRET=super-secret
GOOGLE_APPLICATION_CREDENTIALS=/workspace/service-account.json
```

Provide a Google Cloud service account with Storage permissions. For local dev, set `GOOGLE_APPLICATION_CREDENTIALS` to a JSON key path.

## Run locally
```
npm run dev
```

## Deploy (Cloud Run)
```
gcloud builds submit --tag gcr.io/PROJECT_ID/backend-api
gcloud run deploy backend-api --image gcr.io/PROJECT_ID/backend-api --platform managed --allow-unauthenticated --region REGION
```
