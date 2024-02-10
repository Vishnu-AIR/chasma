require("dotenv").config()
const mongoose = require('mongoose');

const db_url = process.env.DB_URI || "mongodb://localhost:27017/"
const db_name = process.env.DB_NAME || "chasma"


const connection = mongoose.createConnection(db_url+db_name)
.on('open',()=>{
    console.log("connected to db")
    
})
.on('error',(error)=>{
    console.log(error);
});

module.exports = connection;