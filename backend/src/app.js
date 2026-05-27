import express from 'express';
import dotenv from 'dotenv';
import pool from './config/db.js';

import  authRoute from '../src/modules/auth/authRoute.js';



dotenv.config();

const app = express();
const PORT = process.env.PORT;


app.use(express.json());
app.use('/api/auth',authRoute);


async function start() {
    try {
        await pool.connect();
        console.log('Connected to the database');
    }
    catch (error) {
        console.error('Error connecting to the database', error);
    } 
}

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
    start();
});
