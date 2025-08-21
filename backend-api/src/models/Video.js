import mongoose from 'mongoose';

const videoSchema = new mongoose.Schema(
  {
    videoId: { type: String, required: true, unique: true, index: true },
    title: { type: String, required: true },
    description: { type: String, default: '' },
    visibility: { type: String, default: 'Public', enum: ['Public', 'Unlisted', 'Private'] },
    tags: { type: [String], default: [] },
    category: { type: String, default: 'All' },
    channelName: { type: String, default: 'Uploader' },
    channelAvatar: { type: String, default: '' },
    thumbnail: { type: String, default: '' },
    videoUrl: { type: String, required: true },
    duration: { type: String, default: '--' },
    views: { type: Number, default: 0 },
  },
  { timestamps: true }
);

export default mongoose.model('Video', videoSchema);


