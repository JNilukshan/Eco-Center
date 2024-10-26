const express = require('express');
const dotenv = require('dotenv');
const connectDB = require('./config/config');
const cors = require('cors');
const authRoutes = require('./routes/authRoutes');
const cartRoutes = require('./routes/cartRoutes');
const vegetableRoutes = require('./routes/vegetableRoutes');
const fileUpload = require('express-fileupload');
const session = require('express-session');

dotenv.config();

const app = express();

connectDB();

app.use(express.json());
app.use(cors());

app.use(fileUpload({
    useTempFiles: true,
    tempFileDir: '/tmp/',
}));

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
app.use('/api/vegetables', vegetableRoutes); 

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));