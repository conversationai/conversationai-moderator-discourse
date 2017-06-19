// Activate Google Cloud Trace and Debug when in production
if (process.env.NODE_ENV === 'production') {
  require('@google/cloud-trace').start();
  require('@google/cloud-debug').start();
}

const { makeServer } = require('@osmod/backend-core');
const { mountWebFrontend } = require('@osmod/frontend-web');
const { mountAPI } = require('@osmod/backend-api');

/**
 * HTTP setup
 */

const {
  app,
  start,
} = makeServer();

// Required for GAE
app.disable('etag');
app.set('trust proxy', true);

// Start the Web frontend
app.use('/', mountWebFrontend());

// Start up the api
app.use('/api', mountAPI());

// Our application will need to respond to health checks when running on
// Compute Engine with Managed Instance Groups.
app.get('/_ah/health', (req, res) => {
  res.status(200).send('ok');
});

start(8080);
