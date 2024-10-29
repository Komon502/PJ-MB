const express = require('express');
const bodyParser = require('body-parser');
const path = require("path");
const app = express();
const bcrypt = require('bcrypt');
// database connection
const con = require("./config/db");
const { log } = require("console");
const { on } = require("events");

// for json exchange
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use(bodyParser.json());

const time = new Date();
const borrow_date = `${time.getFullYear()}-${String(time.getMonth() + 1).padStart(2, '0')}-${String(time.getDate()).padStart(2, '0')}`;
const tomorrow = new Date(time);
tomorrow.setDate(time.getDate() + 1);
const return_date = `${tomorrow.getFullYear()}-${String(tomorrow.getMonth() + 1).padStart(2, '0')}-${String(tomorrow.getDate()).padStart(2, '0')}`;


// ------------- Login --------------
app.post('/login', function (req, res) {
    //import value form html
    const email = req.body.email;
    const raw_password = req.body.password;
    const sql = `SELECT id,role,password, borrowQuota,email FROM user WHERE email = ?;`;
    if (email != "" && raw_password != "") {
    con.query(sql, [email], function (err, results) {
        if (err) {
            res.status(500).send('Server error')
        }
        else {
            // results are array of data from database
            if (results.length === 1) {
                //import sql data
                // const username = results[(index)].password/ id/username
                //check password
                const hash = results[0].password;
                
                bcrypt.compare(raw_password, hash, function (err, same) {
                    if (err) {
                        res.status(500).send('Server Error');
                    }
                    else {
                        if (same) {
                            res.json({ id: results[0].id, role: results[0].role });
                        } else {
                            res.status(401).send('Wrong password')
                        }
                    }
                })
            } else {
                res.status(401).send('Wrong email');
            }
        }
    });
    }else{
        if (email == "") {
            res.status(401).send('Please enter your email')
        }
        if (raw_password == "") {
            res.status(401).send('Please enter your password')
        }
    }
});

// Register Post
app.post("/register", (req, res) => {
    const email = req.body.email;
    const raw_password = req.body.password;
    const sqlCheck = `SELECT email FROM user WHERE email = ?;`;
    const emailRegexp = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/;
    con.query(sqlCheck, [email], function (err, results) {
        if (results != "") {
            if (email === results[0].email) {
                return res.status(401).send("Email has been already used!");
            }
        }
        if (err) {
            return res.status(500).send("Database server error");
        }
        if (results.length == 0) {
            if (emailRegexp.test(email) == true) {
                 // Hash password
            bcrypt.hash(raw_password, 10, function (err, hash) {
                if (err) {
                    res.status(500).send('Server error');
                }
                else {
                    const sql = `INSERT INTO User ( email, password) VALUES (?,?)`;
                    con.query(sql, [email, hash], (err, results) => {
                        if (err) {
                            return res.status(500).send("Database server error");
                        }
                    }
                    );
                    console.log("success");
                    
                    res.status(200).send("Register success!");
                }
            })
            }else{
                res.status(401).send('Wrong email format!')
            }
        }
    });
});

// ------------- GET all rooms --------------
app.get("/rooms", function (_req, res) {
    const sql = "SELECT rt.slotID, r.id AS roomID, r.building, r.image, ts.borrow_time, ts.return_time, rt.room_time_status FROM room_time_slots rt JOIN room r ON rt.roomID = r.id JOIN time_slots ts ON rt.time_slot_id = ts.time_slot_id;";
    con.query(sql, function (err, results) {
        if (err) {
            console.error(err);
            return res.status(500).send("Database server error");
        }
        res.json(results);
    });
});

// ------------- GET User Request --------------
app.get("/user/request", function (req, res) {
    const userID = req.query.userID; 
    if (!userID) {
        return res.status(400).send("User ID is required");
    }
    
    const sql = "SELECT rq.id, r.ID AS roomID, r.building, r.image, rq.request_reason, ts.borrow_time, ts.return_time FROM request rq JOIN room_time_slots rts ON rq.room_slot_ID = rts.slotID JOIN user u ON rq.requestBy = u.id JOIN room r ON rts.roomID = r.id JOIN time_slots ts ON rts.time_slot_id = ts.time_slot_id WHERE u.id = ?;";
    con.query(sql, [userID], function (err, results) {
        if (err) {
            console.error(err);
            return res.status(500).send("Database server error");
        }
        res.json(results);
    });
});

// ------------- GET User History --------------
app.get("/user/history", function (req, res) {
    const userID = req.query.userID
    console.log(userID);
    ; 
    if (!userID) {
        return res.status(400).send("User ID is required");
    }
    const sql = "SELECT htr.id, r.ID AS roomID, r.building, rq.request_reason, ts.borrow_time, ts.return_time, rq.request_status, htr.borrow_status FROM historys htr JOIN request rq ON rq.id = htr.requestId JOIN room_time_slots rts ON rts.slotID = rq.room_slot_ID JOIN time_slots ts ON ts.time_slot_id = rts.time_slot_id JOIN room r ON r.ID = rts.roomID JOIN user u_render ON rq.requestBy = u_render.id WHERE u_render.id = ?;";
    con.query(sql, [userID], function (err, results) {
        if (err) {
            console.error(err);
            return res.status(500).send("Database server error");
        }
        res.json(results);
    });
});

// ------------- POST user rentRoom --------------
app.post("/user/rentRoom", function (req, res) {
    const slotID = req.body.slotID
    const userID = req.body.userID
    const reason = req.body.reason
    
    if (!userID) {   
        return res.status(400).send("User ID is required");
    }
    if (!slotID) {   
        return res.status(400).send("Room ID is required");
    }
    if (!reason) {   
        return res.status(400).send("Reason is required");
    }
    const sql = "INSERT INTO `request`(`room_slot_ID`, `requestBy`,`request_reason`) VALUES (?, ?, ?)";
    con.query(sql, [slotID,userID,reason], function (err, results) {
        if (err) {
            console.error(err);
            return res.status(500).send("Database server error");
        }
        res.send("Rent success!");
    });
});

// ------------- GET All History --------------
app.get("/staff/history", function (req, res) {
    const userID = req.query.userID
    ; 
    if (!userID) {
        return res.status(400).send("User ID is required");
    }
    
    const sql = "SELECT h.id AS id, r.building AS building, u_rqtBy.email AS requestBy, h.borrow_date, h.return_date, u_approver.email AS Approver, u_lender.email AS Lender, h.approveStatus, h.borrowStatus AS borrowStatus FROM history h JOIN room r ON h.roomID = r.ID JOIN user u_approver ON h.approver = u_approver.ID LEFT JOIN user u_lender ON h.Lender = u_lender.ID JOIN user u_rqtBy ON h.requestBy = u_rqtBy.ID JOIN user u ON h.requestBy = u.ID";
    con.query(sql, [userID], function (err, results) {
        if (err) {
            console.error(err);
            return res.status(500).send("Database server error");
        }
        res.json(results);
    });
});


// -------------- Root ---------------
// npx nodemon app
const port = 3000;
app.listen(port,function () {
    console.log("server is ready at " + port);
});

app.get("/movies", function (_req, res) {
    const sql = "SELECT * FROM movies";
    con.query(sql, function (err, results) {
        if (err) {
            console.error(err);
            return res.status(500).send("Database server error");
        }
        res.json(results);
    });
});
