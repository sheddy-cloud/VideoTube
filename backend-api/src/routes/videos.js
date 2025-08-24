import { Router } from 'express';
import multer from 'multer';
import { authRequired } from '../middlewares/auth.js';
import { listVideos, getVideo, listComments, postComment, uploadVideo } from '../controllers/videoController.js';

const router = Router();
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 1024 * 1024 * 1024 },
  fileFilter: (_req, file, cb) => {
    const type = file.mimetype || '';
    if (type.startsWith('video/') || type.startsWith('image/')) return cb(null, true);
    cb(new Error('Only video/image uploads allowed'));
  },
});

router.get('/', listVideos);
router.get('/:id', getVideo);
router.get('/:id/comments', listComments);
router.post('/:id/comments', authRequired, postComment);
router.post('/upload', authRequired, upload.fields([
  { name: 'file', maxCount: 1 },
  { name: 'thumbnail', maxCount: 1 },
]), uploadVideo);

export default router;


