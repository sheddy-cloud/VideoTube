import { Router } from 'express';
import multer from 'multer';
import { authRequired } from '../middlewares/auth.js';
import { listVideos, getVideo, listComments, postComment, uploadVideo } from '../controllers/videoController.js';

const router = Router();
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 1024 * 1024 * 1024 },
  fileFilter: (_req, file, cb) => {
    if ((file.mimetype || '').startsWith('video/')) return cb(null, true);
    cb(new Error('Only video uploads allowed'));
  },
});

router.get('/', listVideos);
router.get('/:id', getVideo);
router.get('/:id/comments', listComments);
router.post('/:id/comments', authRequired, postComment);
router.post('/upload', authRequired, upload.single('file'), uploadVideo);

export default router;


