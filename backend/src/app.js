import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import pool from './config/db.js';

import  authRoute from '../src/modules/auth/authRoute.js';
import dashboardRoute from '../src/modules/dashboard/dashboardRoute.js';
import familyRoute from '../src/modules/family/familyRoute.js';
import medicalCenterRoute from "../src/modules/medicalCenters/medicalCenterRoute.js";
import contactRoute from '../src/modules/contact/contactRoute.js';
import insuranceHistoryRoute from '../src/modules/insurance_history/insurance_history_Route.js';
import medicalRecordRoute from '../src/modules/medicalRecords/medicalRecordRoute.js';
import profileRoute from '../src/modules/profile/profileRoute.js'
import insuranceDetailsRoute from '../src/modules/insurance_details/insurance_details_Route.js'
import insuranceCoverageDetailsRoute from '../src/modules/insurance_coverage/insurance_coverage_Route.js'

dotenv.config();

const app = express();
const PORT = process.env.PORT;


app.use(cors({
  origin: (origin, callback) => {
    if (!origin || /^http:\/\/localhost:\d+$/.test(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
}));

app.use(express.json());
app.use('/api/auth',authRoute);
app.use('/api/dashboard',dashboardRoute);
app.use('/api/family',familyRoute);
app.use('/api/medical-centers',medicalCenterRoute);
app.use('/api/contact-us',contactRoute);
app.use('/api/insurance-history',insuranceHistoryRoute);
app.use('/api/medical-records',medicalRecordRoute);
app.use('/api/profile',profileRoute)
app.use('/api/insurance-details',insuranceDetailsRoute);
app.use('/api/insurance-coverage-details',insuranceCoverageDetailsRoute)

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