const express = require('express');
const dotenv = require('dotenv');
const connectDB = require('./config/config');
const cors = require('cors');
const authRoutes = require('./routes/authRoutes');
const cartRoutes = require('./routes/cartRoutes');
const vegetableRoutes = require('./routes/vegetableRoutes');
const fileUpload = require('express-fileupload');
const session = require('express-session');
const paymentRoutes = require('./routes/paymentRoutes');
const path = require('path'); // Import path module

// Load environment variables
dotenv.config();

// Initialize Express app
const app = express();

// Connect to the database
connectDB();

// Middleware for JSON parsing and CORS
app.use(express.json());
app.use(cors());

// Enable file upload with temporary file storage
app.use(fileUpload({
  useTempFiles: true,
  tempFileDir: '/tmp/',
}));

// Serve static files for uploaded images
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Session configuration
app.use(
  session({
    secret: process.env.SESSION_SECRET,
    resave: false,
    saveUninitialized: true,
    cookie: { secure: false } // set to true if using HTTPS in production
  })
);

// Route configurations
app.use('/api/auth', authRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/vegetables', vegetableRoutes); 
app.use('/api/payments', paymentRoutes);

// Start the server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
