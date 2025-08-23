import { v4 as uuidv4 } from 'uuid';
import { S3Client, PutObjectCommand, GetObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import path from 'path';
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
    const videoFile = (req.files?.file && req.files.file[0]) || req.file;
    const thumbFile = req.files?.thumbnail && req.files.thumbnail[0];
    if (!videoFile) return res.status(400).json({ error: 'file is required' });
    const bucketName = process.env.S3_BUCKET;
    const region = process.env.AWS_REGION;
    if (!bucketName || !region) return res.status(500).json({ error: 'S3 config missing' });

    const s3 = new S3Client({ region });
    const id = uuidv4();
    const ext = path.extname(videoFile.originalname || '') || '.mp4';
    const key = `uploads/${id}${ext}`;

    await s3.send(new PutObjectCommand({
      Bucket: bucketName,
      Key: key,
      Body: videoFile.buffer,
      ContentType: videoFile.mimetype || 'video/mp4',
    }));
    const publicUrl = `https://${bucketName}.s3.${region}.amazonaws.com/${key}`;

    let thumbUrl = '';
    if (thumbFile) {
      const tExt = path.extname(thumbFile.originalname || '') || '.jpg';
      const tKey = `uploads/${id}-thumb${tExt}`;
      await s3.send(new PutObjectCommand({
        Bucket: bucketName,
        Key: tKey,
        Body: thumbFile.buffer,
        ContentType: thumbFile.mimetype || 'image/jpeg',
      }));
      thumbUrl = `https://${bucketName}.s3.${region}.amazonaws.com/${tKey}`;
    }

    const { title, description, visibility, tags = [], category = 'All' } = req.body;
    const video = await Video.create({
      videoId: id,
      title: title || videoFile.originalname,
      description: description || '',
      visibility: visibility || 'Public',
      tags: Array.isArray(tags) ? tags : String(tags || '').split(',').map(t => t.trim()).filter(Boolean),
      category,
      channelName: req.user?.email || 'Uploader',
      channelAvatar: '',
      thumbnail: thumbUrl,
      videoUrl: publicUrl,
      s3Key: key,
      duration: '--',
    });
    return res.json({ videoId: video.videoId, url: publicUrl });
  } catch (err) {
    return next(err);
  }
}

export async function getVideoPlaybackUrl(req, res, next) {
  try {
    const bucketName = process.env.S3_BUCKET;
    const region = process.env.AWS_REGION;
    if (!bucketName || !region) return res.status(500).json({ error: 'S3 config missing' });

    const v = await Video.findOne({ videoId: req.params.id }).lean();
    if (!v) return res.status(404).json({ error: 'Not found' });

    // Derive S3 object key from stored URL (fallback until s3Key is stored explicitly)
    let key = '';
    try {
      const u = new URL(v.videoUrl);
      key = u.pathname.startsWith('/') ? u.pathname.slice(1) : u.pathname;
    } catch {
      return res.status(500).json({ error: 'Invalid video URL stored' });
    }

    const s3 = new S3Client({ region });
    const command = new GetObjectCommand({ Bucket: bucketName, Key: key });
    const url = await getSignedUrl(s3, command, { expiresIn: 60 * 60 }); // 1 hour
    return res.json({ url, expiresIn: 3600 });
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


