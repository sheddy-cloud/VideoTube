import { Router } from 'express';

// naive in-memory dataset, will be fed by videos router
import videosRouter from './videos.js';

const router = Router();

router.get('/', (req, res) => {
  const { q = '', filter = 'All', page = 1, pageSize = 15 } = req.query;
  const query = String(q).toLowerCase();
  const p = Number(page) || 1;
  const ps = Number(pageSize) || 15;

  // Access the in-memory videos via import cache hack. In a real app use a DB.
  const videosModule = requireModuleCache('./videos.js');
  const all = videosModule?.videos || [];

  const results = all.filter(v => {
    const matches = String(v.title || '').toLowerCase().includes(query) || String(v.channelName || '').toLowerCase().includes(query);
    if (filter === 'All') return matches;
    if (filter === 'Videos') return matches; // all are videos in this demo
    if (filter === 'Channels') return false; // no channels in this demo dataset
    return false;
  }).map(v => ({ ...v, type: 'video' }));

  const start = (p - 1) * ps;
  return res.json(results.slice(start, start + ps));
});

function requireModuleCache(relPath) {
  try {
    const specifier = new URL(relPath, import.meta.url).href;
    return global.__videoModuleCache;
  } catch {
    return null;
  }
}

export default router;


