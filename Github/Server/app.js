const express = require("express");
const bodyParser = require("body-parser");
const path = require("path");
const app = express();
const bcrypt = require("bcrypt");
const cron = require("node-cron");
// database connection
const con = require("./config/db");
const { log } = require("console");
const { on } = require("events");

// for json exchange
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use(bodyParser.json());

const time = new Date();
const borrow_date = `${time.getFullYear()}-${String(
  time.getMonth() + 1
).padStart(2, "0")}-${String(time.getDate()).padStart(2, "0")}`;
const tomorrow = new Date(time);
tomorrow.setDate(time.getDate() + 1);
const return_date = `${tomorrow.getFullYear()}-${String(
  tomorrow.getMonth() + 1
).padStart(2, "0")}-${String(tomorrow.getDate()).padStart(2, "0")}`;

// ------------- Login --------------
app.post("/login", function (req, res) {
  //import value form html
  const email = req.body.email;
  const raw_password = req.body.password;
  const sql = `SELECT id,role,password, borrowQuota,email,username FROM user WHERE email = ?;`;
  if (email != "" && raw_password != "") {
    con.query(sql, [email], function (err, results) {
      if (err) {
        res.status(500).send("Server error");
      } else {
        // results are array of data from database
        if (results.length === 1) {
          //import sql data
          // const username = results[(index)].password/ id/username
          //check password
          const hash = results[0].password;

          bcrypt.compare(raw_password, hash, function (err, same) {
            if (err) {
              res.status(500).send("Server Error");
            } else {
              if (same) {
                res.json({
                  id: results[0].id,
                  role: results[0].role,
                  username: results[0].username,
                });
              } else {
                res.status(401).send("Wrong password");
              }
            }
          });
        } else {
          res.status(401).send("Wrong email");
        }
      }
    });
  } else {
    if (email == "") {
      res.status(401).send("Please enter your email");
    }
    if (raw_password == "") {
      res.status(401).send("Please enter your password");
    }
  }
});

// Register Post
app.post("/register", (req, res) => {
  const email = req.body.email;
  const username = req.body.name;
  const studentID = req.body.studentID;
  const raw_password = req.body.password;
  const sqlCheck = `SELECT email FROM user WHERE email = ?;`;
  const emailRegexp =
    /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/;
  // console.log(email, username, raw_password);

  con.query(sqlCheck, [email], function (err, results) {
    if (results != "") {
      if (email === results[0].email)
        return res.status(401).send("Email has been already used!");
      if (username === results[0].username)
        return res.status(401).send("Name has been already used!");
      if (studentID === results[0].studentID)
        return res.status(401).send("studentID has been already used!");
    }
    if (err) {
      return res.status(500).send("Database server error");
    }
    if (results.length == 0) {
      if (emailRegexp.test(email) == true) {
        // Hash password
        bcrypt.hash(raw_password, 10, function (err, hash) {
          if (err) {
            res.status(500).send("Server error");
          } else {
            const sql = `INSERT INTO User ( email, username,studentID, password) VALUES (?,?,?,?)`;
            con.query(
              sql,
              [email, username, studentID, hash],
              (err, results) => {
                if (err) {
                  return res.status(500).send("Database server error");
                }
              }
            );
            // console.log("success");

            res.status(200).send("Register success!");
          }
        });
      } else {
        res.status(401).send("Wrong email format!");
      }
    }
  });
});

// ------------- GET all rooms --------------
app.get("/rooms", function (_req, res) {
  const sql =
    "SELECT rt.slotID, r.id AS roomID, r.building, r.image, DATE_FORMAT(ts.borrow_time, '%H:%i') AS borrow_time, DATE_FORMAT(ts.return_time, '%H:%i') AS return_time, rt.room_time_status FROM room_time_slots rt JOIN room r ON rt.roomID = r.id JOIN time_slots ts ON rt.time_slot_id = ts.time_slot_id ORDER BY  rt.slotID;";
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
  const sql =
    "SELECT rq.id, r.ID AS roomID, r.building,r.image, rq.request_reason, DATE_FORMAT(ts.borrow_time, '%H:%i') AS borrow_time, DATE_FORMAT(ts.return_time, '%H:%i') AS return_time, rq.request_status FROM request rq JOIN room_time_slots rts ON rq.room_slot_ID = rts.slotID JOIN user u ON rq.requestBy = u.id JOIN room r ON rts.roomID = r.id JOIN time_slots ts ON rts.time_slot_id = ts.time_slot_id WHERE rq.requestBy = 1 AND rq.request_status IS NULL AND DATE(rq.request_date) = CURDATE() ORDER BY rq.id;";
  con.query(sql, [userID], function (err, results) {
    if (err) {
      console.error(err);
      return res.status(500).send("Database server error");
    }
    if (results.length > 1) {
      return res.status(400).send("Something is wrong please contact admin!");
    }
    res.json(results);
  });
});

