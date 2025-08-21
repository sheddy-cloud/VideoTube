import { Router } from 'express';
import multer from 'multer';
import { Storage } from '@google-cloud/storage';
import { v4 as uuidv4 } from 'uuid';
import path from 'path';
import fs from 'fs';

const router = Router();
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 1024 * 1024 * 1024 } });

// In-memory dataset for demo
const videos = [];
const commentsByVideoId = {};

router.get('/', (req, res) => {
  const { category = 'All', page = 1, pageSize = 10 } = req.query;
  const p = Number(page) || 1;
  const ps = Number(pageSize) || 10;
  const all = category === 'All' ? videos : videos.filter(v => (v.category || '').toLowerCase() === String(category).toLowerCase());
  const start = (p - 1) * ps;
  return res.json(all.slice(start, start + ps));
});

router.get('/:id', (req, res) => {
  const v = videos.find(x => String(x.id) === String(req.params.id));
  if (!v) return res.status(404).json({ error: 'Not found' });
  return res.json(v);
});

router.get('/:id/comments', (req, res) => {
  const list = commentsByVideoId[req.params.id] || [];
  return res.json(list);
});

// Upload to Google Cloud Storage
router.post('/upload', upload.single('file'), async (req, res, next) => {
  try {
    if (!req.file) return res.status(400).json({ error: 'file is required' });

    const storage = new Storage();
    const bucketName = process.env.GCS_BUCKET;
    if (!bucketName) return res.status(500).json({ error: 'GCS_BUCKET not configured' });

    const id = uuidv4();
    const ext = path.extname(req.file.originalname) || '.mp4';
    const objectName = `uploads/${id}${ext}`;

    const bucket = storage.bucket(bucketName);
    const file = bucket.file(objectName);

    await file.save(req.file.buffer, {
      resumable: false,
      contentType: req.file.mimetype || 'video/mp4',
      public: true,
      metadata: { cacheControl: 'public, max-age=31536000' },
    });

    const publicUrl = `https://storage.googleapis.com/${bucketName}/${objectName}`;

    const { title, description, visibility, tags = [], selectedThumbnailIndex = 0 } = req.body;
    const record = {
      id,
      title: title || req.file.originalname,
      description: description || '',
      visibility: visibility || 'Public',
      tags: Array.isArray(tags) ? tags : String(tags || '').split(',').map(t => t.trim()).filter(Boolean),
      duration: '--',
      views: '0',
      uploadTime: 'just now',
      channelName: 'Uploader',
      channelAvatar: '',
      thumbnail: '',
      videoUrl: publicUrl,
      category: 'All',
    };
    videos.unshift(record);
    commentsByVideoId[id] = [];

    return res.json({ videoId: id, url: publicUrl });
  } catch (err) {
    return next(err);
  }
});

export default router;


