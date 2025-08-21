import { Router } from 'express';
import Video from '../models/Video.js';

const router = Router();

router.get('/', async (req, res, next) => {
  try {
    const { q = '', filter = 'All', page = 1, pageSize = 15 } = req.query;
    const query = String(q).toLowerCase();
    const p = Number(page) || 1;
    const ps = Number(pageSize) || 15;

    const mongoQuery = {
      $or: [
        { title: { $regex: query, $options: 'i' } },
        { channelName: { $regex: query, $options: 'i' } },
      ],
    };

    const results = await Video.find(mongoQuery)
      .sort({ createdAt: -1 })
      .skip((p - 1) * ps)
      .limit(ps)
      .lean();

    return res.json(results.map(v => ({ ...toClientVideo(v), type: 'video' })));
  } catch (err) {
    return next(err);
  }
});

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

export default router;