// ------------- GET User History --------------
app.get("/user/history", function (req, res) {
  const userID = req.query.userID;
  // console.log(userID);
  if (!userID) return res.status(400).send("User ID is required");

  const sql =
    "SELECT htr.id, r.ID AS roomID, r.building, r.image,rq.request_reason, DATE_FORMAT(request_date, '%Y-%m-%d') AS request_date,DATE_FORMAT(ts.borrow_time, '%H:%i') AS borrow_time, DATE_FORMAT(ts.return_time, '%H:%i') AS return_time, rq.request_status, htr.borrow_status FROM historys htr JOIN request rq ON rq.id = htr.requestId JOIN room_time_slots rts ON rts.slotID = rq.room_slot_ID JOIN time_slots ts ON ts.time_slot_id = rts.time_slot_id JOIN room r ON r.ID = rts.roomID JOIN user u_render ON rq.requestBy = u_render.id WHERE u_render.id = ? ORDER BY htr.id;";
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
  const { slotID, userID, reason } = req.body;
  const sql =
    "INSERT INTO `request`(`room_slot_ID`, `requestBy`, `request_reason`) VALUES (?, ?, ?)";

  if (!userID) return res.status(400).send("User ID is required");
  if (!slotID) return res.status(400).send("Room ID is required");
  if (!reason) return res.status(400).send("Reason is required");

  con.query(
    "SELECT `borrowQuota` FROM `User` WHERE `id` = ?",
    [userID],
    function (err, results) {
      if (err) {
        console.error(err);
        return res.status(500).send("Database server error");
      }

      // Ensure results is not empty
      if (!results.length) {
        return res.status(404).send("User not found");
      }

      if (results[0].borrowQuota === 1) {
        // Insert the rent request
        con.query(sql, [slotID, userID, reason], function (err) {
          if (err) {
            console.error(err);
            return res.status(500).send("Database server error");
          }

          // Update borrowQuota
          con.query(
            "UPDATE `User` SET `borrowQuota`= 0 WHERE `id` = ?",
            [userID],
            function (err) {
              if (err) {
                console.error(err);
                return res.status(500).send("Database server error");
              }
              res.send("Rent success!");
            }
          );
        });
      } else {
        return res.status(400).send("You have limited your quota!");
      }
    }
  );
});

// ------------- GET Approver Request --------------
app.get("/approver/request", function (req, res) {
  const sql =
    "SELECT rq.id, r.ID AS roomID, r.building, u.username,r.image, u.studentID ,rq.request_reason,DATE_FORMAT(ts.borrow_time, '%H:%i') AS borrow_time, DATE_FORMAT(ts.return_time, '%H:%i') AS return_time,rq.request_status FROM request rq JOIN room_time_slots rts ON rq.room_slot_ID = rts.slotID JOIN user u ON rq.requestBy = u.id JOIN room r ON rts.roomID = r.id JOIN time_slots ts ON rts.time_slot_id = ts.time_slot_id WHERE rq.request_status IS NULL AND DATE(rq.request_date) = CURDATE() ORDER BY rq.id;";
  con.query(sql, function (err, results) {
    if (err) {
      console.error(err);
      return res.status(500).send("Database server error");
    }
    res.json(results);
  });
});

// ------------- patch Approver Request --------------
app.patch("/approver/changeRequestStatus", function (req, res) {
  const requestID = req.body.requestID;
  const requestStatus = req.body.requestStatus;
  const approverID = req.body.approverID;
  if (!approverID) return res.status(400).send("approverID is required");
  if (!requestID) return res.status(400).send("requestID is required");
  if (!requestStatus) return res.status(400).send("requestStatus is required");

  const sql = "UPDATE `request` SET `request_status`= ? WHERE `id`= ?";
  con.query(sql, [requestStatus, requestID], function (err, results) {
    if (err) {
      console.error(err);
      return res.status(500).send("Database server error");
    }
    const sql_history_add =
      "INSERT INTO `historys`(`requestID` ,`approver`, borrow_status) VALUES (?, ?, ?);";
    con.query(
      sql_history_add,
      [requestID, approverID, requestStatus],
      function (err, results) {
        if (err) {
          console.error(err);
          return res.status(500).send("Database server error");
        }
      }
    );
    return res.status(200).send("Success!");
  });
});

