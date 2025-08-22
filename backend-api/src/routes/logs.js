import { Router } from 'express';

const router = Router();

router.post('/log-error', (req, res) => {
  console.error('Client error log:', req.body);
  return res.json({ ok: true });
});

router.post('/log-inspected-widget', (req, res) => {
  console.log('Widget inspection:', req.body);
  return res.json({ ok: true });
});

export default router;


