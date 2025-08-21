import { v4 as uuidv4 } from 'uuid';
import { Storage } from '@google-cloud/storage';
import Video from '../models/Video.js';
import Comment from '../models/Comment.js';

export async function listVideos(req, res, next) {
  try {
    const page = Math.max(1, parseInt(req.query.page || '1', 10));
    const pageSize = Math.max(1, Math.min(50, parseInt(req.query.pageSize || '10', 10)));
    const category = req.query.category || 'All';

    const query = category === 'All' ? {} : { category };
    const items = await Video.find(query)
      .sort({ createdAt: -1 })
      .skip((page - 1) * pageSize)
      .limit(pageSize)
      .lean();
    return res.json(items.map(toClientVideo));
  } catch (err) {
    return next(err);
  }
}

export async function getVideo(req, res, next) {
  try {
    const v = await Video.findOne({ videoId: req.params.id }).lean();
    if (!v) return res.status(404).json({ error: 'Not found' });
    return res.json(toClientVideo(v));
  } catch (err) {
    return next(err);
  }
}

export async function listComments(req, res, next) {
  try {
    const comments = await Comment.find({ videoId: req.params.id }).sort({ createdAt: -1 }).lean();
    return res.json(comments.map(c => ({
      id: String(c._id),
      username: c.username,
      avatar: c.avatar || '',
      comment: c.comment,
      likes: c.likes || 0,
      timestamp: c.createdAt,
      isLiked: false,
    })));
  } catch (err) {
    return next(err);
  }
}

export async function postComment(req, res, next) {
  try {
    const { comment } = req.body;
    if (!comment) return res.status(400).json({ error: 'comment required' });
    const created = await Comment.create({
      videoId: req.params.id,
      userId: req.user?.userId,
      username: req.user?.email || 'user',
      comment,
    });
    return res.status(201).json({ id: String(created._id) });
  } catch (err) {
    return next(err);
  }
}

export async function uploadVideo(req, res, next) {
  try {
    if (!req.file) return res.status(400).json({ error: 'file is required' });
    const bucketName = process.env.GCS_BUCKET;
    if (!bucketName) return res.status(500).json({ error: 'GCS_BUCKET not configured' });

    const storage = new Storage();
    const id = uuidv4();
    const objectName = `uploads/${id}`;

    const bucket = storage.bucket(bucketName);
    const file = bucket.file(objectName);
    await file.save(req.file.buffer, {
      resumable: false,
      contentType: req.file.mimetype || 'video/mp4',
      public: true,
      metadata: { cacheControl: 'public, max-age=31536000' },
    });
    const publicUrl = `https://storage.googleapis.com/${bucketName}/${objectName}`;

    const { title, description, visibility, tags = [], category = 'All' } = req.body;
    const video = await Video.create({
      videoId: id,
      title: title || req.file.originalname,
      description: description || '',
      visibility: visibility || 'Public',
      tags: Array.isArray(tags) ? tags : String(tags || '').split(',').map(t => t.trim()).filter(Boolean),
      category,
      channelName: req.user?.email || 'Uploader',
      channelAvatar: '',
      thumbnail: '',
      videoUrl: publicUrl,
      duration: '--',
    });
    return res.json({ videoId: video.videoId, url: publicUrl });
  } catch (err) {
    return next(err);
  }
}

function toClientVideo(v) {
  return {
    id: v.videoId,
    title: v.title,
    description: v.description,
    visibility: v.visibility,
    tags: v.tags,
    category: v.category,
    channelName: v.channelName,
    channelAvatar: v.channelAvatar,
    thumbnail: v.thumbnail,
    videoUrl: v.videoUrl,
    duration: v.duration,
    views: String(v.views || 0),
    uploadTime: v.createdAt,
  };
}


