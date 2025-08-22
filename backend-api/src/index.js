import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import dotenv from 'dotenv';
import { connectDb } from './config/db.js';
import authRouter from './routes/auth.js';

import videosRouter from './routes/videos.js';
import searchRouter from './routes/search.js';
import logsRouter from './routes/logs.js';

dotenv.config();

const app = express();
const port = process.env.PORT || 8080;

app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(morgan('dev'));

app.get('/', (_req, res) => res.json({ status: 'ok', service: 'backend-api' }));

app.use('/auth', authRouter);
app.use('/videos', videosRouter);
app.use('/search', searchRouter);
app.use('/', logsRouter); // /log-error, /log-inspected-widget

app.use((err, _req, res, _next) => {
	console.error('Unhandled error:', err);
	const status = err.status || 500;
	const message = err.message || 'Internal Server Error';
	res.status(status).json({ error: message });
});

connectDb()
	.then(() => {
		app.listen(port, () => {
			console.log(`API listening on :${port}`);
		});
	})
	.catch((err) => {
		console.error('Failed to connect DB', err);
		process.exit(1);
	});


