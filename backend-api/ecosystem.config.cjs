module.exports = {
	apps: [
		{
			name: 'backend-api',
			cwd: __dirname,
			script: 'src/index.js',
			watch: false,
			env: {
				NODE_ENV: 'production',
				PORT: process.env.PORT || 8080,
			},
		},
	],
};