// ------------- GET approver History --------------
app.get("/approver/history", function (req, res) {
  const userID = req.query.userID;
  // console.log(userID);
  if (!userID) return res.status(400).send("User ID is required");
  const sql =
    "SELECT htr.id, r.ID AS roomID, r.building, r.image,rq.request_reason,u_render.studentID, DATE_FORMAT(request_date, '%Y-%m-%d') AS request_date,DATE_FORMAT(ts.borrow_time, '%H:%i') AS borrow_time, DATE_FORMAT(ts.return_time, '%H:%i') AS return_time, u_render.username AS render, rq.request_status FROM historys htr JOIN request rq ON rq.id = htr.requestId JOIN room_time_slots rts ON rts.slotID = rq.room_slot_ID JOIN time_slots ts ON ts.time_slot_id = rts.time_slot_id JOIN room r ON r.ID = rts.roomID JOIN user u_render ON rq.requestBy = u_render.id JOIN user u_approver ON htr.approver = u_approver.id WHERE u_approver.id = ? ORDER BY htr.id;";
  con.query(sql, [userID], function (err, results) {
    if (err) {
      console.error(err);
      return res.status(500).send("Database server error");
    }
    res.json(results);
  });
});

// ------------- GET staff History --------------
app.get("/staff/history", function (req, res) {
  const sql =
    "SELECT htr.id, r.ID AS roomID, r.building, u_render.studentID,rq.request_reason, DATE_FORMAT(request_date, '%Y-%m-%d') AS request_date,r.image, DATE_FORMAT(ts.borrow_time, '%H:%i') AS borrow_time, DATE_FORMAT(ts.return_time, '%H:%i') AS return_time, u_render.username AS render, u_approver.username AS approver, rq.request_status, htr.borrow_status FROM historys htr JOIN request rq ON rq.id = htr.requestId JOIN room_time_slots rts ON rts.slotID = rq.room_slot_ID JOIN time_slots ts ON ts.time_slot_id = rts.time_slot_id JOIN room r ON r.ID = rts.roomID JOIN user u_render ON rq.requestBy = u_render.id JOIN user u_approver ON htr.approver = u_approver.id ORDER BY htr.id;";
  con.query(sql, function (err, results) {
    if (err) {
      console.error(err);
      return res.status(500).send("Database server error");
    }
    res.json(results);
  });
});

// --------------- PUT staff add ----------------
app.put("/staff/add", function (req, res) {
  const roomID = req.body.roomID;
  //Check if room already exists
  const sqlCheck = "SELECT `roomID` FROM `room_time_slots` WHERE roomID = ?;";
  con.query(sqlCheck, [roomID], function (err, results) {
    if (err) {
      console.error(err);
      return res.status(500).send("Database server error");
    }
    if (results.length > 1) {
      // Room already exists
      return res.status(401).send(`This room already being added!`);
    } else {
      const sqlCkeck2 = "SELECT * FROM `Room` WHERE `ID` = ?";
      con.query(sqlCkeck2, [roomID], function (err, results) {
        if (err) {
          console.error(err);
          return res.status(500).send("Database server error");
        }
        if (results.length >= 1) {
          // Room id is exist
          // Add Room
          for (let room_time_slots = 1;room_time_slots <= 4;room_time_slots++){
            const sql = "INSERT INTO `room_time_slots`(`roomID`, `time_slot_id`) VALUES (?,?);";
            con.query(sql, [roomID, room_time_slots], function (err, results) {
              if (err) {
                console.error(err);
                return res.status(500).send("Database server error");
              }
            });
          }
          return res.status(200).send("Add success!");
        } else {
          // Room id is not being founded
          return res.status(401).send(`Not found room ID!`);
        }
      });
    }
  });
});

