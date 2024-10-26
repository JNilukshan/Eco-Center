const express = require('express');
const dotenv = require('dotenv');
const connectDB = require('./config/config');
const cors = require('cors');
const authRoutes = require('./routes/authRoutes');  
const cartRoutes = require('./routes/cartRoutes');
const fileUpload = require('express-fileupload')
const session = require('express-session');

dotenv.config();

const app = express();

connectDB();

app.use(express.json());
app.use(cors());

// Enable file uploads
app.use(fileUpload({
    useTempFiles: true,
    tempFileDir: '/tmp/',  
  }));

// Set up session middleware
app.use(
  session({
    secret: process.env.SESSION_SECRET, 
    resave: false,
    saveUninitialized: true,
    cookie: { secure: false } 
  })
);

app.use('/api/auth', authRoutes);  
app.use('/api/cart', cartRoutes);

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

