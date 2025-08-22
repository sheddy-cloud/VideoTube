module.exports = {
	apps: [
		{
			name: 'backend-api',
			script: 'src/index.js',
			node_args: '--require dotenv/config',
			watch: false,
			env: {
				NODE_ENV: 'production',
				PORT: process.env.PORT || 8080,
			},
		},
	],
};


