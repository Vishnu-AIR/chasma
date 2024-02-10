const mongoose = require('mongoose');
const db = require("../config/db");
const bcrypt = require("bcrypt");
const { Schema } = mongoose;

const adminSchema = new Schema({
    name:{
        type: String,
        require: true,
    },
    email:{
        type:String,
        lowercase: true,
        require:true,
        unique: true
    },
    password:{
        type:String,
        require:true,
    },
    phone:{
        type:String,
        require:true,
        unique: true
    },
    address: { type: String, required: true },
    updatedOn: { type: Date },
    createdOn: { type: Date }
})

adminSchema.pre('save', async function(next) {
   
    this.updatedOn = new Date();
    this.createdOn = new Date();

   
    if(!this.isModified("password")){
        console.log("hahaha")
        return
    }
    try{
        const salt = await bcrypt.genSalt(10);
        const hash = await bcrypt.hash(this.password,salt);
        this.password = hash;
        console.log(hash)
    }catch(err){
        throw err;
    }


    // Hash the password
    
    next();
});

adminSchema.pre('findOneAndUpdate', function(next) {


    const update = this.getUpdate();
    delete update._id;

    this.updatedOn = new Date();

    next();

    // Hash the password
    
});


adminSchema.methods.comparePassword = async function (candidatePassword) {
    try {
        console.log('----------------no password',this.password);
        // @ts-ignore
        const isMatch = await bcrypt.compare(candidatePassword, this.password);
        return isMatch;
        // if(candidatePassword == this.password){
        //     return true
        // }else{
        //     return false
        // }

    } catch (error) {
        throw error;
    }
};

const adminModel = db.model('admin',adminSchema);

module.exports = adminModel;