// --------------- PATCH staff edit ----------------
app.patch("/staff/edit", function (req, res) {
  const slotID = req.body.slotID;
  const room_time_status = req.body.room_time_status;
  const sql = "UPDATE `room_time_slots` SET `room_time_status`= '?' WHERE `slotID` = ?;";
  con.query(sql, [room_time_status, slotID],function (err, results) {
    if (err) {
      console.error(err);
      return res.status(500).send("Database server error");
    }
    return res.status(200).send("Success!");
  });
});

// --------------- DELETE staff delete ----------------
app.delete("/staff/delete", function (req, res) {
const slotID = req.body.slotID;
  const sql = "DELETE FROM `room_time_slots` WHERE `slotID` = ?;";
  con.query(sql, [slotID],function (err, results) {
    if (err) {
      console.error(err);
      return res.status(500).send("Database server error");
    }
    return res.status(200).send("Success!");
  });
});

// ------------- GET Dashboard --------------
app.get("/dashboard", function (req, res) {
  const sql = `SELECT status, IFNULL(SUM(Count), 0) AS Count FROM (SELECT CASE WHEN request_status IS NULL AND DATE(request_date) = CURDATE() THEN 'Pending' END AS status, COUNT(*) AS Count FROM request GROUP BY status UNION ALL SELECT CASE WHEN room_time_status = "0" THEN 'Unavailable' WHEN room_time_status = "1" THEN 'Available' END AS status, COUNT(*) AS Count FROM room_time_slots GROUP BY room_time_status UNION ALL SELECT CASE WHEN borrow_status = "1" AND DATE(rqt.request_date) = CURDATE() THEN 'Reserved' END AS status, COUNT(*) AS Count FROM historys JOIN request rqt ON rqt.id = historys.requestID GROUP BY status UNION ALL SELECT 'Available', 0 UNION ALL SELECT 'Unavailable', 0 UNION ALL SELECT 'Pending', 0 UNION ALL SELECT 'Reserved', 0) AS combined GROUP BY status;`;
  con.query(sql, function (err, results) {
    if (err) {
      console.error(err);
      return res.status(500).send("Database server error");
    }
    res.json(results);
  });
});

//When pass 10 am set to status to 0
cron.schedule("0 10 * * *", () => {
  con.query(
    "UPDATE `room_time_slots` SET `room_time_status` = '0' WHERE `time_slot_id` = '1';",
    (error, results) => {
      if (error) {
        console.error("Error updating value:", error);
      } else {
        console.log("Slot1 set to 0 successfully.");
      }
    }
  );
});

//When pass 12 am set to status to 0
cron.schedule("0 12 * * *", () => {
  con.query(
    "UPDATE `room_time_slots` SET `room_time_status` = '0' WHERE `time_slot_id` = '2';",
    (error, results) => {
      if (error) {
        console.error("Error updating value:", error);
      } else {
        console.log("Slot2 set to 0 successfully.");
      }
    }
  );
});

//When pass 15 am set to status to 0
cron.schedule("0 15 * * *", () => {
  con.query(
    "UPDATE `room_time_slots` SET `room_time_status` = '0' WHERE `time_slot_id` = '3';",
    (error, results) => {
      if (error) {
        console.error("Error updating value:", error);
      } else {
        console.log("Slot3 set to 0 successfully.");
      }
    }
  );
});

//When pass 17 am set to status to 0
cron.schedule("0 17 * * *", () => {
  con.query(
    "UPDATE `room_time_slots` SET `room_time_status` = '0' WHERE `time_slot_id` = '4';",
    (error, results) => {
      if (error) {
        console.error("Error updating value:", error);
      } else {
        console.log("Slot4 set to 0 successfully.");
      }
    }
  );
});

//When pass 24 am set to status to 0 and borrowStatus to 1
cron.schedule("0 0 * * *", () => {
  con.query(
    "UPDATE `room_time_slots` SET `room_time_status` = '1';",
    (error, results) => {
      if (error) {
        console.error("Error updating value:", error);
      } else {
        console.log("room_time_slots set to 1 successfully.");
      }
    }
  );
  con.query("UPDATE `User` SET `borrowQuota`= 1;", (error, results) => {
    if (error) {
      console.error("Error updating value:", error);
    } else {
      console.log("borrowQuota set to 1 successfully.");
    }
  });
});

// -------------- Root ---------------
// npx nodemon app
const port = 3000;
app.listen(port, function () {
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
