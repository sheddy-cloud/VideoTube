import { Router } from 'express';
import { authRequired } from '../middlewares/auth.js';
import User from '../models/User.js';

const router = Router();

router.get('/me', authRequired, async (req, res, next) => {
  try {
    const user = await User.findById(req.user.userId).lean();
    if (!user) return res.status(404).json({ error: 'User not found' });
    return res.json({ id: String(user._id), email: user.email, name: user.name });
  } catch (err) {
    return next(err);
  }
});

router.patch('/me', authRequired, async (req, res, next) => {
  try {
    const { name } = req.body;
    const user = await User.findById(req.user.userId);
    if (!user) return res.status(404).json({ error: 'User not found' });
    if (typeof name === 'string' && name.trim().length >= 2) {
      user.name = name.trim();
    }
    await user.save();
    return res.json({ id: String(user._id), email: user.email, name: user.name });
  } catch (err) {
    return next(err);
  }
});

export default router;


