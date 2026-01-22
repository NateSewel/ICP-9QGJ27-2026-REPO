const app = require('./app');
const sequelize = require('./config/database');

const PORT = process.env.PORT || 3000;

const startServer = async () => {
  // Start listening immediately so health checks pass
  // Using 0.0.0.0 to ensure it's reachable outside the container
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server is running on port ${PORT} and listening on 0.0.0.0`);
  });

  let authenticated = false;
  let retries = 50; // Increased retries
  
  while (!authenticated && retries > 0) {
    try {
      await sequelize.authenticate();
      authenticated = true;
      console.log('Database connection has been established successfully.');
    } catch (error) {
      retries--;
      console.error(`Unable to connect to the database. Retries left: ${retries}`, error.message);
      if (retries === 0) {
        console.error('Max retries reached. Some features may not work.');
        // We don't exit(1) here to allow health checks to stay up, 
        // but the app will be in a degraded state.
      } else {
        // Wait for 5 seconds before retrying
        await new Promise(resolve => setTimeout(resolve, 5000));
      }
    }
  }

  if (authenticated) {
    try {
      // In production, you'd use migrations. For this week's task, we'll sync.
      await sequelize.sync();
      console.log('Database synced successfully.');
    } catch (error) {
      console.error('Error during database sync:', error);
    }
  }
};

startServer();
