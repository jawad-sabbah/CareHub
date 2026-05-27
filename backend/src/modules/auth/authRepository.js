import pool from '../../config/db.js';



class AuthRepository {

   //create the account of policy owner
   async registerAsInsuranceOwner(fullName,email,phone_number,date_of_birth,gender,password){
     const query='insert into users(parent_id,username,email,password,phone_number,date_of_birth,gender,role,relation_id) values($1,$2,$3,$4,$5,$6,$7,$8,$9) returning *';
     const values=[null,fullName,email,password,phone_number,date_of_birth,gender,'user',null];
     const result=await pool.query(query,values);
     return result.rows[0];
   }

   //used for login,check duplicate email 
   async getUserByEmail(email){
      const query='select * from users where email=$1';
      const values=[email];
      const result=await pool.query(query,values);
      return result.rows[0];
   }

   //user for jwt authentication,protect routes,validate user session
   async getUserById(id){
      const query='select * from users where id=$1';
      const values=[id];
      const result=await pool.query(query,values);
      return result.rows[0];
   }

   //used for update the password of user
   async updatePassword(userId, hashedPassword){
      const query='update users set password=$1 where id=$2 returning *';
      const values=[hashedPassword,userId];
      const result=await pool.query(query,values);
      return result.rows[0];
   }
}

export default new AuthRepository();